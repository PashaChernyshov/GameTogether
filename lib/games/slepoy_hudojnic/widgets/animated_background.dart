import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  late Timer _timer;
  late Color _color1;
  late Color _color2;

  final List<Color> _purpleShades = [
    Color(0xFF0D0D1A),
    Color(0xFF1B0F3B),
    Color(0xFF2E145D),
    Color(0xFF392A6D),
    Color(0xFF3F206D),
    Color(0xFF251C44),
  ];

  @override
  void initState() {
    super.initState();
    _color1 = _purpleShades[0];
    _color2 = _purpleShades[1];
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      setState(() {
        _color1 = _color2;
        final otherColors = _purpleShades.where((c) => c != _color1).toList()
          ..shuffle();
        _color2 = otherColors.first;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(begin: _color1, end: _color2),
      duration: const Duration(seconds: 4),
      builder: (context, color, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [color ?? _color1, Colors.black],
              center: Alignment.topLeft,
              radius: 2.0,
            ),
          ),
        );
      },
    );
  }
}
