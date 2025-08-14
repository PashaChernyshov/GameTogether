import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class DrawingTransitionOverlay extends StatefulWidget {
  const DrawingTransitionOverlay({super.key});

  @override
  State<DrawingTransitionOverlay> createState() =>
      _DrawingTransitionOverlayState();
}

class _DrawingTransitionOverlayState extends State<DrawingTransitionOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _appearController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _appearController, curve: Curves.easeIn));

    for (int i = 0; i < 120; i++) {
      _particles.add(_Particle.random());
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      body: Stack(
        children: [
          // Блюр
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(),
          ),

          // Частицы
          ..._particles.map(
            (p) => AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                final progress = _controller.value;
                final offset = Offset(p.dx * progress, p.dy * progress);
                final opacity = 1.0 - progress;
                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 + offset.dx,
                  top: MediaQuery.of(context).size.height / 2 + offset.dy,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: p.size,
                      height: p.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purpleAccent.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.8),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Центр экрана с мультяшной анимацией
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/time.png',
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Время пошло!',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'PixelFont',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Particle {
  final double dx;
  final double dy;
  final double size;

  _Particle(this.dx, this.dy, this.size);

  factory _Particle.random() {
    final rand = Random();
    final angle = rand.nextDouble() * 2 * pi;
    final distance = rand.nextDouble() * 250;
    final size = rand.nextDouble() * 8;
    return _Particle(cos(angle) * distance, sin(angle) * distance, size);
  }
}
