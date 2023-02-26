import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/services/file_picker_isolate/file_picker_isolate.dart';

class SendDragDrop extends StatefulWidget {
  final Function(List<FileInfo> files)? onFilesReady;
  const SendDragDrop({super.key, this.onFilesReady});

  @override
  State<SendDragDrop> createState() => _SendDragDropState();
}

class _SendDragDropState extends State<SendDragDrop> {
  bool loading = false;
  bool isDragEntered = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (details) => setState(() => isDragEntered = true),
      onDragExited: (details) => setState(() => isDragEntered = false),
      onDragDone: (details) async {
        if (loading) return;
        setState(() => loading = true);
        List<FileInfo> files = await FileOperations.convertPathsToFileInfos(details.files.map((e) => e.path).toList());
        setState(() => loading = false);

        widget.onFilesReady?.call(files);
      },
      child: loading
          ? Center(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'mainView.sender.loadingLabel'.tr(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text('mainView.sender.title'.tr(),
                    style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Center(
                  child: ElevatedButton(
                    onPressed: () => filePicker.pickFilesIsolate().then((value) {
                      if (value != null) widget.onFilesReady?.call(value);
                    }),
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(160, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload_file_rounded),
                        Text('mainView.sender.button'.tr()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: Text('mainView.sender.dropFiles'.tr())),
              ],
            ),
    );
  }
}
