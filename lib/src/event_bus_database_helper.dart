import 'package:meta/meta.dart';
import 'package:sil_graphql_client/graph_event_bus.dart';

@sealed
class EventBusDatabaseHelper extends IEventBusDatabaseHelper {
  factory EventBusDatabaseHelper() {
    return _singleton();
  }

  EventBusDatabaseHelper._();

  static EventBusDatabaseHelper _singleton() => EventBusDatabaseHelper._();
}
