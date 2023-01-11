import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/custom_widgets/device_finder_bloc/device_finder.dart';
import 'package:nocab_desktop/custom_widgets/file_list/file_list.dart';
import 'package:nocab_desktop/custom_widgets/sender_qr_bloc/sender_qr.dart';
import 'package:nocab_desktop/extensions/size_extension.dart';
import 'package:nocab_desktop/services/transfer_manager/transfer_manager.dart';

class SendStarterDialog extends StatefulWidget {
  final List<FileInfo> files;
  const SendStarterDialog({Key? key, required this.files}) : super(key: key);

  @override
  State<SendStarterDialog> createState() => _SendStarterDialogState();
}

class _SendStarterDialogState extends State<SendStarterDialog> {
  List<DeviceInfo> deviceClickBlock = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(8),
      child: Container(
          width: 864 + 1,
          height: 516,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: InkWell(
                        onTap: Navigator.of(context).pop,
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.close_rounded),
                        ),
                      )),
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 432,
                    height: 550,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text('sender.files'.tr(),
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Text(
                                  'sender.fileCounter'.plural(widget.files.length, name: 'count', namedArgs: {
                                    'size': widget.files.map((file) => file.byteSize).reduce((a, b) => a + b).formatBytes(useName: true),
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 400,
                          height: 450,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                          ),
                          child: FileList(files: widget.files),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(width: 1, thickness: 1, indent: 64, endIndent: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  SizedBox(
                    width: 432,
                    height: 550,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text('sender.devices'.tr(),
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 400,
                          height: 450,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 300,
                                child: Center(
                                  child: DeviceFinder(
                                    blockDevices: deviceClickBlock,
                                    onPressed: (deviceInfo) async {
                                      setState(() => deviceClickBlock.add(deviceInfo));
                                      TransferManager().sendRequest(deviceInfo, widget.files);
                                    },
                                  ),
                                ),
                              ),
                              SenderQr(
                                onDeviceConnected: (deviceInfo) {
                                  if (mounted) {
                                    setState(() => deviceClickBlock.add(deviceInfo));
                                    TransferManager().sendRequest(deviceInfo, widget.files);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
