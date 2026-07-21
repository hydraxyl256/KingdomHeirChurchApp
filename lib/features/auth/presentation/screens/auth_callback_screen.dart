import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/storage/local_storage_service.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Handles errors during the Supabase Auth deep link callback.
///
/// If a deep link is valid, Supabase intercepts it, completes PKCE,
/// and GoRouter redirects instantly to the dashboard.
/// If the link is invalid, expired, or already used, GoRouter routes here.
class AuthCallbackScreen extends ConsumerStatefulWidget {
  const AuthCallbackScreen({
    this.errorDescription,
    this.errorCode,
    super.key,
  });

  final String? errorDescription;
  final String? errorCode;

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  bool _isResending = false;
  String? _resendFeedback;
  String? _pendingEmail;

  @override
  void initState() {
    super.initState();
    // Retrieve the email we stored during signup/password reset
    final storage = ref.read(localStorageServiceProvider);
    _pendingEmail =
        storage.getString(LocalStorageKeys.pendingVerificationEmail);
  }

  Future<void> _resend() async {
    if (_pendingEmail == null || _pendingEmail!.isEmpty || _isResending) return;

    setState(() {
      _isResending = true;
      _resendFeedback = null;
    });

    try {
      await ref
          .read(authRemoteDataSourceProvider)
          .resendVerificationEmail(_pendingEmail!);
      if (!mounted) return;
      setState(() {
        _resendFeedback =
            'A new verification link has been sent to your email.';
      });
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

  @override
  Widget build(BuildContext context) {
    // Polished default error
    final displayError = widget.errorDescription ??
        'This verification link has expired or is invalid. Please request a new one.';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.authenticationError),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withValues(alpha: 0.1),
                  border:
                      Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 50,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Link Expired or Invalid',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.warmWhite,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                displayError,
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (_pendingEmail != null && _pendingEmail!.isNotEmpty) ...[
                Text(
                  'Send a new link to:\n$_pendingEmail',
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: _isResending ? null : _resend,
                    icon: _isResending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.ink,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded,
                            color: AppColors.ink,),
                    label: Text(
                      _isResending ? 'Sending...' : 'Resend Link',
                      style: AppTypography.textTheme.labelLarge?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.brFull,
                      ),
                    ),
                  ),
                ),
                if (_resendFeedback != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _resendFeedback!,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.goldLight,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
              ],
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: OutlinedButton(
                  onPressed: () => context.go(RouteNames.login),
                  style: OutlinedButton.styleFrom(
                    side:
                        BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.brFull,
                    ),
                  ),
                  child: Text(
                    'Go to Login',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.warmWhite,
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
