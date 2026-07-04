import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/elevation.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/theme/spacing.dart';
import 'package:kingdom_heir/core/widgets/kingdom_heirs_logo.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';

/// Kingdom Heirs — Login Screen (redesigned)
///
/// Goals: Trust · Simplicity · Premium feel.
/// Sections (top → bottom):
///   1. Brand header — official gold logo + tagline (always visible).
///   2. Welcome heading + helper text.
///   3. Form card — email + password (with forgot-password).
///   4. Primary sign-in CTA.
///   5. Social login — Google.
///   6. Register CTA — pinned to safe-area bottom, always visible.
///
/// Tested against viewport widths: 320, 360, 390, 430, and up.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Hint to autofill services that this is a login form.
    _emailController.text = '';
    _passwordController.text = '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _signIn() async {
    _emailFocus.unfocus();
    _passwordFocus.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.hasError) _showError(state.error.toString());
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.hasError) _showError(state.error.toString());
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final mq = MediaQuery.of(context);
    final reduceMotion = mq.disableAnimations;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.navy,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.navy,
        // ── Resize-to-avoid-keyboard so the bottom CTA stays visible ──
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            const _LoginBackground(),
            SafeArea(
              top: false,
              child: Column(
                children: [
                  _LoginScrollable(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    emailFocus: _emailFocus,
                    passwordFocus: _passwordFocus,
                    obscurePassword: _obscurePassword,
                    onToggleObscure: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    isLoading: isLoading,
                    onSignIn: _signIn,
                    onGoogle: _signInWithGoogle,
                    onForgot: () => context.push(RouteNames.forgotPassword),
                    reduceMotion: reduceMotion,
                  ),
                  _BottomRegisterCta(
                    isLoading: isLoading,
                    onRegister: () => context.push(RouteNames.register),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background — layered navy gradients, no per-frame cost
// ─────────────────────────────────────────────────────────────────────────────

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final blob = (size.shortestSide * 0.9).clamp(280.0, 480.0);

    return Stack(
      children: [
        // Base
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.navy,
                Color(0xFF0B1120),
              ],
            ),
          ),
        ),
        // Top-right gold glow
        Positioned(
          top: -blob * 0.45,
          right: -blob * 0.45,
          child: IgnorePointer(
            child: Container(
              width: blob,
              height: blob,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        // Bottom-left navy accent
        Positioned(
          bottom: -blob * 0.55,
          left: -blob * 0.45,
          child: IgnorePointer(
            child: Container(
              width: blob,
              height: blob,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.navyAccent.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scrollable content
// ─────────────────────────────────────────────────────────────────────────────

class _LoginScrollable extends StatelessWidget {
  const _LoginScrollable({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.isLoading,
    required this.onSignIn,
    required this.onGoogle,
    required this.onForgot,
    required this.reduceMotion,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final bool isLoading;
  final VoidCallback onSignIn;
  final VoidCallback onGoogle;
  final VoidCallback onForgot;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
        ).copyWith(top: AppSpacing.xl),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Brand header ──────────────────────────────────────
              const KingdomHeirsBrandHeader(),
              const SizedBox(height: AppSpacing.xxl),

              // ── 2. Welcome heading ───────────────────────────────────
              _WelcomeBlock(reduceMotion: reduceMotion),
              const SizedBox(height: AppSpacing.xl),

              // ── 3. Glass form card ───────────────────────────────────
              const _FormCardDivider(),
              const SizedBox(height: AppSpacing.lg),
              _GlassCard(
                reduceMotion: reduceMotion,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AuthTextField(
                      controller: emailController,
                      focusNode: emailFocus,
                      label: 'Email',
                      hint: 'steward@kingdomheir.org',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      enabled: !isLoading,
                      validator: _emailValidator,
                      onSubmitted: (_) => passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Password',
                          style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: AppColors.warmWhite.withValues(alpha: 0.7),
                            letterSpacing: 0.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Semantics(
                          label: 'Forgot password?',
                          button: true,
                          child: TextButton(
                            onPressed: isLoading ? null : onForgot,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize:
                                  const Size(0, AppSpacing.minTouchTarget),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: AppColors.goldLight,
                            ),
                            child: Text(
                              'Forgot?',
                              style:
                                  AppTypography.textTheme.labelMedium?.copyWith(
                                color: AppColors.goldLight,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    AppColors.goldLight.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _AuthTextField(
                      controller: passwordController,
                      focusNode: passwordFocus,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      enabled: !isLoading,
                      validator: _passwordValidator,
                      onSubmitted: (_) => onSignIn(),
                      trailing: _PasswordVisibilityToggle(
                        obscure: obscurePassword,
                        onTap: onToggleObscure,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _PrimarySignInButton(
                      isLoading: isLoading,
                      onPressed: onSignIn,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── 4. Social login ───────────────────────────────────────
              const SizedBox(height: AppSpacing.xl),
              _GoogleButton(
                isLoading: isLoading,
                onPressed: onGoogle,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Trust microcopy ───────────────────────────────────────
              const _TrustMicrocopy(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  String? _emailValidator(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email is required';
    if (!value.contains('@') || !value.contains('.')) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'At least 6 characters';
    return null;
  }
}



class _WelcomeBlock extends StatelessWidget {
  const _WelcomeBlock({required this.reduceMotion});

  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Text(
          'Welcome back',
          style: AppTypography.textTheme.headlineMedium?.copyWith(
            color: AppColors.warmWhite,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Sign in to continue your walk with the Kingdom.',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.warmWhite.withValues(alpha: 0.62),
            height: 1.45,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (reduceMotion) return content;
    return content
        .animate()
        .fadeIn(duration: AppMotion.standard, curve: AppMotion.decelerate)
        .slideY(begin: 0.04, end: 0, duration: AppMotion.standard);
  }
}

class _FormCardDivider extends StatelessWidget {
  const _FormCardDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0),
                  AppColors.gold.withValues(alpha: 0.45),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'CREDENTIALS',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.gold,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.45),
                  AppColors.gold.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glass card — frosted, gold-edged
// ─────────────────────────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, required this.reduceMotion});

  final Widget child;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: AppRadius.brXl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.warmWhite.withValues(alpha: 0.04),
            borderRadius: AppRadius.brXl,
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.18),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );

    if (reduceMotion) return card;
    return card
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 120),
          duration: AppMotion.standard,
          curve: AppMotion.decelerate,
        )
        .slideY(begin: 0.06, end: 0, duration: AppMotion.standard);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Text field — design-system primitive
// ─────────────────────────────────────────────────────────────────────────────

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.keyboardType,
    required this.textInputAction,
    required this.validator,
    this.label,
    this.obscureText = false,
    this.autofillHints,
    this.enabled = true,
    this.onSubmitted,
    this.trailing,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final FormFieldValidator<String> validator;
  final ValueChanged<String>? onSubmitted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    const baseColor = AppColors.warmWhite;
    final mutedColor = baseColor.withValues(alpha: 0.45);
    final fieldFill = baseColor.withValues(alpha: 0.05);
    final fieldBorder = baseColor.withValues(alpha: 0.14);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      enabled: enabled,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      style: AppTypography.textTheme.bodyMedium?.copyWith(
        color: baseColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: mutedColor.withValues(alpha: 0.7),
        ),
        prefixIcon: Icon(icon, color: mutedColor, size: AppSpacing.iconSm),
        suffixIcon: trailing,
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: _pillBorder(fieldBorder),
        enabledBorder: _pillBorder(fieldBorder),
        focusedBorder: _pillBorder(AppColors.gold, width: 1.5),
        errorBorder: _pillBorder(AppColors.error),
        focusedErrorBorder: _pillBorder(AppColors.error, width: 1.5),
        errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.error.withValues(alpha: 0.92),
        ),
      ),
    );
  }

  OutlineInputBorder _pillBorder(Color color, {double width = 0.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.full),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _PasswordVisibilityToggle extends StatelessWidget {
  const _PasswordVisibilityToggle({
    required this.obscure,
    required this.onTap,
  });

  final bool obscure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: obscure ? 'Show password' : 'Hide password',
      button: true,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.warmWhite.withValues(alpha: 0.55),
          size: AppSpacing.iconSm,
        ),
        splashRadius: AppSpacing.iconMd,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary sign-in button
// ─────────────────────────────────────────────────────────────────────────────

class _PrimarySignInButton extends StatelessWidget {
  const _PrimarySignInButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Sign in',
      button: true,
      enabled: !isLoading,
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.ink,
            disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.4),
            disabledForegroundColor: AppColors.ink.withValues(alpha: 0.5),
            elevation: isLoading ? 0 : AppElevation.level2,
            shadowColor: AppColors.gold.withValues(alpha: 0.45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: AppSpacing.iconSm + 2,
                  height: AppSpacing.iconSm + 2,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.ink),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sign In',
                      style: AppTypography.textTheme.labelLarge?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: AppSpacing.iconSm,
                      color: AppColors.ink,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}


class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48"><path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/><path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/><path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/><path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/><path fill="none" d="M0 0h48v48H0z"/></svg>''',
      width: 18,
      height: 18,
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Ink(
          height: AppSpacing.buttonHeight,
          decoration: BoxDecoration(
            color: disabled ? Colors.white.withValues(alpha: 0.6) : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.full),
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
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.navy),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _GoogleLogo(),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          'Continue with Google',
                          style: AppTypography.textTheme.labelLarge!.copyWith(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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

// ─────────────────────────────────────────────────────────────────────────────
// Trust microcopy
// ─────────────────────────────────────────────────────────────────────────────

class _TrustMicrocopy extends StatelessWidget {
  const _TrustMicrocopy();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 12,
          color: AppColors.warmWhite.withValues(alpha: 0.45),
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            'Encrypted · stewarded by Kingdom Heirs',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.warmWhite.withValues(alpha: 0.45),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom register CTA — pinned to safe area, always visible
// ─────────────────────────────────────────────────────────────────────────────

class _BottomRegisterCta extends StatelessWidget {
  const _BottomRegisterCta({
    required this.isLoading,
    required this.onRegister,
  });

  final bool isLoading;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.warmWhite.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: AppColors.warmWhite.withValues(alpha: 0.10),
              width: 0.5,
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            children: [
              Text(
                'New to the Kingdom?',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.warmWhite.withValues(alpha: 0.65),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Semantics(
                label: 'Create a new account',
                button: true,
                enabled: !isLoading,
                child: TextButton(
                  onPressed: isLoading ? null : onRegister,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    minimumSize: const Size(0, AppSpacing.minTouchTarget),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.gold,
                  ),
                  child: Text(
                    'Create account',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
