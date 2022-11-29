// ignore_for_file: file_names

import 'package:nocab_desktop/custom_dialogs/update_dialog/base_job.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/update_variables.dart';

class CleanTemp extends UpdateJob {
  CleanTemp() : super(translationMasterKey: "cleanTemp");

  @override
  bool get cancelOnFailure => false;

  @override
  Future<bool> run(UpdateVariables variables) async {
    super.startTimer();
    try {
      if (await variables.tempDirectory.exists()) {
        await variables.tempDirectory.delete(recursive: true);
      }
      return finish(descTranslationKey: "success", status: UpdateJobStatus.done);
    } catch (e) {
      return finish(descTranslationKey: "error", status: UpdateJobStatus.failed, errorMessage: e.toString());
    }
  }
}
