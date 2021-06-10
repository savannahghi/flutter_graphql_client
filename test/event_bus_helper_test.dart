import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_graphql_client/graph_event_bus.dart';
import 'package:sqflite/sqflite.dart';

import 'test_utils.dart';

void main() {
  group('EventBusDatabaseHelper ', () {
    test(
        'should instantiate EventBusDatabaseHelper with initDatabaseFunc passed',
        () async {
      final EventBusDatabaseHelper<EventBusDatabase> helper =
          EventBusDatabaseHelper<EventBusDatabase>(initMockDatabase);

      expect(helper, isA<EventBusDatabaseHelper<EventBusDatabase>>());
      expect(helper, isNotNull);
      expect(helper.database, isA<Future<EventBusDatabase>>());
    });

    test(
        'should instantiate EventBusDatabaseHelper without initDatabaseFunc been passed',
        () async {
      expect(() => EventBusDatabaseHelper<Database>(null), returnsNormally);
    });

    test('should insert data', () async {
      final EventBusDatabaseHelper<EventBusDatabase> helper =
          EventBusDatabaseHelper<EventBusDatabase>(initMockDatabase);
      expect(helper, isA<EventBusDatabaseHelper<EventBusDatabase>>());
      expect(helper, isNotNull);
      final int insertResult = await helper.insert(<String, int>{'value': 1});
      expect(insertResult, equals(1));
    });

    test('should fetch data', () async {
      final EventBusDatabaseHelper<EventBusDatabase> helper =
          EventBusDatabaseHelper<EventBusDatabase>(initMockDatabase);

      expect(helper, isA<EventBusDatabaseHelper<EventBusDatabase>>());
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
      final EventBusDatabaseHelper<EventBusDatabase> helper =
          EventBusDatabaseHelper<EventBusDatabase>(initMockDatabase);
      expect(helper, isA<EventBusDatabaseHelper<EventBusDatabase>>());
      expect(helper, isNotNull);
      final int? res = await helper.queryRowCount();
      expect(res, isNull);
    });

    test('should delete data', () async {
      final EventBusDatabaseHelper<EventBusDatabase> helper =
          EventBusDatabaseHelper<EventBusDatabase>(initMockDatabase);
      expect(helper, isA<EventBusDatabaseHelper<EventBusDatabase>>());
      expect(helper, isNotNull);
      final int res = await helper.delete(1);
      expect(res, isNotNull);
      expect(res, equals(1));
    });
  });
}
