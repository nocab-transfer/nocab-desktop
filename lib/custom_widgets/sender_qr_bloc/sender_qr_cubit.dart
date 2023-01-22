import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/custom_widgets/sender_qr_bloc/sender_qr_state.dart';

class SenderQrCubit extends Cubit<SenderQrState> {
  SenderQrCubit() : super(const Initial());

  ServerSocket? serverSocket;
  final Duration refreshDuration = const Duration(seconds: 10);

  String? _verificationString;

  Timer? timer;

  Future<void> startQrServer(Function(DeviceInfo device)? onDeviceConnected) async {
    serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    _verificationString = generateRandomString(16);
    emit(ConnectionWaiting(DeviceManager().currentDeviceInfo.ip, serverSocket!.port, _verificationString!));

    Timer.periodic(refreshDuration, (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      rebuildQr();
    });

    serverSocket!.listen((Socket client) async {
      try {
        var data = await client.first;
        var decodedData = json.decode(utf8.decode(base64.decode(utf8.decode(data))));
        if (_verificationString != decodedData['verificationString']) {
          throw Exception("Verification string doesn't match");
        }
        DeviceInfo device = DeviceInfo.fromJson(decodedData['deviceInfo']);
        await client.close();
        onDeviceConnected?.call(device);

        emit(const Initial());
        await Future.delayed(const Duration(seconds: 1));

        rebuildQr();
      } catch (e) {
        client.close();
        rebuildQr();
      }
    });
  }

  void rebuildQr() {
    _verificationString = generateRandomString(16);
    emit(ConnectionWaiting(DeviceManager().currentDeviceInfo.ip, serverSocket!.port, _verificationString!));
  }

  Future<void> stopQrServer() async {
    await serverSocket?.close();
  }

  String generateRandomString(int len) {
    var r = Random();
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }
}
