import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nocab_desktop/custom_widgets/custom_tooltip/custom_tooltip.dart';
import 'package:nocab_desktop/custom_widgets/svg_color_handler/svg_color_handler.dart';
import 'package:nocab_desktop/extensions/size_extension.dart';
import 'package:nocab_desktop/models/database/device_db.dart';
import 'package:nocab_desktop/models/database/file_db.dart';
import 'package:nocab_desktop/models/database/transfer_db.dart';
import 'package:nocab_desktop/services/database/database.dart';
import 'package:nocab_desktop/services/file_operations/file_operations.dart';

class HistoryDetails extends StatefulWidget {
  final TransferDatabase transfer;
  const HistoryDetails({Key? key, required this.transfer}) : super(key: key);

  @override
  State<HistoryDetails> createState() => _HistoryDetailsState();

  static empty(BuildContext context) => _emptyState(context);
}

class _HistoryDetailsState extends State<HistoryDetails> {
  AnimationController? controller;

  late StreamSubscription _streamSubscription;
  late TransferDatabase transfer;

  @override
  void initState() {
    super.initState();
    transfer = widget.transfer;
    _streamSubscription = Database().isar.transferDatabases.watchObject(widget.transfer.id).listen((event) {
      if (mounted && event != null) setState(() => transfer = event);
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (transfer.transferUuid != widget.transfer.transferUuid) {
      transfer = widget.transfer;
      _streamSubscription.cancel();
      _streamSubscription = Database().isar.transferDatabases.watchObject(widget.transfer.id).listen((event) {
        if (mounted && event != null) setState(() => transfer = event);
      });
    }

    controller?.reset();
    controller?.forward();
    return _buildDetails(context, transfer)
        .animate(onPlay: (c) => controller = c)
        .fadeIn(delay: 100.ms)
        .slideX(begin: -.02, curve: Curves.easeInOutCubicEmphasized);
  }

  Widget _buildDetails(BuildContext context, TransferDatabase transfer) {
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: transfer.status.color.withOpacity(.6),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Text(
                        "history.historyDetails.status.${transfer.status.name}".tr(),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Text("history.historyDetails.managedBy.${transfer.managedBy.name}".tr(),
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDeviceInfo(transfer.senderDevice, context),
                const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.arrow_forward_rounded)),
                _buildDeviceInfo(transfer.receiverDevice, context)
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text("history.historyDetails.info.requestedAt".tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(DateFormat("history.historyDetails.info.dateFormat".tr()).format(transfer.requestedAt),
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                if (transfer.startedAt != null) ...[
                  Column(
                    children: [
                      Text("history.historyDetails.info.startedAt".tr(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(DateFormat("history.historyDetails.info.dateFormat".tr()).format(transfer.startedAt!),
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
                if (transfer.endedAt != null) ...[
                  Column(
                    children: [
                      Text(
                        "history.historyDetails.info.endedAt".tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(DateFormat("history.historyDetails.info.dateFormat".tr()).format(transfer.endedAt!),
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ]
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      "history.historyDetails.info.fileCount".tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text("${transfer.files.length}"),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "history.historyDetails.info.totalFileSize".tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(transfer.files.fold(0, (previousValue, element) => previousValue + element.byteSize).formatBytes()),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                Text("history.historyDetails.info.message".tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(transfer.message ?? "-"),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: transfer.files.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: _buildFileInfo(transfer.files[index], transfer.status),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfo(FileDb file, TransferDbStatus status) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 250,
                      child: CustomTooltip(
                        message: file.name,
                        child: Text(
                          file.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    Text(file.byteSize.formatBytes(), style: const TextStyle(fontSize: 14)),
                  ],
                ),
                FutureBuilder(
                  future: File(file.path ?? "").exists(),
                  builder: (context, snapshot) {
                    if (status == TransferDbStatus.ongoing) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      return CustomTooltip(
                        message: "history.historyDetails.fileTile.warnMessages.ongoing".tr(),
                        child: const Padding(padding: EdgeInsets.only(right: 8.0), child: Icon(Icons.error_rounded, color: Colors.blue)),
                      );
                    }
                    if (snapshot.data == false) {
                      return CustomTooltip(
                        message: "history.historyDetails.fileTile.warnMessages.notFound".tr(),
                        child: const Padding(padding: EdgeInsets.only(right: 8.0), child: Icon(Icons.error_rounded, color: Colors.red)),
                      );
                    }
                    return Row(
                      children: [
                        if (Platform.isWindows) ...[
                          Material(
                            color: Colors.transparent,
                            child: CustomTooltip(
                              message: 'history.historyDetails.fileTile.showInFolder'.tr(),
                              child: InkWell(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                onTap: () => FileOperations.showInFolder(file.path!),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.folder_outlined, size: 20),
                                ),
                              ),
                            ),
                          )
                        ],
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            onTap: () => FileOperations.openFile(file.path!),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('history.historyDetails.fileTile.openFile'.tr()),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfo(DeviceDb deviceInfo, BuildContext context) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        border: deviceInfo.isCurrentDevice ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
        color: !deviceInfo.isCurrentDevice ? Theme.of(context).colorScheme.primary.withOpacity(.1) : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            if (deviceInfo.isCurrentDevice) ...[
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(50)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: Text(
                      "history.historyDetails.youLabel".tr(),
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    deviceInfo.deviceName.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold, color: deviceInfo.isCurrentDevice ? Theme.of(context).colorScheme.primary : null),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    deviceInfo.deviceOs,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    deviceInfo.deviceIp,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _emptyState(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SvgColorHandler(
        svgPath: "assets/images/history_empty_state.svg",
        colorSwitch: {
          const Color(0xff6c63ff): Theme.of(context).colorScheme.primary,
          const Color(0xff3f3d56): Theme.of(context).colorScheme.outline,
          const Color(0xffe6e6e6): Theme.of(context).colorScheme.outlineVariant,
          const Color(0xfff2f2f2): Theme.of(context).colorScheme.primaryContainer,
          const Color(0xffffffff): Theme.of(context).colorScheme.background,
          const Color(0xffcccccc): Theme.of(context).colorScheme.secondary,
        },
        height: 200,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "history.historyDetails.emptyState.title".tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            ),
            Text(
              "history.historyDetails.emptyState.message".tr(),
            ),
          ],
        ),
      ),
    ],
  ).animate(delay: 100.ms).fadeIn().slideX(curve: Curves.easeInOutCubicEmphasized, begin: -.02);
}
