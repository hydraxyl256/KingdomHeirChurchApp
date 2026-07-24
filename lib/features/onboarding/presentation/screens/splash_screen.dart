import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';

/// A quiet handoff from the native launch screen into the app.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _opacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.72, curve: Curves.easeOutCubic),
    );
    _scale = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final reduceMotion = mediaQuery.disableAnimations;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.backgroundLight,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.white, AppColors.backgroundLight],
              stops: [0, 1],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final shortestSide = constraints.biggest.shortestSide;
                final logoWidth = (shortestSide * 0.26).clamp(96.0, 152.0);

                final hero = _SplashBrand(lockupWidth: logoWidth);
                return Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 36),
                        child: reduceMotion
                            ? hero
                            : FadeTransition(
                                opacity: _opacity,
                                child: ScaleTransition(
                                  scale: _scale,
                                  child: hero,
                                ),
                              ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, 0, 24, 28),
                        child: _SplashProgress(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashBrand extends StatelessWidget {
  const _SplashBrand({required this.lockupWidth});

  final double lockupWidth;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Kingdom Heirs. Preparing Believers. Making Disciples. Reaching Nations.',
      image: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BrandMark(width: lockupWidth),
          const SizedBox(height: 28),
          Text(
            'PREPARING BELIEVERS.\nMAKING DISCIPLES. REACHING NATIONS.',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.05,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the cropped, transparent version of the existing brand artwork.
class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Image.asset(
        'assets/images/kingdom_heirs_wordmark.png',
        filterQuality: FilterQuality.high,
        semanticLabel: 'Kingdom Heirs logo',
      ),
    );
  }
}

class _SplashProgress extends StatelessWidget {
  const _SplashProgress();

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width * 0.34).clamp(120.0, 192.0);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Semantics(
      label: 'Loading Kingdom Heirs',
      liveRegion: true,
      child: SizedBox(
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: reduceMotion ? 1 : null,
            minHeight: 2,
            color: AppColors.gold,
            backgroundColor: AppColors.gold.withValues(alpha: 0.18),
          ),
        ),
      ),
    );
  }
}
