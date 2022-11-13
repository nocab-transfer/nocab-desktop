import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocab_desktop/custom_dialogs/welcome_dialog/pages/nocab_mobile_page.dart';
import 'package:nocab_desktop/custom_dialogs/welcome_dialog/welcome_dialog.dart';
import 'package:nocab_desktop/custom_widgets/custom_tooltip/custom_tooltip.dart';
import 'package:nocab_desktop/custom_widgets/svg_color_handler/svg_color_handler.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/screens/history/history.dart';
import 'package:nocab_desktop/services/file_operations/file_operations.dart';
import 'package:nocab_desktop/services/server/server.dart';
import 'package:nocab_desktop/services/transfer/transfer.dart';

class Transfers extends StatelessWidget {
  const Transfers({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      height: 616,
      width: 632,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
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
                        onPressed: FileOperations.openOutputFolder,
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
            StreamBuilder(
              stream: Server().onNewTransfer,
              initialData: const <Transfer>[],
              builder: (context, snapshot) => snapshot.data!.isNotEmpty ? _buildList(snapshot.data!) : _emptyState(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Transfer> transfers) {
    return Container(
      height: 550,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: ListView.builder(
            itemCount: transfers.length,
            reverse: true,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return TransferCard(
                transfer: transfers[index],
              );
            }),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return SizedBox(
      height: 550,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
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
          Container(),
        ],
      ),
    );
  }
}
