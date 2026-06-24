import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/storage/local_storage_service.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/elevation.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/auth/domain/entities/app_user.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';

/// Kingdom Heirs — Stepper Onboarding (Registration)
///
/// A premium 4-step onboarding flow that mirrors the Splash / Start-Here /
/// Login redesigns. Each step is a single focused screen with the official
/// Kingdom Heirs logo, a progress indicator, and Material 3 inputs.
///
///   Step 1 — Account           (email + password + confirm)
///   Step 2 — Personal Info     (full name, phone, bio)
///   Step 3 — Church Connection (role + church name + denomination)
///   Step 4 — Preferences       (notifications, language, theme)
///
/// On the final step the Supabase account is created and the auxiliary
/// fields (phone, bio, church, role, preferences) are persisted via
/// [LocalStorageService] so a subsequent profile-update call can apply them.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  /// PageView controller — drives the horizontal step transition.
  late final PageController _pageController;

  /// Current step index (0..3). Drives progress indicator and back/next logic.
  int _currentStep = 0;

  // ── Step 1 controllers — Account ──────────────────────────────────────────
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // ── Step 2 controllers — Personal Information ─────────────────────────────
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  // ── Step 3 state — Church Connection ───────────────────────────────────────
  UserRole? _role;
  final _churchNameController = TextEditingController();
  String _denomination = '';
  bool _hasAcceptedCovenant = false;

  // ── Step 4 state — Preferences ─────────────────────────────────────────────
  bool _pushNotifications = true;
  bool _emailDigest = true;
  bool _eventReminders = true;
  String _language = 'English';
  String _theme = 'Royal Dark';

  // ── Per-step FormKeys ──────────────────────────────────────────────────────
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();
  final _step4FormKey = GlobalKey<FormState>();

  // ── Step metadata (single source of truth for the indicator + headers). ────
  static const List<_StepMeta> _steps = [
    _StepMeta(
      eyebrow: 'Step 01',
      title: 'Create your account',
      subtitle: 'Begin with the credentials that will guard your stewardship.',
      icon: Icons.lock_outline_rounded,
    ),
    _StepMeta(
      eyebrow: 'Step 02',
      title: 'Personal information',
      subtitle:
          'Help us address you with the reverence you carry in the Kingdom.',
      icon: Icons.person_outline_rounded,
    ),
    _StepMeta(
      eyebrow: 'Step 03',
      title: 'Church connection',
      subtitle: 'Tell us how you serve — and the community you walk with.',
      icon: Icons.church_outlined,
    ),
    _StepMeta(
      eyebrow: 'Step 04',
      title: 'Preferences',
      subtitle: 'Tailor the experience. You can refine these anytime.',
      icon: Icons.tune_rounded,
    ),
  ];

  static const List<String> _denominations = [
    'Pentecostal',
    'Charismatic',
    'Evangelical',
    'Baptist',
    'Methodist',
    'Anglican',
    'Presbyterian',
    'Catholic',
    'Orthodox',
    'Non-denominational',
    'Other',
  ];

  static const List<String> _languages = [
    'English',
    'French',
    'Swahili',
    'Luganda',
    'Arabic',
    'Spanish',
    'Portuguese',
  ];

  static const List<String> _themes = [
    'Royal Dark',
    'Royal Light',
    'System',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _churchNameController.dispose();
    super.dispose();
  }

  // ── Navigation between steps ───────────────────────────────────────────────

  void _next() {
    if (!_validateCurrentStep()) return;
    if (_currentStep >= _steps.length - 1) {
      _submit();
      return;
    }
    _pageController.nextPage(
      duration: AppMotion.emphasized,
      curve: AppMotion.decelerate,
    );
  }

  void _back() {
    if (_currentStep <= 0) {
      context.go(RouteNames.login);
      return;
    }
    _pageController.previousPage(
      duration: AppMotion.emphasized,
      curve: AppMotion.decelerate,
    );
  }

  bool _validateCurrentStep() {
    final formKey = switch (_currentStep) {
      0 => _step1FormKey,
      1 => _step2FormKey,
      2 => _step3FormKey,
      _ => _step4FormKey,
    };
    return formKey.currentState?.validate() ?? false;
  }

  // ── Submit — creates the Supabase account, persists profile fields. ────────

  Future<void> _submit() async {
    if (!_validateCurrentStep()) return;

    final messenger = ScaffoldMessenger.of(context);

    await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
        );

    if (!mounted) return;

    final state = ref.read(authNotifierProvider);
    if (state.hasError) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(state.error.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Persist auxiliary profile fields via SharedPreferences so a
    // subsequent profile-update call can pick them up.
    final storage = ref.read(localStorageServiceProvider);
    if (_role != null) {
      await storage.setString(
        key: LocalStorageKeys.userRole,
        value: _role!.name,
      );
    }
    await storage.setString(
      key: _kProfileDraftKey,
      value: _serializeDraft(),
    );

    if (!mounted) return;
    context.go(RouteNames.dashboard);
  }

  String _serializeDraft() {
    return [
      if (_phoneController.text.trim().isNotEmpty)
        'phone=${_phoneController.text.trim()}',
      if (_bioController.text.trim().isNotEmpty)
        'bio=${_bioController.text.trim()}',
      if (_churchNameController.text.trim().isNotEmpty)
        'church=${_churchNameController.text.trim()}',
      if (_denomination.isNotEmpty) 'denomination=$_denomination',
      if (_hasAcceptedCovenant) 'covenant=true',
      'lang=$_language',
      'theme=$_theme',
      'push=$_pushNotifications',
      'digest=$_emailDigest',
      'eventReminders=$_eventReminders',
    ].join('&');
  }

  Future<void> _signInWithGoogle() async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.hasError) {
      messenger.showSnackBar(
        SnackBar(content: Text(state.error.toString())),
      );
    }
  }

  Future<void> _signInWithApple() async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(authNotifierProvider.notifier).signInWithApple();
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.hasError) {
      messenger.showSnackBar(
        SnackBar(content: Text(state.error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final mq = MediaQuery.of(context);

    // Logo size is responsive (same clamp pattern as splash + login).
    final logoSize = (mq.size.shortestSide * 0.13).clamp(44.0, 64.0);

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
            const Positioned.fill(child: _RegisterBackground()),
            SafeArea(
              child: Column(
                children: [
                  _RegisterHeader(
                    logoSize: logoSize,
                    currentStep: _currentStep,
                    totalSteps: _steps.length,
                    stepMeta: _steps[_currentStep],
                    onClose: () => context.go(RouteNames.login),
                    onBack: _currentStep > 0 ? _back : null,
                  ),
                  _StepProgressIndicator(
                    currentStep: _currentStep,
                    totalSteps: _steps.length,
                    activeColor: AppColors.gold,
                    inactiveColor: Colors.white.withValues(alpha: 0.15),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) {
                        if (!mounted) return;
                        setState(() => _currentStep = i);
                      },
                      children: [
                        _StepAccount(
                          formKey: _step1FormKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmController: _confirmController,
                          obscurePassword: _obscurePassword,
                          obscureConfirm: _obscureConfirm,
                          onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          onToggleConfirm: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          reduceMotion: reduceMotion,
                        ),
                        _StepPersonal(
                          formKey: _step2FormKey,
                          fullNameController: _fullNameController,
                          phoneController: _phoneController,
                          bioController: _bioController,
                          reduceMotion: reduceMotion,
                        ),
                        _StepChurch(
                          formKey: _step3FormKey,
                          role: _role,
                          churchNameController: _churchNameController,
                          denomination: _denomination,
                          denominations: _denominations,
                          hasAcceptedCovenant: _hasAcceptedCovenant,
                          onRoleChanged: (r) => setState(() => _role = r),
                          onDenominationChanged: (d) =>
                              setState(() => _denomination = d ?? ''),
                          onCovenantChanged: (v) => setState(
                            () => _hasAcceptedCovenant = v ?? false,
                          ),
                          reduceMotion: reduceMotion,
                        ),
                        _StepPreferences(
                          formKey: _step4FormKey,
                          pushNotifications: _pushNotifications,
                          emailDigest: _emailDigest,
                          eventReminders: _eventReminders,
                          language: _language,
                          languages: _languages,
                          theme: _theme,
                          themes: _themes,
                          onPushChanged: (v) => setState(
                            () => _pushNotifications = v ?? false,
                          ),
                          onDigestChanged: (v) => setState(
                            () => _emailDigest = v ?? false,
                          ),
                          onEventRemindersChanged: (v) => setState(
                            () => _eventReminders = v ?? false,
                          ),
                          onLanguageChanged: (v) =>
                              setState(() => _language = v ?? 'English'),
                          onThemeChanged: (v) =>
                              setState(() => _theme = v ?? 'Royal Dark'),
                          onSocialGoogle: _signInWithGoogle,
                          onSocialApple: _signInWithApple,
                          reduceMotion: reduceMotion,
                        ),
                      ],
                    ),
                  ),
                  _StepFooter(
                    currentStep: _currentStep,
                    isLoading: isLoading,
                    isLastStep: _currentStep == _steps.length - 1,
                    onBack: _back,
                    onNext: _next,
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

/// Storage key for the serialized profile draft applied post-signup.
const String _kProfileDraftKey = 'registration_profile_draft';

@immutable
class _StepMeta {
  const _StepMeta({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
}

// ─────────────────────────────────────────────────────────────────────────────
// Background — navy gradient + soft gold glow blobs
// ─────────────────────────────────────────────────────────────────────────────

class _RegisterBackground extends StatelessWidget {
  const _RegisterBackground();

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: Stack(
        children: [
          Positioned.fill(child: _BaseGradient()),
          Positioned.fill(child: _MeshGlow()),
        ],
      ),
    );
  }
}

class _BaseGradient extends StatelessWidget {
  const _BaseGradient();

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
          center: Offset(size.width * 0.15, size.height * 0.18),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.18),
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
          center: Offset(size.width * 0.85, size.height * 0.92),
          radius: size.width * 0.5,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.92),
      size.width * 0.5,
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — logo, app name, current step meta
// ─────────────────────────────────────────────────────────────────────────────

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader({
    required this.logoSize,
    required this.currentStep,
    required this.totalSteps,
    required this.stepMeta,
    required this.onClose,
    required this.onBack,
  });

  final double logoSize;
  final int currentStep;
  final int totalSteps;
  final _StepMeta stepMeta;
  final VoidCallback onClose;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _HeaderIconButton(
                icon: onBack != null
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.close_rounded,
                semanticLabel:
                    onBack != null ? 'Previous step' : 'Close registration',
                onTap: onBack ?? onClose,
              ),
              const Spacer(),
              Expanded(
                child: Center(child: _BrandWordmark(logoSize: logoSize)),
              ),
              const Spacer(),
              _StepCounterBadge(
                current: currentStep + 1,
                total: totalSteps,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(
            duration: AppMotion.emphasized,
            switchInCurve: AppMotion.decelerate,
            switchOutCurve: AppMotion.accelerate,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Column(
              key: ValueKey(currentStep),
              children: [
                _GoldEyebrow(text: stepMeta.eyebrow),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  stepMeta.title,
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    color: AppColors.warmWhite,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Text(
                    stepMeta.subtitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.65),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark({required this.logoSize});

  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: 'Kingdom Heirs logo',
          image: true,
          child: Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.warmWhite,
              boxShadow: AppElevation.shadowFor(AppElevation.level3),
            ),
            padding: EdgeInsets.all(logoSize * 0.12),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.jpeg',
                fit: BoxFit.contain,
                semanticLabel: 'Kingdom Heirs',
                errorBuilder: (_, __, ___) => _LogoFallback(size: logoSize),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'KINGDOM HEIRS',
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.warmWhite,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
              Text(
                'Inheriting Excellence',
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.goldLight,
                  fontStyle: FontStyle.italic,
                  fontSize: 9,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'KH',
        style: TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.36,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Material(
        color: Colors.white.withValues(alpha: 0.06),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: AppSpacing.iconLg + AppSpacing.sm,
            height: AppSpacing.iconLg + AppSpacing.sm,
            child: Icon(
              icon,
              size: AppSpacing.iconSm,
              color: AppColors.warmWhite,
            ),
          ),
        ),
      ),
    );
  }
}

class _StepCounterBadge extends StatelessWidget {
  const _StepCounterBadge({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step $current of $total',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.15),
          borderRadius: AppRadius.brFull,
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
        child: Text(
          '$current / $total',
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.goldLight,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class _GoldEyebrow extends StatelessWidget {
  const _GoldEyebrow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSpacing.sm,
          height: 1,
          color: AppColors.gold.withValues(alpha: 0.6),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text.toUpperCase(),
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.gold,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          width: AppSpacing.sm,
          height: 1,
          color: AppColors.gold.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress indicator — connected dots + thin progress bar
// ─────────────────────────────────────────────────────────────────────────────

class _StepProgressIndicator extends StatelessWidget {
  const _StepProgressIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / totalSteps;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Semantics(
        label: 'Step ${currentStep + 1} of $totalSteps',
        value: '${(progress * 100).round()} percent complete',
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalSteps, (i) {
                final isActive = i <= currentStep;
                final isCurrent = i == currentStep;
                return AnimatedContainer(
                  duration: AppMotion.standard,
                  curve: AppMotion.decelerate,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                  ),
                  width: isCurrent ? AppSpacing.xl : AppSpacing.sm,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: isActive ? activeColor : inactiveColor,
                    borderRadius: AppRadius.brFull,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.4),
                              blurRadius: AppSpacing.sm,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: AppRadius.brFull,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                backgroundColor: inactiveColor,
                valueColor: AlwaysStoppedAnimation<Color>(activeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer — back button + primary CTA (Continue / Create Account)
// ─────────────────────────────────────────────────────────────────────────────

class _StepFooter extends StatelessWidget {
  const _StepFooter({
    required this.currentStep,
    required this.isLoading,
    required this.isLastStep,
    required this.onBack,
    required this.onNext,
  });

  final int currentStep;
  final bool isLoading;
  final bool isLastStep;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final ctaLabel = isLastStep ? 'Create Account' : 'Continue';
    final showBack = currentStep > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.navy.withValues(alpha: 0),
            AppColors.navy.withValues(alpha: 0.6),
            AppColors.navy,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Row(
        children: [
          if (showBack) ...[
            Expanded(
              flex: 2,
              child: _GhostButton(label: 'Back', onTap: onBack),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            flex: 5,
            child: _PrimaryCtaButton(
              label: ctaLabel,
              isLoading: isLoading,
              onPressed: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        height: AppSpacing.buttonHeight,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.warmWhite,
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.2),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.brFull,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryCtaButton extends StatelessWidget {
  const _PrimaryCtaButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        height: AppSpacing.buttonHeight,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.ink,
            elevation: 0,
            shadowColor: AppColors.gold.withValues(alpha: 0.4),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.brFull,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.ink),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    if (!isLoading) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppColors.ink,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form Card — glassy container shared across steps
// ─────────────────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.brXl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.55),
            borderRadius: AppRadius.brXl,
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.12),
            ),
            boxShadow: AppElevation.shadowFor(AppElevation.level3),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Field primitives — label + input with consistent gold-accent focus state
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, this.optional = false});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text.toUpperCase(),
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.gold.withValues(alpha: 0.85),
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '(optional)',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.autofillHints,
    this.validator,
    // ignore: unused_element_parameter
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      autofillHints: autofillHints,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.warmWhite,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.3),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: Colors.white.withValues(alpha: 0.4),
                size: AppSpacing.iconSm + 2,
              )
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(
            color: AppColors.gold,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(
            color: AppColors.error.withValues(alpha: 0.8),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(
            color: AppColors.error.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        errorStyle: TextStyle(
          color: AppColors.error.withValues(alpha: 0.9),
          fontSize: 11,
        ),
      ),
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
      button: true,
      label: obscure ? 'Show password' : 'Hide password',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.white.withValues(alpha: 0.5),
            size: AppSpacing.iconSm + 2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1 — Account (email + password + confirm)
// ─────────────────────────────────────────────────────────────────────────────

class _StepAccount extends StatelessWidget {
  const _StepAccount({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.reduceMotion,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Form(
        key: formKey,
        child: _FormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel(text: 'Email'),
              const SizedBox(height: AppSpacing.xs),
              _AuthTextField(
                controller: emailController,
                hint: 'steward@kingdom.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Email is required';
                  }
                  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!regex.hasMatch(v.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              const _FieldLabel(text: 'Password'),
              const SizedBox(height: AppSpacing.xs),
              _AuthTextField(
                controller: passwordController,
                hint: 'At least 8 characters',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                suffixIcon: _PasswordVisibilityToggle(
                  obscure: obscurePassword,
                  onTap: onTogglePassword,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 8) return 'Use at least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              const _FieldLabel(text: 'Confirm Password'),
              const SizedBox(height: AppSpacing.xs),
              _AuthTextField(
                controller: confirmController,
                hint: 'Repeat your password',
                prefixIcon: Icons.verified_user_outlined,
                obscureText: obscureConfirm,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                suffixIcon: _PasswordVisibilityToggle(
                  obscure: obscureConfirm,
                  onTap: onToggleConfirm,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (v != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: AppColors.gold.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Encrypted · stewarded by Kingdom Heirs',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return reduceMotion
        ? body
        : body.animate().fadeIn(duration: AppMotion.standard);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2 — Personal Information (full name, phone, bio)
// ─────────────────────────────────────────────────────────────────────────────

class _StepPersonal extends StatelessWidget {
  const _StepPersonal({
    required this.formKey,
    required this.fullNameController,
    required this.phoneController,
    required this.bioController,
    required this.reduceMotion,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController bioController;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Form(
        key: formKey,
        child: _FormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel(text: 'Full Name'),
              const SizedBox(height: AppSpacing.xs),
              _AuthTextField(
                controller: fullNameController,
                hint: 'John Doe',
                prefixIcon: Icons.badge_outlined,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              const _FieldLabel(text: 'Phone', optional: true),
              const SizedBox(height: AppSpacing.xs),
              _AuthTextField(
                controller: phoneController,
                hint: '+256 700 000 000',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final digits = v.replaceAll(RegExp('[^0-9]'), '');
                  if (digits.length < 7) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              const _FieldLabel(text: 'Bio', optional: true),
              const SizedBox(height: AppSpacing.xs),
              _AuthTextField(
                controller: bioController,
                hint: 'A short note about your walk with God…',
                prefixIcon: Icons.edit_note_rounded,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
            ],
          ),
        ),
      ),
    );

    return reduceMotion
        ? body
        : body.animate().fadeIn(duration: AppMotion.standard);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3 — Church Connection (role + church + denomination + covenant)
// ─────────────────────────────────────────────────────────────────────────────

class _StepChurch extends StatelessWidget {
  const _StepChurch({
    required this.formKey,
    required this.role,
    required this.churchNameController,
    required this.denomination,
    required this.denominations,
    required this.hasAcceptedCovenant,
    required this.onRoleChanged,
    required this.onDenominationChanged,
    required this.onCovenantChanged,
    required this.reduceMotion,
  });

  final GlobalKey<FormState> formKey;
  final UserRole? role;
  final TextEditingController churchNameController;
  final String denomination;
  final List<String> denominations;
  final bool hasAcceptedCovenant;
  final ValueChanged<UserRole?> onRoleChanged;
  final ValueChanged<String?> onDenominationChanged;
  final ValueChanged<bool?> onCovenantChanged;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(text: 'How are you joining us?'),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Choose the role that best reflects your stewardship.',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: UserRole.values.map((r) {
                      final selected = r == role;
                      return _RoleChip(
                        label: r.displayName,
                        icon: _iconForRole(r),
                        selected: selected,
                        onTap: () => onRoleChanged(r),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(text: 'Church Name', optional: true),
                  const SizedBox(height: AppSpacing.xs),
                  _AuthTextField(
                    controller: churchNameController,
                    hint: 'e.g. Upper Room Chapel',
                    prefixIcon: Icons.church_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _FieldLabel(text: 'Denomination', optional: true),
                  const SizedBox(height: AppSpacing.xs),
                  _DenominationDropdown(
                    value: denomination.isEmpty ? null : denomination,
                    items: denominations,
                    onChanged: onDenominationChanged,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  InkWell(
                    borderRadius: AppRadius.brMd,
                    onTap: () => onCovenantChanged(!hasAcceptedCovenant),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: AppSpacing.iconMd,
                            height: AppSpacing.iconMd,
                            child: Checkbox(
                              value: hasAcceptedCovenant,
                              onChanged: onCovenantChanged,
                              activeColor: AppColors.gold,
                              checkColor: AppColors.ink,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1.2,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadius.brXs,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'I have read and embrace the Kingdom Heirs '
                              'covenant of stewardship.',
                              style:
                                  AppTypography.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return reduceMotion
        ? body
        : body.animate().fadeIn(duration: AppMotion.standard);
  }

  IconData _iconForRole(UserRole r) => switch (r) {
        UserRole.member => Icons.person_rounded,
        UserRole.groupLeader => Icons.group_rounded,
        UserRole.volunteer => Icons.volunteer_activism_rounded,
        UserRole.pastor => Icons.menu_book_rounded,
        UserRole.admin => Icons.admin_panel_settings_rounded,
      };
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brFull,
          child: AnimatedContainer(
            duration: AppMotion.standard,
            curve: AppMotion.decelerate,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.gold
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: AppRadius.brFull,
              border: Border.all(
                color: selected
                    ? AppColors.gold
                    : Colors.white.withValues(alpha: 0.18),
              ),
              boxShadow: selected ? AppElevation.shadowGold : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: selected ? AppColors.ink : AppColors.goldLight,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: selected ? AppColors.ink : AppColors.warmWhite,
                    fontWeight: FontWeight.w600,
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

class _DenominationDropdown extends StatelessWidget {
  const _DenominationDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            'Select your denomination',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          icon: Icon(
            Icons.expand_more_rounded,
            color: AppColors.gold.withValues(alpha: 0.8),
          ),
          dropdownColor: AppColors.navyMid,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.warmWhite,
          ),
          items: items
              .map(
                (d) => DropdownMenuItem<String>(
                  value: d,
                  child: Text(d),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4 — Preferences (notifications + language + theme + social alt)
// ─────────────────────────────────────────────────────────────────────────────

class _StepPreferences extends StatelessWidget {
  const _StepPreferences({
    required this.formKey,
    required this.pushNotifications,
    required this.emailDigest,
    required this.eventReminders,
    required this.language,
    required this.languages,
    required this.theme,
    required this.themes,
    required this.onPushChanged,
    required this.onDigestChanged,
    required this.onEventRemindersChanged,
    required this.onLanguageChanged,
    required this.onThemeChanged,
    required this.onSocialGoogle,
    required this.onSocialApple,
    required this.reduceMotion,
  });

  final GlobalKey<FormState> formKey;
  final bool pushNotifications;
  final bool emailDigest;
  final bool eventReminders;
  final String language;
  final List<String> languages;
  final String theme;
  final List<String> themes;
  final ValueChanged<bool?> onPushChanged;
  final ValueChanged<bool?> onDigestChanged;
  final ValueChanged<bool?> onEventRemindersChanged;
  final ValueChanged<String?> onLanguageChanged;
  final ValueChanged<String?> onThemeChanged;
  final VoidCallback onSocialGoogle;
  final VoidCallback onSocialApple;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(text: 'Notifications'),
                  const SizedBox(height: AppSpacing.sm),
                  _SwitchRow(
                    icon: Icons.notifications_active_outlined,
                    title: 'Push notifications',
                    subtitle: 'Receive real-time alerts and prayer prompts',
                    value: pushNotifications,
                    onChanged: onPushChanged,
                  ),
                  const _ThinDivider(),
                  _SwitchRow(
                    icon: Icons.email_outlined,
                    title: 'Weekly email digest',
                    subtitle: 'A curated summary of sermons and devotionals',
                    value: emailDigest,
                    onChanged: onDigestChanged,
                  ),
                  const _ThinDivider(),
                  _SwitchRow(
                    icon: Icons.event_outlined,
                    title: 'Event reminders',
                    subtitle: 'Get notified before services and gatherings',
                    value: eventReminders,
                    onChanged: onEventRemindersChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(text: 'Language'),
                  const SizedBox(height: AppSpacing.xs),
                  _PrefDropdown<String>(
                    value: language,
                    items: languages,
                    icon: Icons.language_rounded,
                    onChanged: onLanguageChanged,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _FieldLabel(text: 'Theme'),
                  const SizedBox(height: AppSpacing.xs),
                  _PrefDropdown<String>(
                    value: theme,
                    items: themes,
                    icon: Icons.palette_outlined,
                    onChanged: onThemeChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(text: 'Or sign up faster'),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Use your existing account to skip the form.',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          label: 'Google',
                          icon: const _GoogleIcon(),
                          onTap: onSocialGoogle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _SocialButton(
                          label: 'Apple',
                          icon: const Icon(
                            Icons.apple_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onTap: onSocialApple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xxs,
                children: [
                  Text(
                    'Already have an account?',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(RouteNames.login),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sign In',
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return reduceMotion
        ? body
        : body.animate().fadeIn(duration: AppMotion.standard);
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: AppSpacing.iconMd,
            height: AppSpacing.iconMd,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 14,
              color: AppColors.goldLight,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.warmWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.gold,
            activeTrackColor: AppColors.gold.withValues(alpha: 0.45),
            inactiveThumbColor: Colors.white.withValues(alpha: 0.7),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}

class _PrefDropdown<T> extends StatelessWidget {
  const _PrefDropdown({
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final IconData icon;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.expand_more_rounded,
            color: AppColors.gold.withValues(alpha: 0.8),
          ),
          dropdownColor: AppColors.navyMid,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.warmWhite,
          ),
          items: items
              .map(
                (v) => DropdownMenuItem<T>(
                  value: v,
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: AppColors.gold.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(child: Text(v.toString())),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue with $label',
      child: SizedBox(
        height: AppSpacing.buttonHeightSm,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.04),
            foregroundColor: Colors.white,
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.18),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.brFull,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFEA4335), width: 1.5),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFFEA4335),
            height: 1,
          ),
        ),
      ),
    );
  }
}
