import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/game_service.dart';
import 'who_draws_screen.dart';
import 'winner_screen.dart';
import 'rules_screen.dart';
import '../widgets/shiny_button.dart';
import '../widgets/animated_background.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen>
    with TickerProviderStateMixin {
  late List<_AnimatedPlayer> _players;

  @override
  void initState() {
    super.initState();
    _players = gameService.players
        .map((p) => _AnimatedPlayer(
              player: p,
              controller: AnimationController(
                vsync: this,
                duration: const Duration(milliseconds: 600),
              ),
            ))
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final animated in _players) {
        animated.controller.forward();
      }
    });

    _players.sort((a, b) => b.player.score.compareTo(a.player.score));
  }

  @override
  void dispose() {
    for (final animated in _players) {
      animated.controller.dispose();
    }
    super.dispose();
  }

  void _next() {
    if (gameService.isGameOver) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WinnerScreen()),
      );
    } else {
      gameService.nextTurn();
      gameService.generateWord();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WhoDrawsScreen()),
      );
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: Colors.black.withOpacity(0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Точно хочешь выйти?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontFamily: 'PixelFont',
              ),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Остаться',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const RulesScreen()),
                    (_) => false,
                  );
                },
                child: const Text(
                  'Да',
                  style: TextStyle(color: Colors.redAccent, fontSize: 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 300).clamp(0.0, 300.0);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const AnimatedBackground(),

            // 🔙 Кнопка выхода
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.exit_to_app, color: Colors.white),
                onPressed: _showExitDialog,
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Текущие баллы:',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontFamily: 'PixelFont',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Первый, кто наберёт 10 очков, победит!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontFamily: 'PixelFont',
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AnimatedList(
                      initialItemCount: _players.length,
                      itemBuilder: (context, index, animation) {
                        final animated = _players[index];
                        return SizeTransition(
                          sizeFactor: CurvedAnimation(
                            parent: animated.controller,
                            curve: Curves.easeOutBack,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black.withOpacity(0.3),
                                border: Border.all(
                                  color: const Color(0xFFB388FF),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    animated.player.name,
                                    style: TextStyle(
                                      color: animated.player.color,
                                      fontSize: 20,
                                      fontFamily: 'PixelFont',
                                    ),
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 600),
                                    transitionBuilder: (child, anim) =>
                                        SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 1),
                                        end: Offset.zero,
                                      ).animate(anim),
                                      child: FadeTransition(
                                          opacity: anim, child: child),
                                    ),
                                    child: Text(
                                      '${animated.player.score}',
                                      key: ValueKey(animated.player.score),
                                      style: TextStyle(
                                        color: animated.player.color,
                                        fontSize: 22,
                                        fontFamily: 'PixelFont',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ShinyButton(
                  text: 'Далее',
                  width: buttonWidth,
                  onPressed: _next,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedPlayer {
  final dynamic player;
  final AnimationController controller;

  _AnimatedPlayer({required this.player, required this.controller});
}
