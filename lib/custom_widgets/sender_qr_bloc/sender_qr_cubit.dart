import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocab_desktop/custom_widgets/receiver_qr_bloc/sender_qr_state.dart';
import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/services/server/server.dart';

class SenderQrCubit extends Cubit<SenderQrState> {
  SenderQrCubit() : super(const Initial());

  ServerSocket? serverSocket;
  final Duration refreshDuration = const Duration(seconds: 30);
  Timer? timer;

  String? _verificationString;

  Future<void> startQrServer(Function(DeviceInfo device)? onDeviceConnected) async {
    serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    _verificationString = generateRandomString(16);
    emit(ConnectionWaiting(Server().selectedIp.address, serverSocket!.port, _verificationString!));

    serverSocket!.listen((Socket client) async {
      try {
        var data = await client.first;
        var decodedData = json.decode(utf8.decode(base64.decode(utf8.decode(data))));
        if (_verificationString != decodedData['verificationString']) {
          client.write("Verification string doesn't match");
          throw Exception("Verification string doesn't match");
        }
        DeviceInfo device = DeviceInfo.fromJson(decodedData['deviceInfo']);
        await client.close();
        onDeviceConnected?.call(device);

        stopTimer(); // while mobile app is scanning the qr, it will scans multiple qrs if we keep showing the qr. And the timer causing rebuilds the qr every 40 milliseconds
        emit(const Initial());
        await Future.delayed(const Duration(seconds: 1));

        _verificationString = generateRandomString(16);
        emit(ConnectionWaiting(Server().selectedIp.address, serverSocket!.port, _verificationString!));
        startTimer();
      } catch (e) {
        client.close();

        stopTimer();
        emit(const Initial());
        await Future.delayed(const Duration(seconds: 1));
        _verificationString = generateRandomString(16);
        emit(ConnectionWaiting(Server().selectedIp.address, serverSocket!.port, _verificationString!));
        startTimer();
      }
    });

    startTimer();
  }

  void stopTimer() {
    timer?.cancel();
  }

  void startTimer() {
    Duration currentDuration = Duration.zero;

    timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (isClosed) {
        serverSocket?.close();
        timer.cancel();
        return;
      }
      if (currentDuration.inMilliseconds % refreshDuration.inMilliseconds == 0) {
        emit(const Initial());
        currentDuration = Duration.zero;
        _verificationString = generateRandomString(16);
      }

      emit(ConnectionWaiting(Server().selectedIp.address, serverSocket!.port, _verificationString!, currentDuration: currentDuration));
      currentDuration += const Duration(milliseconds: 40);
    });
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
