import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocab_desktop/custom_widgets/device_finder_bloc/device_finder_cubit.dart';
import 'package:nocab_desktop/custom_widgets/device_finder_bloc/device_finder_state.dart';
import 'package:nocab_desktop/custom_widgets/svg_color_handler/svg_color_handler.dart';
import 'package:nocab_desktop/l10n/generated/app_localizations.dart';
import 'package:nocab_desktop/models/deviceinfo_model.dart';

class DeviceFinder extends StatefulWidget {
  final Function(DeviceInfo deviceInfo)? onPressed;
  final List<DeviceInfo> blockDevices;
  const DeviceFinder({Key? key, this.onPressed, this.blockDevices = const []}) : super(key: key);

  @override
  State<DeviceFinder> createState() => _DeviceFinderState();
}

class _DeviceFinderState extends State<DeviceFinder> {
  bool isVibrated = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceFinderCubit()..startScanning(),
      child: buildWidget(),
    );
  }

  Widget buildWidget() => BlocConsumer<DeviceFinderCubit, DeviceFinderState>(
        listener: (context, state) {},
        builder: (context, state) {
          switch (state.runtimeType) {
            case NoDevice:
              return _buildNoDevice();
            case Found:
              return _buildDeviceList((state as Found).devices);
            default:
              return _buildNoDevice();
          }
        },
      );

  Widget _buildNoDevice() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgColorHandler(
          svgPath: "assets/images/not_found.svg",
          colorSwitch: {const Color(0xFFFF0000): Theme.of(context).colorScheme.primaryContainer},
          height: 100,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(),
              ),
            ),
            Text(AppLocalizations.of(context).emptyDeviceListLabelText, style: Theme.of(context).textTheme.titleLarge)
          ],
        ),
        Text(AppLocalizations.of(context).searchingDeviceLabelText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildDeviceList(List<DeviceInfo> devices) {
    return ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.blockDevices.map((e) => e.name).toList().contains(devices[index].name) ? null : () => widget.onPressed?.call(devices[index]),
              borderRadius: BorderRadius.circular(10),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: const Icon(Icons.desktop_windows_rounded),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                title: Text(devices[index].name ?? "Unknown"),
                subtitle: Text(devices[index].ip ?? "Unknown"),
              ),
            ),
          );
        });
  }
}
