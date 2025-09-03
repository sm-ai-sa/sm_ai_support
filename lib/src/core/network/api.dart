class Apis {
  static const String baseUrl = 'https://sandbox.unicode.team/api/core';

  static const String categoryIconUrl = 'https://sm-public-space.blr1.cdn.digitaloceanspaces.com';
  // Tenant
  static const String getTenant = '$baseUrl/tenant/info';
  
  // Categories
  static const String getCategories = '$baseUrl/preset/categories-in-app';
  
  // Session Management
  static const String startAnonymousSession = '$baseUrl/in-app/start-anonymous-session';
  static const String assignAnonymousSession = '$baseUrl/in-app/assign-anonymous-sessions';
  static const String startSession = '$baseUrl/in-app/start-session';
  
  // My Sessions
  static const String mySessions = '$baseUrl/in-app/my-sessions';
  static const String myUnreadSessions = '$baseUrl/in-app/customer-unread-sessions';
  static const String mySessionMessages = '$baseUrl/in-app/my-session-messages';
  static const String reopenSession = '$baseUrl/in-app/reopen-session';
  
  // Messaging
  static const String customerSendMessage = '$baseUrl/room/customer-send-message';
  static const String anonymousCustomerSendMessage = '$baseUrl/room/anonymous-customer-send-message';
  static const String customerReadMessages = '$baseUrl/room/customer-read-messages';
  
  // Rating
  static const String rateSession = '$baseUrl/rating/session';
  
  // Authentication
  static const String sendOtp = '$baseUrl/verification/send-in-app-code';
  static const String verifyOtp = '$baseUrl/verification/verify-in-app-code';
  
  // Storage/Upload
  static const String storageUpload = '$baseUrl/storage/upload';
  static const String storageDownload = '$baseUrl/storage/download';
}
