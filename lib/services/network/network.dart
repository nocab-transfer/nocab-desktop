import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

class Network {
  Network._internal();
  static final Network _singleton = Network._internal();
  factory Network() {
    return _singleton;
  }

  late List<NetworkInterface> networkInterfaces;

  final StreamController<List<NetworkInterface>> _networkInterfacesController = StreamController.broadcast();
  Stream<List<NetworkInterface>> get onNetworkInterfacesChanged => _networkInterfacesController.stream;

  Future<void> initialize() async {
    Duration interval = const Duration(seconds: 5);

    networkInterfaces = await NetworkInterface.list();

    Timer.periodic(interval, (timer) async {
      await NetworkInterface.list().then((value) {
        if (listEquals(networkInterfaces, value)) return;
        networkInterfaces = value;
        _networkInterfacesController.add(networkInterfaces);
      });
    });
  }

  static NetworkInterface getCurrentNetworkInterface(List<NetworkInterface> networkInterfaces) {
    // Force to select network interfaces to Wifi or Ethernet
    //                                 ↓ this stands for blocking vEthernet
    var interfaceNameRegex = RegExp(r'(v\b|\b)(ethernet?.?\w+)|(wi.?fi)', caseSensitive: false);

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

    //var networkInterfaces = await NetworkInterface.list();
    return networkInterfaces.firstWhere(
      (element) => interfaceNameRegex.hasMatch(element.name),
      orElse: () => networkInterfaces.firstWhere(
        (element) => defaultInterfaceNames.contains(element.name),
        orElse: () => networkInterfaces.first, // return first if not any matched :(
      ),
    );
  }

  static NetworkInterface? getNetworkInterfaceByName(String name, List<NetworkInterface?> networkInterfaces) {
    return networkInterfaces.firstWhere((element) => element?.name == name);
  }

  static Future<int> getUnusedPort() {
    return ServerSocket.bind(InternetAddress.anyIPv4, 0).then((socket) {
      var port = socket.port;
      socket.close();
      return port;
    });
  }
}
