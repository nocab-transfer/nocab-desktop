import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nocab_desktop/extensions/size_extension.dart';
import 'package:nocab_desktop/l10n/generated/app_localizations.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state.dart';
import 'package:nocab_desktop/services/file_operations/file_operations.dart';

class TransferSuccessView extends StatelessWidget {
  final TransferSuccess state;
  final bool isDownload;
  final Function()? onClose;
  const TransferSuccessView({Key? key, required this.state, required this.isDownload, this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
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
                        child: Icon(Icons.phonelink_rounded, color: Theme.of(context).colorScheme.primary),
                      ),
                      SizedBox(
                        width: 250,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(state.deviceInfo.name ?? "Unknown", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                              Text(state.deviceInfo.ip ?? "", style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Tooltip(
                    message: AppLocalizations.of(context).removeButtonTooltip,
                    child: Material(
                      child: InkWell(
                        onTap: onClose,
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
                  child: Text(isDownload ? AppLocalizations.of(context).receiverCardSuccessLabelText(state.files.length) : AppLocalizations.of(context).senderCardSuccessLabelText(state.files.length), style: const TextStyle(fontSize: 12)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: state.files.length,
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
                                  constraints: BoxConstraints(maxWidth: isDownload ? 250 : 370),
                                  child: Tooltip(
                                    message: state.files[index].name,
                                    child: Text(state.files[index].name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1),
                                  ),
                                ),
                                Text(state.files[index].byteSize.formatBytes(), style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            isDownload ? _buildActions(state.files[index], context) : Container(),
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
      ),
    );
  }

  Widget _buildActions(FileInfo file, BuildContext context) {
    return Row(
      children: [
        Platform.isWindows // TODO: show in folder on other platforms
            ? Material(
                color: Colors.transparent,
                child: Tooltip(
                  message: AppLocalizations.of(context).showInFolderButtonTitle,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    onTap: () => FileOperations.showInFolder(file),
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
            onTap: () => FileOperations.openFile(file),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(AppLocalizations.of(context).openButtonTitle),
                  //Icon(Icons.arrow, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
