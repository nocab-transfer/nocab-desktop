import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocab_desktop/custom_dialogs/welcome_dialog/pages/nocab_mobile_page.dart';
import 'package:nocab_desktop/custom_dialogs/welcome_dialog/welcome_dialog.dart';
import 'package:nocab_desktop/custom_widgets/custom_tooltip/custom_tooltip.dart';
import 'package:nocab_desktop/custom_widgets/svg_color_handler/svg_color_handler.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/screens/history/history.dart';
import 'package:nocab_desktop/services/server/server.dart';
import 'package:nocab_desktop/services/transfer/transfer.dart';

class TransfersPanel extends StatelessWidget {
  const TransfersPanel({super.key});

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
                    onPressed: () => showModal(context: context, builder: (context) => const WelcomeDialog()), //FileOperations.openOutputFolder,
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
    );
  }

  Widget _buildList(List<Transfer> transfers) {
    return Expanded(
      child: SingleChildScrollView(
        child: ListView.builder(
          itemCount: transfers.length,
          reverse: true,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return TransferCard(
              transfer: transfers[index],
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return SizedBox(
      height: 550,
      width: double.infinity,
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
    );
  }
}
