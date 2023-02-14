import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nocab_desktop/custom_widgets/custom_tooltip/custom_tooltip.dart';
import 'package:nocab_desktop/extensions/file_info_functions.dart';
import 'package:nocab_desktop/services/log_manager/log_manager.dart';
import 'package:nocab_desktop/services/settings/settings.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

class LogViewer extends StatefulWidget {
  final File file;
  final bool isCurrentLog;
  LogViewer({super.key, required this.file}) : isCurrentLog = file.path == LogManager.currentLogFile.path;

  @override
  State<LogViewer> createState() => _LogViewerState();
}

class _LogViewerState extends State<LogViewer> {
  List<String> logs = [];
  bool isCorrupted = false;
  StreamSubscription? subscription;
  StreamSubscription? _deleteSubscription;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.isCurrentLog) {
      // If the file is the current log file, then we need to listen to the stream
      LogManager.getCurrentLogs.then((value) {
        setState(() => logs = value);

        Future.delayed(const Duration(milliseconds: 200), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent + 100,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
          );
        });
      });

      subscription = LogManager.onLog.listen((event) async {
        if (logs.isEmpty) return;

        setState(() {
          logs.add(event);
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          if (scrollController.positions.isEmpty) return;
          scrollController.animateTo(
            scrollController.position.maxScrollExtent + 100,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
          );
        });
      });
      return;
    }

    // If the file is not the current log file, then we need to read from the file
    LogManager.getLogsFromFile(widget.file)
        .then((value) => setState(() => logs = value))
        .onError((error, stackTrace) => setState(() => isCorrupted = true));

    subscription = widget.file.parent.watch(events: FileSystemEvent.modify).listen((event) {
      if (event.path == widget.file.path) {
        LogManager.getLogsFromFile(widget.file)
            .then((value) => setState(() {
                  logs = value;
                  isCorrupted = false;
                }))
            .onError((error, stackTrace) => setState(() => isCorrupted = true));
      }
    });
  }

  @override
  void dispose() {
    // If the file is the current log file, subscription is logStream
    // If the file is not the current log file, subscription is fileWatcher
    subscription?.cancel();
    _deleteSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deleteSubscription ??= widget.file.parent.watch(events: FileSystemEvent.delete).listen((event) {
      if (event.path == widget.file.path) {
        Navigator.of(context).pop();
      }
    });

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              //color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHero(context),
                    const SizedBox(width: 8),
                    _buildLogs(context),
                    const SizedBox(width: 8),
                    _buildActions(context),
                  ],
                ),
                Text("Click outside to close", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Hero(
        tag: basenameWithoutExtension(widget.file.path),
        child: Container(
            height: 280,
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              border: Border.fromBorderSide(
                BorderSide(
                  color: widget.file.path == LogManager.currentLogFile.path
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                  width: 2,
                ),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: widget.file.path == LogManager.currentLogFile.path
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Icon(
                              Icons.insert_drive_file_rounded,
                              color: widget.file.path == LogManager.currentLogFile.path
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          basenameWithoutExtension(widget.file.path),
                          style: Theme.of(context).textTheme.labelLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Last Modified: ${SettingsService().getSettings.dateFormatType.dateFormat.format(widget.file.lastModifiedSync())}",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.file.path == LogManager.currentLogFile.path ? "CURRENT LOG" : "OLD LOG",
                          style: Theme.of(context).textTheme.labelSmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton.icon(
                      onPressed: Platform.isWindows ? () => widget.file.openWith() : null,
                      //showModal(context: context, builder: (context) => const LogViewer()),
                      icon: const Icon(Icons.file_open_rounded),
                      label: Text(Platform.isWindows ? "Open with ..." : "Open"),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  Text(
                    "Please don't modify the log files!",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildLogs(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            height: 600,
            width: 600,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: isCorrupted
                ? Center(
                    child: Text("Log file is corrupted!", style: Theme.of(context).textTheme.titleMedium),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: SelectionArea(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: logs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            var log = logs[index];

                            return Text(log.toString());
                          },
                        ),
                      ),
                    ),
                  ),
          ),
          if (widget.isCurrentLog) ...[
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      "Active",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              IconButton(
                onPressed: () => Clipboard.setData(ClipboardData(text: logs.join("\r\n"))),
                icon: const Icon(Icons.copy_all_rounded),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.centerLeft,
                ),
              ),
              IconButton(
                onPressed: () => Share.shareXFiles([XFile(widget.file.path)]),
                icon: const Icon(Icons.share_rounded),
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.centerLeft,
                ),
              ),
              CustomTooltip(
                message: widget.isCurrentLog ? "You can't delete the current log file" : "",
                child: IconButton(
                  onPressed: widget.isCurrentLog ? null : () => widget.file.deleteSync(),
                  icon: const Icon(Icons.delete_rounded),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
