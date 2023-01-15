import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nocab_core/nocab_core.dart';
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
    Logger().get(from: DateTime.now().subtract(const Duration(days: 1))).then((value) {
      setState(() => logs = value);

      Future.delayed(const Duration(milliseconds: 200), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      });
    });

    subscription = Logger().onLogged.listen((event) async {
      if (logs.isEmpty) return;

      var newLogs = await Logger().get();
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
            const Text("Logs"),
          ],
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () async {
              var location = await getDownloadPath();
              if (location == null) return;
              var file = File(join(location, "nocab_desktop_logs.txt"));
              await Logger().exportLogsLast10Days(file);
              Share.shareXFiles([XFile(file.path)], subject: 'Share NoCab Desktop Logs', text: 'Logs');
            },
            icon: const Icon(Icons.download_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          controller: scrollController,
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
    );
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
