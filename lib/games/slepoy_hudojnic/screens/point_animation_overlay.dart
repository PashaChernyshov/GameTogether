import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';

class PointAnimationOverlay extends StatefulWidget {
  final Player player;
  final int delta;

  const PointAnimationOverlay({
    super.key,
    required this.player,
    required this.delta,
  });

  @override
  State<PointAnimationOverlay> createState() => _PointAnimationOverlayState();
}

class _PointAnimationOverlayState extends State<PointAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    // Больше частиц для взрыва
    for (int i = 0; i < 100; i++) {
      _particles.add(_Particle.random(widget.player.color));
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.delta > 0 ? '+1' : '-1';
    final deltaColor = widget.delta > 0 ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(),
          ),
          // Частицы
          ..._particles.map((p) => AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  final progress = Curves.easeOut.transform(_controller.value);
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
                          color: p.color.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                              color: p.color.withOpacity(0.6),
                              blurRadius: 6,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )),
          // Центр: Игрок и очки
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.player.name,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: widget.player.color,
                      fontFamily: 'PixelFont',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: deltaColor,
                      fontFamily: 'PixelFont',
                    ),
                  ),
                ],
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
  final Color color;

  _Particle(this.dx, this.dy, this.size, this.color);

  factory _Particle.random(Color baseColor) {
    final rand = Random();
    final angle = rand.nextDouble() * 2 * pi;
    final distance = rand.nextDouble() * 200 + 50;
    final size = rand.nextDouble() * 10 + 3;

    // Разные оттенки от базового
    final color = Color.lerp(
      baseColor,
      Colors.white,
      rand.nextDouble() * 0.3,
    )!;

    return _Particle(
      cos(angle) * distance,
      sin(angle) * distance,
      size,
      color,
    );
  }
}
