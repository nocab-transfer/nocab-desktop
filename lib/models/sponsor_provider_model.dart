import 'package:flutter/material.dart';

class SponsorProviderModel {
  String name;
  Icon? logo;
  String url;
  bool primary;
  SponsorProviderModel({required this.name, this.logo, required this.url, this.primary = false});
}
