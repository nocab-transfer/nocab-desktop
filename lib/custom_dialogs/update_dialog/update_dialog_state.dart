import 'package:nocab_desktop/custom_dialogs/update_dialog/base_job.dart';

abstract class UpdateDialogState {
  const UpdateDialogState();
}

class CheckingUpdate extends UpdateDialogState {
  const CheckingUpdate();
}

class UpdateAvailable extends UpdateDialogState {
  final String newVersion;
  final String currentVersion;
  final bool isMsixInstalled;
  final String releaseNotes;

  const UpdateAvailable({required this.newVersion, required this.currentVersion, required this.isMsixInstalled, required this.releaseNotes});
}

class CheckError extends UpdateDialogState {
  final String message;
  final String? error;
  const CheckError({required this.message, this.error});
}

class UpdateEvent extends UpdateDialogState {
  final List<UpdateJob> jobs;
  bool get anyFailed => jobs.any((element) => element.status == UpdateJobStatus.failed && element.cancelOnFailure);
  UpdateJob get crashedJob => jobs.firstWhere((element) => element.status == UpdateJobStatus.failed && element.cancelOnFailure);
  const UpdateEvent({required this.jobs});
}
