import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/custom_dialogs/welcome_dialog/pages/nocab_mobile_page.dart';
import 'package:nocab_desktop/custom_dialogs/welcome_dialog/welcome_dialog.dart';
import 'package:nocab_desktop/custom_widgets/svg_color_handler/svg_color_handler.dart';
import 'package:nocab_desktop/services/settings/settings.dart';

class DeviceFinder extends StatefulWidget {
  final Function(DeviceInfo deviceInfo)? onPressed;
  final Map<DeviceInfo, ShareRequest> sentRequests;
  const DeviceFinder({Key? key, this.onPressed, this.sentRequests = const {}}) : super(key: key);

  @override
  State<DeviceFinder> createState() => _DeviceFinderState();
}

class _DeviceFinderState extends State<DeviceFinder> {
  List<DeviceInfo> devices = [];

  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) timer?.cancel();
      Radar.searchForDevices(SettingsService().getSettings.finderPort).listen((event) {
        if (mounted) setState(() => devices = event);
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.sentRequests.forEach((key, value) {
      value.onResponse.then((value) {
        if (mounted) setState(() {});
      });
    });

    if (devices.isEmpty && widget.sentRequests.isEmpty) return _buildNoDevice();
    return _buildList(widget.sentRequests, devices);
  }

  Widget _buildNoDevice() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
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
            Text('deviceScanner.searching'.tr(), style: Theme.of(context).textTheme.titleLarge)
          ],
        ),
        Text('deviceScanner.noDevicesFound'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, letterSpacing: .5)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('deviceScanner.networkHint'.tr(), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
              Text('deviceScanner.instructions'.tr(), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const WelcomeDialog(overridePages: [NoCabMobilePage()]),
              );
            },
            icon: const Icon(Icons.help_outline, size: 16),
            label: Text('deviceScanner.downloadNoCabMobile'.tr(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildList(Map<DeviceInfo, ShareRequest> requests, List<DeviceInfo> devices) {
    devices.removeWhere((element) => requests.entries.where((element) => !element.value.isResponded).any((entry) => entry.key.name == element.name));

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          ListView.builder(
            itemCount: requests.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _listTile(requests.keys.elementAt(index), shareRequest: requests[requests.keys.elementAt(index)]),
          ),
          ListView.builder(
            itemCount: devices.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _listTile(devices[index]),
          )
        ],
      ),
    );
  }

  Widget _listTile(DeviceInfo device, {ShareRequest? shareRequest}) {
    shareRequest;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: shareRequest == null ? () => widget.onPressed?.call(device) : null,
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(device.name),
              Text(
                "${device.ip}:${device.requestPort}",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
          subtitle: _buildRequestState(shareRequest),
        ),
      ),
    );
  }

  Widget _buildRequestState(ShareRequest? request) {
    if (request == null) {
      return RichText(
        text: TextSpan(
          text: "",
          children: [
            const WidgetSpan(child: Icon(Icons.send_rounded, size: 16, color: Colors.blue)),
            TextSpan(
              text: " Ready to Connect",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    if (!request.isResponded) {
      return RichText(
        text: TextSpan(
          text: "",
          children: [
            const WidgetSpan(child: Icon(Icons.send_rounded, size: 16, color: Colors.blue)),
            TextSpan(
              text: " Request Sent",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      if (request.linkedTransfer != null) {
        return RichText(
          text: TextSpan(
            text: "",
            children: [
              const WidgetSpan(child: Icon(Icons.check_rounded, size: 16, color: Colors.green)),
              TextSpan(
                text: " Request Accepted",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }
      return RichText(
        text: TextSpan(
          text: "",
          children: [
            const WidgetSpan(child: Icon(Icons.close_rounded, size: 16, color: Colors.red)),
            TextSpan(
              text: " Request Rejected",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
  }
}
