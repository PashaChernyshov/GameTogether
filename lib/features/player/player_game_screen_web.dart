import 'dart:html';
import 'package:flutter/material.dart';
import 'package:multi_game_app/features/connection/connection_controller.dart';
import 'package:provider/provider.dart';

class PlayerGameScreenImpl extends StatefulWidget {
  final String gameId;

  const PlayerGameScreenImpl({super.key, required this.gameId});

  @override
  State<PlayerGameScreenImpl> createState() => _PlayerGameScreenImplState();
}

class _PlayerGameScreenImplState extends State<PlayerGameScreenImpl> {
  late ConnectionController connectionController;
  String? playerName;
  final TextEditingController _nameController = TextEditingController();
  bool _connected = false;

  @override
  void initState() {
    super.initState();

    final ip = Uri.base.host.isNotEmpty
        ? Uri.base.host
        : window.location.hostname;

    final url = 'ws://$ip:8080';

    connectionController = Provider.of<ConnectionController>(
      context,
      listen: false,
    );

    connectionController.connectToServer(url);
  }

  String _plural(int count) {
    if (count == 1) return 'игрок';
    if (count >= 2 && count <= 4) return 'игрока';
    return 'игроков';
  }

  void _submitName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      playerName = name;
      _connected = true;
    });

    final message = '{"type": "join", "name": "$playerName"}';
    connectionController.sendMessage(message);

    final index = connectionController.connectedPlayers.indexOf(playerName!);
    print('🧾 Игрок "$playerName" имеет номер: ${index + 1}');
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ConnectionController>(context);
    final count = controller.playerCount == 0 ? 1 : controller.playerCount;

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade900,
      body: Center(
        child: !_connected
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Введите имя игрока:',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Например: Игрок 1',
                        hintStyle: const TextStyle(color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitName,
                      child: const Text('Присоединиться'),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    playerName ?? '...',
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Подключено: $count ${_plural(count)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}
