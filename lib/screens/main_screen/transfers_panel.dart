import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/custom_dialogs/welcome_dialog/pages/nocab_mobile_page.dart';
import 'package:nocab_desktop/custom_dialogs/welcome_dialog/welcome_dialog.dart';
import 'package:nocab_desktop/custom_widgets/custom_tooltip/custom_tooltip.dart';
import 'package:nocab_desktop/custom_widgets/svg_color_handler/svg_color_handler.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/screens/history/history.dart';
import 'package:nocab_desktop/services/settings/settings.dart';
import 'package:nocab_desktop/services/transfer_manager/transfer_manager.dart';

class TransfersPanel extends StatefulWidget {
  const TransfersPanel({super.key});

  @override
  State<TransfersPanel> createState() => _TransfersPanelState();
}

class _TransfersPanelState extends State<TransfersPanel> {
  StreamSubscription? _transferSubscription;
  List<Transfer> _transfers = [];
  final List<Transfer> _hiddenTransfers = [];

  @override
  void initState() {
    super.initState();
    _transferSubscription = TransferManager().onNewTransfer.listen((event) {
      if (mounted) setState(() => _transfers = event);
    });
  }

  @override
  void dispose() {
    _transferSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('mainView.transfers.title'.tr(),
                style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
            Row(
              children: [
                CustomTooltip(
                  message: 'mainView.transfers.openOutputFolder'.tr(),
                  child: IconButton(
                    onPressed: openOutputFolder,
                    icon: const Icon(Icons.folder_outlined),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => showModal(
                    context: context,
                    builder: (context) => History(),
                  ),
                  icon: const Icon(Icons.history_rounded),
                  label: Text("mainView.transfers.history".tr()),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        _transfers.any((element) => !_hiddenTransfers.contains(element)) ? _buildList(_transfers) : _emptyState(context),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildList(List<Transfer> transfers) {
    return Expanded(
      child: ScrollConfiguration(
        behavior: const CupertinoScrollBehavior(),
        child: SingleChildScrollView(
          child: ListView.builder(
            itemCount: transfers.length,
            shrinkWrap: true,
            reverse: true,
            itemBuilder: (BuildContext context, int index) {
              if (_hiddenTransfers.contains(transfers[index])) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(top: index != transfers.length - 1 ? 8.0 : 0),
                child: TransferCard(
                  transfer: transfers[index],
                  onClose: () {
                    if (mounted) setState(() => _hiddenTransfers.add(transfers[index]));
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgColorHandler(
              svgPath: "assets/images/noitem.svg",
              colorSwitch: {
                const Color(0xFF7d5fff): Theme.of(context).colorScheme.primary,
              },
            ),
            const SizedBox(height: 30),
            Text(
              'mainView.transfers.emptyMessage'.tr(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const WelcomeDialog(overridePages: [NoCabMobilePage()]),
                  );
                },
                icon: const Icon(Icons.download_rounded),
                label: Text('mainView.transfers.downloadNoCabMobile'.tr(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openOutputFolder() {
    // create method checks if output folder exists and creates it if not, so no need to check output folder exists
    Directory(SettingsService().getSettings.downloadPath).create(recursive: true).then((value) {
      Process.run("start .", [], runInShell: true, workingDirectory: SettingsService().getSettings.downloadPath);
    });
  }
}
