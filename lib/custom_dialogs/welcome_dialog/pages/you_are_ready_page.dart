import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nocab_desktop/custom_icons/custom_icons.dart';
import 'package:nocab_desktop/custom_widgets/sponsor_related/sponsor_providers.dart';
import 'package:url_launcher/url_launcher_string.dart';

class YouAreReadyPage extends StatelessWidget {
  const YouAreReadyPage({super.key});

  final String nocabMobileGithub = "https://github.com/nocab-transfer/nocab-mobile";
  final String nocabDesktopGithub = "https://github.com/nocab-transfer/nocab-desktop";
  final String githubSponsorLink = "https://github.com/sponsors/berkekbgz";
  final String buyMeACoffeeLink = "https://www.buymeacoffee.com/berkekbgz";

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                Text("welcomeDialog.readyPage.references.githubLinks".tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
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
                Text("welcomeDialog.readyPage.references.sponsorToMe".tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SponsorProviders(),
                const SizedBox(height: 8),
                Text("welcomeDialog.readyPage.references.contactText".tr(), style: Theme.of(context).textTheme.bodyLarge),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton.icon(
                    onPressed: () => launchUrlString("mailto:'berkekbgz@gmail.com'"),
                    style: TextButton.styleFrom(
                      fixedSize: const Size(100, 24),
                    ),
                    icon: const Icon(Icons.email_rounded),
                    label: Text('aboutDialog.contact.email'.tr()),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => launchUrlString("https://twitter.com/berkekbgz"),
                    style: TextButton.styleFrom(
                      fixedSize: const Size(100, 24),
                    ),
                    icon: const Icon(CustomIcons.twitter),
                    label: const Text("Twitter"),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => launchUrlString("https://discord.gg/4uB5QgPgab"),
                    style: TextButton.styleFrom(
                      fixedSize: const Size(100, 24),
                    ),
                    icon: const Icon(CustomIcons.discord, size: 18),
                    label: const Text(" Discord"),
                  ),
                ])
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn();
  }
}
