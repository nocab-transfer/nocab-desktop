import 'dart:io';

class Network {
  static Future<NetworkInterface> getCurrentNetworkInterface() async {
    List<String> defaultInterfaceNames = [
      'Wi-Fi',
      'Ethernet',
      'Local Area Connection',
      'Bridge',
      'en',
      'hotspot',
      'w1',
      'eth',
      'wlan0',
    ];

    List<NetworkInterface> interfaces = await NetworkInterface.list();

    return interfaces.firstWhere((element) => defaultInterfaceNames.contains(element.name), orElse: () => interfaces.first);
  }

  static Future<int> getUnusedPort() {
    return ServerSocket.bind(InternetAddress.anyIPv4, 0).then((socket) {
      var port = socket.port;
      socket.close();
      return port;
    });
  }
}
