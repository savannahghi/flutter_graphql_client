import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_graphql_client/graph_constants.dart';
import 'package:flutter_graphql_client/graph_event_bus.dart';

import 'package:flutter_graphql_client/src/i_flutter_graphql_client.dart';
import 'package:flutter_graphql_client/src/save_trace_log.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_graphql_client/src/flutter_graphql_queries.dart';

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
            title: logTitle,
            description: logDescription)
        .saveLog();

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

    /// save logs to firebase
    SaveTraceLog(
            query: generateRetryOTPQuery,
            data: _variables,
            response: data,
            client: client,
            title: 'Send OTP',
            description: 'Send OTP')
        .saveLog();

    final String? parseError = client.parseError(data);

    if (parseError != null) {
      return Future<String>.value(parseError);
    }

    final dynamic otp = data['data']['generateRetryOTP'];
    return otp as String;
  }

  // posts event to the backend once triggered
  Future<void> sendEvent({
    required BuildContext context,
    required String eventName,
    required Map<String, dynamic> payload,
    required IEventBusDatabaseHelper<EventBusDatabase> dbHelper,
    required IGraphQlClient client,
    required String userID,
    required String flavour,
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

    await this.processSendEventsResponse(
      client: client,
      context: context,
      eventName: eventName,
      logResponse: logResponse,
      dbHelper: dbHelper,
      flavour: flavour,
      payload: payload,
      userID: userID,
    );

    SaveTraceLog(
      query: processEvents,
      data: _variables,
      client: client,
      response: logResponse,
      title: 'Process Events',
    ).saveLog();
  }

  Future<void> processSendEventsResponse({
    required BuildContext context,
    required String eventName,
    required Map<String, dynamic> payload,
    required IEventBusDatabaseHelper<EventBusDatabase> dbHelper,
    required IGraphQlClient client,
    required String userID,
    required String flavour,
    required Map<String, dynamic> logResponse,
  }) async {
    if (logResponse['data']['processEvent'] != null &&
        logResponse['data']['processEvent'] != true) {
      final String eventPayload = json.encode(payload);

      final Map<String, dynamic> row = <String, dynamic>{
        kColumnName: eventName,
        kPayload: eventPayload
      };

      await dbHelper.insert(row);

      final List<Map<String, dynamic>> allRows = await dbHelper.queryAllRows();
      for (final Map<String, dynamic> row in allRows) {
        final String _payloadAsString = row['payload'] as String;
        final Map<String, dynamic> _payload =
            json.decode(_payloadAsString) as Map<String, dynamic>;

        this.sendEvent(
          context: context,
          eventName: row['eventName'] as String,
          payload: _payload,
          dbHelper: dbHelper,
          client: client,
          userID: userID,
          flavour: flavour,
        );

        final int id = row['_id'] as int;
        await dbHelper.delete(id);
      }
    }
  }
}
