import 'ws_client_stub.dart' if (dart.library.html) 'ws_client_web.dart';

abstract class WsClient {
  void connect(String url, void Function(String message) onMessage);
  void sendMessage(String message);
  void disconnect();

  factory WsClient() => createWsClient();
}
