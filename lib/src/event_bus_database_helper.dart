import 'package:flutter_graphql_client/graph_event_bus.dart';
import 'package:flutter_graphql_client/src/sqlite.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

abstract class EventBusDatabase extends Database {}

@sealed
class EventBusDatabaseHelper<T extends DatabaseExecutor>
    extends IEventBusDatabaseHelper<T> {
  factory EventBusDatabaseHelper(Future<T> Function()? initDatabaseFunc) {
    return EventBusDatabaseHelper<T>._(
        initDatabaseFunc: initDatabaseFunc ?? initDatabase);
  }

  EventBusDatabaseHelper._({required Future<T> Function() initDatabaseFunc}) {
    super.initDatabase = initDatabaseFunc;
  }
}
