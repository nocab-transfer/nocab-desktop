import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocab_desktop/models/database/transfer_db.dart';
import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state.dart';
import 'package:nocab_desktop/services/database/database.dart';
import 'package:nocab_desktop/services/transfer/transfer.dart';

class TransferCardCubit extends Cubit<TransferCardState> {
  TransferCardCubit() : super(const TransferCardInitial());

  late Transfer transfer;

  void start(Transfer transfer) {
    this.transfer = transfer;
    emit(TransferStarted(transfer.deviceInfo));
    transfer.start(
      onDataReport: _onDataReport,
      onEnd: _onEnd,
      onError: _onError,
    );

    Database().updateTransfer(
      transfer.uniqueId,
      status: TransferDbStatus.ongoing,
      files: transfer.files,
      startedAt: DateTime.now(),
      managedBy: TransferDbManagedBy.user,
    );
  }

  void _onDataReport(
          List<FileInfo> files, List<FileInfo> filesTransferred, FileInfo currentFile, double speed, double progress, DeviceInfo deviceInfo) =>
      emit(Transferring(files, filesTransferred, currentFile, speed, progress, deviceInfo));

  void _onEnd(DeviceInfo deviceInfo, List<FileInfo> files) {
    emit(TransferSuccess(deviceInfo, files));
    Database().updateTransfer(
      transfer.uniqueId,
      status: TransferDbStatus.success,
      endedAt: DateTime.now(),
    );
  }

  void _onError(DeviceInfo deviceInfo, String message) {
    emit(TransferFailed(deviceInfo, message));
    Database().updateTransfer(
      transfer.uniqueId,
      status: TransferDbStatus.success,
      endedAt: DateTime.now(),
      message: message,
    );
  }
}
