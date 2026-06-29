// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Kingdom Heir';

  @override
  String welcomeMessage(String name) {
    return 'Bienvenue, $name';
  }

  @override
  String get sermonsTab => 'Sermons';

  @override
  String get eventsTab => 'Événements';

  @override
  String get givingTab => 'Dons';

  @override
  String get prayerTab => 'Prière';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageDesc => 'Changer la langue de l\'application';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bonsoir';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get goodNight => 'Bonne nuit';

  @override
  String get morningTagline => 'Commencez votre journée dans la Parole.';

  @override
  String get afternoonTagline => 'Marchez avec audace en Christ aujourd\'hui.';

  @override
  String get eveningTagline => 'Réfléchissez à sa bonté aujourd\'hui.';

  @override
  String get nightTagline => 'Reposez-vous dans sa paix ce soir.';

  @override
  String get scriptureSave => 'Sauvegarder';

  @override
  String get scriptureShare => 'Partager';

  @override
  String get scriptureListen => 'Écouter';

  @override
  String get scriptureReflect => 'Réfléchir';

  @override
  String get scriptureToday => 'VERSET DU JOUR';
}
