import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:sil_graphql_client/graph_client.dart';
import 'package:sil_graphql_client/graph_event_bus.dart';
import 'package:sqflite/sqflite.dart';

class MockBuildContext extends Mock implements BuildContext {}

class MockEventBusDatabase implements EventBusDatabase {
  @override
  Batch batch() => throw UnimplementedError();

  @override
  Future<void> close() async {}

  @override
  Future<int> delete(String table,
          {String? where, List<Object?>? whereArgs}) async =>
      1;

  @override
  Future<T> devInvokeMethod<T>(String method, [dynamic arguments]) async =>
      true as T;

  @override
  Future<T> devInvokeSqlMethod<T>(String method, String sql,
          [List<Object?>? arguments]) async =>
      true as T;

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {}

  @override
  Future<int> getVersion() async => 1;

  @override
  Future<int> insert(String table, Map<String, Object?> values,
          {String? nullColumnHack,
          ConflictAlgorithm? conflictAlgorithm}) async =>
      1;

  @override
  bool get isOpen => true;

  @override
  String get path => 'path';

  @override
  Future<List<Map<String, Object?>>> query(String table,
          {bool? distinct,
          List<String>? columns,
          String? where,
          List<Object?>? whereArgs,
          String? groupBy,
          String? having,
          String? orderBy,
          int? limit,
          int? offset}) async =>
      <Map<String, Object?>>[
        <String, Object?>{'key': 'value'}
      ];

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async => 1;

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async => 1;

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql,
          [List<Object?>? arguments]) async =>
      <Map<String, Object?>>[
        <String, Object?>{'key': 'value'}
      ];

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async => 1;

  @override
  Future<void> setVersion(int version) async {}

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action,
          {bool? exclusive}) async =>
      true as T;

  @override
  Future<int> update(String table, Map<String, Object?> values,
          {String? where,
          List<Object?>? whereArgs,
          ConflictAlgorithm? conflictAlgorithm}) async =>
      1;
}

class MockSILGraphQlClient extends ISILGraphQlClient {
  MockSILGraphQlClient.withResponse(
      String idToken, String endpoint, this.response) {
    super.idToken = idToken;
    super.endpoint = endpoint;
  }

  late final Response response;

  @override
  Future<Response> query(String queryString, Map<String, dynamic> variables,
          [ContentType contentType = ContentType.json]) async =>
      this.response;
}

// [MockSILGraphQlClient2] adds a timeout in its query method.
// useful for testing timeouts
class MockSILGraphQlClient2 extends ISILGraphQlClient {
  MockSILGraphQlClient2.withResponse(
      String idToken, String endpoint, this.response) {
    super.idToken = idToken;
    super.endpoint = endpoint;
  }

  late final Response response;
}

class MockEventBusDatabaseHelper
    extends IEventBusDatabaseHelper<EventBusDatabase> {
  @override
  Future<int> insert(Map<String, dynamic> row) {
    return Future<int>.value(1);
  }

  @override
  Future<int?> queryRowCount() async {
    return Future<int>.value(1);
  }

  @override
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return Future<List<Map<String, dynamic>>>.value(<Map<String, dynamic>>[
      <String, dynamic>{
        'payload': json.encode(<String, dynamic>{'event': 'test'}),
        'eventName': 'test',
        '_id': 1,
      }
    ]);
  }

  @override
  Future<int> delete(int id) async {
    return Future<int>.value(1);
  }
}
