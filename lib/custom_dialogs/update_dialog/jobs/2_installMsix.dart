// ignore_for_file: file_names

import 'dart:io';

import 'package:nocab_desktop/custom_dialogs/update_dialog/base_job.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/update_variables.dart';

class InstallMsix extends UpdateJob {
  InstallMsix() : super(translationMasterKey: "installMsix");

  @override
  Future<bool> run(UpdateVariables variables) async {
    super.startTimer();
    try {
      if (await variables.updateFile.length() == 0) return finish(descTranslationKey: "fileNotFound", status: UpdateJobStatus.failed);

      return await Process.run("powershell", [
        "-c",
        "Add-AppxPackage -Path ${variables.updateFile.path} -DeferRegistrationWhenPackagesAreInUse",
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
