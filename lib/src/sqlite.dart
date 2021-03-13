import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sil_graphql_client/graph_constants.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

Future<Database> initDatabase() async {
  final Directory documentsDirectory = await getApplicationDocumentsDirectory();
  final String path = join(documentsDirectory.path, kDatabaseName);
  return openDatabase(path, version: kDatabaseVersion, onCreate: onCreate);
}

// SQL code to create the database table
Future<void> onCreate(Database db, int version) async {
  await db.execute('''
          CREATE TABLE $kTable (
            $kColumnId INTEGER PRIMARY KEY,
            $kColumnName TEXT NOT NULL,
            $kPayload TEXT NOT NULL
          )
          ''');
}