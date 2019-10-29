import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';
import 'package:path/path.dart';
import 'dart:io';

class DB {
  static final DB _instance = DB.internal();
  factory DB() => _instance;

  static Database _db;
  final _lock = Lock();

  Future<Database> get db async {
    if (_db == null) {
      await _lock.synchronized(() async {
        if (_db == null) {
          _db = await initDB();
        }
      });
    }
    return _db;
  }

  DB.internal();

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'trend.db');
    var thDB = await openDatabase(path, version: 1, onCreate: _create);
    return thDB;
  }

  void _create(Database db, int version) async {
    var repos = '''CREATE TABLE TrendingRepos(
          id INTEGER PRIMARY KEY NOT NULL,
          items STRING
          )''';
    await db.execute(repos);
  }

  Future<int> addTrendingRepos(data) async {
    var dbClient = await db;

    int res = await dbClient.insert("TrendingRepos", data);

    return res;
  }

  Future fetchTrendingReposFromDB() async {
    var dbClient = await db;
    var res = await dbClient.rawQuery('SELECT * FROM TrendingRepos');
    if (res.isNotEmpty) {
      List resData = json.decode(res.first['items']);

      return resData;
    }

    return [];
  }
}
