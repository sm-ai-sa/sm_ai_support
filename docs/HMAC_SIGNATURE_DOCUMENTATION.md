# HMAC Signature Authentication

This document explains the HMAC (Hash-based Message Authentication Code) signature implementation in the SM AI Support package, which provides cryptographic authentication for API requests.

## Overview

The HMAC signature system adds an additional layer of security to API requests by:
- Generating cryptographic signatures for request authentication
- Including timestamps to prevent replay attacks
- Storing secret keys securely using Flutter Secure Storage
- Automatically signing all API requests through Dio interceptors

## Architecture

### Components

1. **HmacSignatureHelper** - Core HMAC signature generation and verification
2. **HmacInterceptor** - Dio interceptor for automatic request signing
3. **SecureStorageHelper** - Secure storage for HMAC secret keys
4. **SMConfig** - Configuration management for HMAC initialization

### Security Features

- **HMAC-SHA256** - Industry-standard cryptographic hash function
- **Timestamp-based signatures** - Prevents replay attacks
- **Secure key storage** - Uses Flutter Secure Storage with platform-specific encryption
- **Automatic request signing** - Transparent integration with existing API calls

## Implementation

### 1. Initialize with HMAC Secret Key

```dart
import 'package:sm_ai_support/sm_ai_support.dart';

SMSupport(
  parentContext: context,
  smSupportData: SMSupportData(
    appName: 'Your App',
    locale: SMSupportLocale.en,
    tenantId: 'your_tenant_id',
    apiKey: 'your_api_secret',
    secretKey: 'your_secret_key', // Enable HMAC signing
    baseUrl: 'https://your-api-server.com/api/core',
    socketBaseUrl: 'wss://your-api-server.com/ws',
  ),
);
```

### 2. Automatic Request Signing

Once initialized, all API requests are automatically signed:

```dart
// This request will automatically include HMAC signature headers
final response = await DioFactory.getDio().post('/api/endpoint', data: {
  'message': 'Hello World'
});

// Headers added automatically:
// X-Timestamp: 1234567890
// X-Signature: abc123def456...
```

### 3. Manual HMAC Operations (Advanced)

```dart
import 'package:sm_ai_support/src/core/security/hmac_signature_helper.dart';

// Generate signature manually
final signature = await HmacSignatureHelper.generateSignature('request_body');
print('Timestamp: ${signature?['timestamp']}');
print('Signature: ${signature?['signature']}');

// Verify signature
final isValid = await HmacSignatureHelper.verifySignature(
  'request_body',
  '1234567890',
  'signature_to_verify'
);

// Generate auth headers
final headers = await HmacSignatureHelper.generateAuthHeaders('request_body');
```

## Signature Generation Process

### Algorithm

1. **Get Current Timestamp**: Unix timestamp in seconds
2. **Create Message**: Concatenate timestamp + request body
3. **Generate HMAC**: HMAC-SHA256(secret_key, message)
4. **Return Headers**: X-Timestamp and X-Signature

### Example

```
Secret Key: "my-secret-key-12345"
Request Body: '{"user":"john","action":"login"}'
Timestamp: "1640995200"
Message: "1640995200" + '{"user":"john","action":"login"}'
HMAC-SHA256: "a1b2c3d4e5f6..."
```

### Headers Added to Request

```
X-Timestamp: 1640995200
X-Signature: a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456
```

## Server-Side Verification

Your server should verify HMAC signatures using this process:

### 1. Extract Headers

```python
timestamp = request.headers.get('X-Timestamp')
signature = request.headers.get('X-Signature')
request_body = request.body
```

### 2. Validate Timestamp

```python
import time

current_time = int(time.time())
request_time = int(timestamp)
time_difference = abs(current_time - request_time)

# Reject requests older than 5 minutes
if time_difference > 300:
    return "Request expired"
```

### 3. Verify Signature

```python
import hmac
import hashlib

# Recreate the message
message = timestamp + request_body

# Generate expected signature
expected_signature = hmac.new(
    secret_key.encode('utf-8'),
    message.encode('utf-8'),
    hashlib.sha256
).hexdigest()

# Compare signatures
if not hmac.compare_digest(signature, expected_signature):
    return "Invalid signature"
```

## Configuration Options

### Conditional HMAC Signing

You can customize which requests get signed:

