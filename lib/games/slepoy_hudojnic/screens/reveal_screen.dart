import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'countdown_transition_screen.dart'; // Новый импорт!
import '../widgets/animated_background.dart';
import '../widgets/shiny_button.dart';

class RevealScreen extends StatefulWidget {
  final List<Offset> points;
  const RevealScreen({super.key, required this.points});

  @override
  State<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends State<RevealScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late Ticker _sparkTicker;
  final List<_Spark> sparks = [];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _sparkTicker = createTicker((_) => _updateSparks())..start();
    _spawnInitialSparks();
  }

  void _spawnInitialSparks() {
    final rand = Random();
    for (int i = 0; i < 25; i++) {
      sparks.add(_Spark(
        position: Offset(rand.nextDouble() * 400, rand.nextDouble() * 400),
        velocity: Offset((rand.nextDouble() - 0.5) * 0.5, -rand.nextDouble()),
        life: rand.nextDouble() * 1.5 + 0.5,
      ));
    }
  }

  void _updateSparks() {
    final dt = 1 / 60;
    setState(() {
      for (final s in sparks) {
        s.position += s.velocity * 2;
        s.life -= dt;
      }
      sparks.removeWhere((s) => s.life <= 0);
      while (sparks.length < 25) {
        _spawnInitialSparks();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _sparkTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 300).clamp(0.0, 300.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AnimatedBackground(),
          CustomPaint(
            painter: SparklePainter(sparks),
            child: Container(),
          ),
          Column(
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Покажи свой шедевр всем участникам',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontFamily: 'PixelFont',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFB388FF),
                              width: 3,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              color: Colors.black,
                              child: CustomPaint(
                                painter: DrawingPainter(points: widget.points),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              ShinyButton(
                text: 'Показать',
                width: buttonWidth,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CountdownTransitionScreen(points: widget.points),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;
  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Spark {
  Offset position;
  Offset velocity;
  double life;

  _Spark({
    required this.position,
    required this.velocity,
    required this.life,
  });
}

class SparklePainter extends CustomPainter {
  final List<_Spark> sparks;

  SparklePainter(this.sparks);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in sparks) {
      final alpha = (255 * (s.life / 2)).clamp(0, 255).toInt();
      final paint = Paint()
        ..color = Colors.white.withOpacity(alpha / 255)
        ..strokeWidth = 2.0;

      canvas.drawCircle(s.position, 2.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
