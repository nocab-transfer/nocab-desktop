import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state.dart';
import 'package:nocab_desktop/services/transfer/transfer.dart';

class TransferCardCubit extends Cubit<TransferCardState> {
  TransferCardCubit() : super(const TransferCardInitial());

  int i = 0;

  void start(Transfer transfer) {
    emit(TransferStarted(transfer.deviceInfo));
    transfer.start(
      onDataReport: _onDataReport,
      onEnd: _onEnd,
      onError: _onError,
    );
  }

  void _onDataReport(List<FileInfo> files, List<FileInfo> filesTransferred, FileInfo currentFile, double speed, double progress, DeviceInfo deviceInfo) => emit(Transferring(files, filesTransferred, currentFile, speed, progress, deviceInfo));

  void _onEnd(DeviceInfo deviceInfo, List<FileInfo> files) => emit(TransferSuccess(deviceInfo, files));

  void _onError(DeviceInfo deviceInfo, String message) => emit(TransferFailed(deviceInfo, message));
}
