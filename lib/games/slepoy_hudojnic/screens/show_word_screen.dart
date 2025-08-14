import 'package:flutter/material.dart';
import '../services/game_service.dart';
import 'drawing_screen.dart';
import '../widgets/animated_background.dart';
import '../widgets/shiny_button.dart';
import 'drawing_transition_overlay.dart'; // подключаем внешний файл

class ShowWordScreen extends StatelessWidget {
  const ShowWordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 300).clamp(0.0, 300.0);

    return Scaffold(
      backgroundColor: Colors.transparent, // прозрачный фон
      body: Stack(
        children: [
          const AnimatedBackground(), // анимированный фон
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  gameService.currentWord,
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white, // ⚠️ чтобы было видно на фоне
                    fontFamily: 'PixelFont',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ShinyButton(
                    text: 'Рисовать!',
                    width: buttonWidth,
                    onPressed: () async {
                      await Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (_, __, ___) =>
                              const DrawingTransitionOverlay(),
                        ),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DrawingScreen(),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
