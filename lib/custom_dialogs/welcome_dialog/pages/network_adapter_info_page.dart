import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NetworkAdapterInfoPage extends StatefulWidget {
  const NetworkAdapterInfoPage({Key? key}) : super(key: key);

  @override
  State<NetworkAdapterInfoPage> createState() => _NetworkAdapterInfoPageState();
}

class _NetworkAdapterInfoPageState extends State<NetworkAdapterInfoPage> {
  var opacity = 0.0;
  final String mobileAppLink = "https://github.com/nocab-transfer/nocab-mobile/releases";
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          opacity = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Meet Nocab Mobile!", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Text("NoCab Mobile is required to connect with your phone\nUnfortunetaly there is no ios application 😔", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400)),
            const SizedBox(height: 20),
            Text("Download the mobile application for android:", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: "1- Go to ",
                        children: [
                          WidgetSpan(child: InkWell(onTap: () => launchUrlString(mobileAppLink), child: Text("NoCab Mobile Github", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blue, fontWeight: FontWeight.w600)))),
                          const TextSpan(text: ".\t"),
                          WidgetSpan(child: InkWell(onTap: () => Clipboard.setData(ClipboardData(text: mobileAppLink)), child: const Icon(Icons.copy_rounded, size: 20))),
                        ],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text("2- Download the latest version of mobile application.", style: Theme.of(context).textTheme.bodyMedium),
                    Text("3- Install the application.", style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                Tooltip(
                  message: mobileAppLink,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: QrImage(
                        data: mobileAppLink,
                        size: 120,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
