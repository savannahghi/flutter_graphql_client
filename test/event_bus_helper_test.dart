import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sil_graphql_client/graph_event_bus.dart';

void main() {
  const String channelName = 'com.tekartik.sqflite';
  const MethodChannel channel = MethodChannel(channelName);
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return true;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group('EventBusDatabaseHelper ', () {
    test('should instatiate EventBusDatabaseHelper', () async {
      final EventBusDatabaseHelper helper = EventBusDatabaseHelper();
      expect(helper, isA<EventBusDatabaseHelper>());
      expect(helper, isNotNull);
    });

    // test('should throw expection on missing plugin', () async {
    //   final EventBusDatabaseHelper helper = EventBusDatabaseHelper();
    //   expect(helper.initDatabase(), throwsException);
    // });

    // test('should open database', () async {
    //   final EventBusDatabaseHelper helper = EventBusDatabaseHelper();
    //   final Future<Database> db = helper.initDatabase();
    //   expect(db, isNotNull);
    //   expect(helper.initDatabase(), throwsException);
    // });
  });
}
