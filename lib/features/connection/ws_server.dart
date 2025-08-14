import 'dart:io';

class WsServer {
  final List<WebSocket> _clients = [];

  Future<void> start() async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 4040);
    print('WebSocket server listening on ws://${server.address.address}:4040');

    await for (HttpRequest request in server) {
      if (request.uri.path == '/ws') {
        WebSocketTransformer.upgrade(request).then((WebSocket socket) {
          _clients.add(socket);
          print('Client connected: ${socket.hashCode}');

          socket.listen(
            (data) {
              final index = _clients.indexOf(socket);
              print('📨 Получено сообщение от клиента [#${index + 1}]: $data');

              // Пересылаем ВСЕМ (включая отправителя)
              for (var client in _clients) {
                client.add(data);
              }
            },
            onDone: () {
              print('Client disconnected: ${socket.hashCode}');
              _clients.remove(socket);
            },
            onError: (error) {
              print('Socket error: $error');
              _clients.remove(socket);
            },
          );
        });
      } else {
        request.response.statusCode = HttpStatus.forbidden;
        await request.response.close();
      }
    }
  }
}
