import 'package:easy_localization/easy_localization.dart';
import 'package:nocab_desktop/custom_widgets/svg_color_handler/svg_color_handler.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/services/file_operations/file_operations.dart';
import 'package:nocab_desktop/services/server/server.dart';
import 'package:nocab_desktop/services/transfer/transfer.dart';

class Transfers extends StatefulWidget {
  const Transfers({Key? key}) : super(key: key);

  @override
  State<Transfers> createState() => _TransfersState();
}

class _TransfersState extends State<Transfers> {
  @override
  void initState() {
    super.initState();
    Server().onNewTransfer.listen((event) {
      setState(() {});
    });
  }

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
                Text('mainView.transfers.title'.tr(), style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: FileOperations.openOutputFolder,
                  icon: const Icon(Icons.folder_outlined),
                  label: Text('mainView.transfers.openOutputFolder'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            ),
            Server().activeTransfers.isNotEmpty ? _buildList(Server().activeTransfers) : _emptyState(),
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
            itemCount: Server().activeTransfers.length,
            reverse: true,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return TransferCard(
                transfer: Server().activeTransfers[index],
              );
            }),
      ),
    );
  }

  Widget _emptyState() {
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            textAlign: TextAlign.center,
          ),
          Container(),
        ],
      ),
    );
  }
}
