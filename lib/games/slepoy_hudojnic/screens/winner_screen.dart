import 'package:flutter/material.dart';
import '../services/game_service.dart';
import 'gallery_screen.dart';
import 'player_entry_screen.dart';
import '../widgets/shiny_button.dart';
import '../widgets/animated_background.dart';

class WinnerScreen extends StatelessWidget {
  const WinnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final winner = gameService.winner;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 100).clamp(200.0, 300.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AnimatedBackground(), // 🎉 Анимированный фон

          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Победил:',
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'PixelFont',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    winner.name,
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: 'PixelFont',
                      fontWeight: FontWeight.bold,
                      color: winner.color,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Кнопка "Галерея рисунков"
                  ShinyButton(
                    text: 'Галерея рисунков',
                    width: buttonWidth,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GalleryScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Кнопка "Начать заново"
                  ShinyButton(
                    text: 'Начать заново',
                    width: buttonWidth,
                    onPressed: () {
                      gameService.players.clear();
                      gameService.gallery.clear();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PlayerEntryScreen()),
                        (route) => false,
                      );
                    },
                    gradientColors1Override: const [
                      Color.fromARGB(255, 53, 7, 75),
                      Color.fromARGB(255, 41, 6, 59),
                      Color.fromARGB(255, 40, 3, 82),
                    ],
                    gradientColors2Override: const [
                      Color.fromARGB(255, 136, 21, 149),
                      Color.fromARGB(255, 131, 17, 120),
                      Color.fromARGB(255, 185, 40, 198),
                    ],
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
