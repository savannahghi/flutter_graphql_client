import 'dart:convert';

import 'package:http/http.dart';
import 'package:sil_graphql_client/graph_event_bus.dart';

import 'mocks.dart';

const String testToken = 'testToken';
const String testURL = 'https://savannahtest.com/api';

String generateValidResponsePayload(Map<String, dynamic> data) =>
    json.encode(data);

MockSILGraphQlClient generateMockGraphQLClient(Map<String, dynamic> data) =>
    MockSILGraphQlClient.withResponse('token', 'https://example.sil',
        Response(generateValidResponsePayload(data), 200));

// todo(dexter) : replace with generics
MockSILGraphQlClient2 generateMockGraphQLClient2(Map<String, dynamic> data) =>
    MockSILGraphQlClient2.withResponse(
        'token',
        'http://192.168.1.202/index.php',
        Response(generateValidResponsePayload(data), 200));

/// [initMockDatabase] creates a mock database
Future<EventBusDatabase> initMockDatabase() async {
  return MockEventBusDatabase();
}
