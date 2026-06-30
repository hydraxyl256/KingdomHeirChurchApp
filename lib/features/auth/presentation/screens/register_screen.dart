import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/storage/local_storage_service.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';

/// Kingdom Heirs — Single-Screen Registration.
///
/// A premium, single-page registration flow with inline validation:
///   • Email
///   • Password (8+ chars, upper, lower, number, special)
///   • Confirm Password (must match)
///   • "Continue with Google" button
///   • "Already have an account? Sign In" footer
///
/// Multi-step wizard removed per production-ready redesign.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // ── Form controllers ───────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // Toggles
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Tracks whether the user has interacted with each field so we
  // surface inline errors lazily (only after they've typed or blurred).
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmTouched = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => _onChanged('email'));
    _passwordController.addListener(() => _onChanged('password'));
    _confirmController.addListener(() => _onChanged('confirm'));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onChanged(String field) {
    // Surface (or hide) errors as the user types, so validation is
    // truly inline — never deferred until Submit.
    if (!mounted) return;
    setState(() {
      switch (field) {
        case 'email':
          _emailTouched = true;
        case 'password':
          _passwordTouched = true;
        case 'confirm':
          _confirmTouched = true;
      }
    });
  }

  // ── Validators ─────────────────────────────────────────────────────────────

  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
    '[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  static final RegExp _upperRegex = RegExp('[A-Z]');
  static final RegExp _lowerRegex = RegExp('[a-z]');
  static final RegExp _digitRegex = RegExp('[0-9]');
  static final RegExp _specialRegex =
      RegExp(r'[!@#$&*~%^()_\-+=\[\]{};:.,?<>/|\\]');

  String? _validateEmail(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? raw) {
    final value = raw ?? '';
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'At least 8 characters';
    if (!value.contains(_upperRegex)) return 'Add an uppercase letter';
    if (!value.contains(_lowerRegex)) return 'Add a lowercase letter';
    if (!value.contains(_digitRegex)) return 'Add a number';
    if (!value.contains(_specialRegex)) return 'Add a special character';
    return null;
  }

  String? _validateConfirm(String? raw) {
    final value = raw ?? '';
    if (value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return "Passwords don't match";
    return null;
  }

  /// Strength meter — drives a thin progress bar under the password field.
  int _passwordScore(String value) {
    var score = 0;
    if (value.length >= 8) score++;
    if (value.contains(_upperRegex)) score++;
    if (value.contains(_lowerRegex)) score++;
    if (value.contains(_digitRegex)) score++;
    if (value.contains(_specialRegex)) score++;
    return score;
  }

  // ── Submit — email registration ──────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Force re-validate so all 3 fields show errors even if user
      // hit Enter without touching them.
      setState(() {
        _emailTouched = true;
        _passwordTouched = true;
        _confirmTouched = true;
      });
      return;
    }

    final email = _emailController.text.trim();

    await ref.read(authNotifierProvider.notifier).signUp(
          email: email,
          password: _passwordController.text,
          fullName: '', // No name field — Supabase profile populated
          //                    via OAuth metadata or by the user in
          //                    their profile screen.
        );

    if (!mounted) return;

    final state = ref.read(authNotifierProvider);
    if (state.hasError) {
      final msg =
          state.error?.toString() ?? 'Sign-up failed. Please try again.';
      // Supabase prefixes like "AuthException: " or "Exception: " are
      // stripped so the user sees only the actual reason.
      final cleaned = msg
          .replaceFirst('AuthException: ', '')
          .replaceFirst('Exception: ', '')
          .replaceFirst('AuthApiException: ', '');
      // ignore: unawaited_futures
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cleaned),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );
      return;
    }

    // Stash the registered email so the verification landing screen
    // can show it after a deep-link re-entry (user backgrounded the app,
    // tapped the email link, bounced back via kingdomheir://verify).
    unawaited(
      ref.read(localStorageServiceProvider).setString(
            key: LocalStorageKeys.pendingVerificationEmail,
            value: email,
          ),
    );

    if (!mounted) return;

    // Always send the user to the verification landing screen after
    // registration — even if Supabase happens to confirm the email
    // synchronously, the screen handles that and forwards to the
    // dashboard.
    context.go('${RouteNames.verifyEmail}?email=${Uri.encodeComponent(email)}');
  }

  // ── Submit — Google OAuth ────────────────────────────────────────────────

  Future<void> _signInWithGoogle() async {
    // ignore: unawaited_futures
    HapticFeedback.lightImpact();
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      if (!mounted) return;
      final state = ref.read(authNotifierProvider);
      if (state.hasError) {
        final raw = state.error?.toString() ?? 'Google sign-in failed';
        final msg = raw
            .replaceFirst('AuthException: ', '')
            .replaceFirst('Exception: ', '')
            .replaceFirst('AuthApiException: ', '');
        // Cancellation by the user is silent.
        if (msg.toLowerCase().contains('cancel')) return;
        if (!mounted) return;
        // ignore: unawaited_futures
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.navy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
      // On success the auth state stream will redirect via GoRouter's
      // redirect-listener — no manual `context.go` required.
    } catch (e) {
      if (!mounted) return;
      // ignore: unawaited_futures
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final mq = MediaQuery.of(context);

    // Logo size is responsive (same clamp as splash + login).
    final logoSize = (mq.size.shortestSide * 0.13).clamp(44.0, 64.0);

    // Disable provider rebuilds mid-submit (and keep both
    // buttons independently disabled while the other is loading).
    final isEmailBusy = isLoading;
    final isGoogleBusy = isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.navy,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.navy,
        body: Stack(
          children: [
            // ── Background painters ─────────────────────────────────────────
            const Positioned.fill(child: _RegisterBackground()),
            const Positioned.fill(child: _MeshGlowPainter()),

            // ── Foreground ────────────────────────────────────────────────
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        mq.size.height - mq.padding.top - mq.padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.xl),

                        // ── Brand block ─────────────────────────────────
                        _BrandHeader(
                          logoSize: logoSize,
                          reduceMotion: reduceMotion,
                        ).animate(target: reduceMotion ? 1 : 0).fadeIn(
                              duration: AppMotion.standard,
                              delay: const Duration(milliseconds: 80),
                            ),

                        const SizedBox(height: AppSpacing.xl),

                        // ── Form card ──────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Form(
                            key: _formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _TitleBlock(reduceMotion: reduceMotion),

                                const SizedBox(height: AppSpacing.xl),

                                // ── Email ─────────────────────────
                                _AuthLabel(
                                  text: 'Email Address',
                                  reduceMotion: reduceMotion,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  autofillHints: const [AutofillHints.email],
                                  style: _fieldTextStyle(),
                                  decoration: _fieldDecoration(
                                    hint: 'you@kingdomheirs.org',
                                    icon: Icons.alternate_email_rounded,
                                  ),
                                  validator: (v) =>
                                      _emailTouched ? _validateEmail(v) : null,
                                  onChanged: (_) => _emailTouched = true,
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context).nextFocus(),
                                ),

                                const SizedBox(height: AppSpacing.lg),

                                // ── Password ─────────────────────
                                _AuthLabel(
                                  text: 'Password',
                                  reduceMotion: reduceMotion,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  style: _fieldTextStyle(),
                                  decoration: _fieldDecoration(
                                    hint: 'Minimum 8 characters',
                                    icon: Icons.lock_outline_rounded,
                                    trailing: _VisibilityToggle(
                                      visible: !_obscurePassword,
                                      onTap: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                  ).copyWith(
                                    suffixIconConstraints: const BoxConstraints(
                                      minHeight: 48,
                                      minWidth: 48,
                                    ),
                                  ),
                                  validator: (v) => _passwordTouched
                                      ? _validatePassword(v)
                                      : null,
                                  onChanged: (_) => _passwordTouched = true,
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context).nextFocus(),
                                ),

                                // ── Password strength meter ─────
                                if (_passwordController.text.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: AppSpacing.sm,
                                    ),
                                    child: _PasswordStrengthMeter(
                                      score: _passwordScore(
                                        _passwordController.text,
                                      ),
                                      reduceMotion: reduceMotion,
                                    ),
                                  ),

                                const SizedBox(height: AppSpacing.lg),

                                // ── Confirm Password ───────────
                                _AuthLabel(
                                  text: 'Confirm Password',
                                  reduceMotion: reduceMotion,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                TextFormField(
                                  controller: _confirmController,
                                  obscureText: _obscureConfirm,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  style: _fieldTextStyle(),
                                  decoration: _fieldDecoration(
                                    hint: 'Re-enter your password',
                                    icon: Icons.lock_clock_outlined,
                                    trailing: _VisibilityToggle(
                                      visible: !_obscureConfirm,
                                      onTap: () => setState(
                                        () =>
                                            _obscureConfirm = !_obscureConfirm,
                                      ),
                                    ),
                                  ).copyWith(
                                    suffixIconConstraints: const BoxConstraints(
                                      minHeight: 48,
                                      minWidth: 48,
                                    ),
                                  ),
                                  validator: (v) => _confirmTouched
                                      ? _validateConfirm(v)
                                      : null,
                                  onChanged: (_) => _confirmTouched = true,
                                  onFieldSubmitted: (_) => _submit(),
                                ),

                                const SizedBox(height: AppSpacing.xl),

                                // ── Create Account (primary) ────
                                AppButton(
                                  label: isEmailBusy
                                      ? 'Creating account…'
                                      : 'Create Account',
                                  isLoading: isEmailBusy,
                                  onPressed: (isEmailBusy || isGoogleBusy)
                                      ? null
                                      : _submit,
                                ),

                                const SizedBox(height: AppSpacing.lg),

                                // ── Divider ─────────────────────
                                const _OrDivider(),

                                const SizedBox(height: AppSpacing.lg),

                                // ── Continue with Google ───────
                                _GoogleButton(
                                  onPressed: (isEmailBusy || isGoogleBusy)
                                      ? null
                                      : _signInWithGoogle,
                                  isLoading: isGoogleBusy,
                                  reduceMotion: reduceMotion,
                                ),

                                const SizedBox(height: AppSpacing.xl),

                                // ── Sign In footer ────────────
                                _SignInFooter(
                                  reduceMotion: reduceMotion,
                                  onSignInTap: () =>
                                      context.go(RouteNames.login),
                                ),

                                const SizedBox(height: AppSpacing.lg),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // ── Footer brand line ──────────────────────
                        const Padding(
                          padding: EdgeInsets.only(
                            top: AppSpacing.lg,
                            bottom: AppSpacing.md,
                          ),
                          child: _LegalFooter(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Decoration helpers ────────────────────────────────────────────────────

  TextStyle _fieldTextStyle() => AppTypography.textTheme.bodyLarge!.copyWith(
        color: AppColors.white,
        fontWeight: FontWeight.w500,
      );

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? trailing,
  }) {
    final fillColor = Colors.white.withValues(alpha: 0.08);
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.textTheme.bodyMedium!.copyWith(
        color: Colors.white.withValues(alpha: 0.45),
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: fillColor,
      prefixIcon: Icon(
        icon,
        color: AppColors.gold.withValues(alpha: 0.85),
        size: 20,
      ),
      suffixIcon: trailing == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: trailing,
            ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: BorderSide(
          color: Colors.redAccent.withValues(alpha: 0.6),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: AppTypography.textTheme.bodySmall!.copyWith(
        color: Colors.redAccent,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Brand block — Logo + title above the form card.
class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.logoSize, required this.reduceMotion});
  final double logoSize;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.gold.withValues(alpha: 0.35),
                AppColors.gold.withValues(alpha: 0),
              ],
            ),
          ),
          child: Center(
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.jpeg',
                width: logoSize - 8,
                height: logoSize - 8,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Kingdom Heirs',
          style: AppTypography.textTheme.titleLarge!.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Foundation',
          style: AppTypography.textTheme.labelSmall!.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

/// Welcome title + subtitle above the form.
class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.reduceMotion});
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create your account',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.textTheme.headlineSmall!.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Steward your walk with us in three quick steps.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.textTheme.bodyMedium!.copyWith(
            color: Colors.white.withValues(alpha: 0.65),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

