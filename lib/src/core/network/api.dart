import 'package:sm_ai_support/src/core/config/sm_support_config.dart';

class Apis {
  // Get the base URL from SMConfig
  static String get baseUrl => SMConfig.smData.baseUrl;

  static const String categoryIconUrl = 'https://sm-public-space.blr1.cdn.digitaloceanspaces.com';
  
  // Tenant
  static String get getTenant => '$baseUrl/tenant/info';

  // Categories
  static String get getCategories => '$baseUrl/preset/categories-in-app';

  // Session Management
  static String get startAnonymousSession => '$baseUrl/in-app/start-anonymous-session';
  static String get assignAnonymousSession => '$baseUrl/in-app/assign-anonymous-sessions';
  static String get startSession => '$baseUrl/in-app/start-session';

  // My Sessions
  static String get mySessions => '$baseUrl/in-app/my-sessions';
  static String get myUnreadSessions => '$baseUrl/in-app/customer-unread-sessions';
  static String get mySessionMessages => '$baseUrl/in-app/my-session-messages';
  static String get reopenSession => '$baseUrl/in-app/reopen-session';

  // Messaging
  static String get customerSendMessage => '$baseUrl/in-app/customer-send-message';
  static String get anonymousCustomerSendMessage => '$baseUrl/in-app/anonymous-customer-send-message';
  static String get customerReadMessages => '$baseUrl/in-app/customer-read-messages';
  static String get anonymousCustomerReadMessage => '$baseUrl/in-app/anonymous-customer-read-messages';

  // Rating
  static String get rateSession => '$baseUrl/rating/session';
  static String get rateSessionAnonymous => '$baseUrl/rating/session/anonymous';

  // Authentication
  static String get sendOtp => '$baseUrl/in-app/verification/send-code';
  static String get verifyOtp => '$baseUrl/in-app/verification/verify-code';

  // Storage/Upload
  static String get storageUpload => '$baseUrl/in-app/storage/upload';
  static String get storageDownload => '$baseUrl/storage/download';
}
