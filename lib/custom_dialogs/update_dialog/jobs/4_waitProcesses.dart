// ignore_for_file: file_names

import 'package:nocab_desktop/custom_dialogs/update_dialog/base_job.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/update_variables.dart';
import 'package:nocab_desktop/services/server/server.dart';

class WaitProcesses extends UpdateJob {
  WaitProcesses() : super(translationMasterKey: "waitProcesses");

  @override
  Future<bool> run(UpdateVariables variables) async {
    super.startTimer();
    try {
      do {
        if (Server().activeTransfers.any((element) => element.ongoing)) {
          await Server().activeTransfers.firstWhere((element) => element.ongoing).onEvent.last;
        } else {
          break;
        }
      } while (true);
    } catch (e) {
      return finish(descTranslationKey: "error", status: UpdateJobStatus.failed, errorMessage: e.toString());
    }
    return finish(descTranslationKey: "success", status: UpdateJobStatus.done);
  }
}
