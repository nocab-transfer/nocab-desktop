import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nocab_desktop/custom_icons/custom_icons.dart';
import 'package:nocab_desktop/custom_widgets/sponsor_related/sponsor_avatars.dart';
import 'package:nocab_desktop/custom_widgets/sponsor_related/sponsor_providers.dart';
import 'package:nocab_desktop/services/github/github.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutDialogCustomized extends StatelessWidget {
  const AboutDialogCustomized({Key? key}) : super(key: key);

  final String githubSponsorLink = "https://github.com/sponsors/berkekbgz";
  final String buyMeACoffeeLink = "https://www.buymeacoffee.com/berkekbgz";
  final String patreon = "https://www.patreon.com/berkekbgz";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //override the default behavior of the dialog
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: SponsorAvatars(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: GestureDetector(
                //make the dialog not close when content is tapped
                onTap: () {},
                child: SizedBox(
                  width: 600,
                  child: AboutDialog(
                    applicationVersion: "NoCab Client for desktop file transfer.",
                    applicationIcon: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const Image(
                        image: AssetImage('assets/logo/logo.png'),
                        height: 70,
                        width: 70,
                      ),
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => launchUrlString('https://github.com/nocab-transfer'),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('aboutDialog.openGithubPage'.tr()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 450,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("aboutDialog.sponsor.title".tr(),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                              ),
                              const SponsorProviders(),
                              Divider(color: Theme.of(context).colorScheme.secondary),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("aboutDialog.contact.title".tr(),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                              ),
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
                              ]),
                              Divider(color: Theme.of(context).colorScheme.secondary),
                              Text('aboutDialog.contributors'.tr(), style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  //border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
                                ),
                                height: 50,
                                width: 400,
                                child: FutureBuilder(
                                  future: Github().getContributors(owner: 'nocab-transfer', repo: 'nocab-desktop'),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data!.isEmpty) {
                                        return Center(
                                          child: Text(
                                            'aboutDialog.errorMessage'.tr(),
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                                          ),
                                        );
                                      }
                                      return Center(
                                        child: ListView.builder(
                                          itemCount: snapshot.data!.length,
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Center(
                                                child: Tooltip(
                                                  waitDuration: const Duration(milliseconds: 500),
                                                  message: snapshot.data![index]['login'],
                                                  child: InkWell(
                                                    onTap: () => launchUrlString(snapshot.data![index]['html_url']),
                                                    child: CircleAvatar(
                                                      backgroundImage: NetworkImage(snapshot.data![index]['avatar_url']),
                                                      radius: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                                .animate()
                                                .scaleXY(delay: (0.1 * index).seconds, duration: 0.3.seconds, curve: Curves.easeOutBack)
                                                .fadeIn(delay: (0.1 * index).seconds, duration: 0.3.seconds);
                                          },
                                        ),
                                      );
                                    } else {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
