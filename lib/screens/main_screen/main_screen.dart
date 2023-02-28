import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/custom_dialogs/sender_dialog/sender_dialog.dart';
import 'package:nocab_desktop/screens/main_screen/receiver_panel.dart';
import 'package:nocab_desktop/screens/main_screen/send_drag_drop_area.dart';
import 'package:nocab_desktop/screens/main_screen/settings_panel.dart';
import 'package:nocab_desktop/screens/main_screen/transfers_panel.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 32.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height - 64 - (MediaQuery.of(context).size.height / 5) - 16,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ReceiverPanel(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 5,
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 8,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: SettingsPanel(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: SendDragDrop(
                                onFilesReady: (files) {
                                  return showModal(
                                    context: context,
                                    configuration: const FadeScaleTransitionConfiguration(barrierDismissible: false),
                                    builder: ((context) => SendStarterDialog(files: files)),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width / 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TransfersPanel(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
