const String kLoginLogoutPrompt =
    'Oops!!! Something wrong just happened. If this persists, log out and login again';

const String kDatabaseName = 'EventBus.db';
const int kDatabaseVersion = 1;

const String kTable = 'eventBus_table';

const String kColumnId = '_id';
const String kColumnName = 'eventName';
const String kPayload = 'payload';

const int kRequestTimeoutSeconds = 45;
const Map<String, dynamic> kTimeoutResponsePayload = <String, dynamic>{
  'statusCode': 408,
  'error': 'Network connection unreliable. Please try again later.'
};

const String kPostMethodName = 'POST';
const String kGetMethodName = 'GET';