/// Form label (uppercase, gold, letter-spaced).
class _AuthLabel extends StatelessWidget {
  const _AuthLabel({required this.text, required this.reduceMotion});
  final String text;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.textTheme.labelSmall!.copyWith(
        color: AppColors.gold,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Password visibility toggle (eye / eye-off).
class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.visible, required this.onTap});
  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: visible ? 'Hide password' : 'Show password',
      button: true,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.white.withValues(alpha: 0.7),
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// 5-bar strength meter.
class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({
    required this.score,
    required this.reduceMotion,
  });
  final int score; // 0..5
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    const labels = ['Too weak', 'Weak', 'Fair', 'Good', 'Strong', 'Excellent'];
    const colors = [
      Colors.redAccent,
      Colors.deepOrange,
      Colors.orange,
      Colors.amber,
      Colors.lightGreen,
      Colors.green,
    ];
    final clamped = score.clamp(0, 5);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: clamped / 5,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(colors[clamped]),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 64),
          child: Text(
            labels[clamped],
            textAlign: TextAlign.right,
            style: AppTypography.textTheme.labelSmall!.copyWith(
              color: colors[clamped],
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// "or" divider with gold lines.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'or',
            style: AppTypography.textTheme.labelMedium!.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Official Google "G" multi-color SVG (brand-compliant).
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_googleSvg, width: 18, height: 18);
  }
}

