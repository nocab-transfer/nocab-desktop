import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/models/file_model.dart';

abstract class TransferCardState {
  const TransferCardState();
}

class TransferCardInitial extends TransferCardState {
  const TransferCardInitial();
}

class TransferStarted extends TransferCardState {
  final DeviceInfo deviceInfo;
  const TransferStarted(this.deviceInfo);
}

class Transferring extends TransferCardState {
  final List<FileInfo> files;
  final List<FileInfo> filesTransferred;
  final FileInfo currentFile;
  final double speed;
  final double progress;
  final DeviceInfo deviceInfo;
  const Transferring(
    this.files,
    this.filesTransferred,
    this.currentFile,
    this.speed,
    this.progress,
    this.deviceInfo,
  );
}

class TransferSuccess extends TransferCardState {
  final DeviceInfo deviceInfo;
  final List<FileInfo> files;
  const TransferSuccess(this.deviceInfo, this.files);
}

class TransferFileEnded extends TransferCardState {
  final FileInfo file;
  const TransferFileEnded(this.file);
}

class TransferFailed extends TransferCardState {
  final DeviceInfo deviceInfo;
  final String message;
  const TransferFailed(this.deviceInfo, this.message);
}
