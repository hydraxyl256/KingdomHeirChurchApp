import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/core/widgets/app_text_field.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _resetComplete = false;

  // Password strength state
  double _strength = 0;
  String _strengthLabel = '';
  Color _strengthColor = AppColors.error;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkStrength);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _checkStrength() {
    final p = _passwordController.text;
    double strength = 0;
    if (p.length >= 8) strength += 0.25;
    if (p.contains(RegExp('[A-Z]'))) strength += 0.25;
    if (p.contains(RegExp('[0-9]'))) strength += 0.25;
    if (p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    setState(() {
      _strength = strength;
      if (strength <= 0.25) {
        _strengthLabel = 'Weak';
        _strengthColor = AppColors.error;
      } else if (strength <= 0.5) {
        _strengthLabel = 'Fair';
        _strengthColor = AppColors.warning;
      } else if (strength <= 0.75) {
        _strengthLabel = 'Good';
        _strengthColor = const Color(0xFF3B82F6);
      } else {
        _strengthLabel = 'Strong';
        _strengthColor = AppColors.success;
      }
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    await ref
        .read(authNotifierProvider.notifier)
        .updatePassword(_passwordController.text);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _resetComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: context.pop,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: _resetComplete
              ? _SuccessView()
              : _FormView(
                  formKey: _formKey,
                  passwordController: _passwordController,
                  confirmController: _confirmController,
                  isLoading: _isLoading,
                  strength: _strength,
                  strengthLabel: _strengthLabel,
                  strengthColor: _strengthColor,
                  onSubmit: _submit,
                ),
        ),
      ),
    );
  }
}

// ─── Form View ────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  const _FormView({
    required this.formKey,
    required this.passwordController,
    required this.confirmController,
    required this.isLoading,
    required this.strength,
    required this.strengthLabel,
    required this.strengthColor,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool isLoading;
  final double strength;
  final String strengthLabel;
  final Color strengthColor;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldDark, AppColors.gold],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_open_rounded,
                  color: AppColors.ink,
                  size: 48,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            ),

            const SizedBox(height: AppSpacing.xxl),

            Text(
              'Create New Password',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: AppSpacing.xs),

            Text(
              'Your new password must be different from your previous one.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                height: 1.6,
              ),
            ).animate().fadeIn(delay: 180.ms),

            const SizedBox(height: AppSpacing.xxl),

            // New password
            AppTextField(
              controller: passwordController,
              label: 'New Password',
              hint: 'Minimum 8 characters',
              prefixIcon: Icons.lock_outline_rounded,
              isPassword: true,
              autofillHints: const [AutofillHints.newPassword],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8) return 'Minimum 8 characters';
                return null;
              },
            ).animate().fadeIn(delay: 260.ms),

            // Strength meter
            if (passwordController.text.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                      child: LinearProgressIndicator(
                        value: strength,
                        backgroundColor:
                            theme.colorScheme.onSurface.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(strengthColor),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    strengthLabel,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: strengthColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            // Password requirements
            _RequirementsCard(password: passwordController.text),

            const SizedBox(height: AppSpacing.md),

            // Confirm password
            AppTextField(
              controller: confirmController,
              label: 'Confirm Password',
              hint: 'Re-enter your new password',
              prefixIcon: Icons.lock_outline_rounded,
              isPassword: true,
              autofillHints: const [AutofillHints.newPassword],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm password';
                if (v != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ).animate().fadeIn(delay: 360.ms),

            const SizedBox(height: AppSpacing.xxl),

            AppButton(
              label: 'Reset Password',
              icon: Icons.lock_reset_rounded,
              isLoading: isLoading,
              onPressed: onSubmit,
            ).animate().fadeIn(delay: 440.ms),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

// ─── Password Requirements Card ───────────────────────────────────────────────

class _RequirementsCard extends StatelessWidget {
  const _RequirementsCard({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final reqs = [
      ('At least 8 characters', password.length >= 8),
      ('One uppercase letter', password.contains(RegExp('[A-Z]'))),
      ('One number', password.contains(RegExp('[0-9]'))),
      (
        'One special character',
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password must contain:',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...reqs.map(
            (req) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxs),
              child: Row(
                children: [
                  Icon(
                    req.$2
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 14,
                    color: req.$2 ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    req.$1,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: req.$2
                          ? AppColors.success
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Success View ─────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.goldDark, AppColors.gold],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.ink,
            size: 56,
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut).fadeIn(),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Password Reset!',
          style: AppTypography.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Your password has been updated successfully. '
          'You can now sign in with your new password.',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: AppSpacing.xxxl),
        AppButton(
          label: 'Back to Sign In',
          icon: Icons.login_rounded,
          onPressed: () => context.go(RouteNames.login),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }
}
