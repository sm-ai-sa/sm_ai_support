import 'package:sm_ai_support/sm_ai_support.dart';

/// Global authentication manager for the SM AI Support package
class AuthManager {
  static AuthManager? _instance;
  static AuthManager get instance => _instance ??= AuthManager._();
  
  AuthManager._();

  /// Global authentication status - accessible throughout the app
  static bool get isAuthenticated => SharedPrefHelper.isAuthenticated;
  
  /// Get current auth token
  static String? get authToken => SharedPrefHelper.getAuthToken();
  
  /// Get current customer data
  static CustomerModel? get currentCustomer {
    final id = SharedPrefHelper.getCustomerId();
    final phone = SharedPrefHelper.getCustomerPhone();
    
    if (id == null || phone == null) return null;
    
    return CustomerModel(
      id: id,
      name: SharedPrefHelper.getCustomerName(),
      email: SharedPrefHelper.getCustomerEmail(),
      phone: phone,
    );
  }

  /// Save authentication data after successful login
  static Future<void> saveAuthData({
    required String token,
    required CustomerModel? customer,
  }) async {
    await SharedPrefHelper.setAuthToken(token);
    await SharedPrefHelper.setCustomerData(
      id: customer?.id ?? "",
      name: customer?.name ?? "",
      email: customer?.email ?? "",
      phone: customer?.phone ?? "",
    );
    await SharedPrefHelper.setAuthenticated(true);
  }

  /// Clear all authentication data (logout)
  static Future<void> logout() async {
    await SharedPrefHelper.clearAllAuthData();
  }

  /// Check if current auth data is valid
  static bool get hasValidAuthData => SharedPrefHelper.hasValidAuthData;

  /// Initialize authentication manager (call this on app startup)
  static Future<void> init() async {
    await SharedPrefHelper.init();
    
    // Validate existing auth data on startup
    if (SharedPrefHelper.isAuthenticated && !SharedPrefHelper.hasValidAuthData) {
      // If marked as authenticated but missing data, clear everything
      await logout();
    }
  }

  /// Get auth token for API calls (used by DioFactory)
  static String? getTokenForRequest() {
    if (!isAuthenticated) return null;
    return authToken;
  }
}
