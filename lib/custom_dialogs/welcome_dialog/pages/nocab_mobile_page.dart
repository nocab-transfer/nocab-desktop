import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NoCabMobilePage extends StatefulWidget {
  const NoCabMobilePage({Key? key}) : super(key: key);

  @override
  State<NoCabMobilePage> createState() => _NoCabMobilePageState();
}

class _NoCabMobilePageState extends State<NoCabMobilePage> {
  var opacity = 0.0;
  final String mobileAppLink =
      "https://github.com/nocab-transfer/nocab-mobile/releases";
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
            Text("welcomeDialog.noCabMobilePage.title".tr(),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Text("welcomeDialog.noCabMobilePage.description".tr(),
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            Text("welcomeDialog.noCabMobilePage.description2".tr(),
                style: Theme.of(context).textTheme.bodyLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: "welcomeDialog.noCabMobilePage.instructions.step1"
                            .tr()
                            .split('{link}')[0],
                        children: [
                          WidgetSpan(
                              child: InkWell(
                                  onTap: () => launchUrlString(mobileAppLink),
                                  child: Text("NoCab Mobile Github Releases",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.w600)))),
                          TextSpan(
                              text:
                                  "${'welcomeDialog.noCabMobilePage.instructions.step1'.tr().split('{link}')[1]}.\t"),
                          WidgetSpan(
                              child: InkWell(
                                  onTap: () => Clipboard.setData(
                                      ClipboardData(text: mobileAppLink)),
                                  child: const Icon(Icons.copy_rounded,
                                      size: 20))),
                        ],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                        "welcomeDialog.noCabMobilePage.instructions.step2".tr(),
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                        "welcomeDialog.noCabMobilePage.instructions.step3".tr(),
                        style: Theme.of(context).textTheme.bodyMedium),
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
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.12),
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
