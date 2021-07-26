import 'package:flutter_graphql_client/src/flutter_graphql_utils.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'test_utils.dart';

void main() {
  group('FlutterGraphQLUtils', () {
    const String phoneNumber = '+25471234567';

    test('should send OTP', () async {
      final Map<String, dynamic> validOtpResponse = <String, dynamic>{
        'data': <String, dynamic>{'generateAndEmailOTP': '123456'}
      };

      final MockGraphQlClient mockGraphQlClient =
          generateMockGraphQLClient(validOtpResponse);

      final String actualOtp = await GraphQlUtils().sendOtp(
          phoneNumber: phoneNumber,
          logTitle: 'send otp',
          client: mockGraphQlClient,
          email: 'savannah@healthcloud.co.ke');

      expect(actualOtp, validOtpResponse['data']['generateAndEmailOTP']);
    });

    test('should send retry OTP', () async {
      final Map<String, dynamic> validOtpResponse = <String, dynamic>{
        'data': <String, dynamic>{'generateRetryOTP': '123456'}
      };

      final MockGraphQlClient mockGraphQlClient =
          generateMockGraphQLClient(validOtpResponse);

      final String actualOtp = await GraphQlUtils().generateRetryOtp(
          phoneNumber: phoneNumber, client: mockGraphQlClient, step: 1);

      expect(actualOtp, validOtpResponse['data']['generateRetryOTP']);
    });

    test('should fail to send OTP with error as List<Map<String,dynamic>>',
        () async {
      const String expectedOtpErr = 'this is an otp error';

      final Map<String, dynamic> validOtpErrorResponse = <String, dynamic>{
        'errors': <dynamic>[
          <String, dynamic>{'message': expectedOtpErr}
        ],
      };

      final MockGraphQlClient mockGraphQlClient =
          generateMockGraphQLClient(validOtpErrorResponse);

      final String actualOtp = await GraphQlUtils().sendOtp(
          phoneNumber: phoneNumber,
          logTitle: 'send otp',
          client: mockGraphQlClient);

      expect(actualOtp, expectedOtpErr);
    });

    test('should fail to send OTP with error as String', () async {
      const String expectedOtpErr = 'this is an otp error';

      final Map<String, dynamic> validOtpErrorResponse = <String, dynamic>{
        'errors': expectedOtpErr,
      };

      final MockGraphQlClient mockGraphQlClient =
          generateMockGraphQLClient(validOtpErrorResponse);

      final String actualOtp = await GraphQlUtils().sendOtp(
          phoneNumber: phoneNumber,
          logTitle: 'send otp',
          client: mockGraphQlClient);

      expect(actualOtp, expectedOtpErr);
    });

    test('should fail to send retry OTP with an error occurs', () async {
      const String expectedOtpErr = 'this is an otp error';

      final Map<String, dynamic> validOtpErrorResponse = <String, dynamic>{
        'errors': <dynamic>[
          <String, dynamic>{'message': expectedOtpErr}
        ],
      };

      final MockGraphQlClient mockGraphQlClient =
          generateMockGraphQLClient(validOtpErrorResponse);

      final String actualOtp = await GraphQlUtils().generateRetryOtp(
          phoneNumber: phoneNumber, client: mockGraphQlClient, step: 1);

      expect(actualOtp, expectedOtpErr);
    });
  });
}
