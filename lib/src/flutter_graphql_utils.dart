import 'dart:async';

import 'package:flutter_graphql_client/src/flutter_graphql_queries.dart';
import 'package:flutter_graphql_client/src/i_flutter_graphql_client.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

@sealed
class GraphQlUtils {
  /// a function that sends a verification code to a phone
  ///
  /// @params
  /// [BuildContext context] - the context, that will be used to get the graphQL client
  /// [String phoneNumber] - the phone number to send the verification code to
  /// [String logTitle] - the title of the log that will be saved to firebase
  /// [String logDescription] - the description of the log that will be saved to firebase
  /// [String email] (optional) - the email address, if any, to send the verification code to
  /// [bool sendToEmailOnly] (optional) - a [bool] that indicates whether to send an otp to the email only
  ///
  /// NOTES:
  /// if an email is not presented, the code will only be sent to the phone
  Future<String> sendOtp({
    required String phoneNumber,
    required String logTitle,
    required IGraphQlClient client,
    String? logDescription,
    String? email,
    bool sendToEmailOnly = false,
  }) async {
    final Map<String, dynamic> _sendToEmailAndPhoneVariables =
        generateAndEmailOtpVariables(email, phoneNumber);

    final Map<String, dynamic> _sendToEmailOnlyVariables =
        generateEmailOTPQueryVariables(email);

    final http.Response result = await client.query(
      sendToEmailOnly ? generateEmailOTPQuery : generateAndEmailOtpQuery,
      sendToEmailOnly
          ? _sendToEmailOnlyVariables
          : _sendToEmailAndPhoneVariables,
    );

    final Map<String, dynamic> data = client.toMap(result);
    final String? parseError = client.parseError(data);

    if (parseError != null) {
      return Future<String>.value(parseError);
    }

    final dynamic otp = data['data']
        [sendToEmailOnly ? 'emailVerificationOTP' : 'generateAndEmailOTP'];

    return otp as String;
  }

  Future<String> generateRetryOtp({
    required String phoneNumber,
    required int step,
    required IGraphQlClient client,
  }) async {
    final Map<String, dynamic> _variables = <String, dynamic>{
      'msisdn': phoneNumber,
      'step': step
    };

    final http.Response result =
        await client.query(generateRetryOTPQuery, _variables);

    final Map<String, dynamic> data = client.toMap(result);

    final String? parseError = client.parseError(data);

    if (parseError != null) {
      return Future<String>.value(parseError);
    }

    final dynamic otp = data['data']['generateRetryOTP'];
    return otp as String;
  }
}
