import 'dart:io';

class Network {
  static Future<NetworkInterface> getCurrentNetworkInterface() async {
    // Force to select network interfaces to Wifi or Ethernet
    //                                 ↓ this stands for blocking vEthernet
    var interfaceNameRegex = RegExp(r'(v\b|\b)(ethernet?.?\w+)|(wi?.?fi?)', caseSensitive: false);

    // if it is not found check this names matching
    List<String> defaultInterfaceNames = [
      'Local Area Connection',
      'Bridge',
      'en',
      'hotspot',
      'w1',
      'eth',
      'wlan0',
    ];

    var networkInterfaces = await NetworkInterface.list();
    return networkInterfaces.firstWhere(
      (element) => interfaceNameRegex.hasMatch(element.name),
      orElse: () => networkInterfaces.firstWhere(
        (element) => defaultInterfaceNames.contains(element.name),
        orElse: () => networkInterfaces.first, // return first if not any matched :(
      ),
    );
  }

  static Future<int> getUnusedPort() {
    return ServerSocket.bind(InternetAddress.anyIPv4, 0).then((socket) {
      var port = socket.port;
      socket.close();
      return port;
    });
  }
}
