import 'dart:async';
import 'dart:convert';

import 'package:flutter_graphql_client/src/constants.dart';
import 'package:gql/ast.dart' as ast;
import 'package:gql/language.dart' as lang;
import 'package:http/http.dart';
import 'package:source_span/source_span.dart';

enum ContentType { json, form }

/// [IGraphQlClient] is the blueprint of a valid GraphQL client.
/// To construct a graphQL client, extend this class. This class provide
/// out of the box implementation of client methods but they can be overridden.
/// Best use case for overriding is when defining a mock client. Check [mocks.dart]
/// for a concrete mocking implementation.
abstract class IGraphQlClient extends BaseClient {
  late String idToken;
  late String endpoint;

  bool clientIsValid() {
    return true;
  }

  bool checkQueryString(String query) {
    try {
      // Parses graphql query string to check if its a valid graphql query
      final ast.DocumentNode _ = lang.parseString(
        query,
      );
      return true;
    } on SourceSpanException catch (_) {
      return false;
    }
  }

  Uri fromUriOrString(dynamic uri) =>
      uri is String ? Uri.parse(uri) : uri as Uri;

  Map<String, String> get requestHeaders {
    return <String, String>{
      'Authorization': 'Bearer ${this.idToken}',
      'content-type': 'application/json'
    };
  }

  Map<String, dynamic> toMap(Response? response) {
    if (response == null) return <String, dynamic>{};
    final dynamic _res = json.decode(utf8.decode(response.bodyBytes));
    if (_res is List<dynamic>) return _res[0] as Map<String, dynamic>;
    return _res as Map<String, dynamic>;
  }

  Future<Response> query(
    String queryString,
    Map<String, dynamic> variables,
  ) async {
    if (!this.checkQueryString(queryString)) {
      return throw const FormatException(
          'The provided query string is malformed');
    }

    final Map<String, dynamic> bodyMap = <String, dynamic>{
      'query': queryString,
      'variables': variables,
    };

    return this.postWithTimeout(bodyMap);
  }

  Future<Response> postWithTimeout(Map<String, dynamic> bodyMap) {
    return this
        .post(fromUriOrString(this.endpoint), body: json.encode(bodyMap))
        .timeout(
      const Duration(seconds: kRequestTimeoutSeconds),
      onTimeout: () {
        return Response(
          json.encode(kTimeoutResponsePayload),
          408,
          headers: this.requestHeaders,
        );
      },
    );
  }

  /// [callRESTAPI] is used when making unauthenticated REST backend calls
  Future<Response> callRESTAPI({
    required String endpoint,
    required String method,
    Map<String, dynamic>? variables,
  }) async {
    final Request request = Request(method, this.fromUriOrString(endpoint));

    request.body = json.encode(variables);
    return Response.fromStream(
      await this.send(request).timeout(
        const Duration(seconds: kRequestTimeoutSeconds),
        onTimeout: () {
          final String timeoutInput = json.encode(kTimeoutResponsePayload);
          final List<int> body = utf8.encode(timeoutInput);
          return StreamedResponse(
            ByteStream.fromBytes(body),
            408,
            headers: this.requestHeaders,
          );
        },
      ),
    );
  }

  String? parseError(Map<String, dynamic>? body) {
    if (body == null) return null;

    final Object? error =
        body.containsKey('errors') ? body['errors'] : body['error'];

    if (error == null) return null;

    if (error is List<dynamic>) {
      final Map<String, dynamic> firstEntry =
          error.first as Map<String, dynamic>;
      return firstEntry['message'] as String;
    }

    if (error is String) {
      return error.contains(RegExp('ID token', caseSensitive: false))
          ? kLoginLogoutPrompt
          : error;
    }

    return null;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    request.headers.addAll(this.requestHeaders);
    return request.send();
  }
}
