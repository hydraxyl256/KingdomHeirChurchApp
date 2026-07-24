import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/app.dart';
import 'package:kingdom_heir/bootstrap.dart';
import 'package:kingdom_heir/features/onboarding/presentation/screens/splash_screen.dart';

class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({super.key});

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  ProviderContainer? _container;
  bool _minSplashDurationElapsed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Keep the native-to-Flutter entrance visible without delaying startup.
    final splashTimer =
        Future<void>.delayed(const Duration(milliseconds: 1100));

    // 2. Heavy initialization (Supabase, Firebase, SharedPreferences, etc.)
    final containerFuture = bootstrap();

    // Wait for both to complete concurrently
    await splashTimer;
    final container = await containerFuture;

    if (mounted) {
      setState(() {
        _container = container;
        _minSplashDurationElapsed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If fully initialized and splash animation is done, swap to the real app
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _container != null && _minSplashDurationElapsed
          ? UncontrolledProviderScope(
              key: const ValueKey('application'),
              container: _container!,
              child: const KingdomHeirApp(),
            )
          : const MaterialApp(
              key: ValueKey('splash'),
              debugShowCheckedModeBanner: false,
              home: SplashScreen(),
            ),
    );
  }
}
