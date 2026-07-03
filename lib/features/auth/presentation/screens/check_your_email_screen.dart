import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:url_launcher/url_launcher.dart';

/// "Check Your Email" — landing page shown after registration.
///
/// Responsibilities:
///   • Display the email the verification message was sent to.
///   • Provide an "Open Email App" deep link.
///   • Provide a "Resend Email" action with a 60-second anti-spam cooldown.
///   • Provide a "Change Email" fallback.
///   • Provide an "I've Verified My Email" manual retry that polls Supabase
///     every 5 seconds so the user lands in the dashboard without having
///     to background / foreground the app.
///   • Handle offline, expired-link, and already-verified edge cases.
class CheckYourEmailScreen extends ConsumerStatefulWidget {
  const CheckYourEmailScreen({
    required this.email,
    super.key,
  });

  /// Email the verification message was sent to. Captured at signup so the
  /// screen survives a process restart.
  final String email;

  @override
  ConsumerState<CheckYourEmailScreen> createState() =>
      _CheckYourEmailScreenState();
}

class _CheckYourEmailScreenState extends ConsumerState<CheckYourEmailScreen> {
  /// Anti-spam cooldown. Disabled until [_cooldownSeconds] reaches zero.
  int _cooldownSeconds = 60;

  /// Set while a resend request is in flight to disable the button.
  bool _isResending = false;

  /// Optional inline status message under the resend button — used for
  /// success / error feedback so the user is never left guessing.
  String? _resendFeedback;

  /// Set true when manual check detects verification, so we can play the success animation.
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ── Cooldown & Polling ──────────────────────────────────────────────────

