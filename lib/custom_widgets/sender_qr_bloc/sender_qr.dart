import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/custom_widgets/sender_qr_bloc/sender_qr_cubit.dart';
import 'package:nocab_desktop/custom_widgets/sender_qr_bloc/sender_qr_state.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SenderQr extends StatefulWidget {
  final Function(DeviceInfo deviceInfo)? onDeviceConnected;
  const SenderQr({Key? key, this.onDeviceConnected}) : super(key: key);

  @override
  State<SenderQr> createState() => _SenderQrState();
}

class _SenderQrState extends State<SenderQr> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _animation = Tween<double>(begin: 1, end: 0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    return SizedBox(
      height: 150,
      width: 400,
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
                  Text('senderQr.title'.tr(), style: Theme.of(context).textTheme.titleMedium),
                  Text('senderQr.instructions'.tr(), style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text('senderQr.loading.title'.tr(), style: Theme.of(context).textTheme.bodySmall),
                  Text('senderQr.loading.message'.tr(), style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQR(BuildContext context, String ip, int port, String verificationString, Duration currentDuration) {
    _controller.reset();
    _controller.forward();
    return SizedBox(
      height: 150,
      width: 400,
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
                        Text('senderQr.title'.tr(), style: Theme.of(context).textTheme.titleMedium),
                        Text('senderQr.instructions'.tr(), style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Text('senderQr.loaded.waitingConnection'.tr(), style: Theme.of(context).textTheme.bodySmall),
                        Text('senderQr.loaded.connectionInfo'.tr(namedArgs: {'ip': ip, 'port': port.toString()}),
                            style: Theme.of(context).textTheme.bodyMedium),
                        Text(verificationString,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5))),
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
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 25, height: 25, child: CircularProgressIndicator(value: _animation.value)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("${(_animation.value * 10).toInt()}", style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
