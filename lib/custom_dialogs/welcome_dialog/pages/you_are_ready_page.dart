import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class YouAreReadyPage extends StatefulWidget {
  const YouAreReadyPage({Key? key}) : super(key: key);

  @override
  State<YouAreReadyPage> createState() => _YouAreReadyPageState();
}

class _YouAreReadyPageState extends State<YouAreReadyPage> {
  var opacity = 0.0;
  String nocabMobileGithub = "https://github.com/nocab-transfer/nocab-mobile";
  String nocabDesktopGithub = "https://github.com/nocab-transfer/nocab-desktop";
  String githubSponsorLink = "https://github.com/sponsors/berkekbgz";
  String buyMeACoffeeLink = "https://www.buymeacoffee.com/berkekbgz";

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("welcomeDialog.readyPage.title".tr(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Text("welcomeDialog.readyPage.description".tr(), style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            Container(
              width: 500,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("welcomeDialog.readyPage.references.githubLinks".tr(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () => launchUrlString(nocabMobileGithub),
                        icon: const Icon(Icons.phone_android_rounded),
                        label: Text("welcomeDialog.readyPage.references.mobile".tr()),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => launchUrlString(nocabDesktopGithub),
                        icon: const Icon(Icons.desktop_windows_rounded),
                        label: Text("welcomeDialog.readyPage.references.desktop".tr()),
                      ),
                    ],
                  ),
                  Text("welcomeDialog.readyPage.references.sponsorToMe".tr(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () => launchUrlString(githubSponsorLink),
                        icon: const Icon(Icons.favorite),
                        label: Text("welcomeDialog.readyPage.references.fromGithub".tr()),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => launchUrlString(buyMeACoffeeLink),
                        icon: const Icon(Icons.coffee_rounded),
                        label: Text("welcomeDialog.readyPage.references.fromBuymeacoffee".tr()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("welcomeDialog.readyPage.references.contactText".tr(), style: Theme.of(context).textTheme.bodyLarge),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    TextButton(
                      onPressed: () => launchUrlString("mailto:'berkekbgz@gmail.com'"),
                      style: TextButton.styleFrom(
                        fixedSize: const Size(70, 24),
                      ),
                      child: Text('welcomeDialog.readyPage.references.email'.tr()),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => launchUrlString("https://twitter.com/berkekbgz"),
                      style: TextButton.styleFrom(
                        fixedSize: const Size(70, 24),
                      ),
                      child: const Text("Twitter"),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => launchUrlString("https://discordapp.com/users/505780125057679360"),
                      style: TextButton.styleFrom(
                        fixedSize: const Size(70, 24),
                      ),
                      child: const Text("Discord"),
                    ),
                  ])
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
