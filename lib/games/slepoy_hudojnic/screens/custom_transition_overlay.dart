import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class CustomTransitionOverlay extends StatefulWidget {
  const CustomTransitionOverlay({super.key});

  @override
  State<CustomTransitionOverlay> createState() =>
      _CustomTransitionOverlayState();
}

class _CustomTransitionOverlayState extends State<CustomTransitionOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _scaleController;
  late Animation<double> _imageScale;
  late Animation<double> _textScale;
  final List<_Particle> _particles = [];

  final List<String> phrases = [
    'Смотри не вспотей',
    'Это - Вау!',
    'Надо же так!',
    'Посмотрим, посмотрим.',
    'Тебе бы в художники...',
    'Красота!',
    'Шедевр!',
    'Гениально!',
    'Ну ты даёшь!',
    'Пушка!',
    'Прелесть!',
    'Изумительно!',
    'Апупенно!',
    'Браво!',
  ];

  final List<String> imagePaths = [
    'assets/images/q.png',
    'assets/images/e.png',
    'assets/images/r.png',
    'assets/images/t.png',
    'assets/images/y.png',
    'assets/images/u.png',
  ];

  late final String selectedText;
  late final String selectedImage;

  @override
  void initState() {
    super.initState();

    selectedText = (phrases..shuffle()).first;
    selectedImage = (imagePaths..shuffle()).first;

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _imageScale = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _textScale = CurvedAnimation(
      parent: _scaleController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    );

    // 🔥 Увеличили количество частиц
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
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: Stack(
        children: [
          // 🌫️ Блюр заднего фона
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(),
          ),

          // 🌟 Светящиеся частицы
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

          // 🎉 Анимация центра: картинка и текст
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _imageScale,
                  child: Image.asset(selectedImage, width: 180, height: 180),
                ),
                const SizedBox(height: 20),
                ScaleTransition(
                  scale: _textScale,
                  child: Text(
                    selectedText,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'PixelFont',
                    ),
                    textAlign: TextAlign.center,
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

  _Particle(this.dx, this.dy, this.size);

  factory _Particle.random() {
    final rand = Random();
    final angle = rand.nextDouble() * 2 * pi;
    final distance = rand.nextDouble() * 250 + 100;
    final size = rand.nextDouble() * 8 + 4;
    return _Particle(cos(angle) * distance, sin(angle) * distance, size);
  }
}
