library sil_graphql_client;

import 'dart:async';
import 'dart:convert';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/widgets.dart';

import 'package:http/http.dart';

import 'package:gql/language.dart' as lang;
import 'package:gql/ast.dart' as ast;
import 'package:sil_graphql_client/constants.dart';
import 'package:source_span/source_span.dart';

// import 'package:firebase_performance/firebase_performance.dart';

/// [SILGraphQlClient] the main entry point client creation
///
/// This class is a singleton which ensues that the same object can
/// be referenced multiple times in the app
///
///
enum ContentType { json, form }

class SILGraphQlClient extends BaseClient {
  String _idToken;
  String _endpoint;

  static final SILGraphQlClient Function(String idToken, String endpoint)
      _singleton = (String idToken, String endpoint) =>
          SILGraphQlClient._(idToken, endpoint);

  factory SILGraphQlClient({String token, String url}) {
    return _singleton(token, url);
  }

  bool clientIsValid() {
    print('From gql client; ID TOKEN : ${this._idToken}');
    if (this._idToken != null && this._endpoint != null) {
      return true;
    }
    return false;
  }

  SILGraphQlClient._(String idToken, String endpoint) {
    this._idToken = idToken;
    this._endpoint = endpoint;
  }

  Uri _fromUriOrString(dynamic uri) =>
      uri is String ? Uri.parse(uri) : uri as Uri;

  bool _checkQueryString(String q) {
    try {
      String query = r'''''';
      query += q;
      // Parses graphql query string to check if its a valid graphql query
      final ast.DocumentNode _ = lang.parseString(
        query,
      );
      return true;
    } on SourceSpanException catch (_) {
      return false;
    }
  }

  Future<Response> query(String queryString, Map<String, dynamic> variables,
      [ContentType contentType = ContentType.json]) async {
    if (!this._checkQueryString(queryString)) {
      return throw FormatException('The provided query string is malformed');
    }

    if (!(variables is Map)) {
      return throw Exception(
          'Expected variable to be of type Map<String,dynamic>');
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      'query': queryString,
      'variables': variables,
    };

    return await this
        .post(_fromUriOrString(this._endpoint), body: json.encode(bodyMap))
        .timeout(
      Duration(seconds: 60),
      onTimeout: () {
        final String payload = json.encode(<String, dynamic>{
          'statusCode': 408,
          'error': 'Network connection unreliable. Please try again later.'
        });

        return Response(
          payload,
          408,
          headers: contentType == ContentType.json
              ? this.requestHeaders
              : this.fileRequestHeaders,
        );
      },
    );
  }

  Map<String, String> get fileRequestHeaders {
    return <String, String>{
      'Authorization': 'Bearer ${this._idToken}',
      'content-type': 'application/x-www-form-urlencoded'
    };
  }

  Map<String, String> get requestHeaders {
    return <String, String>{
      'Authorization': 'Bearer ${this._idToken}',
      'content-type': 'application/json'
    };
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final Stopwatch timer = Stopwatch();
    timer.start();

    StreamedResponse response;

    final HttpMetric metric = FirebasePerformance.instance
        .newHttpMetric(request.url.toString(), HttpMethod.Post);

    await metric.start();

    try {
      request.headers.addAll(this.requestHeaders);
      response = await request.send();

      metric
        ..responsePayloadSize = response.contentLength
        ..responseContentType = response.headers['Content-Type']
        ..requestPayloadSize = request.contentLength
        ..httpResponseCode = response.statusCode;
    } finally {
      await metric.stop();
    }

    timer.stop();

    //  print('Request duration : ${timer.elapsed.inMilliseconds} millisecondes');

    return response;
  }

  Map<String, dynamic> toMap(Response response) {
    final dynamic _res = json.decode(response.body);
    if (_res is Map) return _res as Map<String, dynamic>;
    return _res is List<dynamic> ? _res[0] as Map<String, dynamic> : null;
  }

  String parseError(Map<String, dynamic> body) {
    Object error =
        body.containsKey('errors') != null ? body['errors'] : body['error'];
    if (error is String) {
      return error.contains(RegExp('ID token', caseSensitive: false))
          ? kLoginLogoutPrompt
          : error;
    }
    if (error is List<dynamic>) {
      return error[0]['message'];
    }
    return null;
  }
}

/// [SimpleCall] exposes a minimal way make quickly make a call to
/// the graphql server.
///
/// By the time the call is made,its expected that [SILGraphQlClient]
/// has occured. Other an authentication error will occur.
///
/// All keyword arguments are required.
///
/// if [variables] is no required, map an empty `map` insted of null
///
/// [graphClient] argument should be a valid instance of [SILGraphQlClient]
///
/// Example
///
/// ```dart
///
///  SimpleCall.callAPI(context, virtualCards, {},  SILAppWrapperBase.of(context).graphQLClient)
///
/// ```
///
class SimpleCall {
  static Future<dynamic> callAPI({
    @required String querystring,
    @required Map<String, dynamic> variables,
    @required dynamic graphClient,
    bool raw = false,
  }) async {
    if (!(graphClient is SILGraphQlClient)) {
      return throw Exception(
          'Expected `graphClient` to be of type `SILGraphQlClient`');
    }

    final Response result = await graphClient.query(querystring, variables);

    // returns the raw http response without preprocessing
    if (raw) {
      return result;
    }

    final Map<String, dynamic> body = graphClient.toMap(result);

    if (graphClient.parseError(body) != null) {
      return <String, dynamic>{'error': graphClient.parseError(body)};
    } else {
      return body;
    }
  }
}
