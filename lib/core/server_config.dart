// lib/core/server_config.dart

import 'dart:io';

Future<String> getLocalIpAddress() async {
  final interfaces = await NetworkInterface.list();
  for (var interface in interfaces) {
    for (var addr in interface.addresses) {
      if (addr.type == InternetAddressType.IPv4 &&
          !addr.isLoopback &&
          !addr.address.startsWith('169')) {
        return addr.address;
      }
    }
  }
  return 'localhost';
}
