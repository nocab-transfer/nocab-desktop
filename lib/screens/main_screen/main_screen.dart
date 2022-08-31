import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:nocab_desktop/custom_dialogs/network_adapter_settings.dart';
import 'package:nocab_desktop/custom_dialogs/send_starter_dialog.dart';
import 'package:nocab_desktop/l10n/generated/app_localizations.dart';
import 'package:nocab_desktop/screens/main_screen/qr.dart';
import 'package:nocab_desktop/screens/main_screen/send_drag_drop_area.dart';
import 'package:nocab_desktop/screens/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/services/settings/settings.dart';

import 'transfers_panel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    height: 450,
                    width: 450,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)!.receiverTitle, style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                              TextButton.icon(
                                onPressed: () => showDialog(context: context, builder: (context) => const NetworkAdapterSettings()),
                                icon: const Icon(Icons.wifi_find_rounded),
                                label: Text(AppLocalizations.of(context)!.networkAdapterSettingsButtonTitle),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 380,
                            //color: Colors.red,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
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
                                            text: AppLocalizations.of(context)!.deviceShownAsLabelText("split").split("split")[0],
                                            style: Theme.of(context).textTheme.headline6,
                                            children: [
                                              TextSpan(text: snapshot.data?.deviceName.toUpperCase() ?? "", style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).colorScheme.primary)),
                                              TextSpan(
                                                text: AppLocalizations.of(context)!.deviceShownAsLabelText("split").split("split")[1], //FlutterI18n.translate(context, "main_screen.device_shown_as").split("{device_name}")[1],
                                                style: Theme.of(context).textTheme.headline6,
                                              ),
                                            ],
                                          ),

                                          //style: TextStyle(fontSize: 22, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  AppLocalizations.of(context)!.orLabelText,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.scanQrCodeLabelText,
                                  style: const TextStyle(fontSize: 20),
                                ),
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
                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                      ),
                                      child: const Qr(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                      ),
                      height: 150,
                      width: 150,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(AppLocalizations.of(context)!.settingsTitle, style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Center(
                              child: ElevatedButton(
                                onPressed: () => showGeneralDialog(
                                  context: context,
                                  transitionDuration: const Duration(milliseconds: 200),
                                  barrierDismissible: true,
                                  barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                                  pageBuilder: (context, animation, secondaryAnimation) => const Settings(),
                                  transitionBuilder: (context, animation, secondaryAnimation, child) {
                                    return BackdropFilter(filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), child: SlideTransition(position: Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(animation), child: child));
                                  },
                                ),
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(70, 70),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                                ),
                                child: const Icon(Icons.settings_outlined),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    SendDragDrop(
                      onFilesReady: (files) {
                        return showModal(
                          context: context,
                          configuration: const FadeScaleTransitionConfiguration(barrierDismissible: false),
                          builder: ((context) => SendStarterDialog(files: files)),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: const Padding(
              padding: EdgeInsets.only(left: 100, right: 70),
              child: Center(child: Transfers()),
            ),
          ),
        ],
      ),
    );
  }
}
