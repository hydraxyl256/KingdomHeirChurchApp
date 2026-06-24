import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/analytics/analytics_service.dart';
import 'package:kingdom_heir/features/giving/data/repositories/giving_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Giving Data Providers
// ─────────────────────────────────────────────────────────────────────────────

final givingHistoryProvider =
    FutureProvider.autoDispose<List<DonationModel>>((ref) async {
  final repo = ref.watch(givingRepositoryProvider);
  final result = await repo.getDonationHistory();
  return result.fold((err) => throw Exception(err), (data) => data);
});

final annualSummaryProvider = FutureProvider.autoDispose<double>((ref) async {
  final repo = ref.watch(givingRepositoryProvider);
  final result = await repo.getAnnualSummary();
  return result.fold((err) => throw Exception(err), (data) => data);
});

// ─────────────────────────────────────────────────────────────────────────────
// Payment Processing State
// ─────────────────────────────────────────────────────────────────────────────

enum PaymentProcessingState {
  idle,
  initializing,
  redirecting, // New state to launch webview/browser
  waitingForAuth, // Pushed USSD to user's phone, waiting for PIN input via Paystack
  verifying, // Webhook received, checking final status
  success, // Payment successful
  error, // Payment failed or cancelled
}

class PaymentState {
  const PaymentState({
    this.status = PaymentProcessingState.idle,
    this.errorMessage,
    this.receiptNumber,
    this.checkoutUrl,
  });

  final PaymentProcessingState status;
  final String? errorMessage;
  final String? receiptNumber;
  final String? checkoutUrl;

  PaymentState copyWith({
    PaymentProcessingState? status,
    String? errorMessage,
    String? receiptNumber,
    String? checkoutUrl,
  }) {
    return PaymentState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
    );
  }
}

final paymentProcessingProvider =
    StateNotifierProvider.autoDispose<PaymentProcessingNotifier, PaymentState>(
        (ref) {
  return PaymentProcessingNotifier(ref.watch(givingRepositoryProvider), ref);
});

class PaymentProcessingNotifier extends StateNotifier<PaymentState> {
  PaymentProcessingNotifier(this._repo, this._ref)
      : super(const PaymentState());

  final GivingRepository _repo;
  final Ref _ref;
  StreamSubscription<DonationModel>? _donationSubscription;

  @override
  void dispose() {
    _donationSubscription?.cancel();
    super.dispose();
  }

  Future<void> initiateMobileMoneyPayment({
    required double amount,
    required String fund,
    required String network, // 'momo_mtn', 'momo_airtel', or 'card'
    required bool isRecurring,
    required bool feeCovered,
  }) async {
    state = state.copyWith(status: PaymentProcessingState.initializing);

    unawaited(
      _ref.read(analyticsServiceProvider).logDonationStarted(
            amount: amount,
            fund: fund,
            paymentMethod: network,
          ),
    );

    // 1. Log pending transaction in our database via Edge Function
    final initResult = await _repo.initializeDonation(
      amount: amount,
      fund: fund,
      paymentMethod: network,
      isRecurring: isRecurring,
      feeCovered: feeCovered,
    );

    await initResult.fold(
      (err) async => state = state.copyWith(
        status: PaymentProcessingState.error,
        errorMessage: err,
      ),
      (jsonString) async {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        final donationId = data['id'] as String;
        final checkoutUrl = data['url'] as String;

        state = state.copyWith(
          status: PaymentProcessingState.redirecting,
          checkoutUrl: checkoutUrl,
        );

        // Subscribe to the Supabase row to wait for the webhook to update it.
        unawaited(_donationSubscription?.cancel());
        _donationSubscription =
            _repo.watchDonation(donationId).listen((donation) {
          if (donation.status == 'completed') {
            _ref.read(analyticsServiceProvider).logDonationCompleted(
                  amount: amount,
                  fund: fund,
                  paymentMethod: network,
                );
            state = state.copyWith(
              status: PaymentProcessingState.success,
              receiptNumber: donation.receiptNumber,
            );
            _donationSubscription?.cancel();
          } else if (donation.status == 'failed' ||
              donation.status == 'cancelled') {
            state = state.copyWith(
              status: PaymentProcessingState.error,
              errorMessage: 'Transaction ${donation.status}. Please try again.',
            );
            _donationSubscription?.cancel();
          }
        });
      },
    );
  }
}
