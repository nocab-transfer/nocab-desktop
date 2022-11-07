import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocab_desktop/custom_widgets/sponsor_related/sponsor_snackbar.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_cubit.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state_views/transfer_card_transferfailed.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state_views/transfer_card_transferring.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state_views/transfer_card_transferstarted.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state_views/transfer_card_transfersuccess.dart';
import 'package:nocab_desktop/extensions/size_extension.dart';
import 'package:nocab_desktop/services/database/database.dart';
import 'package:nocab_desktop/services/server/server.dart';
import 'package:nocab_desktop/services/transfer/receiver.dart';
import 'package:nocab_desktop/services/transfer/transfer.dart';

class TransferCard extends StatelessWidget {
  final Transfer transfer;
  const TransferCard({Key? key, required this.transfer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransferCardCubit()..start(transfer),
      child: BlocConsumer<TransferCardCubit, TransferCardState>(
        listener: (context, state) async {
          // if transfer succseeded and
          if (state is TransferSuccess &&
              (await Database().getCount == 2 ||
                  await Database().getCount % 10 == 0 ||
                  transfer.files.fold(0, (totalSize, element) => totalSize + element.byteSize) > 1.gbToBytes)) {
            if (context.mounted) SponsorSnackbar.show(context);
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
          state: state as TransferSuccess, isDownload: transfer is Receiver, onClose: () => Server().removeTransferFromList(transfer));
    case TransferFailed:
      return TransferFailedView(
          state: state as TransferFailed, isDownload: transfer is Receiver, onClose: () => Server().removeTransferFromList(transfer));
    default:
      return Container();
  }
}
