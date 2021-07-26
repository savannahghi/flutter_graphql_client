/// sends an OTP to the provided phone number and/or email address
const String generateAndEmailOtpQuery = r'''
query GenerateAndEmailOTP($msisdn: String!, $email: String) {
  generateAndEmailOTP(msisdn: $msisdn, email: $email)
}
''';

/// sends an OTP through alternative means such as twilio and WhatsApp
const String generateRetryOTPQuery = r'''
query GenerateRetryOTP($msisdn: String!, $step: Int!) {
  generateRetryOTP(msisdn: $msisdn, retryStep: $step)
}
''';

/// sends an OTP to an email only
const String generateEmailOTPQuery = r'''
query GenerateemailVerificationOTP($email: String!){
  emailVerificationOTP(email: $email)
}
 ''';

/// sends an OTP to an phone only
const String generateOTPQuery = r'''
query GenerateOTP($msisdn: String!) {
  generateOTP(msisdn: $msisdn) 
}
 ''';

/// verifies the email sent from [generateEmailOTPQuery]. It updates the [isEmailVerified]
/// bool in the user's firebase profile
const String verifyEmailOTPQuery = r'''
    mutation VerifyEmailOtp($email: String!, $otp: String!){
      verifyEmailOTP(email: $email, otp: $otp)
    }
  ''';

Map<String, dynamic> generateEmailOTPQueryVariables(String? email) {
  return <String, dynamic>{'email': email};
}

Map<String, dynamic> generateAndEmailOtpVariables(
    String? email, String phoneNumber) {
  final Map<String, dynamic> variables = <String, dynamic>{
    'msisdn': phoneNumber
  };

  variables['email'] = email;
  return variables;
}
