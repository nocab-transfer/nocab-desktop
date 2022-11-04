class SponsorModel {
  late String name;
  late String imageUrl;
  late bool primary;

  SponsorModel({required this.name, required this.imageUrl, required this.primary});

  SponsorModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    imageUrl = json['imageUrl'];
    primary = json['primary'];
  }
}
