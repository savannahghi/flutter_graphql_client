import 'dart:async';
import 'dart:convert';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart';
import 'package:sil_graphql_client/constants.dart';
import 'package:sil_graphql_client/sil_graphql_client.dart';

import '../mocks.dart';
import '../test_utils.dart';

void main() {
  const MethodChannel channel = FirebasePerformance.channel;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return true;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group('SimpleCall', () {
    test('should make a simple call and return some data', () async {
      MockSilGraphQlClient mockSilGraphQlClient = MockSilGraphQlClient();
      Map<String, dynamic> expectedData = <String, dynamic>{
        'some_data': 'no coverage'
      };

      when(mockSilGraphQlClient.query('some-string', <String, dynamic>{}))
          .thenAnswer(
        (_) => Future<Response>.value(Response(json.encode(expectedData), 201)),
      );

      when(mockSilGraphQlClient.toMap(any)).thenReturn(expectedData);

      when(mockSilGraphQlClient.parseError(any))
          .thenAnswer((Invocation realInvocation) => null);

      Map<String, dynamic> data = await SimpleCall.callAPI(
        querystring: 'some-string',
        variables: <String, dynamic>{},
        graphClient: mockSilGraphQlClient,
      );

      expect(data, isA<Map<String, dynamic>>());
      expect(data, isNotNull);
      expect(data, expectedData);
    });

    test('should return a raw response when raw is set to true', () async {
      MockSilGraphQlClient mockSilGraphQlClient = MockSilGraphQlClient();
      Map<String, dynamic> expectedData = <String, dynamic>{
        'some_data': 'no coverage'
      };

      when(mockSilGraphQlClient.query('some-string', <String, dynamic>{}))
          .thenAnswer(
        (_) => Future<Response>.value(Response(json.encode(expectedData), 201)),
      );

      when(mockSilGraphQlClient.toMap(any)).thenReturn(expectedData);

      when(mockSilGraphQlClient.parseError(any))
          .thenAnswer((Invocation realInvocation) => null);

      Response response = await SimpleCall.callAPI(
        querystring: 'some-string',
        variables: <String, dynamic>{},
        graphClient: mockSilGraphQlClient,
        raw: true,
      );

      expect(response, isA<Response>());
      expect(response, isNotNull);
      expect(json.decode(response.body), expectedData);
    });

    test('should throw an exception if the wrong graphQlClient is supplied',
        () async {
      expect(
          () async => await SimpleCall.callAPI(
                querystring: 'some-string',
                variables: <String, dynamic>{},
                graphClient: null,
                raw: true,
              ),
          throwsException);
    });

    test('should correctly parse an error', () async {
      MockSilGraphQlClient mockSilGraphQlClient = MockSilGraphQlClient();
      Map<String, dynamic> expectedData = <String, dynamic>{
        'errors': 'no coverage'
      };

      when(mockSilGraphQlClient.query('some-string', <String, dynamic>{}))
          .thenAnswer(
        (_) => Future<Response>.value(Response(json.encode(expectedData), 201)),
      );

      when(mockSilGraphQlClient.toMap(any)).thenReturn(expectedData);

      when(mockSilGraphQlClient.parseError(any))
          .thenAnswer((Invocation realInvocation) => 'no coverage');

      Map<String, dynamic> response = await SimpleCall.callAPI(
        querystring: 'some-string',
        variables: <String, dynamic>{},
        graphClient: mockSilGraphQlClient,
      );

      expect(response, isA<Map<String, dynamic>>());
      expect(response, isNotNull);
      expect(response, <String, dynamic>{'error': 'no coverage'});
    });
  });

  group('SILGraphQLClient', () {
    SILGraphQlClient validClient = SILGraphQlClient(
      token: testToken,
      url: testURL,
    );

    SILGraphQlClient nullValuedClient = SILGraphQlClient(
      token: null,
      url: null,
    );

    String validGaphQLQuery = '''
        query UserInfo(\$id: ID!) {
          user(id: \$id) {
            id
            name
          }
        }
      ''';

    Map<String, dynamic> validBody = <String, dynamic>{
      'id_token': null,
      'is_anonymous': true,
      'refresh_token': 'some-refresh-token',
      'uid': 'BkOpHPj9hLRnhYcmglIpc0VEQ9p1',
      'expires_in': '3600'
    };

    Map<String, dynamic> idTokenErrorBody = <String, dynamic>{
      'errors': 'ID token error',
    };

    Map<String, dynamic> errorBody = <String, dynamic>{
      'errors': 'generic error occurred',
    };

    Map<String, dynamic> errorListBody = <String, dynamic>{
      'errors': <Map<String, dynamic>>[
        <String, String>{'message': 'generic list error occurred'}
      ]
    };
    Response validResponse = Response(
      json.encode(
        validBody,
      ),
      201,
    );

    test(
        'client should be valid if token and url are not null and invalid when they are',
        () {
      final bool isValid = validClient.clientIsValid();
      final bool nullClientIsValid = nullValuedClient.clientIsValid();

      expect(nullClientIsValid, false);
      expect(isValid, true);
    });

    test('should throw [FormatException] if query string is malformed',
        () async {
      expect(
        () async => await validClient.query('invalid query', <String, dynamic>{
          'id': 'error',
        }),
        throwsA(isInstanceOf<FormatException>()),
      );
    });

    test('should throw [Exception] if Variable param is not a map', () async {
      expect(
        () async => await validClient.query(validGaphQLQuery, null),
        throwsA(isInstanceOf<Exception>()),
      );
    });

    test(
        'Given a valid SIL GraphQL client\'s getters when called on a valid should the appropriate return values should be returned',
        () {
      expect(validClient.fileRequestHeaders, <String, String>{
        'Authorization': 'Bearer $testToken',
        'content-type': 'application/x-www-form-urlencoded'
      });
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
