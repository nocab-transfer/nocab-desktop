import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/custom_dialogs/network_adapter_settings/network_adapter_settings.dart';
import 'package:nocab_desktop/services/server/server.dart';
import 'package:nocab_desktop/services/settings/settings.dart';

class NetworkAdapterInfoPage extends StatefulWidget {
  const NetworkAdapterInfoPage({Key? key}) : super(key: key);

  @override
  State<NetworkAdapterInfoPage> createState() => _NetworkAdapterInfoPageState();
}

class _NetworkAdapterInfoPageState extends State<NetworkAdapterInfoPage> {
  var opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          opacity = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("welcomeDialog.networkAdapterPage.title".tr(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Text("welcomeDialog.networkAdapterPage.description".tr(), style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            Text("welcomeDialog.networkAdapterPage.description2".tr(), style: Theme.of(context).textTheme.bodyLarge),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 50,
                        width: 5,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 450,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 300,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(SettingsService().getSettings.networkInterfaceName, style: Theme.of(context).textTheme.titleLarge, overflow: TextOverflow.ellipsis),
                                    Text(Server().selectedIp.address, style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => showModal(context: context, builder: (context) => const NetworkAdapterSettings()).then((value) => setState(() {})),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: Text("welcomeDialog.networkAdapterPage.changeButton".tr()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("welcomeDialog.networkAdapterPage.hint".tr(), style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
