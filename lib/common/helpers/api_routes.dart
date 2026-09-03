class ApiRoutes {
  // static const String baseURL="https://208.109.247.90/api/";
  static const String baseURL="https://leodishinstallers.com/api/";

  static const String loginEndpoint="auth/login";
  static const String sendEmailOtp="auth/forgot-password";
  static const String verifyEmailOtp="auth/verify-reset-otp";
  static const String resetPassword="auth/reset-password";
  static const String updateProfile="auth/profile/update";
  static const String changePassword="auth/change-password";

  static const String locationMonitoring = 'auth/gps-tracking';
  static const String fetchProfile="auth/profile";
  static const String taskSubmitted="tasks/submitted";
}