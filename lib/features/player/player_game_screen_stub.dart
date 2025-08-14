import 'package:flutter/material.dart';

class PlayerGameScreenImpl extends StatelessWidget {
  final String gameId;

  const PlayerGameScreenImpl({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Not supported on Desktop')),
    );
  }
}
