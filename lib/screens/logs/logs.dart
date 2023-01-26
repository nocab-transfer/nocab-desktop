import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/custom_dialogs/alert_box/alert_box.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class Logs extends StatefulWidget {
  const Logs({super.key});

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  List logs = [];

  StreamSubscription? subscription;
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    NoCabCore.getLogs(from: DateTime.now().subtract(const Duration(days: 7))).then((value) {
      setState(() => logs = value);

      Future.delayed(const Duration(milliseconds: 200), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      });
    });

    subscription = NoCabCore.onLogged.listen((event) async {
      if (logs.isEmpty) return;

      var newLogs = await NoCabCore.getLogs(from: DateTime.now().subtract(const Duration(days: 7)));
      setState(() {
        logs = newLogs;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      });
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
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
                    text: "(Last 7 days)",
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
          TextButton.icon(
            onPressed: () async {
              showDeleteDialog(context).then((value) {
                if (value) NoCabCore.deleteLogs();
              });
            },
            icon: const Icon(Icons.delete_forever_rounded),
            label: const Text("Delete"),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          IconButton(
            onPressed: () async {
              var location = await getDownloadPath();
              if (location == null) return;
              var file = File(join(location, "nocab_desktop_logs.txt"));
              await NoCabCore.exportToFile(file);
              Share.shareXFiles([XFile(file.path)], subject: 'Share NoCab Desktop Logs', text: 'Logs');
            },
            icon: const Icon(Icons.download_rounded),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
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
    );
  }

  Future<bool> showDeleteDialog(BuildContext context) async {
    return await showModal<bool>(
          context: context,
          builder: (context) => AlertBox(
            title: "Delete Logs",
            message: "Are you sure you want to delete all logs?",
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      directory = await getDownloadsDirectory();
    } catch (err) {
      return null;
    }
    return directory?.path;
  }
}
