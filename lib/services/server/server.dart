import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:nocab_desktop/custom_dialogs/file_accepter_dialog/file_accepter_dialog.dart';
import 'package:nocab_desktop/models/database/transfer_db.dart';
import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/models/settings_model.dart';
import 'package:nocab_desktop/services/database/database.dart';
import 'package:nocab_desktop/services/file_operations/file_operations.dart';
import 'package:nocab_desktop/services/network/network.dart';
import 'package:nocab_desktop/services/settings/settings.dart';
import 'package:nocab_desktop/services/transfer/receiver.dart';
import 'package:nocab_desktop/services/transfer/sender.dart';
import 'package:nocab_desktop/services/transfer/transfer.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';

class Server {
  static final Server _singleton = Server._internal();

  factory Server() {
    return _singleton;
  }

  Server._internal();

  late InternetAddress _selectedIp;

  InternetAddress get selectedIp => _selectedIp;
  set setSelectedIp(NetworkInterface interface) =>
      _selectedIp = interface.addresses.firstWhere((element) => element.type == InternetAddressType.IPv4, orElse: () {
        FlutterPlatformAlert.showAlert(
          windowTitle: 'Warning',
          text: 'Selected network adapter is not contain IPv4 address. Please select another network interface.',
          options: FlutterPlatformAlertOption(additionalWindowTitleOnWindows: 'NoCab Desktop'),
          alertStyle: AlertButtonStyle.ok,
          iconStyle: IconStyle.warning,
        );
        return InternetAddress("0.0.0.0", type: InternetAddressType.IPv4);
      });

  static String deviceID = "test";
  late DeviceInfo deviceInfo;

  Future<void> initialize() async {
    List<NetworkInterface> networkInterfaces = await NetworkInterface.list();
    setSelectedIp = networkInterfaces.firstWhere((element) => element.name == SettingsService().getSettings.networkInterfaceName, orElse: () {
      var networkInterface = Network.getCurrentNetworkInterface(networkInterfaces);
      SettingsService().setSettings(SettingsService().getSettings.copyWith(networkInterfaceName: networkInterface.name));
      return networkInterface;
    });

    deviceInfo = DeviceInfo(
        name: SettingsService().getSettings.deviceName,
        ip: selectedIp.address,
        port: SettingsService().getSettings.mainPort,
        opsystem: Platform.operatingSystemVersion,
        deviceId: deviceID);
    SettingsService().onSettingChanged.listen((settings) {
      deviceInfo = DeviceInfo(
        name: settings.deviceName,
        ip: selectedIp.address,
        port: settings.mainPort,
        opsystem: Platform.operatingSystemVersion,
        deviceId: deviceID,
      );
    });
  }

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  final _changeController = StreamController<List<Transfer>>.broadcast();
  Stream<List<Transfer>> get onNewTransfer => _changeController.stream;

  List<Transfer> activeTransfers = [];

  //Receiver

  bool activeRequest = false;
  Future<void> startReceiver() async {
    // other devices can find this device
    ServerSocket? finderSocket;
    try {
      finderSocket = await ServerSocket.bind(InternetAddress.anyIPv4, SettingsService().getSettings.finderPort);
    } catch (e) {
      FlutterPlatformAlert.showAlert(
        windowTitle: 'Error',
        text: 'Port ${SettingsService().getSettings.finderPort} is already in use. Please change the port in the settings.\n\n$e',
        alertStyle: AlertButtonStyle.ok,
        iconStyle: IconStyle.error,
      );
    }

    finderSocket?.listen((socket) {
      socket.write(base64.encode(utf8.encode(json.encode(deviceInfo.toJson()))));
    });

    ServerSocket? serverSocket;
    try {
      serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, SettingsService().getSettings.mainPort);
    } catch (e) {
      FlutterPlatformAlert.showCustomAlert(
        windowTitle: 'Error',
        text:
            'Port ${SettingsService().getSettings.mainPort} is already in use. Try restarting the application.\n\nIf the problem persists, recreate settings. Recreating settings will assign an unused port.\n\n$e',
        positiveButtonTitle: 'Quit',
        negativeButtonTitle: 'Recreate settings file',
        iconStyle: IconStyle.error,
      ).then((value) async {
        if (value == CustomButton.negativeButton) {
          await finderSocket?.close();
          await SettingsService().recreateSettings();
          return;
        } else if (value == CustomButton.positiveButton) {
          exit(0);
        }
      });
    }

