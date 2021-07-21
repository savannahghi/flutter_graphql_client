library flutter_graphql_client;

import 'dart:convert';

import 'package:flutter_graphql_client/src/flutter_graphql_queries.dart';
import 'package:flutter_graphql_client/src/i_flutter_graphql_client.dart';

/// Post the variables and response to server for debug tracing
/// this will be useful when hunting for notorious debugs.
/// The trace will be raw hence it should be be truncated in anyway
class SaveTraceLog {
  SaveTraceLog({
    required this.query,
    required this.client,
    required this.response,
    required this.title,
    this.description,
    this.data,
  });

  final String query;
  final dynamic data;
  final dynamic response;
  final String title;
  final String? description;
  final IGraphQlClient client;
  void saveLog() {
    final Map<String, dynamic> traceObj = <String, dynamic>{
      'query': query,
      // 'data': data,
      'response': response
    };
    client.query(postTraceLog, <String, dynamic>{
      'title': title,
      'description': description ??
          'Description not provided. Using default ; Trace description ${DateTime.now().toIso8601String()}',
      'traces': <dynamic>[json.encode(traceObj)]
    });
  }
}
