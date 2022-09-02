import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nocab_desktop/l10n/generated/app_localizations.dart';
import 'package:nocab_desktop/models/settings_model.dart';
import 'package:nocab_desktop/services/server/server.dart';
import 'package:nocab_desktop/services/settings/settings.dart';

class NetworkAdapterSettings extends StatelessWidget {
  const NetworkAdapterSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(8),
      child: Container(
        width: 600,
        height: 500,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 34,
                    child: Text(AppLocalizations.of(context).networkAdapterSettingsButtonTitle, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  Material(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.close_rounded, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
                height: 444,
                child: FutureBuilder<List<NetworkInterface>>(
                  future: NetworkInterface.list(),
                  initialData: const [],
                  builder: (context, adapters) {
                    return ListView.builder(
                      itemCount: adapters.data!.length,
                      itemBuilder: (context, index) {
                        return _buildListTile(
                          adapters.data![index],
                          Server().currentInterFace.addresses.first.address == adapters.data![index].addresses.first.address,
                          context: context,
                        );
                      },
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(NetworkInterface interface, bool isSelected, {required BuildContext context}) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          onTap: () {
            Server().currentInterFace = interface;
            SettingsService().setSettings(SettingsService().getSettings.copyWith(networkInterfaceName: interface.name));
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 70,
                  width: 5,
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(interface.name, style: Theme.of(context).textTheme.titleLarge),
                      Text(interface.addresses.first.address, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
