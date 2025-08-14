import 'package:flutter/material.dart';
import 'player_game_screen_stub.dart'
    if (dart.library.html) 'player_game_screen_web.dart';

class PlayerGameScreen extends StatelessWidget {
  final String gameId;

  const PlayerGameScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return PlayerGameScreenImpl(gameId: gameId);
  }
}
