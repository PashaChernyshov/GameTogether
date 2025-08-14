import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/player.dart';

class VictoryOverlay extends StatefulWidget {
  final Player player;

  const VictoryOverlay({super.key, required this.player});

  @override
  State<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<VictoryOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Добавим много частиц
    for (int i = 0; i < 200; i++) {
      _particles.add(_Particle.random(color: widget.player.color));
    }

    // Закрытие экрана через 3 секунды
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerColor = widget.player.color;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: Stack(
        children: [
          // Блюр фона
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(),
          ),

          // Частицы
          ..._particles.map((p) => AnimatedBuilder(
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
                          color: p.color.withOpacity(0.8),
                          boxShadow: [
                            BoxShadow(
                              color: p.color.withOpacity(0.9),
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )),

          // Текст по центру
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Text(
                    'Победа!',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'PixelFont',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    widget.player.name,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: playerColor,
                      fontFamily: 'PixelFont',
                    ),
                  ),
                ),
              ],
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
  final Color color;

  _Particle(this.dx, this.dy, this.size, this.color);

  factory _Particle.random({required Color color}) {
    final rand = Random();
    final angle = rand.nextDouble() * 2 * pi;
    final distance = rand.nextDouble() * 250 + 100;
    final size = rand.nextDouble() * 8 + 3;

    return _Particle(
      cos(angle) * distance,
      sin(angle) * distance,
      size,
      color,
    );
  }
}
