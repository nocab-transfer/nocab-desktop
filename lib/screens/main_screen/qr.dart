import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/services/server/server.dart';
import 'package:nocab_desktop/services/settings/settings.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Qr extends StatefulWidget {
  const Qr({Key? key}) : super(key: key);

  @override
  State<Qr> createState() => _QrState();
}

class _QrState extends State<Qr> {
  @override
  Widget build(BuildContext context) {
    return _builQr();
  }

  Widget _builQr() {
    return StreamBuilder(
      stream: SettingsService().onSettingChanged,
      initialData: SettingsService().getSettings,
      builder: (context, snapshot) {
        return QrImage(
          data: base64.encode(utf8.encode(json.encode(DeviceInfo(name: snapshot.data?.deviceName, ip: Server().selectedIp.address, port: snapshot.data?.mainPort, opsystem: Platform.operatingSystem, uuid: "").toJson()))), //server.getQr, //TODO: get qr from server
          version: QrVersions.auto,
          dataModuleStyle: const QrDataModuleStyle(color: Colors.black, dataModuleShape: QrDataModuleShape.circle),
          eyeStyle: const QrEyeStyle(color: Colors.black, eyeShape: QrEyeShape.circle),
        );
      },
    );
  }
}
