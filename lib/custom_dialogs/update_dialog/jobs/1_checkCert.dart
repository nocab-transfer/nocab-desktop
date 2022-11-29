// ignore_for_file: file_names

import 'dart:io';

import 'package:nocab_desktop/custom_dialogs/update_dialog/base_job.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/update_variables.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class CheckCertificate extends UpdateJob {
  CheckCertificate() : super(translationMasterKey: "checkCert");

  @override
  Future<bool> run(UpdateVariables variables) async {
    super.startTimer();
    bool certificateInstalled = await checkCert(variables);

    if (!certificateInstalled) {
      if (status == UpdateJobStatus.failed) return false;
      return installCert(variables);
    }

    return finish(descTranslationKey: "alreadyInstalled", status: UpdateJobStatus.done);
  }

  Future<bool> checkCert(UpdateVariables variables) async {
    try {
      return await Process.run(
        "powershell",
        ["-c", r'(gci Cert:CurrentUser\Root | Where-Object {$_.Thumbprint -eq ', '"${variables.signatureThumbprint}"}).Thumbprint'],
      ).then((ProcessResult results) {
        if (results.exitCode == 0) {
          return results.stdout.toString().toUpperCase().contains(variables.signatureThumbprint.toUpperCase());
        } else {
          return finish(descTranslationKey: "checkError", status: UpdateJobStatus.failed, errorMessage: results.stderr.toString());
        }
      });
    } catch (e) {
      return finish(descTranslationKey: "checkError", status: UpdateJobStatus.failed, errorMessage: e.toString());
    }
  }

  Future<bool> installCert(UpdateVariables variables) async {
    try {
      var response = await http.get(Uri.parse(variables.signatureUrl));
      var file = File(join(Directory.systemTemp.path, "nocab_update", "cert_${variables.latestRelease["tag_name"]}.crt"));
      await file.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);
      return await Process.run("powershell", [
        "-c",
        r"$process= Start-Process",
        "powershell",
        "-verb runas",
        "-ArgumentList",
        '"-Command certutil -addstore -f Root ${file.path}"',
        "-PassThru",
        "-Wait",
        "-WindowStyle Hidden",
        ";",
        r"$process.ExitCode",
        ";",
      ]).then((ProcessResult results) async {
        if (results.exitCode == 0 && results.stdout.toString().trim() == "0") {
          if (await checkCert(variables)) return finish(descTranslationKey: "Certificate installed", status: UpdateJobStatus.done);
        }
        if (status == UpdateJobStatus.failed) return false; // if the job has already failed, don't overwrite the error message
        return finish(descTranslationKey: "installError", status: UpdateJobStatus.failed, errorMessage: results.stderr.toString());
      });
    } catch (e) {
      return finish(descTranslationKey: "installError", status: UpdateJobStatus.failed, errorMessage: e.toString());
    }
  }
}
