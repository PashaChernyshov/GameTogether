import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'ws_client.dart';

class ConnectionController extends ChangeNotifier {
  final List<String> _connectedPlayers = [];
  final WsClient _wsClient = WsClient();
  String? _selfName;

  List<String> get connectedPlayers => List.unmodifiable(_connectedPlayers);
  int get playerCount => _connectedPlayers.length;

  void connectToServer(String url, {String? selfName}) {
    _selfName = selfName;
    print('🌐 Подключаемся к серверу: $url');

    _wsClient.connect(url, (message) {
      print('📥 Получено сообщение: $message');

      try {
        final decoded = jsonDecode(message);

        if (decoded is Map && decoded['type'] == 'join') {
          final name = decoded['name']?.toString();
          if (name != null &&
              name != _selfName &&
              !_connectedPlayers.contains(name)) {
            _connectedPlayers.add(name);
            print('➕ Добавлен игрок: $name');
            notifyListeners();
          }
        }

        if (decoded is Map && decoded['type'] == 'leave') {
          final name = decoded['name']?.toString();
          if (name != null &&
              name != _selfName &&
              _connectedPlayers.contains(name)) {
            _connectedPlayers.remove(name);
            print('➖ Удалён игрок: $name');
            notifyListeners();
          }
        }
      } catch (e) {
        print('❗ Ошибка парсинга JSON: $e');
      }
    });
  }

  void sendMessage(String message) {
    _wsClient.sendMessage(message);
  }

  void disconnect() {
    _wsClient.disconnect();
  }

  void clearPlayers() {
    _connectedPlayers.clear();
    notifyListeners();
  }
}
