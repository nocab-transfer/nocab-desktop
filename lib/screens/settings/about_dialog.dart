import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/services/github/github.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutDialogCustomized extends StatelessWidget {
  const AboutDialogCustomized({Key? key}) : super(key: key);

  final String githubSponsorLink = "https://github.com/sponsors/berkekbgz";
  final String buyMeACoffeeLink = "https://www.buymeacoffee.com/berkekbgz";

  @override
  Widget build(BuildContext context) {
    return AboutDialog(
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
                Text(
                  "aboutDialog.sponsor.title".tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => launchUrlString(githubSponsorLink),
                      icon: const Icon(Icons.favorite),
                      label: Text("aboutDialog.sponsor.fromGithub".tr()),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => launchUrlString(buyMeACoffeeLink),
                      icon: const Icon(Icons.coffee_rounded),
                      label: Text("aboutDialog.sponsor.fromBuymeacoffee".tr()),
                    ),
                  ],
                ),
                Divider(color: Theme.of(context).colorScheme.secondary),
                Text("aboutDialog.contact.title".tr(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(
                    onPressed: () => launchUrlString("mailto:'berkekbgz@gmail.com'"),
                    style: TextButton.styleFrom(
                      fixedSize: const Size(70, 24),
                    ),
                    child: Text('aboutDialog.contact.email'.tr()),
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
                ]),
                Divider(color: Theme.of(context).colorScheme.secondary),
                Text('aboutDialog.contributors'.tr(), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    //border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
                  ),
                  height: 100,
                  width: 350,
                  child: FutureBuilder(
                    future: Github.getContributors(owner: 'nocab-transfer', repo: 'nocab-desktop'),
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
                        return GridView.builder(
                          itemCount: snapshot.data!.length,
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
                          itemBuilder: (context, index) {
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => launchUrlString(snapshot.data![index]['html_url']),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(snapshot.data![index]['avatar_url']),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        snapshot.data![index]['login'],
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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
    );
  }
}
