import 'package:flutter_test/flutter_test.dart';
import 'package:sil_graphql_client/graph_event_bus.dart';

import 'test_utils.dart';

void main() {
  group('EventBusDatabaseHelper ', () {
    test('should instatiate EventBusDatabaseHelper', () async {
      final EventBusDatabaseHelper helper =
          EventBusDatabaseHelper(initDatabase: initMockDatabase);
      expect(helper, isA<EventBusDatabaseHelper>());
      expect(helper, isNotNull);
      expect(helper.database, isA<Future<EventBusDatabase>>());
    });

    test('should insert data', () async {
      final EventBusDatabaseHelper helper =
          EventBusDatabaseHelper(initDatabase: initMockDatabase);
      expect(helper, isA<EventBusDatabaseHelper>());
      expect(helper, isNotNull);
      final int insertResult = await helper.insert(<String, int>{'value': 1});
      expect(insertResult, equals(1));
    });

    test('should fetch data', () async {
      final EventBusDatabaseHelper helper =
          EventBusDatabaseHelper(initDatabase: initMockDatabase);
      expect(helper, isA<EventBusDatabaseHelper>());
      expect(helper, isNotNull);
      final List<Map<String, dynamic>> queryResult =
          await helper.queryAllRows();
      expect(
          queryResult,
          equals(<Map<String, dynamic>>[
            <String, dynamic>{'key': 'value'}
          ]));
    });

    test('should row count to be null', () async {
      final EventBusDatabaseHelper helper =
          EventBusDatabaseHelper(initDatabase: initMockDatabase);
      expect(helper, isA<EventBusDatabaseHelper>());
      expect(helper, isNotNull);
      final int? res = await helper.queryRowCount();
      expect(res, isNull);
    });

    test('should delete data', () async {
      final EventBusDatabaseHelper helper =
          EventBusDatabaseHelper(initDatabase: initMockDatabase);
      expect(helper, isA<EventBusDatabaseHelper>());
      expect(helper, isNotNull);
      final int res = await helper.delete(1);
      expect(res, isNotNull);
      expect(res, equals(1));
    });
  });
}
