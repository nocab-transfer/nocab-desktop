import 'dart:io';

import 'package:flutter/material.dart';

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
                    child: Text("Network Adapter Settings", style: Theme.of(context).textTheme.headline6),
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
              child: ListView.builder(
                itemCount: 0,
                itemBuilder: (context, index) {
                  return Container(); /*_buildListTile(
                    server.networkInterfaces[index],
                    server.selectedNetworkInterface.addresses.first.address == server.networkInterfaces[index].addresses.first.address,
                    context: context,
                  );*/
                },
              ),
            ),
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
            /*server.selectedNetworkInterface = interface;
            server.deviceInfo.ip = interface.addresses.first.address;
            server.refreshQr();
            print(utf8.decode(base64.decode(server.getQr)));
            Navigator.of(context).pop();*/
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  width: 5,
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.background,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(interface.name, style: Theme.of(context).textTheme.headline6),
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