    serverSocket?.listen((socket) {
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
          socket.close();
        }
      }, onDone: () {
        activeRequest = false;
      });
    });
  }

  Future<void> _requestHandler(ShareRequest request, Socket socket) async {
    // TODO: Database ban check
    request.transferUuid = const Uuid().v4();
    Database().pushTransferToDb(TransferDatabase()
      ..device = request.deviceInfo.toIsarDb()
      ..files = request.files.map((e) => e.toIsarDb()).toList()
      ..transferUuid = request.transferUuid!
      ..requestedAt = DateTime.now()
      ..status = TransferDbStatus.pendingForAcceptance
      ..type = TransferDbType.download
      ..managedBy = TransferDbManagedBy.user);
    if (true) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (buildContext) => FileAccepterDialog(
          request: request,
          socket: socket,
        ),
      );
      windowManager.focus();
    }
  }

  Future<void> acceptRequest(ShareRequest request, Socket socket) async {
    ShareResponse shareResponse = ShareResponse(response: true);
    socket.write(base64.encode(utf8.encode(json.encode(shareResponse.toJson()))));
    socket.close();

    request.files = request.files.map<FileInfo>((e) {
      e.path = FileOperations.findUnusedFilePath(downloadPath: SettingsService().getSettings.downloadPath, fileName: e.name);
      return e;
    }).toList();

    Receiver receiver = Receiver(
      deviceInfo: request.deviceInfo,
      files: request.files,
      transferPort: request.transferPort,
      uniqueId: request.transferUuid!,
    )..onEvent.listen((report) => Database().updateTransferByReport(report));

    activeTransfers.add(receiver);
    _changeController.add(activeTransfers);
  }

  Future<void> rejectRequest(ShareRequest request, Socket socket, [String? message]) async {
    ShareResponse shareResponse = ShareResponse(response: false, info: message ?? "User rejected request");
    socket.write(base64.encode(utf8.encode(json.encode(shareResponse.toJson()))));
    socket.close();
    Database().updateTransfer(
      request.transferUuid!,
      status: TransferDbStatus.declined,
      managedBy: TransferDbManagedBy.user,
    );
  }

  // Sender

  Future<bool> send(DeviceInfo deviceInfo, List<FileInfo> files) async {
    int port = await Network.getUnusedPort();

    var request = ShareRequest(
      deviceInfo: DeviceInfo(
        name: SettingsService().getSettings.deviceName,
        ip: selectedIp.address,
        port: SettingsService().getSettings.mainPort,
        opsystem: Platform.operatingSystemVersion,
        deviceId: deviceID,
      ),
      files: files,
      transferPort: port,
    )..transferUuid = const Uuid().v4();

    Socket socket = await Socket.connect(deviceInfo.ip, deviceInfo.port);
    socket.write(base64.encode(utf8.encode(json.encode(request.toJson()))));

    Database().pushTransferToDb(TransferDatabase()
      ..device = request.deviceInfo.toIsarDb()
      ..files = request.files.map((e) => e.toIsarDb()).toList()
      ..transferUuid = request.transferUuid!
      ..requestedAt = DateTime.now()
      ..status = TransferDbStatus.pendingForAcceptance
      ..type = TransferDbType.upload
      ..managedBy = TransferDbManagedBy.user);

    ShareResponse shareResponse = ShareResponse.fromJson(json.decode(utf8.decode(base64.decode(utf8.decode(await socket.first)))));

    if (!shareResponse.response!) {
      await Database().updateTransfer(request.transferUuid!, status: TransferDbStatus.declined);
      return false;
    }

    Sender sender = Sender(
      deviceInfo: deviceInfo,
      files: files,
      transferPort: port,
      uniqueId: request.transferUuid!,
    )..onEvent.listen((report) => Database().updateTransferByReport(report));

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
