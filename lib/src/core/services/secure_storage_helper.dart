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
  static const String _smSecretKey = 'sm_secret';

  /// Store SMSecret securely
  static Future<void> setSMSecret(String secret) async {
    try {
      await _secureStorage.write(key: _smSecretKey, value: secret);
      smPrint('SMSecret stored securely');
    } catch (e) {
      smPrint('Error storing SMSecret: $e');
      rethrow;
    }
  }

  /// Retrieve SMSecret from secure storage
  static Future<String?> getSMSecret() async {
    try {
      final secret = await _secureStorage.read(key: _smSecretKey);
      return secret;
    } catch (e) {
      smPrint('Error retrieving SMSecret: $e');
      return null;
    }
  }

  /// Clear SMSecret from secure storage
  static Future<void> clearSMSecret() async {
    try {
      await _secureStorage.delete(key: _smSecretKey);
      smPrint('SMSecret cleared from secure storage');
    } catch (e) {
      smPrint('Error clearing SMSecret: $e');
      rethrow;
    }
  }

  /// Check if SMSecret exists in secure storage
  static Future<bool> hasSMSecret() async {
    try {
      final secret = await getSMSecret();
      return secret != null && secret.isNotEmpty;
    } catch (e) {
      smPrint('Error checking SMSecret existence: $e');
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
}
