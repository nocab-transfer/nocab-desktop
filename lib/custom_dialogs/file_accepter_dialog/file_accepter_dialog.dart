import 'package:easy_localization/easy_localization.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/custom_widgets/file_list/file_list.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/services/transfer_manager/transfer_manager.dart';

class FileAccepterDialog extends StatefulWidget {
  final ShareRequest request;
  const FileAccepterDialog({Key? key, required this.request}) : super(key: key);

  @override
  State<FileAccepterDialog> createState() => _FileAccepterDialogState();
}

class _FileAccepterDialogState extends State<FileAccepterDialog> {
  @override
  void initState() {
    super.initState();
    widget.request.onResponse.then((value) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          //height: 500,
          width: 500,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  height: 100,
                  child: Center(
                      child: Icon(
                    Icons.file_present_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.onPrimary,
                  )),
                ),
                Text(
                  'fileAccepter.title'.plural(widget.request.files.length, name: 'count', namedArgs: {
                    'deviceName': widget.request.deviceInfo.name,
                  }),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'fileAccepter.connectionInfo'.tr(namedArgs: {
                      'ip': widget.request.deviceInfo.ip,
                      'port': widget.request.transferPort.toString(),
                    }),
                    maxLines: 2,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  width: 400,
                  height: MediaQuery.of(context).size.width / 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: FileList(files: widget.request.files),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 170, maxHeight: 55, minHeight: 55, minWidth: 110),
                      child: OutlinedButton(
                        onPressed: () => TransferManager().rejectRequest(widget.request),
                        style: OutlinedButton.styleFrom(
                          surfaceTintColor: Theme.of(context).colorScheme.error,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          side: BorderSide(width: 2, color: Theme.of(context).colorScheme.error),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: Text(
                          'fileAccepter.rejectButton'.tr(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 170, maxHeight: 55, minHeight: 55, minWidth: 110),
                      child: ElevatedButton(
                        onPressed: () async => TransferManager().acceptRequest(widget.request),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: Text(
                          'fileAccepter.acceptButton'.tr(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
