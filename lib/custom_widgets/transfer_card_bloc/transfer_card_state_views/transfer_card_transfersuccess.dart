import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/custom_widgets/custom_tooltip/custom_tooltip.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state.dart';
import 'package:nocab_desktop/extensions/file_info_functions.dart';
import 'package:nocab_desktop/extensions/size_extension.dart';

class TransferSuccessView extends StatefulWidget {
  final TransferSuccess state;
  final bool isDownload;
  final Function()? onClose;
  const TransferSuccessView({Key? key, required this.state, required this.isDownload, this.onClose}) : super(key: key);

  @override
  State<TransferSuccessView> createState() => _TransferSuccessViewState();
}

class _TransferSuccessViewState extends State<TransferSuccessView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.height / 15,
                      child: Icon(widget.isDownload ? Icons.download_rounded : Icons.upload_rounded, color: Theme.of(context).colorScheme.primary),
                    ),
                    SizedBox(
                      width: 250,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.state.deviceInfo.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            Text(widget.state.deviceInfo.ip, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                CustomTooltip(
                  message: 'mainView.transfers.card.transferSuccess.removeButtonTooltip'.tr(),
                  child: Material(
                    child: InkWell(
                      onTap: widget.onClose,
                      borderRadius: BorderRadius.circular(10),
                      hoverColor: Theme.of(context).colorScheme.primary.withAlpha(40),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //"${state.files.length} file(s) ${isDownload ? "downloaded" : "sent"} successfully"
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.isDownload
                    ? 'mainView.transfers.card.transferSuccess.receiverSuccess'.plural(widget.state.files.length, name: 'count')
                    : 'mainView.transfers.card.transferSuccess.senderSuccess'.plural(widget.state.files.length, name: 'count')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: widget.state.files.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(maxWidth: widget.isDownload ? 250 : 370),
                                child: CustomTooltip(
                                  message: widget.state.files[index].name,
                                  child: Text(widget.state.files[index].name,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1),
                                ),
                              ),
                              Text(widget.state.files[index].byteSize.formatBytes(), style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                          widget.isDownload ? _buildActions(widget.state.files[index]) : Container(),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
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
                      child: Icon(Icons.folder_outlined, size: 20),
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
