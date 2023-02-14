import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/screens/logs/log_viewer.dart';
import 'package:nocab_desktop/services/log_manager/log_manager.dart';
import 'package:nocab_desktop/services/settings/settings.dart';
import 'package:path/path.dart';

class Logs extends StatefulWidget {
  const Logs({super.key});

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  final outerController = ScrollController();

  final GlobalKey<AnimatedGridState> _gridKey = GlobalKey<AnimatedGridState>();
  late final List<File> logFiles;
  StreamSubscription? _logSubscription;

  @override
  void initState() {
    super.initState();
    logFiles = LogManager.getLogFiles..sort((a, b) => basenameWithoutExtension(b.path).compareTo(basenameWithoutExtension(a.path)));

    _logSubscription = Directory(LogManager.logFolderPath).watch().listen((event) {
      if (event.type == FileSystemEvent.delete) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              var index = logFiles.indexWhere((element) => element.path == event.path);
              var file = logFiles.removeAt(index);
              _gridKey.currentState?.removeItem(
                index,
                (context, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation.drive(Tween(begin: 0.8, end: 1.0)),
                    child: _buildLogFileGrid(context, file),
                  ),
                ),
              );
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.arrow_back_ios_rounded),
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                text: "Logs",
                style: Theme.of(context).textTheme.titleLarge,
                children: [
                  TextSpan(
                    text: " (Count: ${logFiles.length} "
                        "Total Size: "
                        "${logFiles.fold(0, (previousValue, element) => previousValue + element.lengthSync()) / 1000} KB)",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                "Logs older than 7 days are automatically deleted",
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: _buildGridView(logFiles),
        ),
      ),
    );
  }

  Widget _buildGridView(List<File> initialLogFiles) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          if (event.scrollDelta.dy > 0) {
            outerController.jumpTo(outerController.offset + 100);
          } else {
            outerController.jumpTo(outerController.offset - 100);
          }
        }
      },
      child: AnimatedGrid(
        key: _gridKey,
        controller: outerController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        initialItemCount: initialLogFiles.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index, animation) {
          return _buildLogFileGrid(
            context,
            initialLogFiles[index],
          );
        },
      ),
    );
  }

  Widget _buildLogFileGrid(BuildContext context, File file) {
    return Hero(
      tag: basenameWithoutExtension(file.path),
      transitionOnUserGestures: true,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          border: Border.fromBorderSide(
            BorderSide(
              color: file.path == LogManager.currentLogFile.path
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary.withOpacity(0.4),
              width: 2,
            ),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: file.path == LogManager.currentLogFile.path
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        Icons.insert_drive_file_rounded,
                        color: file.path == LogManager.currentLogFile.path
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    basenameWithoutExtension(file.path),
                    style: Theme.of(context).textTheme.labelLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    file.existsSync()
                        ? "Last Modified: ${SettingsService().getSettings.dateFormatType.dateFormat.format(file.lastModifiedSync())}"
                        : "File Deleted",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    file.path == LogManager.currentLogFile.path ? "CURRENT LOG" : "OLD LOG",
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      opaque: false,
                      barrierColor: Colors.black.withOpacity(0.5),
                      transitionDuration: const Duration(milliseconds: 200),
                      reverseTransitionDuration: const Duration(milliseconds: 200),
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return FadeTransition(
                          opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
                          child: ScaleTransition(
                            scale: animation.drive(Tween(begin: 0.90, end: 1.0).chain(CurveTween(curve: Curves.easeInOut))),
                            //opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
                            child: LogViewer(file: file),
                          ),
                        );
                      },
                    )),
                icon: const Icon(Icons.file_open_rounded),
                label: const Text("Open"),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
