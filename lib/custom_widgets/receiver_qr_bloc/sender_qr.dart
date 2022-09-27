import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocab_desktop/custom_widgets/receiver_qr_bloc/sender_qr_cubit.dart';
import 'package:nocab_desktop/custom_widgets/receiver_qr_bloc/sender_qr_state.dart';
import 'package:nocab_desktop/l10n/generated/app_localizations.dart';
import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SenderQr extends StatefulWidget {
  final Function(DeviceInfo deviceInfo)? onDeviceConnected;
  const SenderQr({Key? key, this.onDeviceConnected}) : super(key: key);

  @override
  State<SenderQr> createState() => _SenderQrState();
}

class _SenderQrState extends State<SenderQr> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SenderQrCubit()..startQrServer(widget.onDeviceConnected),
      child: buildWidget(),
    );
  }

  Widget buildWidget() => BlocConsumer<SenderQrCubit, SenderQrState>(
        listener: (context, state) {},
        builder: (context, state) {
          switch (state.runtimeType) {
            case Initial:
              return _buildInitial();
            case ConnectionWaiting:
              return _buildQR(context, (state as ConnectionWaiting).ip, state.port, state.verificationString, state.currentDuration);
            default:
              return Container();
            //return _buildNoDevice();
          }
        },
      );

  Widget _buildInitial() {
    return Container(
      height: 150,
      width: 400,
      decoration: const BoxDecoration(
        //border: Border.all(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.2)),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
          SizedBox(
            width: 280,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context).scanQrCodeLabelText, style: Theme.of(context).textTheme.titleMedium),
                  Text(AppLocalizations.of(context).senderQrInfoLabelText, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context).serverCreatingLabelText, style: Theme.of(context).textTheme.bodySmall),
                  Text(AppLocalizations.of(context).loadingLabelText, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQR(BuildContext context, String ip, int port, String verificationString, Duration currentDuration) {
    var refreshDuration = context.read<SenderQrCubit>().refreshDuration;
    return Container(
      height: 150,
      width: 400,
      decoration: const BoxDecoration(
        //border: Border.all(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.2)),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 350,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImage(
                  size: 120,
                  padding: const EdgeInsets.all(0),
                  data: base64.encode(utf8.encode('$ip:$port:$verificationString')),
                  version: QrVersions.auto,
                  dataModuleStyle: QrDataModuleStyle(color: Theme.of(context).colorScheme.onSurface, dataModuleShape: QrDataModuleShape.circle),
                  eyeStyle: QrEyeStyle(color: Theme.of(context).colorScheme.onSurface, eyeShape: QrEyeShape.circle),
                ),
                SizedBox(
                  width: 214,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context).scanQrCodeLabelText, style: Theme.of(context).textTheme.titleMedium),
                        Text(AppLocalizations.of(context).senderQrInfoLabelText, style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Text(AppLocalizations.of(context).waitingForConnectionLabelText, style: Theme.of(context).textTheme.bodySmall),
                        Text("$ip:$port", style: Theme.of(context).textTheme.bodyMedium),
                        Text(verificationString, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      value: 1 - (currentDuration.inMilliseconds / refreshDuration.inMilliseconds),
                      strokeWidth: 4,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${refreshDuration.inSeconds - currentDuration.inSeconds}", style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
