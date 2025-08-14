import 'dart:ui';
import 'package:multi_game_app/games/slepoy_hudojnic/widgets/slow_sparkles.dart';
import 'package:flutter/material.dart';
import 'package:multi_game_app/games/slepoy_hudojnic/screens/player_entry_screen.dart';
import '../widgets/animated_logo.dart';
import '../widgets/animated_background.dart';
import '../widgets/shiny_button.dart';
// ✨ Падающие частицы
import 'cartoon_page_transition.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  void _showRulesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: Navigator.of(context),
      ),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: ListView(
                  controller: scrollController,
                  children: const [
                    Center(
                      child: SizedBox(
                        width: 50,
                        height: 6,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'ПРАВИЛА ИГРЫ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'PixelFont',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '• В каждом раунде один из игроков становится художником и рисует слово — вслепую!\n\n'
                      '• Остальные игроки стараются угадать, что изображено.\n\n'
                      '• Кто угадал — получает 1 балл (вы назначаете вручную).\n\n'
                      '• Побеждает тот, кто первым наберёт 10 баллов.\n\n'
                      '🔸 Пример: Артём рисует слово “Котик”, остальные угадывают. Маша первой поняла — она получает балл!',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 300).clamp(0.0, 300.0);

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          const SlowSparkles(), // ✨ Добавлены падающие частицы
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // 🌟 Логотип с подсветкой
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const AnimatedLogo(),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Слепой художник',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white70,
                          fontFamily: 'PixelFont',
                        ),
                      ),

                      const SizedBox(height: 60),

                      ShinyButton(
                        text: 'Играть',
                        width: buttonWidth,
                        onPressed: () {
                          Navigator.push(
                            context,
                            CartoonPageRoute(page: const PlayerEntryScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      ShinyButton(
                        text: 'Правила',
                        width: buttonWidth,
                        delay: const Duration(milliseconds: 600),
                        onPressed: () => _showRulesSheet(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