  void _startCooldown() {
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_cooldownSeconds <= 0) {
        t.cancel();
        return;
      }
      setState(() => _cooldownSeconds--);
    });
  }



  Future<void> _checkVerification() async {
    try {
      // Refresh the session — this pulls the latest email_confirmed_at
      // from Supabase. If the user has tapped the link in another
      // device or already verified, this picks it up.
      final dataSource = ref.read(authRemoteDataSourceProvider);
      final user = await dataSource.refreshVerificationStatus();

      if (user != null && user.emailConfirmedAt != null) {
        if (!mounted) return;
        setState(() => _verified = true);
        // Drive the auth state through Riverpod so the router redirects
        // us to the dashboard via its refreshListenable.
        ref
          ..invalidate(authStateProvider)
          ..invalidate(currentUserProvider);
        if (!mounted) return;
        // Show the success state briefly, then route on.
        await Future<void>.delayed(const Duration(milliseconds: 900));
        if (!mounted) return;
        context.go(RouteNames.dashboard);
      } else if (mounted) {
        setState(
          () => _resendFeedback =
              "We haven't detected verification yet. Please tap the link in your email.",
        );
      }
    } on supabase.AuthException catch (e) {
      if (mounted) {
        setState(() => _resendFeedback = e.message);
      }
    } catch (_) {
      // Network failures during manual polling
      if (mounted) {
        setState(
          () => _resendFeedback =
              'Could not reach the server. Check your connection and try again.',
        );
      }
    }
  }

  // ── Action handlers ────────────────────────────────────────────────────

  Future<void> _resend() async {
    if (_cooldownSeconds > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _resendFeedback = null;
    });

    try {
      await ref
          .read(authRemoteDataSourceProvider)
          .resendVerificationEmail(widget.email);
      if (!mounted) return;
      setState(() {
        _resendFeedback = 'A fresh verification email is on its way.';
        _cooldownSeconds = 60;
      });
      _startCooldown();
    } on supabase.AuthException catch (e) {
      if (!mounted) return;
      setState(() => _resendFeedback = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _resendFeedback =
            'Could not resend the email. Check your connection and try again.',
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _openEmailApp() async {
    // Prefer the user's default mail app via a `mailto:` URL — Android
    // and iOS both resolve this without extra permissions.
    final uri = Uri(scheme: 'mailto', path: widget.email);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No mail app available. Open your email app manually.',
          ),
        ),
      );
    }
  }

  void _changeEmail() {
    // Send the user back to register so they can use a different address.
    // The previously-issued verification email is now stale.
    context.go(RouteNames.register);
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _VerifyBackground()),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _verified
                  ? const _VerifiedSuccessView()
                  : _CheckEmailView(
                      email: widget.email,
                      cooldownSeconds: _cooldownSeconds,
                      isResending: _isResending,
                      feedback: _resendFeedback,
                      onOpenEmail: _openEmailApp,
                      onResend: _resend,
                      onChangeEmail: _changeEmail,
                      onManualVerify: _checkVerification,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── View: "Check Your Email" ───────────────────────────────────────────────

class _CheckEmailView extends StatelessWidget {
  const _CheckEmailView({
    required this.email,
    required this.cooldownSeconds,
    required this.isResending,
    required this.feedback,
    required this.onOpenEmail,
    required this.onResend,
    required this.onChangeEmail,
    required this.onManualVerify,
  });

  final String email;
  final int cooldownSeconds;
  final bool isResending;
  final String? feedback;
  final VoidCallback onOpenEmail;
  final VoidCallback onResend;
  final VoidCallback onChangeEmail;
  final VoidCallback onManualVerify;

  @override
  Widget build(BuildContext context) {
    final canResend = cooldownSeconds <= 0 && !isResending;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          const _Illustration(),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Check your email',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'We sent a verification link to\n'),
                TextSpan(
                  text: email,
                  style: const TextStyle(
                    color: AppColors.goldLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(
                  text:
                      '\n\nTap the link to activate your Kingdom Heirs account.',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Primary action — Open Email App ────────────────────────────
          _PrimaryButton(
            label: 'Open Email App',
            icon: Icons.mail_outline_rounded,
            onPressed: onOpenEmail,
            semanticLabel: 'Open your email application',
          ),
          const SizedBox(height: AppSpacing.md),

          // ── "I've verified" — manual escape hatch + auto-poll fallback
          _OutlineButton(
            label: "I've verified my email",
            icon: Icons.verified_outlined,
            onPressed: onManualVerify,
            semanticLabel: 'Check verification status now',
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Resend ─────────────────────────────────────────────────────
          Center(
            child: _ResendControl(
              cooldownSeconds: cooldownSeconds,
              enabled: canResend,
              isLoading: isResending,
              feedback: feedback,
              onResend: onResend,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Change email ───────────────────────────────────────────────
          Center(
            child: TextButton.icon(
              onPressed: onChangeEmail,
              icon: const Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppColors.goldLight,
              ),
              label: const Text('Use a different email'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.goldLight,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Tips block ─────────────────────────────────────────────────
          const _TipsCard(),
          const SizedBox(height: AppSpacing.lg),

          // ── Spam-folder escape hatch ───────────────────────────────────
          Center(
            child: Text(
              "Check your spam folder if the email hasn't arrived in 2 minutes.",
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────

class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 132,
        height: 132,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Icon(
          Icons.mark_email_unread_outlined,
          size: 64,
          color: AppColors.gold,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        height: AppSpacing.buttonHeight,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: AppColors.ink),
          label: Text(
            label,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.ink,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.brFull,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        height: AppSpacing.buttonHeight,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18, color: AppColors.warmWhite),
          label: Text(
            label,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.25),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.brFull,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResendControl extends StatelessWidget {
  const _ResendControl({
    required this.cooldownSeconds,
    required this.enabled,
    required this.isLoading,
    required this.feedback,
    required this.onResend,
  });

  final int cooldownSeconds;
  final bool enabled;
  final bool isLoading;
  final String? feedback;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final label = cooldownSeconds > 0
        ? 'Resend available in ${cooldownSeconds}s'
        : 'Resend verification email';

    return Column(
      children: [
        Semantics(
          button: true,
          enabled: enabled,
          label: label,
          child: TextButton.icon(
            onPressed: enabled ? onResend : null,
            icon: isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.goldLight,
                    ),
                  )
                : Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: enabled
                        ? AppColors.goldLight
                        : Colors.white.withValues(alpha: 0.3),
                  ),
            label: Text(
              label,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: enabled
                    ? AppColors.goldLight
                    : Colors.white.withValues(alpha: 0.4),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        if (feedback != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            feedback!,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.65),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: AppRadius.brLg,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 18,
            color: AppColors.gold.withValues(alpha: 0.85),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Tip: Tap the link on this device — it will open the app, '
              'sign you in, and take you to the dashboard automatically.',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedSuccessView extends StatelessWidget {
  const _VerifiedSuccessView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.success, width: 2),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 64,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Email verified!',
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Taking you to your dashboard…',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Background ────────────────────────────────────────────────────────────

class _VerifyBackground extends StatelessWidget {
  const _VerifyBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 1.2,
          colors: [
            Color(0xFF162033),
            Color(0xFF0F172A),
            Color(0xFF0B1120),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: _MeshGlow(),
    );
  }
}

class _MeshGlow extends StatelessWidget {
  const _MeshGlow();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MeshGlowPainter());
  }
}

class _MeshGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..blendMode = BlendMode.screen
      ..shader = RadialGradient(
        colors: [
          AppColors.gold.withValues(alpha: 0.10),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.2, size.height * 0.2),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.2),
      size.width * 0.6,
      paint1,
    );

    final paint2 = Paint()
      ..blendMode = BlendMode.screen
      ..shader = RadialGradient(
        colors: [
          AppColors.gold.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.85, size.height * 0.85),
          radius: size.width * 0.5,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.85),
      size.width * 0.5,
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
