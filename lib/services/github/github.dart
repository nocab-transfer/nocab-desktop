import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

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

  Future<bool> isUpdateAvailable({bool includePrerelease = false}) async {
    try {
      var releasesUrl = 'https://api.github.com/repos/nocab-transfer/test/releases';

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;

      var data = await http.get(Uri.parse(releasesUrl));
      if (data.statusCode == 200) {
        List jsonData = jsonDecode(data.body);

        var latestRelease = includePrerelease
            ? jsonData.first
            : jsonData.firstWhere(
                (element) => element["prerelease"] == false,
                orElse: () => jsonData.first,
              );
        String latestVersion = latestRelease["tag_name"];
        return (_isVersionGreaterThan(latestVersion.replaceAll('v', ''), version));
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  bool _isVersionGreaterThan(String newVersion, String currentVersion) {
    List<String> currentV = currentVersion.split(".");
    List<String> newV = newVersion.split(".");
    bool a = false;
    for (var i = 0; i <= 2; i++) {
      a = int.parse(newV[i]) > int.parse(currentV[i]);
      if (int.parse(newV[i]) != int.parse(currentV[i])) break;
    }
    return a;
  }
}
