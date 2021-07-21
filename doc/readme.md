# flutter_graphql_client

`flutter_graphql_client` is an open source project &mdash; it's one among many other shared libraries that make up the wider ecosystem of software made and open sourced by `Savannah Informatics Limited`.

A shared library for `BeWell-Consumer` and `BeWell-Professional` that is responsible for exposing graphql_client and helper methods for use in the various apps.

This package implements functions to make API calls. This blends both GRAPHQL and REST.
Since graphql make this bulk of this package, the name of the package favours.

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
