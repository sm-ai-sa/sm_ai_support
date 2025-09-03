import 'package:shared_preferences/shared_preferences.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

class SharedPrefHelper {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call SharedPrefHelper.init() first.');
    }
    return _prefs!;
  }

  // Keys for storing data
  static const String _authTokenKey = 'auth_token';
  static const String _customerIdKey = 'customer_id';
  static const String _customerNameKey = 'customer_name';
  static const String _customerEmailKey = 'customer_email';
  static const String _customerPhoneKey = 'customer_phone';
  static const String _isAuthenticatedKey = 'is_authenticated';
  static const String _anonymousSessionIdsKey = 'anonymous_session_ids';

  // Auth Token Methods
  static Future<void> setAuthToken(String token) async {
    await prefs.setString(_authTokenKey, token);
    await prefs.setBool(_isAuthenticatedKey, true);
  }

  static String? getAuthToken() {
    return prefs.getString(_authTokenKey);
  }

  static Future<void> clearAuthToken() async {
    await prefs.remove(_authTokenKey);
    await prefs.setBool(_isAuthenticatedKey, false);
  }

  // Customer Data Methods
  static Future<void> setCustomerData({
    required String id,
    String? name,
    String? email,
    required String phone,
  }) async {
    await prefs.setString(_customerIdKey, id);
    await prefs.setString(_customerPhoneKey, phone);
    
    if (name != null) {
      await prefs.setString(_customerNameKey, name);
    } else {
      await prefs.remove(_customerNameKey);
    }
    
    if (email != null) {
      await prefs.setString(_customerEmailKey, email);
    } else {
      await prefs.remove(_customerEmailKey);
    }
  }

  static String? getCustomerId() {
    return prefs.getString(_customerIdKey);
  }

  static String? getCustomerName() {
    return prefs.getString(_customerNameKey);
  }

  static String? getCustomerEmail() {
    return prefs.getString(_customerEmailKey);
  }

  static String? getCustomerPhone() {
    return prefs.getString(_customerPhoneKey);
  }

  // Authentication Status
  static bool get isAuthenticated {
    return prefs.getBool(_isAuthenticatedKey) ?? false;
  }

  static Future<void> setAuthenticated(bool value) async {
    await prefs.setBool(_isAuthenticatedKey, value);
  }

  // Clear All Authentication Data
  static Future<void> clearAllAuthData() async {
    await prefs.remove(_authTokenKey);
    await prefs.remove(_customerIdKey);
    await prefs.remove(_customerNameKey);
    await prefs.remove(_customerEmailKey);
    await prefs.remove(_customerPhoneKey);
    await prefs.setBool(_isAuthenticatedKey, false);
  }

  // Check if we have complete auth data
  static bool get hasValidAuthData {
    final token = getAuthToken();
    final customerId = getCustomerId();
    final phone = getCustomerPhone();
    
    return token != null && 
           token.isNotEmpty && 
           customerId != null && 
           customerId.isNotEmpty &&
           phone != null && 
           phone.isNotEmpty;
  }

  // Anonymous Session IDs Management
  static Future<void> addAnonymousSessionId(String sessionId) async {
    final List<String> currentIds = getAnonymousSessionIds();
    if (!currentIds.contains(sessionId)) {
      currentIds.add(sessionId);
      await prefs.setStringList(_anonymousSessionIdsKey, currentIds);
    }

    smPrint('Anonymous Session IDs: $currentIds');
  }

  static List<String> getAnonymousSessionIds() {
    return prefs.getStringList(_anonymousSessionIdsKey) ?? [];
  }

  static Future<void> clearAnonymousSessionIds() async {
    await prefs.remove(_anonymousSessionIdsKey);
  }

  static Future<void> removeAnonymousSessionId(String sessionId) async {
    final List<String> currentIds = getAnonymousSessionIds();
    currentIds.remove(sessionId);
    await prefs.setStringList(_anonymousSessionIdsKey, currentIds);
  }

  static bool hasAnonymousSessionIds() {
    return getAnonymousSessionIds().isNotEmpty;
  }
}
