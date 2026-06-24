import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/features/giving/presentation/providers/giving_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutOrderSummaryScreen extends ConsumerStatefulWidget {
  const CheckoutOrderSummaryScreen({super.key});

  @override
  ConsumerState<CheckoutOrderSummaryScreen> createState() =>
      _CheckoutOrderSummaryScreenState();
}

class _CheckoutOrderSummaryScreenState
    extends ConsumerState<CheckoutOrderSummaryScreen> {
  final _amountController = TextEditingController(text: '200.00');
  String _selectedType = 'Tithe';
  String _selectedNetwork = 'momo_mtn';
  bool _isRecurring = false;
  bool _feeCovered = false;

  final _types = ['Tithe', 'Offering', 'Missions', 'Building Fund', 'Other'];
  final _networks = [
    {'id': 'momo_mtn', 'name': 'MTN Mobile Money'},
    {'id': 'momo_airtel', 'name': 'AirtelTigo Money'},
    {'id': 'card', 'name': 'Credit / Debit Card'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _processPayment() {
    final amt = double.tryParse(_amountController.text) ?? 0.0;
    if (amt <= 0) return;

    ref.read(paymentProcessingProvider.notifier).initiateMobileMoneyPayment(
          amount: amt,
          fund: _selectedType,
          network: _selectedNetwork,
          isRecurring: _isRecurring,
          feeCovered: _feeCovered,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paymentState = ref.watch(paymentProcessingProvider);
    final currency = ref.watch(currencyProvider);

    // Listen for success or error to show dialogs
    ref.listen<PaymentState>(paymentProcessingProvider, (previous, next) {
      if (next.status == PaymentProcessingState.success &&
          previous?.status != PaymentProcessingState.success) {
        _showSuccessDialog(next.receiptNumber ?? 'Unknown');
      } else if (next.status == PaymentProcessingState.error &&
          previous?.status != PaymentProcessingState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Transaction failed'),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next.status == PaymentProcessingState.redirecting &&
          previous?.status != PaymentProcessingState.redirecting) {
        if (next.checkoutUrl != null) {
          launchUrl(Uri.parse(next.checkoutUrl!),
              mode: LaunchMode.inAppBrowserView,);
        }
      }
    });

    final amt = double.tryParse(_amountController.text) ?? 0.0;
    final fee = _feeCovered ? (amt * 0.015) : 0.0; // 1.5% estimate
    final total = amt + fee;

    final isProcessing = paymentState.status != PaymentProcessingState.idle &&
        paymentState.status != PaymentProcessingState.error &&
        paymentState.status != PaymentProcessingState.success;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount
            Text('Amount', style: theme.textTheme.titleMedium)
                .animate()
                .fadeIn(),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                prefixText: '$currency ',
                prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: AppSpacing.xl),

            // Quick amounts
            Wrap(
              spacing: AppSpacing.sm,
              children: ['50', '100', '200', '500'].map((v) {
                return ActionChip(
                  label: Text('$currency $v'),
                  onPressed: () => setState(() => _amountController.text = v),
                  backgroundColor: _amountController.text == v
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : null,
                );
              }).toList(),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: AppSpacing.xl),

            // Type
            Text('Giving Category', style: theme.textTheme.titleMedium)
                .animate()
                .fadeIn(delay: 200.ms),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              items: _types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: AppSpacing.xl),

            // Payment Method
            Text('Payment Method', style: theme.textTheme.titleMedium)
                .animate()
                .fadeIn(delay: 275.ms),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedNetwork,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              items: _networks
                  .map(
                    (n) => DropdownMenuItem(
                      value: n['id'],
                      child: Text(n['name']!),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedNetwork = v!),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: AppSpacing.xl),

            // Recurring toggle
            Card(
              child: SwitchListTile(
                title: const Text('Set as Recurring Gift'),
                subtitle: const Text('Automatically give every month'),
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v),
                activeThumbColor: AppColors.primary,
              ),
            ).animate().fadeIn(delay: 325.ms),

            const SizedBox(height: AppSpacing.sm),

            // Fee cover toggle
            Card(
              child: SwitchListTile(
                title: const Text('Cover Transaction Fee'),
                subtitle: const Text(
                    'Add 1.5% so 100% of your gift goes to the church',),
                value: _feeCovered,
                onChanged: (v) => setState(() => _feeCovered = v),
                activeThumbColor: AppColors.primary,
              ),
            ).animate().fadeIn(delay: 335.ms),

            const SizedBox(height: AppSpacing.xl),

            // Order summary
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                      label: 'Amount',
                      value: '$currency ${amt.toStringAsFixed(2)}',),
                  if (_feeCovered)
                    _SummaryRow(
                        label: 'Processing Fee',
                        value: '$currency ${fee.toStringAsFixed(2)}',),
                  _SummaryRow(label: 'Category', value: _selectedType),
                  _SummaryRow(
                      label: 'Type',
                      value: _isRecurring ? 'Recurring (Monthly)' : 'One-time',),
                  const Divider(),
                  _SummaryRow(
                    label: 'Total',
                    value: '$currency ${total.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 350.ms),

            const SizedBox(height: AppSpacing.xl),

            // Loading state feedback
            if (isProcessing) ...[
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: AppColors.gold),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _getProcessingMessage(paymentState.status),
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: AppColors.primary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(),
              const SizedBox(height: AppSpacing.lg),
            ] else
              AppButton(
                label: 'Confirm & Give',
                onPressed: _processPayment,
                icon: Icons.lock_rounded,
              ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: AppSpacing.md),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded,
                      size: 12, color: AppColors.navyLight,),
                  const SizedBox(width: 4),
                  Text(
                    'Secured by Paystack · PCI DSS Compliant',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 450.ms),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  String _getProcessingMessage(PaymentProcessingState state) {
    switch (state) {
      case PaymentProcessingState.initializing:
        return 'Connecting to payment gateway securely...';
      case PaymentProcessingState.redirecting:
      case PaymentProcessingState.waitingForAuth:
        return 'Please complete the payment in the browser/prompt...';
      case PaymentProcessingState.verifying:
        return 'Verifying transaction status...';
      // ignore: no_default_cases
      default:
        return 'Processing...';
    }
  }

  void _showSuccessDialog(String receiptNumber) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded,
            color: AppColors.success, size: 48,),
        title: const Text('Thank You!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your generous giving has been received successfully.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                'Receipt No: $receiptNumber',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontFamily: 'monospace',),
              ),
            ),
          ],
        ),
        actions: [
          AppButton(
            label: 'Done',
            onPressed: () {
              Navigator.pop(context); // close dialog
              context.pop(); // go back to hub
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });
  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}
