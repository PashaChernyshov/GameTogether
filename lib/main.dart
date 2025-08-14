import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multi_game_app/features/connection/connection_controller.dart';
import 'package:multi_game_app/features/home/home_screen.dart';
import 'package:multi_game_app/features/player/player_game_screen.dart';
import 'package:provider/provider.dart';

import 'server.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    Future(() async {
      await startServer();
    });
    print('Сервер запущен');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ConnectionController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Game App',
      theme: ThemeData.dark(),
      home: const _PlatformEntryPoint(),
    );
  }
}

class _PlatformEntryPoint extends StatelessWidget {
  const _PlatformEntryPoint();

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      final uri = Uri.base;
      final gameId = uri.queryParameters['game'];
      if (gameId != null && gameId.isNotEmpty) {
        return PlayerGameScreen(gameId: gameId);
      }
    }

    return const HomeScreen();
  }
}
