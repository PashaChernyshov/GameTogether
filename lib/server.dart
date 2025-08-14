import 'dart:convert';
import 'dart:io';

Future<void> startServer() async {
  final staticFiles = Directory('build/web');

  if (!staticFiles.existsSync()) {
    print('❌ Не найдена папка build/web. Выполни: flutter build web');
    return;
  }

  HttpServer server;
  try {
    server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  } on SocketException catch (e) {
    print('❌ Не удалось запустить сервер: $e');
    return;
  }

  final webSocketClients = <WebSocket>[];
  final socketToName = <WebSocket, String>{};

  final interfaces = await NetworkInterface.list(
    includeLoopback: false,
    type: InternetAddressType.IPv4,
  );

  final ip = interfaces
      .expand((interface) => interface.addresses)
      .map((a) => a.address)
      .firstWhere(
        (addr) => addr.startsWith('192.168.') || addr.startsWith('10.'),
        orElse: () => '127.0.0.1',
      );

  print('✅ HTTP/WebSocket сервер запущен на http://$ip:8080');

  server.listen((HttpRequest request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = await WebSocketTransformer.upgrade(request);
      webSocketClients.add(socket);

      print('📡 Новое WebSocket-соединение (${webSocketClients.length} всего)');

      socket.listen(
        (data) {
          final index = webSocketClients.indexOf(socket);
          print('📨 Получено сообщение от клиента [#${index + 1}]: $data');

          try {
            final decoded = jsonDecode(data);
            if (decoded is Map &&
                decoded['type'] == 'join' &&
                decoded['name'] != null) {
              final name = decoded['name'].toString();
              socketToName[socket] = name;

              print('🧍 Игрок $name подключён');

              for (final client in webSocketClients) {
                client.add(jsonEncode({'type': 'join', 'name': name}));
              }
            }
          } catch (e) {
            print('❗ Ошибка парсинга сообщения: $e');
          }
        },
        onDone: () {
          final name = socketToName.remove(socket);
          webSocketClients.remove(socket);

          if (name != null) {
            print('❌ Игрок $name отключился');
            for (final client in webSocketClients) {
              client.add(jsonEncode({'type': 'leave', 'name': name}));
            }
          } else {
            print('❌ Отключено соединение без регистрации (анонимный сокет)');
          }
        },
        onError: (error) {
          print('⚠️ Ошибка WebSocket: $error');
        },
        cancelOnError: true,
      );
    } else {
      final path = request.uri.path == '/' ? '/index.html' : request.uri.path;
      final file = File('${staticFiles.path}$path');
      if (await file.exists()) {
        final ext = file.path.split('.').last;
        request.response.headers.contentType = ContentType.parse(_mime(ext));
        await request.response.addStream(file.openRead());
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('Not Found');
      }
      await request.response.close();
    }
  });
}

String _mime(String ext) {
  switch (ext) {
    case 'html':
      return 'text/html';
    case 'js':
      return 'application/javascript';
    case 'css':
      return 'text/css';
    case 'png':
      return 'image/png';
    case 'jpg':
      return 'image/jpeg';
    case 'svg':
      return 'image/svg+xml';
    default:
      return 'text/plain';
  }
}
