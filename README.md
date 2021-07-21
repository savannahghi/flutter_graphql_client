[![Release](https://img.shields.io/badge/Version-^0.1.21-red.svg?style=for-the-badge)](https://shields.io/)
[![Maintained](https://img.shields.io/badge/Maintained-Actively-informational.svg?style=for-the-badge)](https://shields.io/)

# flutter_graphql_client

`flutter_graphql_client` is an open source project &mdash; it's one among many other shared libraries that make up the wider ecosystem of software made and open sourced by `Savannah Informatics Limited`.

A shared library for `BeWell-Consumer` and `BeWell-Professional` that is responsible for exposing graphql_client and helper methods for use in the various apps.

This package implements functions to make API calls. This blends both GRAPHQL and REST.
Since graphql make this bulk of this package, the name of the package favours.

## Installation Instructions

Use this package as a library by depending on it

Run this command:

- With Flutter:

```dart
$ flutter pub add flutter_graphql_client
```

This will add a line like this to your package's pubspec.yaml (and run an implicit dart pub get):

```dart
dependencies:
  flutter_graphql_client: ^0.1.21
```

Alternatively, your editor might support flutter pub get. Check the docs for your editor to learn more.

Lastly:

Import it like so:

```dart
import 'package:flutter_graphql_client/graph_client.dart';
```

## How to use this package

### Making GRAPHQL calls

```dart
final dynamic data = await SimpleCall.callAPI(
    querystring: 'valid-query-string' ,
    variables: <String, dynamic>{'pay':'load'},
    graphClient: graphQlClientInstance ,
)
```

### Making REST calls

GET

```dart
final dynamic data = await SimpleCall.callRestAPI(
    endpoint: 'http://example.com/test' ,
    method: 'GET',
    graphClient: graphQlClientInstance ,
)
```

POST

```dart
final dynamic data = await SimpleCall.callRestAPI(
    endpoint: 'http://example.com/test' ,
    method: 'POST',
    variables: <String, dynamic>{'pay':'load'},
    graphClient: graphQlClientInstance ,
)
```
