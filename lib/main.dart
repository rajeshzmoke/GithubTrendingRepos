import 'package:flutter/material.dart';
import 'package:github_trending_repos/trending.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Trending(),
    );
  }
}
