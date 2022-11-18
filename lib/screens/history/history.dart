import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nocab_desktop/models/database/transfer_db.dart';
import 'package:nocab_desktop/screens/history/history_details.dart';
import 'package:nocab_desktop/screens/history/history_list.dart';

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
