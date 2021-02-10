/// sends an OTP to the provided phone number and/or email address
final String generateAndEmailOtpQuery = r'''
query GenerateAndEmailOTP($msisdn: String!, $email: String) {
  generateAndEmailOTP(msisdn: $msisdn, email: $email)
}
''';

/// sends an OTP through alternative means such as twilio and whatsapp
final String generateRetryOTPQuery = r'''
query GenerateRetryOTP($msisdn: String!, $step: Int!) {
  generateRetryOTP(msisdn: $msisdn, retryStep: $step)
}
''';

/// sends an OTP to an email only
final String generateEmailOTPQuery = r'''
query GenerateemailVerificationOTP($email: String!){
  emailVerificationOTP(email: $email)
}
 ''';

/// sends an OTP to an phone only
final String generateOTPQuery = r'''
query GenerateOTP($msisdn: String!) {
  generateOTP(msisdn: $msisdn) 
}
 ''';

final String postTraceLog = r'''
mutation Trace($title:String!, $description: String!, $traces: [String!]! ){
  logDebugInfo(title: $title, description: $description, traces: $traces)
}
''';

Map<String, dynamic> generateEmailOTPQueryVariables(String email) {
  return <String, dynamic>{'email': email};
}

/// verifies the email sent from [generateEmailOTPQuery]. It updates the [isEmailVerified]
/// bool in the user's firebase profile
final String verifyEmailOTPQuery = r'''
    mutation VerifyEmailOtp($email: String!, $otp: String!){
      verifyEmailOTP(email: $email, otp: $otp)
    }
  ''';

Map<String, dynamic> generateAndEmailOtpVariables(
    String email, String phoneNumber) {
  Map<String, dynamic> variables = <String, dynamic>{'msisdn': phoneNumber};

  // verify that this is an actual email before sending
  if (email != null && email != '') {
    variables['email'] = email;
  } else {
    variables['email'] = null;
  }

  return variables;
}

// sends events to the backend
final String processEvents = r'''
mutation processEvent(
  $flavour: Flavour!
  $event: EventInput!
){
  processEvent(
    flavour: $flavour
    event: $event
  )
}
''';
