import 'package:firebase_performance/firebase_performance.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:sil_graphql_client/sil_graphql_client.dart';

class MockSilGraphQlClient extends Mock implements SILGraphQlClient {}

class MockBaseClient extends Mock implements BaseClient {}

class MockHttpMetric extends Mock implements HttpMetric {}

class MockDbHelper {
  void insert(Map<String, dynamic> row) {}
  void delete(Map<String, dynamic> row) {}
}
