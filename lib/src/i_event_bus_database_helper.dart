library sil_graphql_client;

import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

abstract class IEventBusDatabaseHelper {
  final String _databaseName = 'EventBus.db';
  final int _databaseVersion = 1;

  String table = 'eventBus_table';

  String columnId = '_id';
  String columnName = 'eventName';
  String payload = 'payload';

  // only have a single app-wide reference to the database
  late Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    return initDatabase();
  }

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> initDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);
    return openDatabase(path, version: _databaseVersion, onCreate: onCreate);
  }

  // SQL code to create the database table
  Future<void> onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $payload TEXT NOT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    final Database db = await this.database;
    return db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final Database db = await this.database;
    return db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    final Database db = await this.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    final Database db = await this.database;
    return db.delete(table, where: '$columnId = ?', whereArgs: <int>[id]);
  }
}
