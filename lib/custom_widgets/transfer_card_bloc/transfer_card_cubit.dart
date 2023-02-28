import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state.dart';

class TransferCardCubit extends Cubit<TransferCardState> {
  TransferCardCubit() : super(const TransferCardInitial());

  late Transfer transfer;

  void start(Transfer transfer) {
    this.transfer = transfer;
    emit(TransferStarted(transfer.deviceInfo));

    transfer.onEvent.listen((event) {
      switch (event.runtimeType) {
        case ProgressReport:
          event as ProgressReport;
          emit(Transferring(
            transfer.files,
            event.filesTransferred,
            event.currentFile,
            event.speed / 1024 / 1024,
            event.progress * 100,
            transfer.deviceInfo,
          ));
          break;
        case EndReport:
          event as EndReport;
          emit(TransferSuccess(transfer.deviceInfo, transfer.files));
          break;
        case ErrorReport:
          event as ErrorReport;
          emit(TransferFailed(transfer.deviceInfo, event.error.title));
          break;
        case CancelReport:
          event as CancelReport;
          emit(TransferCancelled(transfer.deviceInfo));
          break;
        default:
      }
    });
  }

  void cancel() {
    transfer.cancel();
  }
}
