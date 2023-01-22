import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nocab_desktop/services/sponsors/sponsors.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SponsorProviders extends StatelessWidget {
  const SponsorProviders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //width: 300,
      height: 40,
      child: ListView.builder(
        itemCount: Sponsors.getSponsors.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          var widget = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: TextButton.icon(
              label: Text(
                Sponsors.getSponsors[index].name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              icon: Sponsors.getSponsors[index].logo ?? const Icon(Icons.error_outline_rounded),
              onPressed: () => launchUrlString(Sponsors.getSponsors[index].url),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                shape: Sponsors.getSponsors[index].primary
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      )
                    : null,
              ),
            ),
          );
          if (Sponsors.getSponsors[index].primary) {
            return widget
                .animate(onPlay: (controller) => controller.repeat(), delay: const Duration(milliseconds: 200))
                .shimmer(angle: 240, color: const Color(0xFFFFFBFF), duration: 500.ms)
                .then(delay: const Duration(milliseconds: 800));
          }

          return widget;
        },
      ),
    );
  }
}
