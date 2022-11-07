import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nocab_desktop/custom_widgets/custom_tooltip/custom_tooltip.dart';
import 'package:nocab_desktop/extensions/size_extension.dart';
import 'package:nocab_desktop/models/file_model.dart';

class FileList extends StatefulWidget {
  final List<FileInfo> files;
  const FileList({Key? key, required this.files}) : super(key: key);

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.files.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              onTap: widget.files[index].path != null
                  ? () => Process.start(widget.files[index].name, [], workingDirectory: File(widget.files[index].path!).parent.path, runInShell: true)
                  : null,
              child: SizedBox(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Center(
                                child: Text(
                                    widget.files[index].name.split('.').last.length > 4
                                        ? "?"
                                        : widget.files[index].name.split('.').last.toUpperCase(),
                                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 15, fontWeight: FontWeight.w900))),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: CustomTooltip(
                                  message: widget.files[index].name,
                                  child: Text(
                                    widget.files[index].name,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Text(widget.files[index].byteSize.formatBytes(), style: const TextStyle(fontSize: 12)),
                              if (widget.files[index].subDirectory != null) ...[
                                Text(widget.files[index].subDirectory!, style: const TextStyle(fontSize: 10), maxLines: 2),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
