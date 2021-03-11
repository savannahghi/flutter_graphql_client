import 'package:flutter/widgets.dart';

import 'package:sil_graphql_client/src/sil_graphql_utils.dart';
import 'package:test/test.dart';

import './mocks.dart';
import './test_utils.dart';

void main() {
  group('SILGraphQlUtils', () {
    const String phoneNumber = '+25471234567';

    test('should send OTP', () async {
      final Map<String, dynamic> validOtpResponse = <String, dynamic>{
        'data': <String, dynamic>{'generateAndEmailOTP': '123456'}
      };

      final MockSILGraphQlClient mockSilGraphQlClient =
          generateMockGraphQLClient(validOtpResponse);

      final String actualOtp = await SILGraphQlUtils().sendOtp(
          phoneNumber: phoneNumber,
          logTitle: 'send otp',
          client: mockSilGraphQlClient,
          email: 'savannah@healthcloud.co.ke');

      expect(actualOtp, validOtpResponse['data']['generateAndEmailOTP']);
    });

    test('should send retry OTP', () async {
      final Map<String, dynamic> validOtpResponse = <String, dynamic>{
        'data': <String, dynamic>{'generateRetryOTP': '123456'}
      };

      final MockSILGraphQlClient mockSilGraphQlClient =
          generateMockGraphQLClient(validOtpResponse);

      final String actualOtp = await SILGraphQlUtils().generateRetryOtp(
          phoneNumber: phoneNumber, client: mockSilGraphQlClient, step: 1);

      expect(actualOtp, validOtpResponse['data']['generateRetryOTP']);
    });

    test('should fail to send OTP with error as List<Map<String,dynamic>>',
        () async {
      const String expectedOtpErr = 'this is an otp error';

      final Map<String, dynamic> validOtpErroorResponse = <String, dynamic>{
        'errors': <dynamic>[
          <String, dynamic>{'message': expectedOtpErr}
        ],
      };

      final MockSILGraphQlClient mockSilGraphQlClient =
          generateMockGraphQLClient(validOtpErroorResponse);

      final String actualOtp = await SILGraphQlUtils().sendOtp(
          phoneNumber: phoneNumber,
          logTitle: 'send otp',
          client: mockSilGraphQlClient);

      expect(actualOtp, expectedOtpErr);
    });

    test('should fail to send OTP with error as String', () async {
      const String expectedOtpErr = 'this is an otp error';

      final Map<String, dynamic> validOtpErroorResponse = <String, dynamic>{
        'errors': expectedOtpErr,
      };

      final MockSILGraphQlClient mockSilGraphQlClient =
          generateMockGraphQLClient(validOtpErroorResponse);

      final String actualOtp = await SILGraphQlUtils().sendOtp(
          phoneNumber: phoneNumber,
          logTitle: 'send otp',
          client: mockSilGraphQlClient);

      expect(actualOtp, expectedOtpErr);
    });

    test('should fail to send retry OTP with an error occurs', () async {
      const String expectedOtpErr = 'this is an otp error';

      final Map<String, dynamic> validOtpErroorResponse = <String, dynamic>{
        'errors': <dynamic>[
          <String, dynamic>{'message': expectedOtpErr}
        ],
      };

      final MockSILGraphQlClient mockSilGraphQlClient =
          generateMockGraphQLClient(validOtpErroorResponse);

      final String actualOtp = await SILGraphQlUtils().generateRetryOtp(
          phoneNumber: phoneNumber, client: mockSilGraphQlClient, step: 1);

      expect(actualOtp, expectedOtpErr);
    });

    test('should send event', () async {
      final Map<String, dynamic> validSendResponse = <String, dynamic>{
        'data': <String, dynamic>{'processEvent': true}
      };

      final MockSILGraphQlClient mockSilGraphQlClient =
          generateMockGraphQLClient(validSendResponse);

      final MockEventBusDatabaseHelper dbHelper = MockEventBusDatabaseHelper();

      final BuildContext context = MockBuildContext();

      expect(
          SILGraphQlUtils().sendEvent(
              context: context,
              client: mockSilGraphQlClient,
              dbHelper: dbHelper,
              eventName: 'test',
              flavour: 'pro',
              payload: <String, dynamic>{'payload': 'test'},
              userID: ''),
          isA<void>());
    });

    test('should send event', () async {
      final Map<String, dynamic> validSendResponse = <String, dynamic>{
        'data': <String, dynamic>{'processEvent': true}
      };

      final MockSILGraphQlClient mockSilGraphQlClient =
          generateMockGraphQLClient(validSendResponse);

      final MockEventBusDatabaseHelper dbHelper = MockEventBusDatabaseHelper();

      final BuildContext context = MockBuildContext();

      expect(
          SILGraphQlUtils().sendEvent(
              context: context,
              client: mockSilGraphQlClient,
              dbHelper: dbHelper,
              eventName: 'test',
              flavour: 'pro',
              payload: <String, dynamic>{'payload': 'test'},
              userID: ''),
          isA<void>());
    });

    test('should send event', () async {
      final Map<String, dynamic> validSendResponse = <String, dynamic>{
        'data': <String, dynamic>{'processEvent': false}
      };

      final MockSILGraphQlClient mockSilGraphQlClient =
          generateMockGraphQLClient(validSendResponse);

      final MockEventBusDatabaseHelper dbHelper = MockEventBusDatabaseHelper();

      final BuildContext context = MockBuildContext();

      expect(
          SILGraphQlUtils().processSendEventsResponse(
              logResponse: validSendResponse,
              context: context,
              client: mockSilGraphQlClient,
              dbHelper: dbHelper,
              eventName: 'test',
              flavour: 'pro',
              payload: <String, dynamic>{'payload': 'test'},
              userID: ''),
          isA<void>());
    });
  });
}
