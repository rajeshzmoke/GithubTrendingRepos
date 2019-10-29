import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:github_trending_repos/api/api.dart';
import 'package:github_trending_repos/database/db.dart';

import 'package:github_trending_repos/model/repo_model.dart';
import 'package:github_trending_repos/util/shimmer.dart';

class Trending extends StatefulWidget {
  Trending({Key key}) : super(key: key);

  @override
  _TrendingState createState() => _TrendingState();
}

class _TrendingState extends State<Trending> {
  Future _reposdata;

  DB db = DB();
  @override
  void initState() {
    super.initState();

    _fetchTrendingRepos();
  }

  _fetchTrendingRepos() async {
    var trendsData = await db.fetchTrendingReposFromDB();

    if (trendsData.isEmpty) {
      Api.getTrendingRepos().then((onValue) async {
        var apiData = json.encode(onValue);
        await db.addTrendingRepos({"items": apiData});

        setState(() {
          _reposdata = Future.value(onValue);
        });
      }).catchError((onError) {
        setState(() {
          _reposdata = Future.error(onError);
        });
      });
    } else {
      List dbData = trendsData.map((r) => RepoModel.fromJson(r)).toList();
      setState(() {
        _reposdata = Future.value(dbData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Github Trending Repos'),
      ),
      body: FutureBuilder(
        future: _reposdata,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (!snapshot.hasData) {
            return ShimmerList(
              isBottomLinesActive: true,
              isCircularImage: false,
              length: 25,
            );
          }
          List repoData = snapshot.data;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: repoData.length,
            itemBuilder: (context, index) {
              RepoModel item = repoData[index];
              return ListTile(
                leading: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.star,
                      color: Colors.red,
                    ),
                    Text(item.stargazersCount.toString())
                  ],
                ),
                title: Text(item?.name ?? "-"),
                subtitle: Text(item?.description ?? "No description"),
                trailing: Text(item?.language ?? ""),
              );
            },
          );
        },
      ),
    );
  }
}
