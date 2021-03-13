# sil_graphql_client

This package implements functions to make API calls. This blends both GRAPHQL and REST.
Since graphql make this bulk of this package, the name of the package favours.

### Making GRAPHQL calls

```dart
final dynamic data = await SimpleCall.callAPI(
    querystring: 'valid-query-string' ,
    variables: <String, dynamic>{'pay':'load'},
    graphClient: silGraphQlClientInstance ,
)
```

### Making REST calls

GET

```dart
final dynamic data = await SimpleCall.callRestAPI(
    endpoint: 'http://example.com/test' ,
    method: 'GET',
    graphClient: silGraphQlClientInstance ,
)
```

POST

```dart
final dynamic data = await SimpleCall.callRestAPI(
    endpoint: 'http://example.com/test' ,
    method: 'POST',
    variables: <String, dynamic>{'pay':'load'},
    graphClient: silGraphQlClientInstance ,
)
```
