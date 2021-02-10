import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sil_graphql_client/sil_graphql_queries.dart';
import 'package:sil_graphql_client/sil_graphql_utils.dart';
import 'package:http/http.dart' as http;

import '../mocks.dart';

void main() {
  group('SILGraphQlUtils', () {
    test('should send OTP', () async {
      MockSilGraphQlClient mockSilGraphQlClient = MockSilGraphQlClient();

      /// setup
      final String expectedOtp = '123456';

      when(mockSilGraphQlClient.query(any, any)).thenAnswer(
        (_) => Future<http.Response>.value(
          http.Response(
            json.encode(<String, dynamic>{'generateAndEmailOTP': '123456'}),
            200,
          ),
        ),
      );

      when(mockSilGraphQlClient.toMap(any)).thenReturn(
        <String, dynamic>{
          'data': <String, dynamic>{'generateAndEmailOTP': '123456'}
        },
      );

      /// act
      final String actualOtp = await SILGraphQlUtils.sendOtp(
          phoneNumber: '+25471234567',
          logTitle: 'send otp',
          client: mockSilGraphQlClient);

      /// verify
      expect(actualOtp, expectedOtp);
      verify(mockSilGraphQlClient.query(any, any)).called(2);
    });

    test('should fail to send OTP', () async {
      MockSilGraphQlClient mockSilGraphQlClient = MockSilGraphQlClient();

      /// setup
      final String expectedOtp = 'Error';

      when(mockSilGraphQlClient.query(any, any)).thenAnswer(
        (_) => Future<http.Response>.value(
          http.Response(
            json.encode(<String, dynamic>{'error': 'invalid auth token'}),
            400,
          ),
        ),
      );

      when(mockSilGraphQlClient.toMap(any)).thenReturn(
        <String, dynamic>{'error': 'invalid auth token'},
      );

      /// act
      final String actualOtp = await SILGraphQlUtils.sendOtp(
          phoneNumber: '+25471234567',
          logTitle: 'send otp',
          client: mockSilGraphQlClient);

      /// verify
      expect(actualOtp, expectedOtp);
      verify(mockSilGraphQlClient.query(any, any)).called(2);
    });

    test('should fail to send OTP with an error', () async {
      MockSilGraphQlClient mockSilGraphQlClient = MockSilGraphQlClient();

      /// setup
      final String expectedOtp = 'Error';

      when(mockSilGraphQlClient.query(any, any)).thenAnswer(
        (_) => Future<http.Response>.value(
          http.Response(
            json.encode(<String, dynamic>{'error': 'invalid auth token'}),
            400,
          ),
        ),
      );

      when(mockSilGraphQlClient.toMap(any)).thenReturn(
        <String, dynamic>{'error': 'invalid auth token'},
      );

      when(mockSilGraphQlClient.parseError(any))
          .thenReturn('some error occurred');

      /// act
      final String actualOtp = await SILGraphQlUtils.sendOtp(
          phoneNumber: '+25471234567',
          logTitle: null,
          logDescription: 'send OTP',
          client: mockSilGraphQlClient);

      /// verify
      expect(actualOtp, expectedOtp);
      verify(mockSilGraphQlClient.query(any, any)).called(2);
    });

    test('should send retry OTP', () async {
      MockSilGraphQlClient mockSilGraphQlClient = MockSilGraphQlClient();

      /// setup
      final String expectedRetryOtp = '123456';

      when(mockSilGraphQlClient.toMap(any)).thenReturn(
        <String, dynamic>{
          'data': <String, dynamic>{'generateRetryOTP': '123456'}
        },
      );

      when(mockSilGraphQlClient.toMap(any)).thenReturn(<String, dynamic>{
        'data': <String, dynamic>{'generateRetryOTP': '123456'}
      });

      /// act
      final String actualOtp = await SILGraphQlUtils.generateRetryOtp(
          phoneNumber: '+25471234567', step: 1, client: mockSilGraphQlClient);

      /// verify
      expect(actualOtp, expectedRetryOtp);
      verify(mockSilGraphQlClient.query(any, any)).called(2);
    });

    test('should fail to send retry OTP with an error occurs', () async {
      MockSilGraphQlClient mockSilGraphQlClient = MockSilGraphQlClient();

      /// setup
      final String expectedOtp = 'Error';

      when(mockSilGraphQlClient.query(any, any)).thenAnswer(
        (_) => Future<http.Response>.value(
          http.Response(
            json.encode(<String, dynamic>{'error': 'invalid auth token'}),
            400,
          ),
        ),
      );

      when(mockSilGraphQlClient.toMap(any)).thenReturn(
        <String, dynamic>{'error': 'invalid auth token'},
      );

      when(mockSilGraphQlClient.parseError(any))
          .thenReturn('some error occurred');

      /// act
      final String actualOtp = await SILGraphQlUtils.generateRetryOtp(
          phoneNumber: '+25471234567', step: 1, client: mockSilGraphQlClient);

      /// verify
      expect(actualOtp, expectedOtp);
      verify(mockSilGraphQlClient.query(any, any)).called(2);
    });

    test(
        'should fail to send retry OTP in case a failure in parsing an error occurs',
        () async {
      MockSilGraphQlClient mockSilGraphQlClient = MockSilGraphQlClient();

      /// setup
      final String expectedOtp = 'Error';

      when(mockSilGraphQlClient.query(any, any)).thenAnswer(
        (_) => Future<http.Response>.value(
          http.Response(
            json.encode(<String, dynamic>{'error': 'invalid auth token'}),
            400,
          ),
        ),
      );

      when(mockSilGraphQlClient.toMap(any)).thenReturn(
        <String, dynamic>{'error': 'invalid auth token'},
      );

      /// act
      final String actualOtp = await SILGraphQlUtils.generateRetryOtp(
          phoneNumber: '+25471234567', step: 1, client: mockSilGraphQlClient);

      /// verify
      expect(actualOtp, expectedOtp);
      verify(mockSilGraphQlClient.query(any, any)).called(2);
    });

    test('should save logs to backend', () async {
      MockSilGraphQlClient graphQlClient = MockSilGraphQlClient();

      SaveTraceLog(
        query: 'some query',
        data: <String, dynamic>{'data': 'some data'},
        client: graphQlClient,
        response: 'some data',
        title: null,
        description: null,
      ).saveLog();

      verify(graphQlClient.query(postTraceLog, any)).called(1);
    });
  });
}
