import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocab_desktop/custom_widgets/device_finder_bloc/device_finder_state.dart';
import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/services/settings/settings.dart';

class DeviceFinderCubit extends Cubit<DeviceFinderState> {
  DeviceFinderCubit() : super(const NoDevice());

  Timer? timer;

  Future<void> startScanning() async {
    var networkList = await NetworkInterface.list();
    NetworkInterface currentInterface = networkList.firstWhere((element) => element.name == SettingsService().getSettings.networkInterfaceName, orElse: () => networkList.first);
    String baseIp = currentInterface.addresses.first.address.split('.').sublist(0, 3).join('.');

    timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (isClosed) timer?.cancel();

      List<DeviceInfo> devices = [];
      for (int i = 1; i < 255; i++) {
        try {
          Socket socket = await Socket.connect('$baseIp.$i', 62192, timeout: const Duration(milliseconds: 15));
          Uint8List data = await socket.first.timeout(const Duration(seconds: 5));
          if (data.isNotEmpty && socket.remoteAddress.address != currentInterface.addresses.first.address) {
            devices.add(DeviceInfo.fromJson(json.decode(utf8.decode(base64.decode(utf8.decode(data))))));
            if (!isClosed) emit(Found(devices));
          }

          socket.close();
          // ignore: empty_catches
        } catch (e) {}
      }

      if (devices.isEmpty && !isClosed) emit(const NoDevice());
    });
  }

  Future<void> stopScanning() async {
    timer?.cancel();
  }

  Future<bool> isDeviceStillActive(DeviceInfo device) async {
    var socket = await Socket.connect(device.ip, 62193, timeout: const Duration(seconds: 1));
    Uint8List data = await socket.first.timeout(const Duration(seconds: 1));
    if (device.name == json.decode(utf8.decode(base64.decode(utf8.decode(data))))['name']) return true;
    return false;
  }
}
