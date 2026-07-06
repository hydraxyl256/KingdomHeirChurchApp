import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';

/// Change Password screen — for authenticated email/password users.
///
/// Flow:
///   1. Detects whether the signed-in user is an OAuth-only account.
///      If so, it renders an informational view rather than the form.
///   2. Validates all three fields client-side before any network call.
///   3. Re-authenticates the user with their current password (via
///      `reauthenticate()`), then calls `updateUser()` with the new password.
///      Both steps go through the canonical `AuthNotifier.changePassword()`.
///   4. On success: shows a SnackBar and navigates back to Settings.
///   5. On failure: shows a user-friendly error — never exposes raw exceptions.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _submitted = false;

  @override
  void dispose() {
    // Securely wipe controllers so the strings are not kept in memory.
    _currentPwCtrl
      ..text = ''
      ..dispose();
    _newPwCtrl
      ..text = ''
      ..dispose();
    _confirmPwCtrl
      ..text = ''
      ..dispose();
    super.dispose();
  }

  // ─── Helper ─────────────────────────────────────────────────────────────

  /// Returns the Supabase auth provider for the current session.
  /// Possible values: 'email', 'google', 'apple', etc.
  String get _authProvider =>
      ref.read(authRepositoryProvider).currentAuthProvider;

  bool get _isOAuthOnly => _authProvider != 'email';

  // ─── Actions ────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await ref.read(authNotifierProvider.notifier).changePassword(
          email: user.email,
          currentPassword: _currentPwCtrl.text,
          newPassword: _newPwCtrl.text,
        );

    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      _showError(_friendlyError(authState.error));
    } else {
      final scheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password changed successfully.'),
          backgroundColor: scheme.tertiary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      // Clear controllers now that we're done.
      _currentPwCtrl.text = '';
      _newPwCtrl.text = '';
      _confirmPwCtrl.text = '';
      context.pop();
    }
  }

  String _friendlyError(Object? error) {
    final msg = error?.toString() ?? '';
    if (msg.toLowerCase().contains('invalid login') ||
        msg.toLowerCase().contains('invalid credentials') ||
        msg.toLowerCase().contains('wrong password')) {
      return 'Your current password is incorrect. Please try again.';
    }
    if (msg.toLowerCase().contains('network') ||
        msg.toLowerCase().contains('socket') ||
        msg.toLowerCase().contains('connection')) {
      return 'No internet connection. Please try again.';
    }
    if (msg.toLowerCase().contains('same password') ||
        msg.toLowerCase().contains('new password should be different')) {
      return 'Your new password must be different from your current password.';
    }
    // Generic fallback — never expose raw backend strings.
    return 'Could not change password. Please try again later.';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Validators ─────────────────────────────────────────────────────────

  String? _validateCurrent(String? v) {
    if (!_submitted) return null;
    if (v == null || v.isEmpty) return 'Current password is required.';
    return null;
  }

  String? _validateNew(String? v) {
    if (!_submitted) return null;
    if (v == null || v.isEmpty) return 'New password is required.';
    if (v.length < 8) return 'Password must be at least 8 characters.';
    if (!v.contains(RegExp('[A-Z]'))) {
      return 'Include at least one uppercase letter.';
    }
    if (!v.contains(RegExp('[0-9]'))) {
      return 'Include at least one number.';
    }
    if (v == _currentPwCtrl.text) {
      return 'New password must differ from your current password.';
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    if (!_submitted) return null;
    if (v == null || v.isEmpty) return 'Please confirm your new password.';
    if (v != _newPwCtrl.text) return 'Passwords do not match.';
    return null;
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.colorScheme.surface;
    final textMuted = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: const Text(
          'Change Password',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: isLoading ? null : () => context.pop(),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: _isOAuthOnly
            ? _OAuthInfoView(provider: _authProvider)
            : _buildForm(
                context,
                theme: theme,
                isDark: isDark,
                cardColor: cardColor,
                textMuted: textMuted,
                isLoading: isLoading,
              ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context, {
    required ThemeData theme,
    required bool isDark,
    required Color cardColor,
    required Color textMuted,
    required bool isLoading,
  }) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Info card ───────────────────────────────────────────
              _InfoCard(cardColor: cardColor, textMuted: textMuted)
                  .animate()
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: AppSpacing.xxl),

              // ── Current password ─────────────────────────────────────
              _PasswordField(
                controller: _currentPwCtrl,
                label: 'Current Password',
                hint: 'Enter your current password',
                obscure: _obscureCurrent,
                enabled: !isLoading,
                autofillHint: AutofillHints.password,
                validator: _validateCurrent,
                onToggle: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
              ).animate().fadeIn(delay: 80.ms),

              const SizedBox(height: AppSpacing.lg),

              // ── New password ─────────────────────────────────────────
              _PasswordField(
                controller: _newPwCtrl,
                label: 'New Password',
                hint: 'At least 8 characters, 1 uppercase, 1 number',
                obscure: _obscureNew,
                enabled: !isLoading,
                autofillHint: AutofillHints.newPassword,
                validator: _validateNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
              ).animate().fadeIn(delay: 120.ms),

              const SizedBox(height: AppSpacing.lg),

              // ── Confirm new password ─────────────────────────────────
              _PasswordField(
                controller: _confirmPwCtrl,
                label: 'Confirm New Password',
                hint: 'Re-enter your new password',
                obscure: _obscureConfirm,
                enabled: !isLoading,
                autofillHint: AutofillHints.newPassword,
                validator: _validateConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ).animate().fadeIn(delay: 160.ms),

              const SizedBox(height: AppSpacing.xxxl),

              // ── Submit button ────────────────────────────────────────
              _SubmitButton(isLoading: isLoading, onPressed: _submit)
                  .animate()
                  .fadeIn(delay: 200.ms),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── OAuth Info View ──────────────────────────────────────────────────────────

class _OAuthInfoView extends StatelessWidget {
  const _OAuthInfoView({required this.provider});

  final String provider;

  String get _providerLabel {
    switch (provider.toLowerCase()) {
      case 'google':
        return 'Google';
      case 'apple':
        return 'Apple';
      default:
        return provider;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_person_rounded,
                size: 48,
                color: theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Password managed by $_providerLabel',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your account uses $_providerLabel to sign in. '
              'To change your password, please visit your '
              '$_providerLabel account settings.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ─── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.cardColor, required this.textMuted});

  final Color cardColor;
  final Color textMuted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Use at least 8 characters with one uppercase letter and one number.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Password field ───────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscure,
    required this.enabled,
    required this.autofillHint,
    required this.validator,
    required this.onToggle,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final bool enabled;
  final String autofillHint;
  final FormFieldValidator<String> validator;
  final VoidCallback onToggle;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          autofillHints: [autofillHint],
          textInputAction: textInputAction,
          keyboardType: TextInputType.visiblePassword,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
              fontSize: 13,
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: onToggle,
              tooltip: obscure ? 'Show password' : 'Hide password',
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Submit button ────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.onPrimary),
                ),
              )
            : const Text(
                'Update Password',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
