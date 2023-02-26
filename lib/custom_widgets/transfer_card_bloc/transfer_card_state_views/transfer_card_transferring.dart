import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/custom_widgets/custom_tooltip/custom_tooltip.dart';
import 'package:nocab_desktop/extensions/file_info_functions.dart';
import 'package:nocab_desktop/extensions/size_extension.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state.dart';

class TransferringView extends StatelessWidget {
  final Transferring state;
  final bool isDownload;
  final Function() onCancel;
  const TransferringView({super.key, required this.state, required this.isDownload, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: MediaQuery.of(context).size.height / 5,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.height / 15,
                      child: Icon(isDownload ? Icons.download_rounded : Icons.upload_rounded, color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    SizedBox(
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.deviceInfo.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            Text(state.deviceInfo.ip, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: ElevatedButton.icon(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      foregroundColor: Theme.of(context).colorScheme.error,
                      surfaceTintColor: Theme.of(context).colorScheme.error,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.all(16),
                    ),
                    label: Text('mainView.transfers.card.transferring.cancelButton'.tr()),
                    icon: const Icon(Icons.cancel_rounded),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "mainView.transfers.card.transferring.title.${isDownload ? 'download' : 'upload'}".plural(
                        state.files.length,
                        name: 'count',
                      ),
                      style: Theme.of(context).textTheme.labelLarge),
                  //Icon(isDownload ? Icons.download_rounded : Icons.upload_rounded, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              itemCount: state.files.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (state.filesTransferred.map((e) => e.name).contains(state.files[index].name)) {
                  return _buildtransferred(state.files[index], context);
                } else if (state.files[index].name == state.currentFile.name) {
                  return _buildTransferring(state.files[index], state, context);
                } else {
                  return _buildFilePending(state.files[index], context);
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilePending(FileInfo file, BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: CustomTooltip(
                    message: file.name,
                    child: Text(file.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                ),
                Text(file.byteSize.formatBytes(), style: const TextStyle(fontSize: 14)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text('mainView.transfers.card.transferring.pending'.tr()),
                  const Icon(Icons.pending_actions_rounded),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTransferring(FileInfo file, Transferring state, BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: CustomTooltip(
                    message: file.name,
                    child: Text(file.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                ),
                Text(file.byteSize.formatBytes(), style: const TextStyle(fontSize: 14)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('mainView.transfers.card.transferring.speed'.tr(namedArgs: {'speed': state.speed.toStringAsFixed(2)}),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('mainView.transfers.card.transferring.progress'.tr(namedArgs: {'progress': state.progress.toStringAsFixed(2)}),
                    style: const TextStyle(fontSize: 14)),
              ],
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: LinearProgressIndicator(
            value: state.progress / 100,
            minHeight: 2,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildtransferred(FileInfo file, BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: CustomTooltip(
                    message: file.name,
                    child: Text(file.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                ),
                Text(file.byteSize.formatBytes(), style: const TextStyle(fontSize: 14)),
              ],
            ),
            isDownload ? _buildActions(file) : Container(),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActions(FileInfo file) {
    return Row(
      children: [
        Platform.isWindows
            ? Material(
                color: Colors.transparent,
                child: CustomTooltip(
                  message: 'mainView.transfers.card.showInFolder'.tr(),
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    onTap: () => file.showInFolder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.folder_outlined),
                    ),
                  ),
                ),
              )
            : Container(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            onTap: () => file.openFile(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text('mainView.transfers.card.openFile'.tr()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
