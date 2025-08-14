import 'package:flutter/material.dart';
import 'package:multi_game_app/features/connection/connection_controller.dart';
import 'package:multi_game_app/features/connection/qr_generator.dart';
import 'package:provider/provider.dart';

class ConnectionScreen extends StatefulWidget {
  final String gameId;

  const ConnectionScreen({super.key, required this.gameId});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  @override
  void initState() {
    super.initState();

    final ip = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
    final url = 'ws://$ip:8080';

    Future.microtask(() {
      final controller = Provider.of<ConnectionController>(
        context,
        listen: false,
      );
      controller.connectToServer(url, selfName: '__host__');
    });
  }

  String _plural(int count) {
    if (count == 1) return 'игрок';
    if (count >= 2 && count <= 4) return 'игрока';
    return 'игроков';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ConnectionController>(context);
    final count = controller.playerCount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Ожидание игроков')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QRGenerator(gameId: widget.gameId),
            const SizedBox(height: 20),
            Text('Подключено: $count ${_plural(count)}'),
            ...controller.connectedPlayers.map((p) => Text(p)).toList(),
          ],
        ),
      ),
    );
  }
}
