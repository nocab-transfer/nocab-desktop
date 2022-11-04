import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nocab_desktop/custom_icons/custom_icons.dart';
import 'package:nocab_desktop/models/sponsor_model.dart';
import 'package:nocab_desktop/models/sponsor_provider_model.dart';
import 'package:http/http.dart' as http;

class Sponsors {
  static const String githubRedirectUrl = "https://github.com/sponsors/berkekbgz";
  static const String patreonRedirectUrl = "https://www.patreon.com/berkekbgz";
  static const String buymeacoffeeRedirectUrl = "https://www.buymeacoffee.com/berkekbgz";

  static final List<SponsorProviderModel> _sponsors = [
    SponsorProviderModel(
      name: "Github Sponsors",
      logo: const Icon(CustomIcons.github),
      url: githubRedirectUrl,
      primary: true,
    ),
    SponsorProviderModel(
      name: "Patreon",
      logo: const Icon(CustomIcons.patreon, size: 20),
      url: patreonRedirectUrl,
    ),
    SponsorProviderModel(
      name: "Buy Me A Coffee",
      logo: const Icon(CustomIcons.buymeacoffee),
      url: buymeacoffeeRedirectUrl,
    ),
  ];

  static List<SponsorProviderModel> get getSponsors => _sponsors;

  static Future<List<SponsorModel>> fetchHighTierSupponsors() async {
    const String sponsorsUrl = "https://raw.githubusercontent.com/berkekbgz/sponsors/main/sponsors.json";
    try {
      var response = await http.get(Uri.parse(sponsorsUrl));
      if (response.statusCode == 200) {
        final List<dynamic> sponsors = jsonDecode(response.body);
        return sponsors.map((sponsor) => SponsorModel.fromJson(sponsor)).toList()..sort((a, b) => a.primary ? -1 : 1);
      }
    } catch (e) {
      return [];
    }
    return [];
  }
}
