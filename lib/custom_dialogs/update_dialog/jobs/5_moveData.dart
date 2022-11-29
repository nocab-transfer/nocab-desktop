// ignore_for_file: file_names

import 'dart:io';

import 'package:nocab_desktop/custom_dialogs/update_dialog/base_job.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/update_variables.dart';
import 'package:path/path.dart';
import 'package:io/io.dart' as io;

class MoveData extends UpdateJob {
  MoveData() : super(translationMasterKey: "moveData");

  @override
  bool get portableToMsix => true;

  @override
  bool get cancelOnFailure => true;

  @override
  Future<bool> run(UpdateVariables variables) async {
    super.startTimer();
    try {
      var msixName = await Process.run(
        "powershell",
        ["-c", r'(Get-AppxPackage -Name "NoCabTransfer.Desktop").PackageFamilyName'],
      ).then((ProcessResult results) {
        if (results.exitCode == 0) {
          return results.stdout.toString().trim();
        } else {
          finish(descTranslationKey: "msixNameError", status: UpdateJobStatus.failed, errorMessage: results.stderr.toString());
          return "";
        }
      });

      // if the job has already failed, don't overwrite the error message
      if (msixName.isEmpty || status == UpdateJobStatus.failed) {
        return finish(descTranslationKey: "msixNameError", status: UpdateJobStatus.failed);
      }

      String portableDataDir = join(Platform.environment['APPDATA']!, r'NoCab Desktop');
      String msixDataDir = join(Platform.environment['LOCALAPPDATA']!, r'Packages', msixName, r'LocalCache', r'Roaming', r'NoCab Desktop');
      await io.copyPath(portableDataDir, msixDataDir);
      return finish(descTranslationKey: "success", status: UpdateJobStatus.done);
    } catch (e) {
      return finish(descTranslationKey: "error", status: UpdateJobStatus.failed, errorMessage: e.toString());
    }
  }
}