```dart
// In DioFactory, replace HmacInterceptor with ConditionalHmacInterceptor
dio?.interceptors.add(ConditionalHmacInterceptor(
  includePaths: ['/api/secure'], // Only sign these paths
  excludePaths: ['/api/public'],  // Never sign these paths
  customCondition: (options) => options.method == 'POST', // Custom logic
));
```

### HMAC Settings

```dart
// Check if HMAC is enabled
final hasHmacKey = await SMConfig.hasHmacSecretKey();

// Get HMAC secret key
final hmacKey = await SMConfig.getHmacSecretKey();

// Clear HMAC secret key
await SMConfig.clearHmacSecretKey();

// Clear all secure data
await SMConfig.clearAllSecureData();
```

## Security Best Practices

### 1. Secret Key Management

- **Use strong keys**: Minimum 32 characters, randomly generated
- **Rotate keys regularly**: Implement key rotation strategy
- **Never hardcode keys**: Use environment variables or secure configuration
- **Separate keys per environment**: Different keys for dev/staging/production

### 2. Timestamp Validation

- **Set reasonable time windows**: Default 5 minutes, adjust based on needs
- **Synchronize clocks**: Ensure server and client time synchronization
- **Handle clock skew**: Account for minor time differences

### 3. Request Body Handling

- **Include entire body**: Sign the complete request payload
- **Consistent encoding**: Always use UTF-8 encoding
- **Handle different content types**: JSON, form data, etc.

### 4. Error Handling

- **Log signature failures**: Monitor for potential attacks
- **Graceful degradation**: Handle signature errors appropriately
- **Retry logic**: Implement proper retry mechanisms

### 5. Performance Considerations

- **HMAC is fast**: Minimal performance impact
- **Cache considerations**: Be careful with request caching
- **Monitor performance**: Track signature generation times

## Troubleshooting

### Common Issues

1. **Signature Mismatch**
   - Check secret key consistency
   - Verify timestamp format
   - Ensure request body encoding

2. **Timestamp Expired**
   - Check system clock synchronization
   - Adjust time window if needed
   - Handle network delays

3. **Missing Headers**
   - Verify HMAC secret key is set
   - Check interceptor configuration
   - Ensure Dio factory initialization

### Debug Logging

Enable debug logging to troubleshoot HMAC issues:

```dart
// Look for these log messages:
// 🔐 HMAC Secret Key stored successfully
// 🔐 HMAC Signature generated for timestamp: ...
// 🔐 HMAC Interceptor: Signature added to request headers
```

## Migration Guide

### Enabling HMAC for Existing Apps

1. **Add HMAC secret key** to your SMSupportData initialization
2. **Update server-side** to handle HMAC signatures
3. **Test thoroughly** in development environment
4. **Deploy gradually** using feature flags if needed

### Disabling HMAC

To disable HMAC signing:

```dart
// Set secretKey to empty string to disable HMAC
SMSupportData(
  appName: 'Your App',
  locale: SMSupportLocale.en,
  tenantId: 'your_tenant_id',
  apiKey: 'your_api_secret',
  secretKey: '', // HMAC disabled
  baseUrl: 'https://your-api-server.com/api/core',
  socketBaseUrl: 'wss://your-api-server.com/ws',
);
```

## API Reference

### HmacSignatureHelper

- `setHmacSecretKey(String key)` - Store HMAC secret key securely
- `getHmacSecretKey()` - Retrieve HMAC secret key
- `hasHmacSecretKey()` - Check if HMAC secret key exists
- `clearHmacSecretKey()` - Clear HMAC secret key
- `generateSignature(String body)` - Generate HMAC signature
- `verifySignature(String body, String timestamp, String signature)` - Verify signature
- `generateAuthHeaders(String body)` - Generate auth headers
- `shouldApplyHmacSignature(String path)` - Check if path should be signed
- `isTimestampValid(String timestamp)` - Validate timestamp

### SMConfig HMAC Methods

- `getHmacSecretKey()` - Get HMAC secret key
- `hasHmacSecretKey()` - Check if HMAC secret key exists
- `clearHmacSecretKey()` - Clear HMAC secret key
- `clearAllSecureData()` - Clear all secure data

## Examples

See `example/hmac_example.dart` for complete working examples of:
- Basic HMAC signature generation
- Request signing
- Server-side verification
- Integration with SM AI Support package
