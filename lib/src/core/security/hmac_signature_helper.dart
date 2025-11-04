import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sm_ai_support/src/core/services/secure_storage_helper.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

/// Helper class for generating and verifying HMAC signatures with timestamp
/// Used for securing API requests with cryptographic signatures
class HmacSignatureHelper {
  static const String _secretKey = 'secret_key';

  /// Store secret key securely
  static Future<void> setSecretKey(String secretKey) async {
    try {
      await SecureStorageHelper.setSecureValue(_secretKey, secretKey);
      smPrint('🔐 Secret Key stored securely');
    } catch (e) {
      smPrint('🔐 Error storing Secret Key: $e');
      rethrow;
    }
  }

  /// Retrieve secret key from secure storage
  static Future<String?> getSecretKey() async {
    try {
      return await SecureStorageHelper.getSecureValue(_secretKey);
    } catch (e) {
      smPrint('🔐 Error retrieving Secret Key: $e');
      return null;
    }
  }

  /// Check if secret key exists
  static Future<bool> hasSecretKey() async {
    try {
      final key = await getSecretKey();
      return key != null && key.isNotEmpty;
    } catch (e) {
      smPrint('🔐 Error checking Secret Key existence: $e');
      return false;
    }
  }

  /// Clear secret key from secure storage
  static Future<void> clearSecretKey() async {
    try {
      await SecureStorageHelper.deleteSecureValue(_secretKey);
      smPrint('🔐 Secret Key cleared from secure storage');
    } catch (e) {
      smPrint('🔐 Error clearing Secret Key: $e');
      rethrow;
    }
  }

  /// Generate HMAC signature with timestamp
  /// Returns a Map containing timestamp and signature
  static Future<Map<String, String>?> generateSignature(String body) async {
    try {
      final secretKey = await getSecretKey();
      if (secretKey == null || secretKey.isEmpty) {
        smPrint('🔐 HMAC Secret Key not found, cannot generate signature');
        return null;
      }

      // Get current timestamp in seconds
      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      
      // Create message: timestamp + body
      final message = timestamp + body;
      
      // Generate HMAC-SHA256 signature
      final key = utf8.encode(secretKey);
      final bytes = utf8.encode(message);
      final hmacSha256 = Hmac(sha256, key);
      final digest = hmacSha256.convert(bytes);
      
      smPrint('🔐 HMAC Signature generated for timestamp: $timestamp');
      
      return {
        'timestamp': timestamp,
        'signature': digest.toString(),
      };
    } catch (e) {
      smPrint('🔐 Error generating HMAC signature: $e');
      return null;
    }
  }

  /// Verify HMAC signature
  /// Returns true if signature is valid
  static Future<bool> verifySignature(String body, String timestamp, String signature) async {
    try {
      final secretKey = await getSecretKey();
      if (secretKey == null || secretKey.isEmpty) {
        smPrint('🔐 HMAC Secret Key not found, cannot verify signature');
        return false;
      }

      // Recreate the message
      final message = timestamp + body;
      
      // Generate HMAC-SHA256 signature
      final key = utf8.encode(secretKey);
      final bytes = utf8.encode(message);
      final hmacSha256 = Hmac(sha256, key);
      final digest = hmacSha256.convert(bytes);
      
      // Compare signatures
      final isValid = digest.toString() == signature;
      smPrint('🔐 HMAC Signature verification: ${isValid ? "✅ Valid" : "❌ Invalid"}');
      
      return isValid;
    } catch (e) {
      smPrint('🔐 Error verifying HMAC signature: $e');
      return false;
    }
  }

  /// Generate signature and return headers for API request
  /// Returns headers with lowercase names as per backend specification:
  /// - x-api-key (API key for tenant identification)
  /// - x-t (Unix timestamp in seconds)
  /// - x-signature (HMAC-SHA256 signature)
  static Future<Map<String, String>?> generateAuthHeaders(String body) async {
    try {
      // Get API key from secure storage
      final apiKey = await SecureStorageHelper.getAPIKey();
      if (apiKey == null || apiKey.isEmpty) {
        smPrint('🔐 API Key not found, cannot generate HMAC headers');
        return null;
      }

      final result = await generateSignature(body);
      if (result == null) {
        smPrint('🔐 Failed to generate HMAC signature for headers');
        return null;
      }
      
      final headers = {
        'x-api-key': apiKey,                // Backend expects lowercase x-api-key
        'x-t': result['timestamp']!,        // Backend expects x-t (not X-Timestamp)
        'x-signature': result['signature']!, // Backend expects lowercase x-signature
      };
      
      smPrint('🔐 HMAC Auth headers generated: x-api-key, x-t, x-signature');
      smPrint('🔐 API Key: ${apiKey.substring(0, 4)}..., Timestamp: ${result['timestamp']}, Signature: ${result['signature']!.substring(0, 8)}...');
      return headers;
    } catch (e) {
      smPrint('🔐 Error generating HMAC auth headers: $e');
      return null;
    }
  }

  /// Check if HMAC signature should be applied to request
  /// This can be customized based on endpoint patterns or other criteria
  static bool shouldApplyHmacSignature(String path) {
    // Skip HMAC for video URLs (common video file extensions)
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.flv', '.m4v'];
    final lowerPath = path.toLowerCase();

    if (videoExtensions.any((ext) => lowerPath.contains(ext))) {
      smPrint('🔐 Skipping HMAC for video file: $path');
      return false;
    }

    // Skip HMAC for presigned URLs (R2/Cloudflare Workers, S3, etc.)
    // These URLs already have their own authentication via query parameters
    if (path.contains('workers.dev') ||
        path.contains('r2.dev') ||
        path.contains('cloudflare') ||
        path.contains('accessToken=') ||
        path.contains('X-Amz-Signature=')) {
      smPrint('🔐 Skipping HMAC for presigned URL: $path');
      return false;
    }

    // Apply HMAC to all other API requests by default
    return true;
  }

  /// Validate timestamp to prevent replay attacks
  /// Returns true if timestamp is within acceptable range (default: 5 minutes)
  static bool isTimestampValid(String timestamp, {int maxAgeInSeconds = 300}) {
    try {
      final requestTime = int.parse(timestamp);
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final timeDifference = (currentTime - requestTime).abs();
      
      final isValid = timeDifference <= maxAgeInSeconds;
      smPrint('🔐 Timestamp validation: ${isValid ? "✅ Valid" : "❌ Expired"} (${timeDifference}s ago)');
      
      return isValid;
    } catch (e) {
      smPrint('🔐 Error validating timestamp: $e');
      return false;
    }
  }
}
