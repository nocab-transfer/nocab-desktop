import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/base_job.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/jobs/0_downloadMsix.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/jobs/1_checkCert.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/jobs/3_cleanTemp.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/jobs/4_waitProcesses.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/jobs/2_installMsix.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/jobs/5_moveData.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/jobs/6_cleanPortable.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/jobs/7_finish.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/update_dialog_state.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/update_variables.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class UpdateDialogCubit extends Cubit<UpdateDialogState> {
  UpdateDialogCubit() : super(const CheckingUpdate());

  final List<UpdateJob> allJobsSorted = [
    DownloadMsix(),
    CheckCertificate(),
    InstallMsix(),
    CleanTemp(),
    WaitProcesses(),
    MoveData(),
    CleanPortableFiles(),
    FinishUpdate(),
  ];

  late UpdateVariables variables;
  String releasesUrl = 'https://api.github.com/repos/nocab-transfer/nocab-desktop/releases';
  bool includePrerelease = false;

  Future<void> check() async {
    emit(const CheckingUpdate());
    var currentVersion = await PackageInfo.fromPlatform().then((value) => value.version);
    Map release;
    try {
      var data = await http.get(Uri.parse(releasesUrl));
      if (data.statusCode == 200) {
        List jsonData = jsonDecode(data.body);

        release = includePrerelease
            ? jsonData.first
            : jsonData.firstWhere(
                (element) => element["prerelease"] == false,
                orElse: () => jsonData.first,
              );
      } else if (data.statusCode == 403) {
        emit(const CheckError(message: "Rate limit exceeded. Please try again later."));
        return;
      } else {
        emit(CheckError(message: "Failed to check for updates. Please try again later.", error: "Status code: ${data.statusCode}"));
        return;
      }
    } catch (e) {
      emit(CheckError(message: "Error while checking for updates.", error: "$e"));
      return;
    }

    // set variables
    variables = UpdateVariables(
      latestRelease: release,
      tempDirectory: Directory(join(Directory.systemTemp.path, "nocab_update")),
      signatureThumbprint: (release["assets"] as List)
          .firstWhere((element) => element["name"].toString().contains("signature"))["name"]
          .toString()
          .split("-")
          .last
          .split(".")
          .first,
      signatureUrl: (release["assets"] as List)
          .firstWhere(
            (element) => element["name"].toString().contains("signature"),
          )["browser_download_url"]
          .toString(),
      url: (release["assets"] as List).firstWhere((element) => element["name"].toString().contains("msix"))["browser_download_url"].toString(),
      updateFile: File(join(Directory.systemTemp.path, "nocab_update", "nocab.msix")),
    );

    bool msixInstalled;

    try {
      msixInstalled = await Process.run(
        "powershell",
        ["-c", r'(Get-AppxPackage -Name "NoCabTransfer.Desktop").InstallLocation'],
      ).then((ProcessResult results) {
        return results.stdout.toString().trim() == File(Platform.resolvedExecutable).parent.path;
      });
    } catch (e) {
      emit(const CheckError(message: "Error while checking for updates."));
      return;
    }

    emit(UpdateAvailable(
      newVersion: release['tag_name'],
      currentVersion: currentVersion,
      releaseNotes: release['body'],
      isMsixInstalled: msixInstalled,
    ));
  }

  Future<void> update({required bool msixInstalled}) async {
    emit(const UpdateEvent(jobs: []));

    List<UpdateJob> jobs = [];
    for (var job in allJobsSorted) {
      if (job.portableToMsix && msixInstalled) continue;
      jobs.add(job);
    }

    for (var job in jobs) {
      emit(UpdateEvent(jobs: jobs));
      job.status = UpdateJobStatus.running;
      var jobStatus = await job.run(variables).timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          job.status = UpdateJobStatus.failed;
          return job.finish(descTranslationKey: "timeOut", status: UpdateJobStatus.failed);
        },
      );
      emit(UpdateEvent(jobs: jobs));
      if (!jobStatus && job.cancelOnFailure) {
        for (var element in jobs) {
          if (element.status == UpdateJobStatus.pending) {
            element.status = UpdateJobStatus.notStarted;
          }
        }
        emit(UpdateEvent(jobs: jobs));
        return;
      }
    }

    emit(UpdateEvent(jobs: jobs));
  }
}
