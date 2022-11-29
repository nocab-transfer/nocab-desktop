// ignore_for_file: file_names

import 'package:nocab_desktop/custom_dialogs/update_dialog/base_job.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/update_variables.dart';
import 'package:http/http.dart' as http;

class DownloadMsix extends UpdateJob {
  DownloadMsix() : super(translationMasterKey: "downloadMsix");

  @override
  Future<bool> run(UpdateVariables variables) async {
    super.startTimer();
    try {
      var response = await http.get(Uri.parse(variables.url));
      await variables.updateFile.create(recursive: true);
      await variables.updateFile.writeAsBytes(response.bodyBytes);
    } catch (e) {
      return finish(descTranslationKey: "error", status: UpdateJobStatus.failed, errorMessage: e.toString());
    }
    return finish(descTranslationKey: "success", status: UpdateJobStatus.done);
  }
}
