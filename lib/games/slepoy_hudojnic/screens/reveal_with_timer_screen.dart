import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../widgets/animated_background.dart';
import 'assign_point_screen.dart';

class RevealWithTimerScreen extends StatefulWidget {
  final List<Offset> points;
  const RevealWithTimerScreen({super.key, required this.points});

  @override
  State<RevealWithTimerScreen> createState() => _RevealWithTimerScreenState();
}

class _RevealWithTimerScreenState extends State<RevealWithTimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _barController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late Timer _timer;
  int remaining = 20;

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

    _barController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startTimer();

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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => remaining--);
      if (remaining <= 0) {
        _timer.cancel();
        _endScreen();
      }
    });
  }

  Future<void> _endScreen() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AssignPointScreen()),
    );
  }

  void _endEarly() {
    _timer.cancel();
    _endScreen();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _barController.dispose();
    _pulseController.dispose();
    _sparkTicker.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AnimatedBackground(),

          // ✨ Эффект частиц
          CustomPaint(
            painter: _SparklePainter(sparks),
            child: Container(),
          ),

          Column(
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Участники отгадывают что тут нарисовано',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontFamily: 'PixelFont',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) {
                  final scale = remaining <= 10 ? _pulseAnimation.value : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Text(
                      remaining > 0
                          ? 'Осталось: $remaining сек'
                          : 'Время вышло!',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'PixelFont',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedBuilder(
                  animation: _barController,
                  builder: (_, __) {
                    return Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1.0 - _barController.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFB388FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
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
                                painter: _DrawingPainter(points: widget.points),
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
              const SizedBox(height: 10),
              TextButton(
                onPressed: _endEarly,
                child: const Text(
                  'Закончить раньше',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontFamily: 'PixelFont',
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<Offset> points;

  _DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
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

class _SparklePainter extends CustomPainter {
  final List<_Spark> sparks;

  _SparklePainter(this.sparks);

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
