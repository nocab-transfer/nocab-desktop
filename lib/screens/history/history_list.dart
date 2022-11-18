import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nocab_desktop/models/database/transfer_db.dart';
import 'package:nocab_desktop/screens/history/history_item.dart';
import 'package:nocab_desktop/services/database/database.dart';

class HistoryList extends StatefulWidget {
  final StreamController<TransferDatabase?> onClickedController;
  const HistoryList({Key? key, required this.onClickedController}) : super(key: key);

  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  late StreamSubscription _databaseSubscription;
  late StreamSubscription _onClickedSubscription;
  String? _selectedUuid;

  @override
  void initState() {
    super.initState();
    _databaseSubscription = Database().isar.transferDatabases.watchLazy().listen((event) {
      if (mounted) setState(() {});
    });

    _onClickedSubscription = widget.onClickedController.stream.listen((event) {
      if (mounted) setState(() => _selectedUuid = event?.transferUuid);
    });
  }

  @override
  void dispose() {
    _databaseSubscription.cancel();
    _onClickedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Database().getTransfers(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) return _buildEmpty();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text.rich(
                    TextSpan(text: "history.title".tr(), children: [
                      TextSpan(
                        text: " (${snapshot.data!.length})",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ]),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    reverse: true,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var item = Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: HistoryItem(
                          transfer: snapshot.data![index],
                          index: snapshot.data!.length - index,
                          onClicked: (transfer) => widget.onClickedController.add(transfer),
                          isSelected: _selectedUuid == snapshot.data![index].transferUuid,
                        ),
                      );

                      // avoid unnecessary animations
                      if (snapshot.data!.length - index < 15) {
                        return item.animate().slideX(delay: (30 * (snapshot.data!.length - index)).ms, begin: -.02, curve: Curves.easeOut).fadeIn();
                      }

                      return item;
                    },
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 100).animate(delay: 100.ms).fadeIn().moveY(begin: -50, curve: Curves.easeInOutCubicEmphasized),
          const SizedBox(height: 20),
          Text(
            "history.historyList.emptyState.title".tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "history.historyList.emptyState.message".tr(),
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().slideX(delay: 100.ms, begin: -.02, curve: Curves.easeOut).fadeIn();
  }
}
