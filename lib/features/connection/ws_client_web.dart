import 'dart:html';
import 'ws_client.dart';

class WsClientWeb implements WsClient {
  WebSocket? _socket;

  @override
  void connect(String url, void Function(String message) onMessage) {
    _socket = WebSocket(url);

    _socket?.onOpen.listen((_) {
      print('WebSocket connected to $url');
    });

    _socket?.onError.listen((event) {
      print('WebSocket connection error: $event');
    });

    _socket?.onClose.listen((event) {
      print('WebSocket closed');
    });

    _socket?.onMessage.listen((event) {
      onMessage(event.data);
    });
  }

  @override
  void sendMessage(String message) {
    _socket?.send(message);
  }

  @override
  void disconnect() {
    _socket?.close();
  }
}

WsClient createWsClient() => WsClientWeb();
