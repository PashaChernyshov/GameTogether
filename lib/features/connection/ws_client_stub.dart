import 'dart:io';
import 'ws_client.dart';

class WsClientStub implements WsClient {
  WebSocket? _socket;

  @override
  void connect(String url, void Function(String message) onMessage) async {
    try {
      _socket = await WebSocket.connect(url);
      print('Connected to server at $url');
      _socket?.listen(
        (data) => onMessage(data.toString()),
        onError: (error) => print('WebSocket error: $error'),
        onDone: () => print('WebSocket connection closed'),
      );
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
    }
  }

  @override
  void sendMessage(String message) {
    _socket?.add(message);
  }

  @override
  void disconnect() {
    _socket?.close();
  }
}

WsClient createWsClient() => WsClientStub();
