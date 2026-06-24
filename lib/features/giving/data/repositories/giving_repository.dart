import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

final givingRepositoryProvider = Provider<GivingRepository>((ref) {
  return SupabaseGivingRepository(supabase.Supabase.instance.client);
});

class DonationModel {
  const DonationModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.fund,
    required this.paymentMethod,
    required this.status,
    required this.isRecurring,
    required this.createdAt,
    this.receiptNumber,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      fund: json['fund'] as String,
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String,
      isRecurring: json['is_recurring'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      receiptNumber: json['receipt_number'] as String?,
    );
  }

  final String id;
  final double amount;
  final String currency;
  final String fund;
  final String paymentMethod;
  final String status;
  final bool isRecurring;
  final DateTime createdAt;
  final String? receiptNumber;
}

abstract class GivingRepository {
  /// Fetches the authenticated user's donation history.
  Future<Either<String, List<DonationModel>>> getDonationHistory();

  /// Gets the total amount given by the user in the current year.
  Future<Either<String, double>> getAnnualSummary();

  /// Logs a pending transaction before hitting the payment gateway.
  Future<Either<String, String>> initializeDonation({
    required double amount,
    required String fund,
    required String paymentMethod,
    required bool isRecurring,
    required bool feeCovered,
  });

  /// Streams real-time updates for a specific donation (useful for waiting on mobile money webhooks).
  Stream<DonationModel> watchDonation(String donationId);
}

class SupabaseGivingRepository implements GivingRepository {
  SupabaseGivingRepository(this._client);
  final supabase.SupabaseClient _client;

  @override
  Future<Either<String, List<DonationModel>>> getDonationHistory() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('User not authenticated.');

      final response = await _client
          .from('donations')
          .select()
          .eq('donor_id', user.id)
          .order('created_at', ascending: false);

      final list = (response as List)
          .map((e) => DonationModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return right(list);
    } catch (e) {
      return left('Failed to load history: $e');
    }
  }

  @override
  Future<Either<String, double>> getAnnualSummary() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return right(0);

      final currentYear = DateTime.now().year;
      final yearStart = '$currentYear-01-01T00:00:00.000Z';
      final yearEnd = '$currentYear-12-31T23:59:59.999Z';

      // Calculate directly from donations table — donor_annual_summary view may not exist yet
      final response = await _client
          .from('donations')
          .select('amount')
          .eq('donor_id', user.id)
          .eq('status', 'completed')
          .gte('created_at', yearStart)
          .lte('created_at', yearEnd);

      final rows = response as List<dynamic>;
      if (rows.isEmpty) return right(0);

      final total = rows.fold<double>(
        0,
        (sum, dynamic row) =>
            sum + ((row as Map<String, dynamic>)['amount'] as num? ?? 0).toDouble(),
      );

      return right(total);
    } catch (e) {
      // Gracefully return 0 if donations table doesn't exist yet either
      return right(0);
    }
  }

  @override
  Future<Either<String, String>> initializeDonation({
    required double amount,
    required String fund,
    required String paymentMethod,
    required bool isRecurring,
    required bool feeCovered,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('Authentication required to give.');

      final gateway = paymentMethod == 'card' ? 'paystack' : 'flutterwave';

      final response = await _client.functions.invoke(
        'initialize-payment',
        body: {
          'amount': amount,
          'fund': fund,
          'paymentMethod': paymentMethod,
          'isRecurring': isRecurring,
          'feeCovered': feeCovered,
          'gateway': gateway,
          'email': user.email ?? 'guest@kingdomheir.org',
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null || data['checkoutUrl'] == null) {
        return left('Invalid response from payment gateway');
      }

      // Return checkoutUrl and donationId combined by a pipe or just the URL.
      // But we need to watch the donation ID.
      // We will return a JSON string so the provider can parse both.
      return right(
          '{"id": "${data['donationId']}", "url": "${data['checkoutUrl']}"}',);
    } catch (e) {
      return left('Failed to initialize transaction: $e');
    }
  }

  @override
  Stream<DonationModel> watchDonation(String donationId) {
    return _client
        .from('donations')
        .stream(primaryKey: ['id'])
        .eq('id', donationId)
        .map((events) => DonationModel.fromJson(events.first));
  }
}
