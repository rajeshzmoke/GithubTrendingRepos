import 'dart:convert';
import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:github_trending_repos/model/repo_model.dart';
import 'package:http/http.dart' as http;

class Api {
  static const String _url = "api.github.com";

  static Future getTrendingRepos() async {
    final lastWeek = DateTime.now().subtract(Duration(days: 7));

    final formattedDate = formatDate(lastWeek, [yyyy, '-', mm, '-', dd]);

    final uri = Uri.https(_url, '/search/repositories', {
      'q': 'created:>$formattedDate',
      'sort': 'stars',
      'order': 'desc',
      'page': '0',
      'per_page': '25'
    });
    var resBody;
    var res;
    try {
      res = await http.get(uri);

      if (res.statusCode == 200) {
        resBody = json.decode(res.body);
        List repoData =
            resBody["items"].map((r) => RepoModel.fromJson(r)).toList();
        return repoData;
      } else {
        return Future.error("Error fetching repos");
      }
    } on SocketException {
      return Future.error("No connectivity");
    }
  }
}
