import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:sil_graphql_client/graph_client.dart';
import 'package:sil_graphql_client/graph_event_bus.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabase extends Mock implements Database {}

class MockSaveTraceLog extends Mock implements SaveTraceLog {}

class MockBuildContext extends Mock implements BuildContext {}

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

class MockEventBusDatabaseHelper extends IEventBusDatabaseHelper {
  @override
  Future<Database> initDatabase() async => MockDatabase();

  @override
  Future<Database> get database async => MockDatabase();

  @override
  Future<void> onCreate(Database db, int version) async {
    return Future<void>.value();
  }

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
