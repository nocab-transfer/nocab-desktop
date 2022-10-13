import 'dart:convert';

import 'package:http/http.dart' as http;

class Github {
  static Future<List<Map>> getContributors(
      {required String owner, required String repo}) async {
    try {
      var url = 'https://api.github.com/repos/$owner/$repo/contributors';
      var response = await http.get(Uri.parse(url));
      return jsonDecode(response.body).cast<Map>();
    } catch (e) {
      return [];
    }
  }
}
