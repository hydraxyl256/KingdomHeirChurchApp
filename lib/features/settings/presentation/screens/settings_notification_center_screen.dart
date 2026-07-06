import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/localization/locale_provider.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final cardColor = theme.colorScheme.surface;
    final textMuted = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
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
                  color: theme.colorScheme.shadow.withValues(alpha: 0.05),
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
                  borderColor: theme.colorScheme.primary,
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
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          user?.role?.displayName ?? 'Member',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_rounded,
                    color: theme.colorScheme.primary,
                  ),
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
                    color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.dark_mode_rounded,
                    color: theme.colorScheme.secondary,
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
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: theme.colorScheme.primary,
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
            children: [
              _PersistentSwitchTile(
                storageKey: 'notif_sunday',
                title: 'Sunday Service Reminders',
                subtitle: 'Remind me before Sunday worship',
                defaultValue: true,
                iconColor: theme.colorScheme.error,
                icon: Icons.church_rounded,
              ),
              Divider(
                height: 1,
                indent: 56,
                color: theme.colorScheme.outlineVariant,
              ),
              _PersistentSwitchTile(
                storageKey: 'notif_events',
                title: 'Event Updates',
                subtitle: 'Notify me about new events',
                defaultValue: true,
                iconColor: theme.colorScheme.tertiary,
                icon: Icons.event_rounded,
              ),
              Divider(
                height: 1,
                indent: 56,
                color: theme.colorScheme.outlineVariant,
              ),
              _PersistentSwitchTile(
                storageKey: 'notif_groups',
                title: 'Group Messages',
                subtitle: 'New messages in my groups',
                defaultValue: true,
                iconColor: theme.colorScheme.secondary,
                icon: Icons.groups_rounded,
              ),
              Divider(
                height: 1,
                indent: 56,
                color: theme.colorScheme.outlineVariant,
              ),
              _PersistentSwitchTile(
                storageKey: 'notif_giving',
                title: 'Giving Receipts',
                subtitle: 'Email receipt for each gift',
                defaultValue: false,
                iconColor: theme.colorScheme.tertiary,
                icon: Icons.receipt_long_rounded,
              ),
              Divider(
                height: 1,
                indent: 56,
                color: theme.colorScheme.outlineVariant,
              ),
              _PersistentSwitchTile(
                storageKey: 'notif_devotional',
                title: 'Daily Devotional',
                subtitle: 'Morning reminder at 7 AM',
                defaultValue: true,
                iconColor: theme.colorScheme.primary,
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
                  theme.colorScheme.secondary,
                ),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(RouteNames.changePassword),
              ),
              Divider(
                height: 1,
                indent: 56,
                color: theme.colorScheme.outlineVariant,
              ),
              ListTile(
                leading: _iconBox(
                  Icons.language_rounded,
                  theme.colorScheme.tertiary,
                ),
                title: const Text('Language'),
                subtitle: Text(
                  _currentLanguageLabel(ref.watch(localeProvider).languageCode),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showLanguageDialog(context, ref),
              ),
              Divider(
                height: 1,
                indent: 56,
                color: theme.colorScheme.outlineVariant,
              ),
              ListTile(
                leading: _iconBox(
                  Icons.privacy_tip_outlined,
                  theme.colorScheme.secondary,
                ),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _launchPrivacyPolicy(context),
              ),
              Divider(
                height: 1,
                indent: 56,
                color: theme.colorScheme.outlineVariant,
              ),
              ListTile(
                leading: _iconBox(
                  Icons.info_outline_rounded,
                  theme.colorScheme.tertiary,
                ),
                title: const Text('About Kingdom Heir'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(RouteNames.settingsAbout),
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
                    color: theme.colorScheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isLoggingOut
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.error,
                          ),
                        )
                      : Icon(
                          Icons.logout_rounded,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                ),
                title: Text(
                  _isLoggingOut ? 'Signing out...' : 'Sign Out',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: _isLoggingOut ? null : () async {
                  final outerContext = context;
                  final messenger = ScaffoldMessenger.of(outerContext);

                  final confirmed = await showDialog<bool>(
                    context: outerContext,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Theme.of(dialogContext).colorScheme.error,
                            ),
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
                        SnackBar(
                          content: const Text(
                            'Sign out failed. Please try again.',
                          ),
                          backgroundColor: theme.colorScheme.error,
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
    final scheme = Theme.of(context).colorScheme;
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
                    activeColor: scheme.primary,
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
    final scheme = Theme.of(context).colorScheme;
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
                  activeColor: scheme.primary,
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
    final scheme = Theme.of(context).colorScheme;
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
                  activeColor: scheme.primary,
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

  Future<void> _launchPrivacyPolicy(BuildContext ctx) async {
    const url =
        'https://sites.google.com/view/kingdom-heirs-ministry/home';
    final uri = Uri.parse(url);
    final launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && ctx.mounted) {
      final scheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not open Privacy Policy. Please try again.',
          ),
          backgroundColor: scheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'Retry',
            textColor: scheme.onError,
            onPressed: () => _launchPrivacyPolicy(ctx),
          ),
        ),
      );
    }
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
              color: Theme.of(context).colorScheme.primary,
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
    final theme = Theme.of(context);
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
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
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return ListTile(
      leading: Container(
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
          color: onSurface.withValues(alpha: 0.55),
          fontSize: 12,
        ),
      ),
      // Use trailing Switch (not SwitchListTile) so the active-state
      // gold color is strictly contained inside the switch widget bounds
      // and never propagates a tinted ink splash across the entire tile.
      trailing: Switch(
        value: _value,
        onChanged: (v) async {
          setState(() => _value = v);
          final storage = ref.read(localStorageServiceProvider);
          await storage.setBool(key: widget.storageKey, value: v);
        },
        // Thumb: themed on-surface when ON, muted when OFF
        activeThumbColor: theme.colorScheme.onPrimary,
        inactiveThumbColor: onSurface.withValues(alpha: 0.55),
        // Track colors — gold only inside the switch, never the tile
        activeTrackColor: theme.colorScheme.primary,
        inactiveTrackColor: onSurface.withValues(alpha: 0.12),
        // Remove track border in all states for a clean look
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        // Comfortable tap target without expanding into neighbour rows
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

}

extension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
