import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'reveal_with_timer_screen.dart';

class CountdownTransitionScreen extends StatefulWidget {
  final List<Offset> points;

  const CountdownTransitionScreen({super.key, required this.points});

  @override
  State<CountdownTransitionScreen> createState() =>
      _CountdownTransitionScreenState();
}

class _CountdownTransitionScreenState extends State<CountdownTransitionScreen>
    with TickerProviderStateMixin {
  late AnimationController _blurController;
  late Animation<double> _blurAnimation;

  late AnimationController _textScaleController;
  late Animation<double> _textScaleAnimation;

  late AnimationController _flashController;
  late Animation<double> _flashOpacity;

  late Timer _countdownTimer;
  int _count = 3;
  String _label = '3...';

  bool _showFlash = false;

  @override
  void initState() {
    super.initState();

    // Анимация блюра
    _blurController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _blurAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _blurController, curve: Curves.easeInOut),
    );
    _blurController.forward();

    // Анимация появления текста (мультяшная)
    _textScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textScaleController, curve: Curves.elasticOut),
    );

    // Анимация моргания
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _flashOpacity = Tween<double>(begin: 0.0, end: 0.7).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _animateText();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_count > 1) {
        setState(() {
          _count--;
          _label = '$_count...';
        });
        _animateText();
      } else if (_count == 1) {
        setState(() {
          _count = 0;
          _label = 'Время пошло!';
        });
        _animateText();
        _startFlashing();
      } else {
        _countdownTimer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RevealWithTimerScreen(points: widget.points),
          ),
        );
      }
    });
  }

  void _animateText() {
    _textScaleController.reset();
    _textScaleController.forward();
  }

  void _startFlashing() async {
    _showFlash = true;
    for (int i = 0; i < 5; i++) {
      await _flashController.forward();
      await _flashController.reverse();
    }
    _showFlash = false;
  }

  @override
  void dispose() {
    _blurController.dispose();
    _textScaleController.dispose();
    _flashController.dispose();
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _blurAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // Фон с блюром
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _blurAnimation.value,
                  sigmaY: _blurAnimation.value,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),

              // Моргание белым при "Время пошло!"
              if (_showFlash)
                AnimatedBuilder(
                  animation: _flashOpacity,
                  builder: (context, child) {
                    return Container(
                      color: Colors.white.withOpacity(_flashOpacity.value),
                    );
                  },
                ),

              // Центр: текст с мультяшной анимацией
              Center(
                child: ScaleTransition(
                  scale: _textScaleAnimation,
                  child: Text(
                    _label,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontFamily: 'PixelFont',
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
