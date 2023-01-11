import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/custom_widgets/sponsor_related/sponsor_snackbar.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_cubit.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state_views/transfer_card_transferfailed.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state_views/transfer_card_transferring.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state_views/transfer_card_transferstarted.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state_views/transfer_card_transfersuccess.dart';
import 'package:nocab_desktop/extensions/size_extension.dart';
import 'package:nocab_desktop/models/database/transfer_db.dart';
import 'package:nocab_desktop/services/database/database.dart';
import 'package:nocab_desktop/services/transfer_manager/transfer_manager.dart';

class TransferCard extends StatelessWidget {
  final Transfer transfer;
  const TransferCard({Key? key, required this.transfer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransferCardCubit()..start(transfer),
      child: BlocConsumer<TransferCardCubit, TransferCardState>(
        listener: (context, state) async {
          if (state is TransferSuccess) {
            await Future.delayed(const Duration(seconds: 1)); // wait for database to update
            int successfullTransfers = await Database().getCountFiltered(status: TransferDbStatus.success);
            int latestTransferSize = transfer.files.fold(0, (totalSize, element) => totalSize + element.byteSize);
            if (successfullTransfers == 0) return;
            if (successfullTransfers == 2 || successfullTransfers % 10 == 0 || latestTransferSize > 1.gbToBytes) {
              if (context.mounted) SponsorSnackbar.show(context, latestTransferSize: latestTransferSize, transferCount: successfullTransfers);
            }
          }
        },
        builder: (context, state) => buildWidget(context, state, transfer),
      ),
    );
  }
}

Widget buildWidget(BuildContext context, TransferCardState state, Transfer transfer) {
  switch (state.runtimeType) {
    case TransferCardInitial:
      return Container();
    case TransferStarted:
      return TransferStartedView(state: state as TransferStarted, isDownload: transfer is Receiver);
    case Transferring:
      return TransferringView(state: state as Transferring, isDownload: transfer is Receiver);
    case TransferSuccess:
      return TransferSuccessView(
          state: state as TransferSuccess, isDownload: transfer is Receiver, onClose: () => TransferManager().removeTranser(transfer));
    case TransferFailed:
      return TransferFailedView(
          state: state as TransferFailed, isDownload: transfer is Receiver, onClose: () => TransferManager().removeTranser(transfer));
    default:
      return Container();
  }
}
