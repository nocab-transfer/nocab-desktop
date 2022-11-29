// ignore_for_file: file_names

import 'dart:io';

import 'package:nocab_desktop/custom_dialogs/update_dialog/base_job.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/update_variables.dart';

class FinishUpdate extends UpdateJob {
  FinishUpdate() : super(translationMasterKey: "finish");

  @override
  Future<bool> run(UpdateVariables variables) async {
    super.startTimer();
    try {
      ProcessResult result = await Process.run(
        "powershell",
        ["-c", r'(Get-Command nocab).CommandType'],
      );

      if (result.stdout.toString().trim() != "Application") {
        return finish(
          descTranslationKey: "aliasError",
          errorMessage: "${result.stdout}\n${result.stderr}",
          status: UpdateJobStatus.failed,
        );
      }

      return await Process.run("powershell", [
        "-c",
        'taskkill /f /fi "imagename eq nocab_desktop.exe"; sleep 2;',
        'start nocab',
      ]).then((value) {
        if (value.exitCode == 0) {
          return finish(descTranslationKey: "success", status: UpdateJobStatus.done);
        } else {
          return finish(descTranslationKey: "error", status: UpdateJobStatus.failed, errorMessage: value.stderr.toString());
        }
      });
    } catch (e) {
      return finish(descTranslationKey: "error", status: UpdateJobStatus.failed, errorMessage: e.toString());
    }
  }
}
