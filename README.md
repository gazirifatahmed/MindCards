import 'package:flutter/material.dart';

/// ============================================== /// mcq_maker — Animated Splash + Logo (Copy-Paste) /// ============================================== /// How to use: /// 1) Replace your lib/main.dart with this file's content. /// 2) Run: flutter run /// 3) (Optional) To use your own PNG/SVG logo instead of FlutterLogo, ///    set useAssetLogo = true and put your asset at assets/logo.png, ///    then add to pubspec.yaml: /// ///    flutter: ///      assets: ///        - assets/logo.png /// /// That's it. Enjoy the smooth animated splash!

void main() { runApp(const McqMakerApp()); }

class McqMakerApp extends StatelessWidget { const McqMakerApp({super.key});

@override Widget build(BuildContext context) { return MaterialApp( debugShowCheckedModeBanner: false, title: 'mcq_maker', themeMode: ThemeMode.system, theme: ThemeData( useMaterial3: true, colorSchemeSeed: const Color(0xFF6750A4), brightness: Brightness.light, ), darkTheme: ThemeData( useMaterial3: true, colorSchemeSeed: const Color(0xFFB69DF8), brightness: Brightness.dark, ), home: const SplashScreen(), ); } }

class SplashScreen extends StatefulWidget { const SplashScreen({super.key});

@override State<SplashScreen> createState() => _SplashScreenState(); }

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin { late final AnimationController _logoController; late final Animation<double> _scale; late final Animation<double> _fade; late final Animation<Offset> _slideUp;

late final AnimationController _glowController; late final Animation<double> _glow;

// Toggle this to use your own asset logo static const bool useAssetLogo = false; // set to true to use assets/logo.png

@override void initState() { super.initState();

// Main logo entrance animation
_logoController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 1600),
);

_scale = Tween<double>(begin: 0.8, end: 1.0).animate(
  CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
);

_fade = Tween<double>(begin: 0.0, end: 1.0).animate(
  CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
);

_slideUp = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
    .animate(
  CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
);

// Subtle pulsing glow while on splash
_glowController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 1400),
  lowerBound: 0.0,
  upperBound: 1.0,
)..repeat(reverse: true);

_glow = CurvedAnimation(parent: _glowController, curve: Curves.easeInOut);

// Start animations
_logoController.forward();

// Navigate after a short delay to show off the animation
Future.delayed(const Duration(milliseconds: 1900), () {
  if (!mounted) return;
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) => const HomeScreen(),
      transitionsBuilder: (context, anim, secondary, child) {
        // Smooth fade + slide for page transition
        final offset = Tween<Offset>(
          begin: const Offset(0.0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));

        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: SlideTransition(position: offset, child: child),
        );
      },
    ),
  );
});

}

@override void dispose() { _logoController.dispose(); _glowController.dispose(); super.dispose(); }

@override Widget build(BuildContext context) { final scheme = Theme.of(context).colorScheme;

return Scaffold(
  backgroundColor: scheme.surface,
  body: Stack(
    children: [
      // Radial decorative background using AnimatedContainer-like effect
      Positioned.fill(
        child: AnimatedBuilder(
          animation: _glow,
          builder: (context, _) {
            return CustomPaint(
              painter: _RadialGlowPainter(
                color: scheme.primary.withOpacity(0.12 + _glow.value * 0.12),
              ),
            );
          },
        ),
      ),

      // Center content
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'app_logo',
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slideUp,
                  child: ScaleTransition(
                    scale: _scale,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withOpacity(0.25 + _glow.value * 0.15),
                            blurRadius: 40 + _glow.value * 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _LogoWidget(useAsset: useAssetLogo),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fade,
              child: const _BouncingDots(),
            ),
          ],
        ),
      ),
    ],
  ),
);

} }

class _LogoWidget extends StatelessWidget { final bool useAsset; const _LogoWidget({required this.useAsset});

@override Widget build(BuildContext context) { final scheme = Theme.of(context).colorScheme;

if (useAsset) {
  // Use your own image (PNG/SVG) placed at assets/logo.png
  return ClipRRect(
    borderRadius: BorderRadius.circular(200),
    child: Image.asset(
      'assets/logo.png',
      width: 120,
      height: 120,
      fit: BoxFit.cover,
    ),
  );
}

// Default: FlutterLogo with a gradient ring
return Stack(
  alignment: Alignment.center,
  children: [
    Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(colors: [
          scheme.primary.withOpacity(0.12),
          scheme.secondary.withOpacity(0.12),
          scheme.tertiary.withOpacity(0.12),
          scheme.primary.withOpacity(0.12),
        ]),
      ),
    ),
    const FlutterLogo(size: 96),
  ],
);

} }

class _BouncingDots extends StatefulWidget { const _BouncingDots();

@override State<_BouncingDots> createState() => _BouncingDotsState(); }

class _BouncingDotsState extends State<_BouncingDots> with SingleTickerProviderStateMixin { late final AnimationController _controller;

@override void initState() { super.initState(); _controller = AnimationController( vsync: this, duration: const Duration(milliseconds: 900), )..repeat(); }

@override void dispose() { _controller.dispose(); super.dispose(); }

@override Widget build(BuildContext context) { final scheme = Theme.of(context).colorScheme;

return SizedBox(
  height: 20,
  child: AnimatedBuilder(
    animation: _controller,
    builder: (_, __) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = (_controller.value + i / 3) % 1.0;
          final dy = Tween<double>(begin: 0, end: -8)
              .chain(CurveTween(curve: Curves.easeInOut))
              .transform(t < 0.5 ? t * 2 : (1 - t) * 2);
          final opacity = 0.5 + 0.5 * (1 - (t - 0.5).abs() * 2);
          return Transform.translate(
            offset: Offset(0, dy),
            child: Opacity(
              opacity: opacity,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      );
    },
  ),
);

} }

class HomeScreen extends StatelessWidget { const HomeScreen({super.key});

@override Widget build(BuildContext context) { final scheme = Theme.of(context).colorScheme;

return Scaffold(
  appBar: AppBar(
    title: Row(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withOpacity(0.12),
            ),
            alignment: Alignment.center,
            child: const FlutterLogo(size: 18),
          ),
        ),
        const SizedBox(width: 12),
        const Text('mcq_maker'),
      ],
    ),
    centerTitle: false,
  ),
  body: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Welcome to mcq_maker',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Your animated splash is ready to go!\nStart building your quiz screens next.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.quiz_outlined),
          label: const Text('Create a new Quiz'),
        ),
      ],
    ),
  ),
);

} }

class _RadialGlowPainter extends CustomPainter { final Color color; _RadialGlowPainter({required this.color});

@override void paint(Canvas canvas, Size size) { final center = size.center(Offset.zero); final radius = size.shortestSide * 0.6; final paint = Paint() ..shader = RadialGradient( colors: [ color, color.withOpacity(0.0), ], stops: const [0.0, 1.0], ).createShader(Rect.fromCircle(center: center, radius: radius));

canvas.drawCircle(center, radius, paint);

}

@override bool shouldRepaint(covariant _RadialGlowPainter oldDelegate) { return oldDelegate.color != color; } }

