import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/custom_widgets/sponsor_related/sponsor_snackbar.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_cubit.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state_views/transfer_card_transfercancelled.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state_views/transfer_card_transferfailed.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state_views/transfer_card_transferring.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state_views/transfer_card_transferstarted.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state_views/transfer_card_transfersuccess.dart';
import 'package:nocab_desktop/extensions/size_extension.dart';
import 'package:nocab_desktop/models/database/transfer_db.dart';
import 'package:nocab_desktop/services/database/database.dart';
import 'package:nocab_desktop/services/settings/settings.dart';

class TransferCard extends StatelessWidget {
  final Transfer transfer;
  final Function()? onClose;
  const TransferCard({Key? key, required this.transfer, this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransferCardCubit()..start(transfer),
      child: BlocConsumer<TransferCardCubit, TransferCardState>(
        listener: (context, state) async {
          if (state is TransferSuccess && !SettingsService().getSettings.hideSponsorSnackbar) {
            await Future.delayed(const Duration(seconds: 1)); // wait for database to update
            int successfullTransfers = await Database().getCountFiltered(status: TransferDbStatus.success);
            int latestTransferSize = transfer.files.fold(0, (totalSize, element) => totalSize + element.byteSize);
            if (successfullTransfers == 0) return;
            if (successfullTransfers == 2 || successfullTransfers % 10 == 0 || latestTransferSize > 1.gbToBytes) {
              if (context.mounted) SponsorSnackbar.show(context, latestTransferSize: latestTransferSize, transferCount: successfullTransfers);
            }
          }
        },
        builder: (context, state) => buildWidget(context, state),
      ),
    );
  }

  Widget buildWidget(BuildContext context, TransferCardState state) {
    switch (state.runtimeType) {
      case TransferCardInitial:
        return Container();
      case TransferStarted:
        return TransferStartedView(state: state as TransferStarted, isDownload: transfer is Receiver);
      case Transferring:
        return TransferringView(
            state: state as Transferring, isDownload: transfer is Receiver, onCancel: () => context.read<TransferCardCubit>().cancel());
      case TransferSuccess:
        return TransferSuccessView(state: state as TransferSuccess, isDownload: transfer is Receiver, onClose: onClose);
      case TransferFailed:
        return TransferFailedView(state: state as TransferFailed, isDownload: transfer is Receiver, onClose: onClose);
      case TransferCancelled:
        return TransferCancelledView(state: state as TransferCancelled, isDownload: transfer is Receiver, onClose: onClose);
      default:
        return Container();
    }
  }
}
