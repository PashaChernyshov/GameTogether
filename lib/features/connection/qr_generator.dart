import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGenerator extends StatelessWidget {
  final String gameId;

  const QRGenerator({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getLocalIp(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final url = 'http://${snapshot.data!}:8080?game=$gameId';

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(data: url, version: QrVersions.auto, size: 250.0),
            const SizedBox(height: 10),
            SelectableText(url, style: const TextStyle(fontSize: 16)),
          ],
        );
      },
    );
  }

  Future<String> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          // Возвращаем только адреса из диапазона 192.168.x.x или 10.x.x.x
          if (addr.address.startsWith('192.168.') ||
              addr.address.startsWith('10.')) {
            return addr.address;
          }
        }
      }

      return 'localhost';
    } catch (_) {
      return 'localhost';
    }
  }
}
