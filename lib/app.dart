import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/localization/locale_provider.dart';
import 'package:kingdom_heir/core/router/app_router.dart';
import 'package:kingdom_heir/core/theme/app_theme.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class KingdomHeirApp extends ConsumerWidget {
  const KingdomHeirApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Kingdom Heir',
      debugShowCheckedModeBanner: false,

      // Theming
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Navigation
      routerConfig: router,

      // Localization
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
