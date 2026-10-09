class ApiRoutes {
  // static const String baseURL="https://208.109.247.90/api/";
  static const String baseURL = "https://leodishinstallers.com/api/";

  static const String loginEndpoint = "auth/login";
  static const String sendEmailOtp = "auth/forgot-password";
  static const String verifyEmailOtp = "auth/verify-reset-otp";
  static const String resetPassword = "auth/reset-password";
  static const String updateProfile = "auth/profile/update";
  static const String changePassword = "auth/change-password";

  static const String dashboardStats = "auth/dashboard";

  static const String locationMonitoring = 'auth/gps-tracking';
  static const String fetchProfile = "auth/profile";
  static const String taskSubmitted = "tasks/submitted";

  static const String workOrderList = "auth/work-order-list";
  static const String workOrderStatusesList = "auth/work-order-statuses-list";
  static const String workOrderStatusUpdate = "auth/work-order-status-update";

  static const String workOrderCheckInSync = "auth/work-order-checkin-sync";
  // Placeholder routes; replace with the backend's confirmed sync endpoints.
  static const String workOrderSowItemsSync = "auth/work-order-sow-items-sync";
  static const String workOrderFieldsSync = "auth/work-order-fields-sync";
  static const String workOrderProposedDatetimeUpdate =
      "auth/work-order-proposed-datetime-update";
}
