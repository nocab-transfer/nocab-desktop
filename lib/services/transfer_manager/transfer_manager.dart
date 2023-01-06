import 'dart:async';
import 'dart:io';

import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/custom_dialogs/file_accepter_dialog/file_accepter_dialog.dart';
import 'package:nocab_desktop/models/settings_model.dart';
import 'package:nocab_desktop/services/database/database.dart';
import 'package:nocab_desktop/services/dialog_service/dialog_service.dart';
import 'package:nocab_desktop/services/network/network.dart';
import 'package:nocab_desktop/services/settings/settings.dart';
import 'package:path_provider/path_provider.dart';

class TransferManager {
  static final TransferManager _singleton = TransferManager._internal();

  factory TransferManager() {
    return _singleton;
  }

  TransferManager._internal();

  final _requestController = StreamController<ShareRequest>.broadcast();
  Stream<ShareRequest> get onRequest => _requestController.stream;

  List<Transfer> transfers = [];

  final _transferController = StreamController<List<Transfer>>.broadcast();
  Stream<List<Transfer>> get onNewTransfer => _transferController.stream;

  int portBindErrorCount = 0;

  Future<void> initialize() async {
    DeviceManager().initialize(
      SettingsService().getSettings.deviceName,
      SettingsService().getNetworkInterface.addresses.first.address,
      SettingsService().getSettings.mainPort,
    );

    RequestListener().start(onError: (e) async {
      if (e is SocketException && e.osError?.errorCode == 10048) {
        if (portBindErrorCount > 5) return; // TODO: Show error dialog
        portBindErrorCount++;
        int newPort = await Network.getUnusedPort();
        await SettingsService().setSettings(SettingsService().getSettings.copyWith(mainPort: newPort));
        DeviceManager().updateDeviceInfo(requestPort: newPort);
        RequestListener().stop();
        initialize();
      }
    });

    RequestListener().onRequest.listen((request) async {
      if (await Database().exist(request.transferUuid)) {
        request.reject(info: "UUID already exist, Please try again");
        return;
      }

      Database().registerRequest(
        request: request,
        receiverDeviceInfo: DeviceManager().currentDeviceInfo,
        senderDeviceInfo: request.deviceInfo,
        thisIsSender: false,
      );

      DialogService().showModal((context) => FileAccepterDialog(request: request));

      _requestController.add(request);
      request.onResponse.then((event) {
        if (event.response) {
          transfers.add(request.linkedTransfer!);
          _transferController.add(transfers);
        }
      });
    });
  }

  Future<void> acceptRequest(ShareRequest request) async {
    request.accept(downloadDirectory: Directory(SettingsService().getSettings.downloadPath), tempDirectory: await getTemporaryDirectory());
  }

  void rejectRequest(ShareRequest request) {
    request.reject();
  }

  void removeTranser(Transfer transfer) {
    transfers.removeWhere((element) => element.uuid == transfer.uuid);
    _transferController.add(transfers);
  }

  Future<void> sendRequest(DeviceInfo receiverDeviceInfo, List files) async {
    var request = RequestMaker.create(files: files, transferPort: await Network.getUnusedPort());

    Database().registerRequest(request: request, receiverDeviceInfo: receiverDeviceInfo, senderDeviceInfo: request.deviceInfo, thisIsSender: true);
    RequestMaker.requestTo(receiverDeviceInfo, request: request);

    request.onResponse.then((event) {
      if (event.response) {
        transfers.add(request.linkedTransfer!);
        _transferController.add(transfers);
      }
    });
  }
}
