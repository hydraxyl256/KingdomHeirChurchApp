import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:kingdom_heir/app_bootstrapper.dart';
import 'package:kingdom_heir/core/config/env.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  Env.validate();

  if (Env.enableCrashReporting && Env.sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options
          ..dsn = Env.sentryDsn
          ..tracesSampleRate = Env.isProduction ? 0.2 : 1.0
          ..environment = Env.flavor;
      },
      appRunner: () async => runApp(const AppBootstrapper()),
    );
  } else {
    runApp(const AppBootstrapper());
  }
}
