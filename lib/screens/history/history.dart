import 'dart:async';

import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/custom_dialogs/alert_box/alert_box.dart';
import 'package:nocab_desktop/models/database/transfer_db.dart';
import 'package:nocab_desktop/screens/history/history_details.dart';
import 'package:nocab_desktop/screens/history/history_list.dart';
import 'package:nocab_desktop/services/database/database.dart';

class History extends StatelessWidget {
  History({Key? key}) : super(key: key);

  final _changeController = StreamController<TransferDatabase?>.broadcast();
  Stream<TransferDatabase?> get onTransferClicked => _changeController.stream;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: 800,
        width: 1100,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 1100 * 3 / 5,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 50,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text("history.title".tr(),
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => showModal(
                                        context: context,
                                        builder: (context) => AlertBox(
                                              title: "history.deleteDialog.title".tr(),
                                              message: "history.deleteDialog.message".tr(),
                                              actions: [
                                                TextButton.icon(
                                                  onPressed: () => Database().deleteAllTransfers().then((value) {
                                                    _changeController.add(null);
                                                    Navigator.pop(context);
                                                  }),
                                                  icon: const Icon(Icons.delete_outline_rounded),
                                                  label: Text('history.deleteDialog.confirmButton'.tr()),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.red,
                                                    textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                                    textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                                    //side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                                  ),
                                                  child: Text('history.deleteDialog.cancelButton'.tr()),
                                                ),
                                              ],
                                            )),
                                    icon: const Icon(Icons.delete_forever_rounded),
                                    label: Text("history.deleteButton.title".tr()),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: HistoryList(onClickedController: _changeController),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                VerticalDivider(endIndent: 20, indent: 20, thickness: 2, color: Theme.of(context).colorScheme.outline),
                Expanded(
                  child: StreamBuilder(
                      stream: onTransferClicked,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return HistoryDetails.empty(context);
                        return HistoryDetails(transfer: snapshot.data!);
                      }),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
