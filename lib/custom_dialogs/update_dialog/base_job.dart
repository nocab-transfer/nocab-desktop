import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/update_variables.dart';

abstract class UpdateJob {
  final bool portableToMsix = false;
  UpdateJobStatus status = UpdateJobStatus.pending;
  final bool cancelOnFailure = true;
  String? errorMessage = "";

  final String translationMasterKey;
  String descTranslationKey;

  UpdateJob(this.translationMasterKey, this.descTranslationKey);

  Future<bool> run(UpdateVariables variables);

  bool finish({required String descTranslationKey, String? errorMessage, required UpdateJobStatus status}) {
    _stopwatch.stop();
    this.descTranslationKey = descTranslationKey;
    this.errorMessage = errorMessage ?? "";
    this.status = status;
    return status == UpdateJobStatus.done;
  }

  final Stopwatch _stopwatch = Stopwatch();
  void startTimer() => _stopwatch.start();

  int get milliseconds => _stopwatch.elapsedMilliseconds;
}

enum UpdateJobStatus {
  notStarted,
  pending,
  running,
  done,
  failed,
}

extension JobStatus on UpdateJobStatus {
  Color color(BuildContext context) {
    switch (this) {
      case UpdateJobStatus.notStarted:
        return Theme.of(context).colorScheme.surfaceVariant;
      case UpdateJobStatus.pending:
        return Theme.of(context).colorScheme.surfaceVariant;
      case UpdateJobStatus.running:
        return Theme.of(context).colorScheme.primary;
      case UpdateJobStatus.done:
        return Theme.of(context).colorScheme.primary;
      case UpdateJobStatus.failed:
        return Theme.of(context).colorScheme.error;
    }
  }

  Widget icon(BuildContext context) {
    switch (this) {
      case UpdateJobStatus.notStarted:
        return const Icon(Icons.remove_circle_rounded, color: Colors.grey);
      case UpdateJobStatus.pending:
        return const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        );
      case UpdateJobStatus.running:
        return SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary),
        );
      case UpdateJobStatus.done:
        return Icon(Icons.check, color: Theme.of(context).colorScheme.onPrimary);
      case UpdateJobStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
    }
  }
}
