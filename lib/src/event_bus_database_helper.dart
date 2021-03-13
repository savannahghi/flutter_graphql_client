import 'package:meta/meta.dart';
import 'package:sil_graphql_client/graph_event_bus.dart';
import 'package:sqflite/sqflite.dart';

abstract class EventBusDatabase extends Database {}

@sealed
class EventBusDatabaseHelper extends IEventBusDatabaseHelper<EventBusDatabase> {
  factory EventBusDatabaseHelper(
      {required Future<EventBusDatabase> Function() initDatabase}) {
    return _singleton(initDatabase);
  }

  EventBusDatabaseHelper._(
      {required Future<EventBusDatabase> Function() initDatabase}) {
    super.initDatabase = initDatabase;
  }

  static EventBusDatabaseHelper _singleton(
          Future<EventBusDatabase> Function() initDatabase) =>
      EventBusDatabaseHelper._(initDatabase: initDatabase);
}