/// "Continue with Google" button — official Google branding + label.
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.onPressed,
    required this.isLoading,
    required this.reduceMotion,
  });
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Ink(
          height: AppSpacing.buttonHeight,
          decoration: BoxDecoration(
            color:
                disabled ? Colors.white.withValues(alpha: 0.6) : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            boxShadow: disabled
                ? const []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.navy,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _GoogleLogo(),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Continue with Google',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.labelLarge!.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// "Already have an account? Sign In" footer with rich-text tap target.
class _SignInFooter extends StatelessWidget {
  const _SignInFooter({
    required this.reduceMotion,
    required this.onSignInTap,
  });
  final bool reduceMotion;
  final VoidCallback onSignInTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          text: 'Already have an account?  ',
          style: AppTypography.textTheme.bodyMedium!.copyWith(
            color: Colors.white.withValues(alpha: 0.65),
          ),
          children: [
            TextSpan(
              text: 'Sign In',
              recognizer: TapGestureRecognizer()..onTap = onSignInTap,
              style: AppTypography.textTheme.labelLarge!.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.gold,
                decorationThickness: 1.4,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Tiny legal / build line at the very bottom.
class _LegalFooter extends StatelessWidget {
  const _LegalFooter();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Kingdom Heirs Foundation · v1.0',
      textAlign: TextAlign.center,
      style: AppTypography.textTheme.labelSmall!.copyWith(
        color: Colors.white.withValues(alpha: 0.35),
        letterSpacing: 1.5,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background (decorative, non-interactive)
// ─────────────────────────────────────────────────────────────────────────────

class _RegisterBackground extends StatelessWidget {
  const _RegisterBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0E1A33),
            Color(0xFF0A1428),
            Color(0xFF050B1A),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

class _MeshGlowPainter extends StatelessWidget {
  const _MeshGlowPainter();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _MeshGlowPainterDelegate(),
        size: Size.infinite,
      ),
    );
  }
}

class _MeshGlowPainterDelegate extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Two soft colored blobs — gold (top-right) + royal-blue (bottom-left).
    final paintGold = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.gold.withValues(alpha: 0.28),
          AppColors.gold.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.85, size.height * 0.05),
          radius: size.shortestSide * 0.6,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.05),
      size.shortestSide * 0.6,
      paintGold,
    );

    final paintBlue = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2F4DA8).withValues(alpha: 0.35),
          const Color(0xFF2F4DA8).withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.1, size.height * 0.95),
          radius: size.shortestSide * 0.7,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.95),
      size.shortestSide * 0.7,
      paintBlue,
    );
  }

  @override
  bool shouldRepaint(covariant _MeshGlowPainterDelegate oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Google brand SVG (multi-color, 18x18 viewBox)
// Source: https://developers.google.com/identity/branding-guidelines
// ─────────────────────────────────────────────────────────────────────────────

const String _googleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#FFC107" d="M43.611 20.083H42V20H24v8h11.303c-1.649 4.657-6.08 8-11.303 8-6.627 0-12-5.373-12-12s5.373-12 12-12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4 12.955 4 4 12.955 4 24s8.955 20 20 20 20-8.955 20-20c0-1.341-.138-2.65-.389-3.917z"/>
  <path fill="#FF3D00" d="M6.306 14.691l6.571 4.819C14.655 15.108 18.961 12 24 12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4 16.318 4 9.656 8.337 6.306 14.691z"/>
  <path fill="#4CAF50" d="M24 44c5.166 0 9.86-1.977 13.409-5.192l-6.19-5.238A11.91 11.91 0 0 1 24 36c-5.202 0-9.619-3.317-11.283-7.946l-6.522 5.025C9.505 39.556 16.227 44 24 44z"/>
  <path fill="#1976D2" d="M43.611 20.083H42V20H24v8h11.303a12.04 12.04 0 0 1-4.087 5.571l.003-.002 6.19 5.238C36.971 39.205 44 34 44 24c0-1.341-.138-2.65-.389-3.917z"/>
</svg>
''';
