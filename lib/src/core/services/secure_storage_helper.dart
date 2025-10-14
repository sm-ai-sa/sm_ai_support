import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

/// Helper class for managing secure storage operations
/// Used for storing sensitive data like SMSecret
class SecureStorageHelper {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for storing secure data
  static const String _apiKeyKey = 'api_key';

  /// Store API Key securely
  static Future<void> setAPIKey(String apiKey) async {
    try {
      await _secureStorage.write(key: _apiKeyKey, value: apiKey);
      smPrint('API Key stored securely');
    } catch (e) {
      smPrint('Error storing API Key: $e');
      rethrow;
    }
  }

  /// Retrieve API Key from secure storage
  static Future<String?> getAPIKey() async {
    try {
      final apiKey = await _secureStorage.read(key: _apiKeyKey);
      return apiKey;
    } catch (e) {
      smPrint('Error retrieving API Key: $e');
      return null;
    }
  }

  /// Clear API Key from secure storage
  static Future<void> clearAPIKey() async {
    try {
      await _secureStorage.delete(key: _apiKeyKey);
      smPrint('API Key cleared from secure storage');
    } catch (e) {
      smPrint('Error clearing API Key: $e');
      rethrow;
    }
  }

  /// Check if API Key exists in secure storage
  static Future<bool> hasAPIKey() async {
    try {
      final apiKey = await getAPIKey();
      return apiKey != null && apiKey.isNotEmpty;
    } catch (e) {
      smPrint('Error checking API Key existence: $e');
      return false;
    }
  }

  /// Clear all secure storage data
  static Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      smPrint('All secure storage data cleared');
    } catch (e) {
      smPrint('Error clearing all secure storage: $e');
      rethrow;
    }
  }

  // Generic secure storage methods for other components

  /// Store any secure value with a custom key
  static Future<void> setSecureValue(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      smPrint('Secure value stored for key: $key');
    } catch (e) {
      smPrint('Error storing secure value for key $key: $e');
      rethrow;
    }
  }

  /// Retrieve any secure value by key
  static Future<String?> getSecureValue(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value;
    } catch (e) {
      smPrint('Error retrieving secure value for key $key: $e');
      return null;
    }
  }

  /// Delete any secure value by key
  static Future<void> deleteSecureValue(String key) async {
    try {
      await _secureStorage.delete(key: key);
      smPrint('Secure value deleted for key: $key');
    } catch (e) {
      smPrint('Error deleting secure value for key $key: $e');
      rethrow;
    }
  }

  /// Check if a secure value exists for the given key
  static Future<bool> hasSecureValue(String key) async {
    try {
      final value = await getSecureValue(key);
      return value != null && value.isNotEmpty;
    } catch (e) {
      smPrint('Error checking secure value existence for key $key: $e');
      return false;
    }
  }
}
