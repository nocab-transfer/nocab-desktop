// ignore_for_file: file_names

import 'dart:io';

import 'package:nocab_desktop/custom_dialogs/update_dialog/base_job.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/update_variables.dart';
import 'package:path/path.dart';

class CleanPortableFiles extends UpdateJob {
  CleanPortableFiles() : super("cleanPortable", "description");

  @override
  bool get portableToMsix => true;

  @override
  bool get cancelOnFailure => false;

  @override
  Future<bool> run(UpdateVariables variables) async {
    super.startTimer();
    String portablePath = File(Platform.resolvedExecutable).parent.path;
    String portableDataDir = join(Platform.environment['APPDATA']!, r'NoCab Desktop');
    List<String> paths = [
      portableDataDir,
      join(portablePath, "data"),
      join(portablePath, "desktop_drop_plugin.dll"),
      join(portablePath, "flutter_platform_alert_plugin.dll"),
      join(portablePath, "flutter_windows.dll"),
      join(portablePath, "isar.dll"),
      join(portablePath, "isar_flutter_libs_plugin.dll"),
      join(portablePath, "nocab_desktop.exe"),
      join(portablePath, "screen_retriever_plugin.dll"),
      join(portablePath, "url_launcher_windows_plugin.dll"),
      join(portablePath, "window_manager_plugin.dll"),
    ];
    var command = List.generate(paths.length, (index) => "Remove-Item '${paths[index]}' -force -recurse;");
    try {
      Process.run("powershell", [
        "-c",
        'wait-process -id $pid ;',
        ...command,
      ]).then((value) {
        if (value.exitCode != 0) {
          return finish(descTranslationKey: "error", status: UpdateJobStatus.failed, errorMessage: value.stderr.toString());
        }
      });
      await Future.delayed(const Duration(seconds: 2)); // Wait for powershell to start
      return finish(descTranslationKey: "success", status: UpdateJobStatus.done);
    } catch (e) {
      return finish(descTranslationKey: "error", status: UpdateJobStatus.failed, errorMessage: e.toString());
    }
  }
}
