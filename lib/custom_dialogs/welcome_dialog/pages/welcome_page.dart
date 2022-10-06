import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  var opacity = 0.0;

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("welcomeDialog.welcomePage.title".tr(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                Text("welcomeDialog.welcomePage.description".tr(), style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 20),
                Text("welcomeDialog.welcomePage.description2".tr(), style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: RichText(
                text: TextSpan(
                  text: 'welcomeDialog.welcomePage.madeWith'.tr().split('{flutterIcon}')[0],
                  children: [
                    WidgetSpan(child: InkWell(onTap: () => launchUrlString('https://flutter.dev/'), child: const FlutterLogo(size: 16))),
                    TextSpan(text: 'welcomeDialog.welcomePage.madeWith'.tr().split('{flutterIcon}')[1]),
                    const TextSpan(text: ' '),
                    TextSpan(text: 'welcomeDialog.welcomePage.builtBy'.tr().split('{author}')[0]),
                    WidgetSpan(
                      child: InkWell(
                        onTap: () => launchUrlString('https://github.com/berkekbgz'),
                        child: Text(
                          'berkekbgz',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    TextSpan(text: 'welcomeDialog.welcomePage.builtBy'.tr().split('{author}')[1]),
                  ],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
