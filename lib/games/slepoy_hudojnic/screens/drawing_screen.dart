import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';
import '../services/game_service.dart';
import '../models/gallery_entry.dart'; // ⬅️ не забудь про импорт!
import '../widgets/shiny_button.dart';
import '../widgets/animated_background.dart';
import 'reveal_screen.dart';
import 'custom_transition_overlay.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen>
    with TickerProviderStateMixin {
  List<Offset> points = [];
  List<_SparkParticle> sparks = [];
  bool finished = false;
  bool showDrawing = false;
  late Timer timer;
  int remaining = 20;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _flashController;
  late Animation<double> _flashOpacity;

  late AnimationController _lerpController;

  late Ticker _sparkTicker;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _flashOpacity = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
    );

    _lerpController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..forward();

    _sparkTicker = createTicker((_) => _updateSparks())..start();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => remaining--);
      if (remaining <= 0) {
        _endDrawing();
      }
    });
  }

  Future<void> _endDrawing() async {
    timer.cancel();
    setState(() => finished = true);

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => const CustomTransitionOverlay(),
      ),
    );

    _proceed();
  }

  Future<void> _proceed() async {
    setState(() => showDrawing = true);
    await Future.delayed(const Duration(milliseconds: 50));

    // ✅ Добавляем рисунок в галерею как GalleryEntry
    gameService.gallery.add(
      GalleryEntry(player: gameService.currentPlayer, points: points),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RevealScreen(points: points)),
    );
  }

  void _addSpark(Offset position) {
    final rand = Random();
    for (int i = 0; i < 3; i++) {
      sparks.add(_SparkParticle(
        position: position,
        velocity: Offset(
            (rand.nextDouble() - 0.5) * 2, (rand.nextDouble() - 0.5) * 2),
        life: 0.6,
      ));
    }
  }

  void _updateSparks() {
    final dt = 1 / 60;
    setState(() {
      sparks.removeWhere((s) => s.life <= 0);
      for (final s in sparks) {
        s.position += s.velocity;
        s.life -= dt;
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _pulseController.dispose();
    _flashController.dispose();
    _lerpController.dispose();
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
          if (remaining <= 10 && !finished)
            AnimatedBuilder(
              animation: _flashOpacity,
              builder: (context, child) {
                return IgnorePointer(
                  child: Container(
                    color: Colors.white.withOpacity(_flashOpacity.value),
                  ),
                );
              },
            ),
          Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'Рисует: ${gameService.currentPlayer.name}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: 'PixelFont',
                ),
              ),
              const SizedBox(height: 10),
              if (!finished)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = remaining <= 10 ? _pulseAnimation.value : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Text(
                        'Осталось: $remaining сек',
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
              if (!finished)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedBuilder(
                    animation: _lerpController,
                    builder: (context, child) {
                      return Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 1.0 - _lerpController.value,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final drawingRect = Rect.fromLTWH(
                        0,
                        0,
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(
                              color: const Color(0xFFB388FF),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              if (!finished) {
                                RenderBox box =
                                    context.findRenderObject() as RenderBox;
                                final local =
                                    box.globalToLocal(details.globalPosition);
                                if (drawingRect.contains(local)) {
                                  setState(() => points.add(local));
                                  _addSpark(local);
                                }
                              }
                            },
                            onPanEnd: (_) => points.add(Offset.zero),
                            child: CustomPaint(
                              painter: DrawingPainter(
                                points: showDrawing ? points : [],
                                sparks: sparks,
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!finished)
                ShinyButton(
                  text: 'Я всё!',
                  width: buttonWidth,
                  onPressed: _endDrawing,
                ),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;
  final List<_SparkParticle> sparks;

  DrawingPainter({
    required this.points,
    this.sparks = const [],
  });

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

    for (final s in sparks) {
      final alpha = (255 * (s.life / 0.6)).clamp(0, 255).toInt();
      final particlePaint = Paint()
        ..color = Colors.white.withOpacity(alpha / 255)
        ..strokeWidth = 2.0;

      canvas.drawCircle(s.position, 2.5, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SparkParticle {
  Offset position;
  Offset velocity;
  double life;

  _SparkParticle({
    required this.position,
    required this.velocity,
    required this.life,
  });
}
