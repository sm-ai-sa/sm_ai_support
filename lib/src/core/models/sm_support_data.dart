import 'package:equatable/equatable.dart';
import 'package:sm_ai_support/src/core/models/auth_model.dart';
import 'package:sm_ai_support/src/core/utils/enums.dart';

///* `SMSupportData` contains the basic configuration needed to initialize the support package
class SMSupportData extends Equatable {
  ///* Name of your application
  final String appName;

  ///* Locale of gateway
  final SMSupportLocale locale;

  ///* Tenant ID to fetch tenant-specific configuration
  final String tenantId;

  ///* API key for authentication (stored securely)
  final String apiKey;

  ///* Secret key for HMAC request signing (stored securely)
  final String secretKey;

  ///* Base URL for REST API endpoints
  final String baseUrl;

  ///* Base URL for WebSocket connections
  final String socketBaseUrl;

  ///* Optional customer data for auto-login functionality
  final CustomerData? customer;

  ///* Data constructor for `SMSupportData` with required parameters only
  const SMSupportData({
    required this.appName,
    required this.locale,
    required this.tenantId,
    required this.apiKey,
    required this.secretKey,
    required this.baseUrl,
    required this.socketBaseUrl,
    this.customer,
  });

  @override
  List<Object?> get props => [appName, locale, tenantId, apiKey, secretKey, baseUrl, socketBaseUrl, customer];
}
