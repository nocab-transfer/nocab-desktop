import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/l10n/generated/app_localizations.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/services/file_operations/file_operations.dart';
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
        // Check if the files contains directories and if so, get all files under those directories

        // create a list contains all directories
        var directoryList = details.files.fold(<Directory>[], (previousValue, element) {
          if (Directory(element.path).existsSync()) previousValue.add(Directory(element.path));
          return previousValue;
        });

        // create a list contains all files
        List<FileInfo> files = [];
        for (var file in details.files.where((element) => File(element.path).existsSync())) {
          files.add(FileInfo(name: file.name, byteSize: await file.length(), isEncrypted: false, hash: "test", path: file.path));
        }

        // add files under directories
        await Future.forEach(directoryList, (dir) async => files.addAll(await FileOperations.getFilesUnderDirectory(dir.path)));

        setState(() => loading = false);
        widget.onFilesReady?.call(files);
      },
      child: loading
          ? Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              height: 150,
              width: 276,
              child: Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context).filesLoadingLabelText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )))
          : Container(
              decoration: BoxDecoration(
                border: Border.all(color: isDragEntered ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.outline, width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              height: 150,
              width: 276,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(AppLocalizations.of(context).senderTitle, style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => filePicker.pickFilesIsolate().then((value) {
                          if (value != null) widget.onFilesReady?.call(value);
                        }),
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.upload_file_rounded),
                            Text(AppLocalizations.of(context).chooseFilesButtonTitle),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(child: Text(AppLocalizations.of(context).dropFilesHereLabelText)),
                  ],
                ),
              ),
            ),
    );
  }
}
