import 'dart:math';
import 'package:flutter/material.dart';

class SlowSparkles extends StatefulWidget {
  const SlowSparkles({super.key});

  @override
  State<SlowSparkles> createState() => _SlowSparklesState();
}

class _SlowSparklesState extends State<SlowSparkles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Sparkle> _sparkles = [];
  final int _numSparkles = 30;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    for (int i = 0; i < _numSparkles; i++) {
      _sparkles.add(_randomSparkle());
    }
  }

  _Sparkle _randomSparkle() {
    return _Sparkle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: 1.5 + _random.nextDouble() * 2,
      opacity: 0.3 + _random.nextDouble() * 0.4,
      speed: 0.002 + _random.nextDouble() * 0.004,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (var sparkle in _sparkles) {
          sparkle.y += sparkle.speed;
          if (sparkle.y > 1.1) {
            sparkle.y = -0.1;
            sparkle.x = _random.nextDouble();
          }
        }

        return IgnorePointer(
          child: CustomPaint(
            painter: _SparklesPainter(_sparkles),
            child: Container(),
          ),
        );
      },
    );
  }
}

class _Sparkle {
  double x;
  double y;
  double size;
  double opacity;
  double speed;

  _Sparkle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
  });
}

class _SparklesPainter extends CustomPainter {
  final List<_Sparkle> sparkles;

  _SparklesPainter(this.sparkles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (final sparkle in sparkles) {
      paint.color = Colors.white.withOpacity(sparkle.opacity);
      canvas.drawCircle(
        Offset(sparkle.x * size.width, sparkle.y * size.height),
        sparkle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
