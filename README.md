# flutter_graphql_client

[![Release](https://img.shields.io/badge/Version-^0.2.2-green.svg?style=for-the-badge)](https://shields.io/)
[![Maintained](https://img.shields.io/badge/Maintained-Actively-informational.svg?style=for-the-badge)](https://shields.io/)

`flutter_graphql_client` is an open source project &mdash; it's one among many other shared libraries that make up the wider ecosystem of software made and open sourced by `Savannah Informatics Limited`.

A shared library for `BeWell-Consumer` and `SladeAdvantage` that is responsible for exposing graphql_client and helper methods for use in the various apps.

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
  flutter_graphql_client: ^0.2.2
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

## Dart & Flutter Version

- Dart 2: >= 2.12
- Flutter: >=2.0.0

## Developing & Contributing

First off, thanks for taking the time to contribute!

Be sure to check out detailed instructions on how to contribute to this project [here](https://github.com/savannahghi/flutter_graphql_client/blob/main/CONTRIBUTING.md) and go through out [Code of Conduct](https://github.com/savannahghi/flutter_graphql_client/blob/main/CODE_OF_CONDUCT.md).

GPG Signing: 
As a contributor, you need to sign your commits. For more details check [here](https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification/signing-commits)

## License

This library is distributed under the MIT license found in the [LICENSE](https://github.com/savannahghi/flutter_graphql_client/blob/main/LICENSE) file.