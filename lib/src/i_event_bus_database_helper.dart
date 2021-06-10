library sil_graphql_client;

import 'package:flutter_graphql_client/graph_constants.dart';
import 'package:sqflite/sqflite.dart';

abstract class IEventBusDatabaseHelper<T extends DatabaseExecutor> {
  /// [database] instance of the database
  Future<T> get database async => initDatabase();

  /// [initDatabase] called to initialize the database
  late Future<T> Function() initDatabase;

  /// [inserts] a row in the database where each key in the Map is a column name
  /// and the value is the column value. The return value is the id of the
  /// inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    final T db = await this.database;
    return db.insert(kTable, row);
  }

  /// [queryAllRows] fetches of the rows are returned as a list of maps, where each map is
  /// a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final T db = await this.database;
    return db.query(kTable);
  }

  /// [queryRowCount] fetches of the methods (insert, query, update, delete) can also be done using
  /// raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    final T db = await this.database;
    return this
        .firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $kTable'));
  }

  /// [delete] removes the row specified by the id. The number of affected rows is
  /// returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    final T db = await this.database;
    return db.delete(kTable, where: '$kColumnId = ?', whereArgs: <int>[id]);
  }

  /// Try to convert anything (int, String) to an int.
  int? parseInt(Object? object) {
    if (object is int) {
      return object;
    } else if (object is String) {
      try {
        return int.parse(object);
      } catch (_) {}
    }
    return null;
  }

  int? firstIntValue(List<Map<String, Object?>> list) {
    if (list.isNotEmpty) {
      final Map<String, Object?> firstRow = list.first;
      if (firstRow.isNotEmpty) {
        return parseInt(firstRow.values.first);
      }
    }
    return null;
  }
}
