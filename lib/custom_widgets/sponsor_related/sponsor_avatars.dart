import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nocab_desktop/services/sponsors/sponsors.dart';

class SponsorAvatars extends StatelessWidget {
  const SponsorAvatars({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Sponsors.fetchHighTierSupponsors(),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) return Container();

          return Center(
            child: Column(
              children: [
                Text(
                  'sponsorRelated.avatars.title'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Center(
                          child: Tooltip(
                            waitDuration: const Duration(milliseconds: 500),
                            message: snapshot.data![index].name,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: snapshot.data![index].primary ? const Color(0xFFFFD700) : const Color(0xFF6667AB), width: 2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(snapshot.data![index].imageUrl),
                                  radius: 20,
                                )
                                    .animate(onPlay: (controller) => controller.repeat(), delay: const Duration(milliseconds: 200))
                                    .shimmer(angle: 240)
                                    .then(delay: const Duration(seconds: 10)),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ).animate().fade(curve: Curves.easeInOut);
        } else {
          return Container();
        }
      },
    );
  }
}
