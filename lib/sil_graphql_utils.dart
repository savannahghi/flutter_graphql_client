import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:sil_graphql_client/sil_graphql_queries.dart';

import 'package:http/http.dart' as http;

class SILGraphQlUtils {
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
  static Future<String> sendOtp({
    @required String phoneNumber,
    @required String logTitle,
    @required dynamic client,
    String logDescription,
    String email,
    bool sendToEmailOnly = false,
  }) async {
    Map<String, dynamic> _sendToEmailAndPhoneVariables =
        generateAndEmailOtpVariables(email, phoneNumber);

    Map<String, dynamic> _sendToEmailOnlyVariables =
        generateEmailOTPQueryVariables(email);

    final http.Response result = await client.query(
      sendToEmailOnly ? generateEmailOTPQuery : generateAndEmailOtpQuery,
      sendToEmailOnly
          ? _sendToEmailOnlyVariables
          : _sendToEmailAndPhoneVariables,
    );

    final Map<String, dynamic> data = client.toMap(result);

    /// save logs to firebase
    SaveTraceLog(
            query: sendToEmailOnly
                ? generateEmailOTPQuery
                : generateAndEmailOtpQuery,
            data: sendToEmailOnly
                ? _sendToEmailOnlyVariables
                : _sendToEmailAndPhoneVariables,
            client: client,
            response: data,
            title: logTitle ?? 'Send OTP',
            description: logDescription ?? 'Send OTP')
        .saveLog();

    if (client.parseError(data) != null) {
      return Future<String>.value('Error');
    }

    if (data['data'] != null) {
      final dynamic otp = data['data']
          [sendToEmailOnly ? 'emailVerificationOTP' : 'generateAndEmailOTP'];

      return otp;
    }

    return Future<String>.value('Error');
  }

  static Future<String> generateRetryOtp({
    @required String phoneNumber,
    @required int step,
    @required dynamic client,
  }) async {
    // ignore: always_specify_types
    Map<String, dynamic> _variables = {'msisdn': phoneNumber, 'step': step};

    final http.Response result =
        await client.query(generateRetryOTPQuery, _variables);

    final Map<String, dynamic> data = client.toMap(result);

    /// save logs to firebase
    SaveTraceLog(
            query: generateRetryOTPQuery,
            data: _variables,
            response: data,
            client: client,
            title: 'Send OTP',
            description: 'Send OTP')
        .saveLog();

    if (client.parseError(data) != null) {
      return Future<String>.value('Error');
    }
    if (data['data'] != null) {
      final dynamic otp = data['data']['generateRetryOTP'];
      return otp;
    }
    return Future<String>.value('Error');
  }

  // posts event to the backend once triggered
  static Future<void> sendEvent({
    @required BuildContext context,
    @required String eventName,
    @required Map<String, dynamic> payload,
    @required dynamic dbHelper,
    @required dynamic client,
    @required String userID,
    @required String flavour,
    String organizationID = 'UNKNOWN',
    String locationID = 'UNKNOWN',
  }) async {
    final Map<String, dynamic> _variables = <String, dynamic>{
      'eventName': eventName,
      'payload': payload
    };

    final http.Response result =
        await client.query(processEvents, <String, dynamic>{
      'flavour': flavour,
      'event': <String, dynamic>{
        'name': eventName,
        'context': <String, dynamic>{
          'userID': userID,
          'organizationID': organizationID,
          'locationID': locationID,
          'timestamp': DateTime.now().toUtc().toIso8601String()
        },
        'payload': <String, dynamic>{'data': payload}
      }
    });

    final Map<String, dynamic> logResponse = client.toMap(result);

    if (logResponse['data'] != null ||
        logResponse['data']['processEvent'] != true) {
      final String eventPayload = json.encode(payload);
      Map<String, dynamic> row = <String, dynamic>{
        dbHelper.columnName: eventName,
        dbHelper.columnName: eventPayload
      };
      await dbHelper.insert(row);
      Timer(Duration(seconds: 120), () async {
        final List<Map<String, dynamic>> allRows =
            await dbHelper.queryAllRows();
        allRows.forEach((Map<String, dynamic> row) async {
          final Map<String, dynamic> _payload =
              json.decode(row['payload']) as Map<String, dynamic>;
          await SILGraphQlUtils.sendEvent(
            context: context,
            eventName: row['eventName'],
            payload: _payload,
            dbHelper: dbHelper,
            client: client,
            userID: userID,
            flavour: flavour,
          );
          final int id = row['_id'];
          await dbHelper.delete(id);
        });
      });
    }

    SaveTraceLog(
      query: processEvents,
      data: _variables,
      client: client,
      response: logResponse,
      title: 'Process Events',
      description: null,
    ).saveLog();
  }
}

/// post the variables and response to server for debug tracing
/// this will be useful when huntiong for notorious debugs.
/// The trace will be raw hence it should be be truncated in anyway
class SaveTraceLog {
  final String query;
  final dynamic data;
  final dynamic response;
  final String title;
  final String description;
  final dynamic client;

  SaveTraceLog({
    @required this.query,
    @required this.client,
    @required this.response,
    @required this.title,
    @required this.description,
    this.data,
  });
  void saveLog() async {
    final Map<String, dynamic> traceObj = <String, dynamic>{
      'query': query,
      // 'data': data,
      'response': response
    };
    await client.query(postTraceLog, <String, dynamic>{
      'title': title ??
          'Title not provided. Using default ; Trace title ${DateTime.now().toIso8601String()}',
      'description': description ??
          'Description not provided. Using default ; Trace description ${DateTime.now().toIso8601String()}',
      'traces': <dynamic>[json.encode(traceObj)]
    });
  }
}
