/// Making GRAPHQL calls

```dart
final dynamic data = await SimpleCall.callAPI(
    querystring: 'valid-query-string' ,
    variables: <String, dynamic>{'pay':'load'},
    graphClient: graphQlClientInstance ,
)
```

/// Making REST calls

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
