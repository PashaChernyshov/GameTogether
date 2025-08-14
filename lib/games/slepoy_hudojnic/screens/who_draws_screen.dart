import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../services/game_service.dart';
import 'show_word_screen.dart';
import '../widgets/shiny_button.dart';
import '../widgets/animated_background.dart';
import 'cartoon_page_transition.dart';

class WhoDrawsScreen extends StatefulWidget {
  const WhoDrawsScreen({super.key});

  @override
  State<WhoDrawsScreen> createState() => _WhoDrawsScreenState();
}

class _WhoDrawsScreenState extends State<WhoDrawsScreen>
    with TickerProviderStateMixin {
  late AnimationController _nameController;
  late Animation<double> _scaleAnimation;
  late List<_Particle> particles;
  late Ticker _ticker;
  late Color particleColor;

  @override
  void initState() {
    super.initState();

    _nameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _nameController, curve: Curves.elasticOut),
    );

    particleColor = gameService.currentPlayer.color;
    particles = [];
    _ticker = createTicker(_updateParticles)..start();

    _nameController.forward();
    _spawnParticles();
  }

  void _spawnParticles() {
    final random = Random();
    for (int i = 0; i < 80; i++) {
      particles.add(_Particle(
        position: Offset(0, 0),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 6,
          (random.nextDouble() - 1.5) * 6,
        ),
        life: 1.8,
        color: particleColor,
      ));
    }
  }

  void _updateParticles(Duration _) {
    final dt = 1 / 60;
    setState(() {
      particles.removeWhere((p) => p.life <= 0);
      for (var p in particles) {
        p.position += p.velocity;
        p.life -= dt;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = gameService.currentPlayer;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 300).clamp(0.0, 300.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AnimatedBackground(), // 🌌 Фиолетовый фон

          // ✨ Частицы
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ParticlePainter(particles),
              ),
            ),
          ),

          // 🌟 Контент
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 25,
                        fontFamily: 'PixelFont',
                      ),
                      children: [
                        const TextSpan(
                          text: 'Рисует: ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: player.name,
                          style: TextStyle(
                            color: player.color,
                            shadows: [
                              Shadow(
                                blurRadius: 12,
                                color: player.color,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ShinyButton(
                  text: 'Что рисовать?',
                  width: buttonWidth,
                  onPressed: () {
                    gameService.generateWord();
                    Navigator.push(
                      context,
                      CartoonPageRoute(page: const ShowWordScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 100,
                  child: const Text(
                    'Отверни экран от остальных игроков и жми на кнопку',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white54,
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

// 🌟 Модель частицы
class _Particle {
  Offset position;
  Offset velocity;
  double life;
  final Color color;

  _Particle({
    required this.position,
    required this.velocity,
    required this.life,
    required this.color,
  });
}

// ✨ Отрисовка частиц
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final alpha = (255 * (p.life / 1.8)).clamp(0, 255).toInt();
      final paint = Paint()
        ..color = p.color.withAlpha(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

      final pos = Offset(size.width / 2, size.height / 2) + p.position;
      canvas.drawCircle(pos, 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
