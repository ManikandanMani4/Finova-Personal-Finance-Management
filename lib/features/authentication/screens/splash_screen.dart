
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final AnimationController _logoController;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _navigationTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (route) => false,
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _glowController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071522),
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _glowController,
              _logoController,
            ]),
            builder: (context, child) {
              final scale = Curves.easeOutBack.transform(
                _logoController.value,
              );

              return Opacity(
                opacity: _logoController.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 300,
                    height: 330,
                    child: AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        final rotation =
                            _glowController.value * 2 * math.pi;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.rotate(
                              angle: rotation,
                              child: Container(
                                width: 270,
                                height: 270,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: SweepGradient(
                                    colors: const [
                                      Color(0xFF00E5FF),
                                      Color(0xFF2979FF),
                                      Color(0xFF9C27FF),
                                      Color(0xFF00E5A8),
                                      Color(0xFFFFC857),
                                      Color(0xFF00E5FF),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00D9FF)
                                          .withAlpha(55),
                                      blurRadius: 50,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 252,
                              height: 252,
                              decoration: const BoxDecoration(
                                color: Color(0xFF071522),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Image.asset(
                              'assets/images/finova_logo.png',
                              width: 280,
                              height: 250,
                              fit: BoxFit.contain,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'YOUR MONEY. YOUR FUTURE.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB8D9E8),
                      fontSize: 11,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF65EBD0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
