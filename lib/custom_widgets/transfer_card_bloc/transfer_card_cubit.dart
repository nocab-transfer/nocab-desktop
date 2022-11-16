import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state.dart';
import 'package:nocab_desktop/services/transfer/report_models/data_report.dart';
import 'package:nocab_desktop/services/transfer/report_models/end_report.dart';
import 'package:nocab_desktop/services/transfer/report_models/error_report.dart';
import 'package:nocab_desktop/services/transfer/transfer.dart';

class TransferCardCubit extends Cubit<TransferCardState> {
  TransferCardCubit() : super(const TransferCardInitial());

  late Transfer transfer;

  void start(Transfer transfer) {
    this.transfer = transfer;
    emit(TransferStarted(transfer.deviceInfo));

    transfer.onEvent.listen((event) {
      switch (event.runtimeType) {
        case DataReport:
          event as DataReport;
          emit(Transferring(event.files, event.filesTransferred, event.currentFile, event.speed, event.progress, event.deviceInfo));
          break;
        case EndReport:
          event as EndReport;
          emit(TransferSuccess(event.device, event.files));
          break;
        case ErrorReport:
          event as ErrorReport;
          emit(TransferFailed(event.device, event.message));
          break;
        default:
      }
    });
  }
}
