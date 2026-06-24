// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Kingdom Heir';

  @override
  String welcomeMessage(String name) {
    return 'Bem-vindo, $name';
  }

  @override
  String get sermonsTab => 'Sermões';

  @override
  String get eventsTab => 'Eventos';

  @override
  String get givingTab => 'Doações';

  @override
  String get prayerTab => 'Oração';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageDesc => 'Mudar idioma do aplicativo';
}
