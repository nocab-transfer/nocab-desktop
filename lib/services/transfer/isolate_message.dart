import 'package:nocab_desktop/models/file_model.dart';

enum ConnectionActionType {
  start,
  event,
  fileEnd,
  end,
  error,
}

class ConnectionAction {
  ConnectionActionType type;

  FileInfo? currentFile;
  int? totalTransferredBytes;

  ConnectionAction(this.type, {this.currentFile, this.totalTransferredBytes});
}
