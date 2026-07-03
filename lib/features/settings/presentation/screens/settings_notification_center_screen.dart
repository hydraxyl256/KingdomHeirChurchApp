import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/localization/locale_provider.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';

class SettingsNotificationCenterScreen extends ConsumerStatefulWidget {
  const SettingsNotificationCenterScreen({super.key});

  @override
  ConsumerState<SettingsNotificationCenterScreen> createState() =>
      _SettingsNotificationCenterScreenState();
}

class _SettingsNotificationCenterScreenState
    extends ConsumerState<SettingsNotificationCenterScreen> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final currency = ref.watch(currencyProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.navyMid : Colors.white;
    final textMuted = theme.colorScheme.onSurface.withValues(alpha: 0.55);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.navyMid : AppColors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          // ── Profile header ──────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                AppAvatar(
                  imageUrl: user?.avatarUrl,
                  name: user?.displayName ?? 'User',
                  size: AppSpacing.avatarLg,
                  borderColor: AppColors.gold,
                  borderWidth: 2.5,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'User',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: textMuted),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          user?.role?.displayName ?? 'Member',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: AppColors.gold),
                  onPressed: () => context.push(RouteNames.myProfile),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          // ── Appearance ─────────────────────────────────────────────
          const _SectionHeader(title: 'Appearance'),
          _SettingsCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.dark_mode_rounded,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                title: const Text('Theme'),
                subtitle: Text(themeMode.name.capitalize()),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showThemeDialog(context, ref, themeMode),
              ),
            ],
          ).animate().fadeIn(delay: 80.ms),

          // ── Currency ───────────────────────────────────────────────
          const _SectionHeader(title: 'Currency'),
          _SettingsCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.monetization_on_rounded,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
                title: const Text('Default Currency'),
                subtitle: Text(kSupportedCurrencies[currency] ?? currency),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showCurrencyDialog(context, ref, currency),
              ),
            ],
          ).animate().fadeIn(delay: 120.ms),

          // ── Notifications ─────────────────────────────────────────
          const _SectionHeader(title: 'Notifications'),
          _SettingsCard(
            isDark: isDark,
            children: const [
              _PersistentSwitchTile(
                storageKey: 'notif_sunday',
                title: 'Sunday Service Reminders',
                subtitle: 'Remind me before Sunday worship',
                defaultValue: true,
                iconColor: Color(0xFFEF4444),
                icon: Icons.church_rounded,
              ),
              Divider(height: 1, indent: 56),
              _PersistentSwitchTile(
                storageKey: 'notif_events',
                title: 'Event Updates',
                subtitle: 'Notify me about new events',
                defaultValue: true,
                iconColor: Color(0xFF0EA5E9),
                icon: Icons.event_rounded,
              ),
              Divider(height: 1, indent: 56),
              _PersistentSwitchTile(
                storageKey: 'notif_groups',
                title: 'Group Messages',
                subtitle: 'New messages in my groups',
                defaultValue: true,
                iconColor: Color(0xFF8B5CF6),
                icon: Icons.groups_rounded,
              ),
              Divider(height: 1, indent: 56),
              _PersistentSwitchTile(
                storageKey: 'notif_giving',
                title: 'Giving Receipts',
                subtitle: 'Email receipt for each gift',
                defaultValue: false,
                iconColor: Color(0xFF10B981),
                icon: Icons.receipt_long_rounded,
              ),
              Divider(height: 1, indent: 56),
              _PersistentSwitchTile(
                storageKey: 'notif_devotional',
                title: 'Daily Devotional',
                subtitle: 'Morning reminder at 7 AM',
                defaultValue: true,
                iconColor: Color(0xFFF59E0B),
                icon: Icons.wb_sunny_rounded,
              ),
            ],
          ).animate().fadeIn(delay: 160.ms),

          // ── Account ────────────────────────────────────────────────
          const _SectionHeader(title: 'Account'),
          _SettingsCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: _iconBox(
                  Icons.lock_outline_rounded,
                  const Color(0xFF6366F1),
                ),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: _iconBox(
                  Icons.language_rounded,
                  const Color(0xFF0EA5E9),
                ),
                title: const Text('Language'),
                subtitle: Text(
                  _currentLanguageLabel(ref.watch(localeProvider).languageCode),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showLanguageDialog(context, ref),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: _iconBox(
                  Icons.privacy_tip_outlined,
                  const Color(0xFF8B5CF6),
                ),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: _iconBox(
                  Icons.info_outline_rounded,
                  const Color(0xFF10B981),
                ),
                title: const Text('About Kingdom Heir'),
                subtitle: const Text('Version 1.0.0'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),

          // ── Danger zone ───────────────────────────────────────────
          const _SectionHeader(title: 'Session'),
          _SettingsCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isLoggingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.error,
                          ),
                        )
                      : const Icon(
                          Icons.logout_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                ),
                title: Text(
                  _isLoggingOut ? 'Signing out...' : 'Sign Out',
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: _isLoggingOut ? null : () async {
                  final outerContext = context;
                  final messenger = ScaffoldMessenger.of(outerContext);

                  final confirmed = await showDialog<bool>(
                    context: outerContext,
                    builder: (_) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed != true) return;

                  if (!mounted) return;
                  setState(() => _isLoggingOut = true);

                  try {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    
                    final authState = ref.read(authNotifierProvider);
                    if (authState.hasError) {
                      throw Exception(authState.error);
                    }
                    
                    // We don't call router.go() here. GoRouter's redirect logic 
                    // will automatically redirect to start-here because auth state changed.

                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('You have been signed out.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Sign out failed. Please try again.'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isLoggingOut = false);
                    }
                  }
                },
              ),
            ],
          ).animate().fadeIn(delay: 240.ms),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) {
    // Capture notifier BEFORE dialog opens — avoids 'ref after dispose' error
    final notifier = ref.read(themeModeProvider.notifier);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Choose Theme'),
        content: RadioGroup<ThemeMode>(
          groupValue: current,
          onChanged: (v) {
            if (v != null) notifier.setTheme(v);
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values
                .map(
                  (m) => RadioListTile<ThemeMode>(
                    value: m,
                    title: Text(m.name.capitalize()),
                    activeColor: AppColors.gold,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) {
    // Capture notifier BEFORE dialog opens — avoids 'ref after dispose' error
    final notifier = ref.read(currencyProvider.notifier);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Currency'),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: SizedBox(
          width: double.maxFinite,
          child: RadioGroup<String>(
            groupValue: current,
            onChanged: (v) {
              if (v != null) notifier.setCurrency(v);
              Navigator.pop(context);
            },
            child: ListView(
              shrinkWrap: true,
              children: kSupportedCurrencies.entries.map((entry) {
                return RadioListTile<String>(
                  value: entry.key,
                  activeColor: AppColors.gold,
                  title: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    const languages = [
      {'code': 'en', 'label': 'English'},
      {'code': 'fr', 'label': 'Français (French)'},
      {'code': 'es', 'label': 'Español (Spanish)'},
      {'code': 'pt', 'label': 'Português (Portuguese)'},
      {'code': 'sw', 'label': 'Kiswahili (Swahili)'},
      {'code': 'lg', 'label': 'Luganda'},
      {'code': 'yo', 'label': 'Yorùbá'},
      {'code': 'ha', 'label': 'Hausa'},
    ];
    // Use localeProvider — the same provider app.dart watches — so changes apply immediately.
    final notifier = ref.read(localeProvider.notifier);
    final currentCode = ref.read(localeProvider).languageCode;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Language'),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: SizedBox(
          width: double.maxFinite,
          child: RadioGroup<String>(
            groupValue: currentCode,
            onChanged: (v) {
              if (v != null) notifier.setLocale(v);
              Navigator.pop(context);
            },
            child: ListView(
              shrinkWrap: true,
              children: languages.map((lang) {
                final code = lang['code']!;
                return RadioListTile<String>(
                  value: code,
                  activeColor: AppColors.gold,
                  title: Text(lang['label']!),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  String _currentLanguageLabel(String? code) {
    const map = {
      'en': 'English',
      'fr': 'Français',
      'es': 'Español',
      'pt': 'Português',
      'sw': 'Kiswahili',
      'lg': 'Luganda',
      'yo': 'Yorùbá',
      'ha': 'Hausa',
    };
    return map[code] ?? 'English';
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children, required this.isDark});
  final List<Widget> children;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyMid : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _PersistentSwitchTile extends ConsumerStatefulWidget {
  const _PersistentSwitchTile({
    required this.storageKey,
    required this.title,
    required this.subtitle,
    required this.defaultValue,
    required this.iconColor,
    required this.icon,
  });

  final String storageKey;
  final String title;
  final String subtitle;
  final bool defaultValue;
  final Color iconColor;
  final IconData icon;

  @override
  ConsumerState<_PersistentSwitchTile> createState() =>
      _PersistentSwitchTileState();
}

class _PersistentSwitchTileState extends ConsumerState<_PersistentSwitchTile> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(localStorageServiceProvider);
    _value = storage.getBool(widget.storageKey) ?? widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: _value,
      activeThumbColor: AppColors.gold,
      onChanged: (v) async {
        setState(() => _value = v);
        final storage = ref.read(localStorageServiceProvider);
        await storage.setBool(key: widget.storageKey, value: v);
      },
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(widget.icon, color: widget.iconColor, size: 20),
      ),
      title: Text(widget.title),
      subtitle: Text(
        widget.subtitle,
        style: TextStyle(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          fontSize: 12,
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
