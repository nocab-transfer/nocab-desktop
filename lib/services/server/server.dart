import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nocab_desktop/custom_dialogs/file_accepter_dialog.dart';
import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/models/settings_model.dart';
import 'package:nocab_desktop/services/file_operations/file_operations.dart';
import 'package:nocab_desktop/services/network/network.dart';
import 'package:nocab_desktop/services/settings/settings.dart';
import 'package:nocab_desktop/services/transfer/receiver.dart';
import 'package:nocab_desktop/services/transfer/sender.dart';
import 'package:nocab_desktop/services/transfer/transfer.dart';
import 'package:window_manager/window_manager.dart';

class Server {
  static final Server _singleton = Server._internal();

  factory Server() {
    return _singleton;
  }

  Server._internal();

  late NetworkInterface currentInterFace;
  late String deviceID = "test";
  late DeviceInfo deviceInfo;

  Future<void> initialize() async {
    List<NetworkInterface> networkInterfaces = await NetworkInterface.list();
    currentInterFace = networkInterfaces.firstWhere((element) => element.name == SettingsService().getSettings.networkInterfaceName, orElse: () {
      var networkInterface = Network.getCurrentNetworkInterface(networkInterfaces);
      SettingsService().setSettings(SettingsService().getSettings.copyWith(networkInterfaceName: networkInterface.name));
      return networkInterface;
    });

    deviceInfo = DeviceInfo(name: SettingsService().getSettings.deviceName, ip: currentInterFace.addresses.first.address, port: SettingsService().getSettings.mainPort, opsystem: Platform.operatingSystemVersion, uuid: deviceID);
    SettingsService().onSettingChanged.listen((settings) {
      deviceInfo = DeviceInfo(
        name: settings.deviceName,
        ip: currentInterFace.addresses.first.address,
        port: settings.mainPort,
        opsystem: Platform.operatingSystemVersion,
        uuid: deviceID,
      );
    });
  }

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final _changeController = StreamController<List<Transfer>>();
  Stream<List<Transfer>> get onNewTransfer => _changeController.stream.asBroadcastStream();

  List<Transfer> activeTransfers = [];

  //Receiver

  bool activeRequest = false;
  Future<void> startReceiver() async {
    // other devices can find this device
    ServerSocket? finderSocket;
    try {
      await ServerSocket.bind(InternetAddress.anyIPv4, SettingsService().getSettings.finderPort);
    } catch (e) {
      //showDialog(context: , builder: builder)
    }

    finderSocket?.listen((socket) {
      socket.write(base64.encode(utf8.encode(json.encode(deviceInfo.toJson()))));
    });

    ServerSocket serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, SettingsService().getSettings.mainPort);

    serverSocket.listen((socket) {
      if (activeRequest) {
        socket.write("Please try again later.");
        socket.close();
      }

      socket.listen((element) {
        activeRequest = true;
        try {
          String socketData = utf8.decode(base64.decode(utf8.decode(element)));
          ShareRequest request = ShareRequest.fromJson(json.decode(socketData));
          _requestHandler(request, socket);
        } catch (e) {
          print(e);
          socket.close();
        }
      }, onDone: () {
        activeRequest = false;
      });
    });
  }

  Future<void> _requestHandler(ShareRequest request, Socket socket) async {
    // TODO: Database ban check
    if (true) {
      showDialog(context: navigatorKey.currentContext!, builder: (buildContext) => FileAccepterDialog(request: request, socket: socket));
      windowManager.focus();
    }
  }

  Future<void> acceptRequest(ShareRequest request, Socket socket) async {
    ShareResponse shareResponse = ShareResponse(response: true);
    socket.write(base64.encode(utf8.encode(json.encode(shareResponse.toJson()))));
    socket.close();

    request.files = request.files.map<FileInfo>((e) {
      e.path = FileOperations.findUnusedFilePath(downloadPath: '${File(Platform.resolvedExecutable).parent.path}\\output', fileName: e.name);
      return e;
    }).toList();

    activeTransfers.add(Receiver(deviceInfo: request.deviceInfo, files: request.files, transferPort: request.transferPort));
    _changeController.add(activeTransfers);
  }

  Future<void> rejectRequest(ShareRequest request, Socket socket, [String? message]) async {
    ShareResponse shareResponse = ShareResponse(response: false, info: message ?? "User rejected request");
    socket.write(base64.encode(utf8.encode(json.encode(shareResponse.toJson()))));
    socket.close();
  }

  // Sender

  Future<bool> send(DeviceInfo deviceInfo, List<FileInfo> files) async {
    int port = await Network.getUnusedPort();

    Socket socket = await Socket.connect(deviceInfo.ip, deviceInfo.port!);
    socket.write(base64.encode(utf8.encode(json.encode(ShareRequest(
      deviceInfo: DeviceInfo(name: SettingsService().getSettings.deviceName, ip: currentInterFace.addresses.first.address, port: SettingsService().getSettings.mainPort, opsystem: Platform.operatingSystemVersion, uuid: deviceID),
      files: files,
      transferPort: port,
      uniqueId: "test",
    ).toJson()))));

    ShareResponse shareResponse = ShareResponse.fromJson(json.decode(utf8.decode(base64.decode(utf8.decode(await socket.first)))));

    if (!shareResponse.response!) return false;

    Sender sender = Sender(deviceInfo: deviceInfo, files: files, transferPort: port);
    activeTransfers.add(sender);
    _changeController.add(activeTransfers);
    return true;
  }

  // tools

  Future<void> removeTransferFromList(Transfer transfer) async {
    activeTransfers.remove(transfer);
    _changeController.add(activeTransfers);
  }
}
