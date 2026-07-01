// Kingdom Heir — Plan Your Visit
//
// Reached from Start Here → "Join Us This Sunday". A single, premium
// scrollable page that gives a first-time visitor everything they need
// to find the church, see service times, get directions, watch live,
// contact the office, and submit a prayer request.
//
// Content values are placeholders pending real church data — see the
// `// TODO(content)` markers below.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/iconography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/core/widgets/app_card.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TODO(content): Replace these placeholders with the real Kingdom Heirs
// Foundation contact details before Play Store release.
// ─────────────────────────────────────────────────────────────────────────────
const String _kAddressLine1 = '123 Kingdom Avenue';
const String _kAddressLine2 = 'Lusaka, Zambia';
const String _kMapsQuery = 'Kingdom Heirs Foundation, Lusaka';
const String _kContactEmail = 'info@kingdomheirs.app';
const String _kContactPhone = '+260 977 000 000';
const String _kWhatsAppNumber = '15555550100'; // E.164, no `+`
const String _kWebsite = 'https://kingdomheirsfoundation.com';
const String _kLiveStreamUrl = 'https://www.youtube.com/@kingdomheirs';
const String _kWatchLiveLabel = 'Watch on YouTube';

class PlanYourVisitScreen extends StatelessWidget {
  const PlanYourVisitScreen({super.key});

  // ── Service times ─────────────────────────────────────────────────────
  static const List<_ServiceTime> _serviceTimes = <_ServiceTime>[
    _ServiceTime(
      day: 'Sunday',
      time: '9:00 AM',
      label: 'Worship Service',
      note: 'In-person & Online',
    ),
    _ServiceTime(
      day: 'Wednesday',
      time: '6:30 PM',
      label: 'Bible Study',
      note: 'Online',
    ),
    _ServiceTime(
      day: 'Friday',
      time: '7:00 PM',
      label: 'Prayer Night',
      note: 'In-person',
    ),
  ];

  Future<bool> _launchExternal(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  Future<void> _openMaps(BuildContext context) async {
    final uri = Uri.parse(
      'https://maps.google.com/?q=${Uri.encodeComponent(_kMapsQuery)}',
    );
    final ok = await _launchExternal(uri);
    if (!ok && context.mounted) {
      _snack(context, 'Could not open maps');
    }
  }

  Future<void> _openLiveStream(BuildContext context) async {
    final ok = await _launchExternal(Uri.parse(_kLiveStreamUrl));
    if (!ok && context.mounted) {
      _snack(context, 'Could not open live stream');
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final ok = await _launchExternal(Uri.parse('https://wa.me/$_kWhatsAppNumber'));
    if (!ok && context.mounted) {
      _snack(context, 'Could not open WhatsApp');
    }
  }

  Future<void> _openMail(BuildContext context) async {
    final ok = await _launchExternal(Uri.parse('mailto:$_kContactEmail'));
    if (!ok && context.mounted) {
      _snack(context, 'Could not open email app');
    }
  }

  Future<void> _openDialer(BuildContext context) async {
    final ok = await _launchExternal(Uri.parse('tel:$_kContactPhone'));
    if (!ok && context.mounted) {
      _snack(context, 'Could not open dialer');
    }
  }

  Future<void> _openWebsite(BuildContext context) async {
    final ok = await _launchExternal(Uri.parse(_kWebsite));
    if (!ok && context.mounted) {
      _snack(context, 'Could not open website');
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar (back + title) ───────────────────────────────────
            _TopBar(onBack: () => context.pop()),
            // ── Scrollable body ──────────────────────────────────────────
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.huge,
                ),
                children: [
                  _HeroCard().animate().fadeIn(
                        duration: AppMotion.standard,
                        curve: AppMotion.decelerate,
                      ),
                  const SizedBox(height: AppSpacing.lg),
                  const _ServiceTimesCard(times: _serviceTimes)
                      .animate()
                      .fadeIn(
                        duration: AppMotion.standard,
                        delay: const Duration(milliseconds: 80),
                        curve: AppMotion.decelerate,
                      ),
                  const SizedBox(height: AppSpacing.lg),
                  _AddressCard(
                    line1: _kAddressLine1,
                    line2: _kAddressLine2,
                    onDirections: () => _openMaps(context),
                  ).animate().fadeIn(
                        duration: AppMotion.standard,
                        delay: const Duration(milliseconds: 160),
                        curve: AppMotion.decelerate,
                      ),
                  const SizedBox(height: AppSpacing.lg),
                  _LiveStreamCard(
                    label: _kWatchLiveLabel,
                    onWatch: () => _openLiveStream(context),
                  ).animate().fadeIn(
                        duration: AppMotion.standard,
                        delay: const Duration(milliseconds: 240),
                        curve: AppMotion.decelerate,
                      ),
                  const SizedBox(height: AppSpacing.lg),
                  _ContactCard(
                    email: _kContactEmail,
                    phone: _kContactPhone,
                    website: _kWebsite,
                    onMail: () => _openMail(context),
                    onCall: () => _openDialer(context),
                    onWhatsApp: () => _openWhatsApp(context),
                    onWebsite: () => _openWebsite(context),
                  ).animate().fadeIn(
                        duration: AppMotion.standard,
                        delay: const Duration(milliseconds: 320),
                        curve: AppMotion.decelerate,
                      ),
                  const SizedBox(height: AppSpacing.lg),
                  _PrayerShortcutCard(
                    onTap: () => context.push(RouteNames.submitPrayer),
                  ).animate().fadeIn(
                        duration: AppMotion.standard,
                        delay: const Duration(milliseconds: 400),
                        curve: AppMotion.decelerate,
                      ),
                  const SizedBox(height: AppSpacing.xl),
                  _BackToDiscoverButton(onTap: () => context.pop())
                      .animate()
                      .fadeIn(
                        duration: AppMotion.standard,
                        delay: const Duration(milliseconds: 480),
                        curve: AppMotion.decelerate,
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
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          _CircleIconButton(icon: Icons.arrow_back_ios_new, onTap: onBack),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Plan Your Visit',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: AppSpacing.minTouchTarget,
          height: AppSpacing.minTouchTarget,
          child: Icon(icon, size: 18, color: AppColors.navy),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero card
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.navyBanner,
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppSpacing.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.goldDark, AppColors.goldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Iconography.directions,
              color: AppColors.navy,
              size: AppSpacing.iconMd,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            "We can't wait to meet you.",
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Kingdom Heirs Foundation is a Christ-centered family on mission. '
            'Whether you join us in person or online, you belong here.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.warmWhite.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Service times
// ─────────────────────────────────────────────────────────────────────────────

class _ServiceTime {
  const _ServiceTime({
    required this.day,
    required this.time,
    required this.label,
    required this.note,
  });

  final String day;
  final String time;
  final String label;
  final String note;
}

class _ServiceTimesCard extends StatelessWidget {
  const _ServiceTimesCard({required this.times});

  final List<_ServiceTime> times;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Iconography.calendar,
            title: 'Service Times',
          ),
          const SizedBox(height: AppSpacing.md),
          for (final t in times) ...[
            _ServiceTimeRow(time: t),
            if (t != times.last)
              const Divider(
                height: AppSpacing.xl,
                thickness: 0.5,
                color: AppColors.dividerLight,
              ),
          ],
        ],
      ),
    );
  }
}

class _ServiceTimeRow extends StatelessWidget {
  const _ServiceTimeRow({required this.time});

