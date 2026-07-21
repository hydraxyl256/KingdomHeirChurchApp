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

/// Kingdom Heirs — Premium Role Selection
///
/// A focused, premium post-registration screen that frames role choice as
/// stewardship rather than a form field. The screen pairs a soft cinematic
/// background with five interactive role cards. Each card explains the
/// concrete benefits of the role, shows iconography, and animates into a
/// selected state on tap.
///
///   • Visual language matches the Splash / Start-Here / Login / Register
///     redesigns (deep navy + royal gold, glass cards, official logo).
///   • Roles are sourced from [UserRole] so any future enum value will
///     automatically appear once its [_RoleMeta] entry is added.
///   • Selection is persisted via [LocalStorageKeys.userRole] so the
///     existing router redirect at `RouteNames.dashboard` continues to work.
class UserRoleSelectionScreen extends ConsumerStatefulWidget {
  const UserRoleSelectionScreen({super.key});

  @override
  ConsumerState<UserRoleSelectionScreen> createState() =>
      _UserRoleSelectionScreenState();
}

class _UserRoleSelectionScreenState
    extends ConsumerState<UserRoleSelectionScreen> {
  /// Currently-selected role (null = no selection yet).
  UserRole? _selected;

  /// True after the user confirms their choice — used to gate the Continue
  /// button and trigger the celebratory micro-animation.
  bool _isConfirming = false;

  // ─────────────────────────────────────────────────────────────────────────
  // Role metadata (icon, tagline, benefits, gradient stops).
  // Kept inside the screen file so design changes ship without touching the
  // domain layer.
  // ─────────────────────────────────────────────────────────────────────────

  static final Map<UserRole, _RoleMeta> _roleMeta = {
    UserRole.member: const _RoleMeta(
      icon: Icons.person_outline_rounded,
      tagline: 'Walk in the community of believers.',
      benefits: [
        'Daily devotionals and curated sermon library',
        'Live service access and prayer wall',
        'Connect with small groups near you',
      ],
    ),
    UserRole.volunteer: const _RoleMeta(
      icon: Icons.volunteer_activism_outlined,
      tagline: 'Lend your gifts to serve the house.',
      benefits: [
        'Browse ministry and serve-team openings',
        'Track your hours and steward milestones',
        'Receive prayer prompts for your team',
      ],
    ),
    UserRole.groupLeader: const _RoleMeta(
      icon: Icons.groups_2_outlined,
      tagline: 'Shepherd a small group with excellence.',
      benefits: [
        'Lead and curate a Kingdom group',
        'Member insights and attendance tools',
        'Curated discussion guides and devotionals',
      ],
    ),
    UserRole.pastor: const _RoleMeta(
      icon: Icons.menu_book_outlined,
      tagline: 'Teach the Word with reverence and clarity.',
      benefits: [
        'Publish sermons, devotionals and notes',
        'Moderate testimonies and prayer feed',
        'Reach congregants with push and email',
      ],
    ),
    UserRole.admin: const _RoleMeta(
      icon: Icons.shield_outlined,
      tagline: 'Steward the Kingdom operating system.',
      benefits: [
        'Manage members, roles and permissions',
        'Curate content, events and announcements',
        'Operational dashboards and analytics',
      ],
    ),
  };

  /// Order matters — the same order is used to render the list.
  static const List<UserRole> _orderedRoles = [
    UserRole.member,
    UserRole.volunteer,
    UserRole.groupLeader,
    UserRole.pastor,
    UserRole.admin,
  ];

  Future<void> _confirm() async {
    final role = _selected;
    if (role == null || _isConfirming) return;

    setState(() => _isConfirming = true);

    // Brief celebratory beat before navigating so the selection animation
    // reads rather than getting clipped.
    await Future<void>.delayed(const Duration(milliseconds: 380));

    if (!mounted) return;
    await ref.read(localStorageServiceProvider).setString(
          key: LocalStorageKeys.userRole,
          value: role.name,
        );
    
    try {
      await ref.read(authRemoteDataSourceProvider).updateProfile({'role': role.name});
    } catch (_) {
      // Fallback to local storage if RLS blocks update
    }

    if (!mounted) return;
    context.go(RouteNames.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final reduceMotion = mq.disableAnimations;
    final isWide = mq.size.shortestSide >= 720;

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
            const Positioned.fill(child: _RoleSelectionBackground()),
            SafeArea(
              child: Column(
                children: [
                  // ── Header ───────────────────────────────────────────────
                  _Header(
                    onBack: () => context.go(RouteNames.dashboard),
                    reduceMotion: reduceMotion,
                  ),

                  // ── Title block ─────────────────────────────────────────
                  _TitleBlock(reduceMotion: reduceMotion),

                  // ── Role cards ──────────────────────────────────────────
                  Expanded(
                    child: isWide
                        ? _WideGrid(
                            roles: _orderedRoles,
                            meta: _roleMeta,
                            selected: _selected,
                            onSelect: _handleSelect,
                            reduceMotion: reduceMotion,
                          )
                        : _NarrowList(
                            roles: _orderedRoles,
                            meta: _roleMeta,
                            selected: _selected,
                            onSelect: _handleSelect,
                            reduceMotion: reduceMotion,
                          ),
                  ),

                  // ── Footer with Continue CTA ────────────────────────────
                  _Footer(
                    selected: _selected,
                    meta: _roleMeta,
                    isConfirming: _isConfirming,
                    onConfirm: _confirm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSelect(UserRole role) {
    if (_isConfirming) return;
    setState(() => _selected = role);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RoleMeta — UI-only metadata per role
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class _RoleMeta {
  const _RoleMeta({
    required this.icon,
    required this.tagline,
    required this.benefits,
  });

  final IconData icon;
  final String tagline;
  final List<String> benefits;
}

// ─────────────────────────────────────────────────────────────────────────────
// Background — navy gradient + soft gold glow blobs
// ─────────────────────────────────────────────────────────────────────────────

class _RoleSelectionBackground extends StatelessWidget {
  const _RoleSelectionBackground();

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: Stack(
        children: [
          Positioned.fill(child: _BaseGradient()),
          Positioned.fill(child: _MeshGlow()),
          Positioned.fill(child: _LightSweep()),
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
    // Top-left warm gold
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

    // Bottom-right cool glow
    final paint2 = Paint()
      ..blendMode = BlendMode.screen
      ..shader = RadialGradient(
        colors: [
          AppColors.navyAccent.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.85, size.height * 0.92),
          radius: size.width * 0.55,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.92),
      size.width * 0.55,
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LightSweep extends StatelessWidget {
  const _LightSweep();

  @override
  Widget build(BuildContext context) {
    // Soft radial highlight behind the headline so the typography reads with
    // a subtle "candle on gold" feel.
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.65),
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.gold.withValues(alpha: 0.06),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — back button + brand wordmark with logo
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.reduceMotion});

  final VoidCallback onBack;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final logoSize = (mq.size.shortestSide * 0.11).clamp(40.0, 56.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Semantics(
            label: 'Back to dashboard',
            button: true,
            child: Material(
              color: Colors.white.withValues(alpha: 0.06),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onBack,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: AppSpacing.iconLg + AppSpacing.sm,
                  height: AppSpacing.iconLg + AppSpacing.sm,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: AppSpacing.iconSm,
                    color: AppColors.warmWhite,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Flexible(
            child: _BrandWordmark(logoSize: logoSize),
          ),
          const Spacer(),
          const SizedBox(
            width: AppSpacing.iconLg + AppSpacing.sm,
            height: AppSpacing.iconLg + AppSpacing.sm,
          ),
        ],
      ),
    ).animate(target: reduceMotion ? 1 : 0).fadeIn(
          duration: AppMotion.standard,
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
            child: ClipOval(
              child: Image.asset(
                'assets/images/app_icon.png',
                fit: BoxFit.cover,
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

// ─────────────────────────────────────────────────────────────────────────────
// Title block — eyebrow, headline, supporting copy
// ─────────────────────────────────────────────────────────────────────────────

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.reduceMotion});

  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          const _GoldEyebrow(text: 'One last step'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'How are you joining us?',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
            ),
            child: Text(
              'Choose the role that best reflects your stewardship — '
              'you can refine this anytime from your profile.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.65),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate(target: reduceMotion ? 1 : 0).fadeIn(
          delay: AppMotion.quick,
          duration: AppMotion.emphasized,
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
// Narrow layout — vertical list of role cards
// ─────────────────────────────────────────────────────────────────────────────

class _NarrowList extends StatelessWidget {
  const _NarrowList({
    required this.roles,
    required this.meta,
    required this.selected,
    required this.onSelect,
    required this.reduceMotion,
  });

  final List<UserRole> roles;
  final Map<UserRole, _RoleMeta> meta;
  final UserRole? selected;
  final ValueChanged<UserRole> onSelect;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      itemCount: roles.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final role = roles[i];
        final entry = meta[role]!;
        final isSelected = role == selected;

        final card = _RoleCard(
          role: role,
          meta: entry,
          isSelected: isSelected,
          onTap: () => onSelect(role),
        );

        if (reduceMotion) return card;

        // Staggered entrance — first card leads, others cascade in.
        return card
            .animate()
            .fadeIn(
              delay: Duration(
                milliseconds: 220 + (i * 80),
              ),
              duration: AppMotion.emphasized,
            )
            .slideY(
              begin: 0.15,
              end: 0,
              duration: AppMotion.emphasized,
              curve: AppMotion.decelerate,
            );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wide layout — 2-column grid for tablet / foldable
// ─────────────────────────────────────────────────────────────────────────────

class _WideGrid extends StatelessWidget {
  const _WideGrid({
    required this.roles,
    required this.meta,
    required this.selected,
    required this.onSelect,
    required this.reduceMotion,
  });

  final List<UserRole> roles;
  final Map<UserRole, _RoleMeta> meta;
  final UserRole? selected;
  final ValueChanged<UserRole> onSelect;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.55,
      ),
      itemCount: roles.length,
      itemBuilder: (context, i) {
        final role = roles[i];
        final entry = meta[role]!;
        final isSelected = role == selected;

        final card = _RoleCard(
          role: role,
          meta: entry,
          isSelected: isSelected,
          onTap: () => onSelect(role),
        );

        if (reduceMotion) return card;

        return card
            .animate()
            .fadeIn(
              delay: Duration(
                milliseconds: 220 + (i * 70),
              ),
              duration: AppMotion.emphasized,
            )
            .slideY(
              begin: 0.12,
              end: 0,
              duration: AppMotion.emphasized,
              curve: AppMotion.decelerate,
            );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role card — primary interactive element
// ─────────────────────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.meta,
    required this.isSelected,
    required this.onTap,
  });

  final UserRole role;
  final _RoleMeta meta;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${role.displayName}. ${meta.tagline}',
      child: AnimatedScale(
        scale: isSelected ? 1.015 : 1.0,
        duration: AppMotion.standard,
        curve: AppMotion.overshoot,
        child: AnimatedContainer(
          duration: AppMotion.standard,
          curve: AppMotion.decelerate,
          decoration: BoxDecoration(
            borderRadius: AppRadius.brXl,
            border: Border.all(
              color: isSelected
                  ? AppColors.gold
                  : Colors.white.withValues(alpha: 0.10),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? AppElevation.shadowGold
                : AppElevation.shadowFor(AppElevation.level2),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.brXl,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AnimatedContainer(
                duration: AppMotion.standard,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.brXl,
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            Color(0xFFD4AF37),
                            Color(0xFFA88B1D),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            const Color(0xFF1E293B).withValues(alpha: 0.78),
                            const Color(0xFF1E293B).withValues(alpha: 0.55),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    splashColor: AppColors.gold.withValues(alpha: 0.18),
                    highlightColor: AppColors.gold.withValues(alpha: 0.08),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: _RoleCardBody(
                        role: role,
                        meta: meta,
                        isSelected: isSelected,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCardBody extends StatelessWidget {
  const _RoleCardBody({
    required this.role,
    required this.meta,
    required this.isSelected,
  });

  final UserRole role;
  final _RoleMeta meta;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final accent = isSelected ? AppColors.ink : AppColors.goldLight;
    final titleColor = isSelected ? AppColors.ink : AppColors.warmWhite;
    final bodyColor = isSelected
        ? AppColors.ink.withValues(alpha: 0.78)
        : Colors.white.withValues(alpha: 0.7);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Icon medallion ───────────────────────────────────────
        _IconMedallion(icon: meta.icon, isSelected: isSelected),
        const SizedBox(width: AppSpacing.md),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Title row ───────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: AppMotion.standard,
                      style: AppTypography.textTheme.titleMedium!.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      child: Text(role.displayName),
                    ),
                  ),
                  _SelectionIndicator(isSelected: isSelected),
                ],
              ),

              const SizedBox(height: AppSpacing.xxs),

              // ── Tagline ─────────────────────────────────────────
              Text(
                meta.tagline,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: bodyColor,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // ── Benefits (visible on selection or always for wide) ─
              AnimatedSize(
                duration: AppMotion.emphasized,
                curve: AppMotion.decelerate,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: AppMotion.standard,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axisAlignment: -1,
                        child: child,
                      ),
                    );
                  },
                  child: isSelected
                      ? Padding(
                          key: ValueKey('benefits-${role.name}'),
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: meta.benefits.map((b) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.xxs,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4,
                                      ),
                                      child: Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: accent,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Expanded(
                                      child: Text(
                                        b,
                                        style: AppTypography
                                            .textTheme.labelSmall
                                            ?.copyWith(
                                          color: bodyColor,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconMedallion extends StatelessWidget {
  const _IconMedallion({required this.icon, required this.isSelected});

  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.standard,
      curve: AppMotion.decelerate,
      width: AppSpacing.avatarMd,
      height: AppSpacing.avatarMd,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isSelected
            ? const LinearGradient(
                colors: [AppColors.ink, Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [AppColors.gold, AppColors.goldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: (isSelected ? AppColors.ink : AppColors.gold)
                .withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: AppSpacing.iconMd,
        color: isSelected ? AppColors.goldLight : AppColors.ink,
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.standard,
      curve: AppMotion.overshoot,
      width: AppSpacing.iconMd,
      height: AppSpacing.iconMd,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.ink : Colors.transparent,
        border: Border.all(
          color:
              isSelected ? AppColors.ink : Colors.white.withValues(alpha: 0.4),
          width: 1.4,
        ),
      ),
      child: AnimatedOpacity(
        duration: AppMotion.standard,
        opacity: isSelected ? 1 : 0,
        child: const Icon(
          Icons.check_rounded,
          size: AppSpacing.iconSm,
          color: AppColors.gold,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer — Continue CTA + role preview chip
// ─────────────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({
    required this.selected,
    required this.meta,
    required this.isConfirming,
    required this.onConfirm,
  });

  final UserRole? selected;
  final Map<UserRole, _RoleMeta> meta;
  final bool isConfirming;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selected != null;
    final mq = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md + mq.viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.navy.withValues(alpha: 0),
            AppColors.navy.withValues(alpha: 0.85),
            AppColors.navy,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Selection preview chip ────────────────────────────────
          AnimatedSwitcher(
            duration: AppMotion.standard,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
              );
            },
            child: hasSelection
                ? Padding(
                    key: ValueKey(selected!.name),
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _RolePreviewChip(role: selected!),
                  )
                : const SizedBox.shrink(key: ValueKey('none')),
          ),

          // ── Continue CTA ─────────────────────────────────────────
          SizedBox(
            height: AppSpacing.buttonHeight,
            width: double.infinity,
            child: AnimatedOpacity(
              duration: AppMotion.standard,
              opacity: hasSelection ? 1 : 0.55,
              child: ElevatedButton(
                onPressed: hasSelection && !isConfirming ? onConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.ink,
                  disabledBackgroundColor:
                      AppColors.gold.withValues(alpha: 0.35),
                  disabledForegroundColor: AppColors.ink.withValues(alpha: 0.5),
                  elevation: 0,
                  shadowColor: AppColors.gold.withValues(alpha: 0.4),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.brFull,
                  ),
                ),
                child: isConfirming
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.ink,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            meta[selected ?? UserRole.member]!.icon,
                            size: 18,
                            color: AppColors.ink,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              hasSelection
                                  ? 'Continue as ${selected!.displayName}'
                                  : 'Select a role to continue',
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTypography.textTheme.labelLarge?.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: AppColors.ink,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RolePreviewChip extends StatelessWidget {
  const _RolePreviewChip({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.10),
        borderRadius: AppRadius.brFull,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              'Selected · ${role.displayName}',
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.goldLight,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
