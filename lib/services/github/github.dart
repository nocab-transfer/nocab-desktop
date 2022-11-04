import 'dart:convert';

import 'package:http/http.dart' as http;

class Github {
  static final Github _singleton = Github._internal();
  factory Github() {
    return _singleton;
  }
  Github._internal();

  List<Map> contributors = [];

  Future<List<Map>> getContributors({required String owner, required String repo}) async {
    if (contributors.isNotEmpty) return contributors;
    try {
      var url = 'https://api.github.com/repos/$owner/$repo/contributors';
      var response = await http.get(Uri.parse(url));
      return contributors = jsonDecode(response.body).cast<Map>();
    } catch (e) {
      return [];
    }
  }
}
