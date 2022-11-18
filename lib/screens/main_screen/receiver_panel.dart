import 'dart:convert';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/custom_dialogs/network_adapter_settings/network_adapter_settings.dart';
import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/services/server/server.dart';
import 'package:nocab_desktop/services/settings/settings.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiverPanel extends StatelessWidget {
  const ReceiverPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('mainView.receiver.title'.tr(),
                style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () => showModal(context: context, builder: (context) => const NetworkAdapterSettings()),
              icon: const Icon(Icons.wifi_find_rounded),
              label: Text('mainView.receiver.networkAdapterSettings'.tr()),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
              stream: SettingsService().onSettingChanged,
              initialData: SettingsService().getSettings,
              builder: (context, snapshot) {
                return RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'mainView.receiver.deviceShownAs'.tr(namedArgs: {'name': "split"}).split("split")[0],
                    style: Theme.of(context).textTheme.titleLarge,
                    children: [
                      TextSpan(
                          text: snapshot.data?.deviceName.toUpperCase() ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                      TextSpan(
                        text: 'mainView.receiver.deviceShownAs'.tr(namedArgs: {'name': "split"}).split("split")[1],
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'mainView.receiver.or'.tr(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Text(
          'mainView.receiver.scanQrCode'.tr(),
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 24),
        Container(
          height: 220,
          width: 220,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),

              //QR code
              child: StreamBuilder(
                stream: SettingsService().onSettingChanged,
                initialData: SettingsService().getSettings,
                builder: (context, snapshot) {
                  return QrImage(
                    data: base64.encode(utf8.encode(json.encode(DeviceInfo(
                            name: snapshot.data!.deviceName,
                            ip: Server().selectedIp.address,
                            port: snapshot.data!.mainPort,
                            opsystem: Platform.operatingSystem,
                            deviceId: "")
                        .toJson()))),
                    version: QrVersions.auto,
                    dataModuleStyle: const QrDataModuleStyle(color: Colors.black, dataModuleShape: QrDataModuleShape.circle),
                    eyeStyle: const QrEyeStyle(color: Colors.black, eyeShape: QrEyeShape.circle),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
