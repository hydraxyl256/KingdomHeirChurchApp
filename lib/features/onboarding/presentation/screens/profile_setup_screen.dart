import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/storage/local_storage_service.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  bool _loading = false;

  Future<void> _continue() async {
    setState(() => _loading = true);
    try {
      final localStorage = ref.read(localStorageServiceProvider);
      await localStorage.setBool(
        key: LocalStorageKeys.onboardingComplete,
        value: true,
      );
      if (mounted) context.go(RouteNames.roleSelection);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final displayName = user?.displayName ?? user?.email ?? 'Member';

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 48,
                  color: AppColors.gold,
                ),
              ).animate().fadeIn(duration: 500.ms).scale(
                    begin: const Offset(0.7, 0.7),
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 28),
              Text(
                'Welcome, $displayName! 🎉',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 12),
              Text(
                "You're now part of the Kingdom Heirs community. "
                'Tap Continue to choose your role and get started.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.navy,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loading ? null : _continue,
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 13,
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
