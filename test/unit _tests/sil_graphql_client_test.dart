import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart';
import 'package:sil_graphql_client/sil_graphql_client.dart';

import '../mocks.dart';

void main() {
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
}
