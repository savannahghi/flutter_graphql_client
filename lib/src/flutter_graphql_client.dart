library flutter_graphql_client;

import 'dart:async';

import 'package:http/http.dart';
import 'package:flutter_graphql_client/graph_client.dart';

/// [GraphQlClient] the main entry point client creation
///
/// This class is a singleton which ensues that the same object can
/// be referenced multiple times in the app
///
class GraphQlClient extends IGraphQlClient {
  GraphQlClient(String idToken, String endpoint) {
    super.idToken = idToken;
    super.endpoint = endpoint;
  }
}

/// [SimpleCall] exposes a minimal way make quickly make a call to
/// the graphql server.
///
/// By the time the call is made,its expected that [GraphQlClient]
/// has occurred. Other an authentication error will occur.
///
/// All keyword arguments are required.
///
/// if [variables] is no required, map an empty `map` instead of null
///
/// [graphClient] argument should be a valid instance of [GraphQlClient]
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
  /// [callAPI] method to call graphQL API
  static Future<dynamic> callAPI({
    required String queryString,
    required Map<String, dynamic> variables,
    required IGraphQlClient graphClient,
    bool raw = false,
  }) async {
    final Response result = await graphClient.query(queryString, variables);

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

  /// [callRestAPI] method to call REST API
  static Future<dynamic> callRestAPI({
    required String endpoint,
    required String method,
    required IGraphQlClient graphClient,
    Map<String, dynamic>? variables,
    bool raw = false,
  }) async {
    final Response result = await graphClient.callRESTAPI(
        endpoint: endpoint, method: method, variables: variables);

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
