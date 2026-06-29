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

  @override
  String get goodMorning => 'Bom Dia';

  @override
  String get goodAfternoon => 'Boa Tarde';

  @override
  String get goodEvening => 'Boa Noite';

  @override
  String get goodNight => 'Boa Noite';

  @override
  String get morningTagline => 'Comece seu dia na Palavra.';

  @override
  String get afternoonTagline => 'Ande com ousadia em Cristo hoje.';

  @override
  String get eveningTagline => 'Reflita sobre sua bondade hoje.';

  @override
  String get nightTagline => 'Descanso em sua paz esta noite.';

  @override
  String get scriptureSave => 'Salvar';

  @override
  String get scriptureShare => 'Compartilhar';

  @override
  String get scriptureListen => 'Ouvir';

  @override
  String get scriptureReflect => 'Refletir';

  @override
  String get scriptureToday => 'VERSO DO DIA';
}
