import 'package:multi_game_app/games/slepoy_hudojnic/models/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/game_service.dart';
import 'score_screen.dart';
import '../widgets/shiny_button.dart';
import 'point_animation_overlay.dart';
import '../widgets/animated_background.dart';
import 'winner_screen.dart';
import 'victory_overlay.dart'; // Не забудь создать этот файл

class AssignPointScreen extends StatelessWidget {
  const AssignPointScreen({super.key});

  void _showAnimatedOverlay(
    BuildContext context,
    Player player,
    int delta,
  ) async {
    // Анимация +1 / -1
    await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) =>
            PointAnimationOverlay(player: player, delta: delta),
      ),
    );

    // Проверка на победу
    if (player.score >= 10) {
      await Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => VictoryOverlay(player: player),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WinnerScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ScoreScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 300).clamp(0.0, 300.0);
    final currentPlayer = gameService.currentPlayer;
    final otherPlayers = gameService.players
        .where((p) => p != currentPlayer)
        .toList();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const AnimatedBackground(),
            ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 60),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Кто угадал, что ты нарисовал(а)?',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontFamily: 'PixelFont',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                AnimationLimiter(
                  child: Column(
                    children: List.generate(otherPlayers.length, (index) {
                      final player = otherPlayers[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 40.0,
                          curve: Curves.easeOutBack,
                          child: FadeInAnimation(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: player.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      player.name,
                                      style: TextStyle(
                                        color: player.color,
                                        fontSize: 20,
                                        fontFamily: 'PixelFont',
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.check),
                                      label: const Text('Угадал'),
                                      onPressed: () {
                                        gameService.addPointTo(player);
                                        _showAnimatedOverlay(
                                          context,
                                          player,
                                          1,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: player.color
                                            .withOpacity(0.8),
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: ShinyButton(
                    text: 'Никто не угадал(',
                    width: buttonWidth,
                    onPressed: () {
                      gameService.addPointTo(currentPlayer, delta: -1);
                      _showAnimatedOverlay(context, currentPlayer, -1);
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
