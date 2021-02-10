import 'package:mockito/mockito.dart';
import 'package:sil_graphql_client/sil_graphql_client.dart';

class MockSilGraphQlClient extends Mock implements SILGraphQlClient {}

class MockDbHelper {
  void insert(Map<String, dynamic> row) {}
  void delete(Map<String, dynamic> row) {}
}

class MockSilgraphQlClient extends Mock implements SILGraphQlClient {}