  final _ServiceTime time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.goldContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            children: [
              Text(
                time.day.substring(0, 3).toUpperCase(),
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time.time,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time.label,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time.note,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Address / directions
// ─────────────────────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.line1,
    required this.line2,
    required this.onDirections,
  });

  final String line1;
  final String line2;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Iconography.directions,
            title: 'Find Us',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            line1,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            line2,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Get Directions',
              icon: Iconography.directions,
              onPressed: onDirections,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Live stream
// ─────────────────────────────────────────────────────────────────────────────

class _LiveStreamCard extends StatelessWidget {
  const _LiveStreamCard({required this.label, required this.onWatch});

  final String label;
  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusXl,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.goldDark, AppColors.goldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconography.live,
              color: AppColors.navy,
              size: AppSpacing.iconLg,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Worship with us online',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stream our services live on YouTube.',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Wrap in `Expanded` so the button takes whatever horizontal
          // space is left in the row — its internal
          // `SizedBox(width: double.infinity)` would otherwise trigger
          // a layout assertion (infinite width) when placed at the end
          // of an unconstrained Row.
          Expanded(
            child: AppButton(
              label: 'Watch Live',
              icon: Iconography.live,
              onPressed: onWatch,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contact
// ─────────────────────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.email,
    required this.phone,
    required this.website,
    required this.onMail,
    required this.onCall,
    required this.onWhatsApp,
    required this.onWebsite,
  });

  final String email;
  final String phone;
  final String website;
  final VoidCallback onMail;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onWebsite;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Iconography.community,
            title: 'Get in Touch',
          ),
          const SizedBox(height: AppSpacing.md),
          _ContactRow(
            icon: Icons.alternate_email,
            label: 'Email',
            value: email,
            onTap: onMail,
          ),
          _ContactRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: phone,
            onTap: onCall,
          ),
          _ContactRow(
            icon: Icons.chat_bubble_outline,
            label: 'WhatsApp',
            value: 'Chat with us',
            onTap: onWhatsApp,
          ),
          _ContactRow(
            icon: Icons.language_outlined,
            label: 'Website',
            value: website.replaceFirst('https://', ''),
            onTap: onWebsite,
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, size: AppSpacing.iconMd, color: AppColors.goldDark),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    value,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: AppSpacing.iconMd,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Prayer shortcut
// ─────────────────────────────────────────────────────────────────────────────

class _PrayerShortcutCard extends StatelessWidget {
  const _PrayerShortcutCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      variant: AppCardVariant.goldBanner,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusXl,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Iconography.taskPrayer,
              color: AppColors.navy,
              size: AppSpacing.iconMd,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Need prayer?',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Share a prayer request — our community is ready to stand with you.',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.navy.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.navy,
            size: AppSpacing.iconMd,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Back to discover
// ─────────────────────────────────────────────────────────────────────────────

class _BackToDiscoverButton extends StatelessWidget {
  const _BackToDiscoverButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.dividerLight),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
        child: const Text(
          'Back to Discover',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSpacing.iconSm, color: AppColors.goldDark),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
