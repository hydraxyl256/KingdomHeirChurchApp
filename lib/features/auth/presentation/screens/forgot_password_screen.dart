import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/core/widgets/app_text_field.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    await ref
        .read(authNotifierProvider.notifier)
        .resetPassword(_emailController.text.trim());

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _emailSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          child: _emailSent
              ? _SuccessView(
                  email: _emailController.text.trim(),
                  onResend: () => setState(() => _emailSent = false),
                )
              : _FormView(
                  formKey: _formKey,
                  emailController: _emailController,
                  isLoading: _isLoading,
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
    required this.emailController,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),

          // Illustration
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
                Icons.lock_reset_rounded,
                color: AppColors.ink,
                size: 48,
              ),
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

          const SizedBox(height: AppSpacing.xxl),

          Text(
            'Forgot Password?',
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.15),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Enter the email address associated with your account. '
            "We'll send a reset link instantly.",
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.65),
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: AppSpacing.xxxl),

          AppTextField(
            controller: emailController,
            label: 'Email Address',
            hint: 'your@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: AppSpacing.xxl),

          AppButton(
            label: 'Send Reset Link',
            icon: Icons.send_rounded,
            isLoading: isLoading,
            onPressed: onSubmit,
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: AppSpacing.xl),

          Center(
            child: Text(
              "Check your spam folder if you don't receive the email.",
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.45),
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

// ─── Success View ─────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.email, required this.onResend});

  final String email;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success checkmark
        Container(
          width: 110,
          height: 110,
          decoration: const BoxDecoration(
            color: AppColors.successContainer,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: AppColors.success,
            size: 56,
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut).fadeIn(),

        const SizedBox(height: AppSpacing.xxl),

        Text(
          'Check Your Email',
          style: AppTypography.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: AppSpacing.md),

        Text(
          'We sent a password reset link to\n',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),

        Text(
          email,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 350.ms),

        const SizedBox(height: AppSpacing.xxxl),

        AppButton(
          label: 'Open Email App',
          icon: Icons.open_in_new_rounded,
          onPressed: () {
            // TODO(dev): use url_launcher to open mail app
          },
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: AppSpacing.md),

        TextButton(
          onPressed: onResend,
          child: Text(
            "Didn't receive it? Resend",
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ).animate().fadeIn(delay: 500.ms),

        const SizedBox(height: AppSpacing.sm),

        TextButton(
          onPressed: context.pop,
          child: Text(
            'Back to Sign In',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
        ).animate().fadeIn(delay: 550.ms),
      ],
    );
  }
}
