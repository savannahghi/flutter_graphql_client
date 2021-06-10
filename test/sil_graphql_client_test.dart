import 'dart:convert';

import 'package:http/http.dart';
import 'package:flutter_graphql_client/graph_client.dart';
import 'package:flutter_graphql_client/graph_constants.dart';
import 'package:test/test.dart';

import './test_utils.dart';
import 'mocks.dart';

void main() {
  group('SimpleCall', () {
    test('should make call and return some data', () async {
      final Map<String, dynamic> expectedData = <String, dynamic>{
        'some_data': 'no coverage'
      };

      final MockSILGraphQlClient mockSilGraphQlClient =
          generateMockGraphQLClient(expectedData);

      final dynamic data = await SimpleCall.callAPI(
        queryString: 'some-string',
        variables: <String, dynamic>{},
        graphClient: mockSilGraphQlClient,
      );

      expect(data, isA<Map<String, dynamic>>());
      expect(data, isNotNull);
      expect(data, expectedData);
    });

    test('should return a raw response when raw is set to true', () async {
      final Map<String, dynamic> expectedData = <String, dynamic>{
        'some_data': 'no coverage'
      };

      final MockSILGraphQlClient mockSilGraphQlClient =
          generateMockGraphQLClient(expectedData);

      final dynamic response = await SimpleCall.callAPI(
        queryString: 'some-string',
        variables: <String, dynamic>{},
        graphClient: mockSilGraphQlClient,
        raw: true,
      );

      expect(response, isA<Response>());
      expect(response, isNotNull);

      final Response response2 = response as Response;
      expect(json.decode(response2.body), expectedData);
    });

    test('should timeout with json content type', () async {
      final Map<String, dynamic> expectedData = <String, dynamic>{
        'some': 'data'
      };

      const String validGraphQLQuery = '''
        query UserInfo(\$id: ID!) {
          user(id: \$id) {
            id
            name
          }
        }
      ''';

      final MockSILGraphQlClient2 mockSilGraphQlClient =
          generateMockGraphQLClient2(expectedData);

      final dynamic response = await SimpleCall.callAPI(
        queryString: validGraphQLQuery,
        variables: <String, dynamic>{},
        graphClient: mockSilGraphQlClient,
      );

      expect(response, isA<Map<String, dynamic>>());
      expect(response, isNotNull);

      expect(response['error'],
          'Network connection unreliable. Please try again later.');
    });

    test('should correctly parse an error', () async {
      final Map<String, dynamic> expectedData = <String, dynamic>{
        'errors': 'no coverage'
      };

      final MockSILGraphQlClient mockSilGraphQlClient =
          generateMockGraphQLClient(expectedData);

      final dynamic response = await SimpleCall.callAPI(
        queryString: 'some-string',
        variables: <String, dynamic>{},
        graphClient: mockSilGraphQlClient,
      );

      expect(response, isA<Map<String, dynamic>>());
      expect(response, isNotNull);
      expect(response, <String, dynamic>{'error': 'no coverage'});
    });

    test('should do a rest request', () async {
      final Map<String, dynamic> expectedData = <String, dynamic>{
        'errors': 'no coverage'
      };

      final MockSILGraphQlClient mockSilGraphQlClient =
          generateMockGraphQLClient(expectedData);

      final dynamic response = await SimpleCall.callRestAPI(
        graphClient: mockSilGraphQlClient,
        endpoint: 'https://test-api.rightbtc.com/v1/markets',
        method: 'GET',
      );

      expect(response, isA<Map<String, dynamic>>());
      expect(response, isNotNull);
    });

    test('should do a rest request with timeout', () async {
      final Map<String, dynamic> expectedData = <String, dynamic>{
        'errors': 'no coverage'
      };

      final MockSILGraphQlClient mockSilGraphQlClient =
          generateMockGraphQLClient(expectedData);

      final dynamic response = await SimpleCall.callRestAPI(
        graphClient: mockSilGraphQlClient,
        endpoint: 'http://192.168.1.202/index.php',
        method: 'GET',
      );

      expect(response, isA<Map<String, dynamic>>());
      expect(response, isNotNull);

      expect(response['error'],
          'Network connection unreliable. Please try again later.');
    });
  });

  group('SILGraphQLClient', () {
    final SILGraphQlClient validClient = SILGraphQlClient(
      token: testToken,
      url: testURL,
    );

    const String validGraphQLQuery = '''
          query UserInfo(\$id: ID!) {
            user(id: \$id) {
              id
              name
            }
          }
        ''';

    final Map<String, dynamic> validBody = <String, dynamic>{
      'id_token': null,
      'is_anonymous': true,
      'refresh_token': 'some-refresh-token',
      'uid': 'BkOpHPj9hLRnhYcmglIpc0VEQ9p1',
      'expires_in': '3600'
    };

    final List<Map<String, dynamic>> validBodyAsList = <Map<String, dynamic>>[
      <String, dynamic>{
        'id_token': null,
        'is_anonymous': true,
        'refresh_token': 'some-refresh-token',
        'uid': 'BkOpHPj9hLRnhYcmglIpc0VEQ9p1',
        'expires_in': '3600'
      }
    ];

    final Map<String, dynamic> idTokenErrorBody = <String, dynamic>{
      'errors': 'ID token error',
    };

    final Map<String, dynamic> errorBody = <String, dynamic>{
      'errors': 'generic error occurred',
    };

    final Map<String, dynamic> errorListBody = <String, dynamic>{
      'errors': <Map<String, dynamic>>[
        <String, String>{'message': 'generic list error occurred'}
      ]
    };
    final Response validResponse = Response(
      json.encode(
        validBody,
      ),
      201,
    );

    test('client should be valid if token and url are not null', () {
      final bool isValid = validClient.clientIsValid();
      expect(isValid, true);
    });

    test('should throw [FormatException] if query string is malformed',
        () async {
      expect(
        () async => validClient.query('invalid query', <String, dynamic>{
          'id': 'error',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw [Exception] if Variable param is not a valid map',
        () async {
      expect(
        () async => validClient.query(validGraphQLQuery, validBody),
        throwsA(isA<Exception>()),
      );
    });

    test('should if response is not a valid List<map>', () async {
      final Response resp = Response(json.encode(validBodyAsList), 200);
      final Map<String, dynamic> m = validClient.toMap(resp);
      expect(m, isA<Map<String, dynamic>>());
    });

    test('should return empty map from null response', () async {
      final Map<String, dynamic> m = validClient.toMap(null);
      expect(m, isA<Map<String, dynamic>>());
    });

    test(
        'Given a valid SIL GraphQL client\'s getters when called on a valid should the appropriate return values should be returned',
        () {
      expect(validClient.requestHeaders, <String, String>{
        'Authorization': 'Bearer $testToken',
        'content-type': 'application/json'
      });
    });

    test(
        'Given a valid SIL GraphQL client the toMap method should return a valid Map from the provided response',
        () {
      expect(validClient.toMap(validResponse), validBody);
    });

    test(
      'should show appropriate prompt or error depending on body supplied',
      () async {
        // valid case
        expect(validClient.parseError(validBody), null);
        // token error
        expect(validClient.parseError(idTokenErrorBody), kLoginLogoutPrompt);
        // other error(except token)
        expect(validClient.parseError(errorBody), 'generic error occurred');
        expect(validClient.parseError(errorListBody),
            'generic list error occurred');
      },
    );
  });
}
