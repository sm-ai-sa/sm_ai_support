# 🚀 SM AI Support

<div align="center">

[![pub package](https://img.shields.io/pub/v/sm_ai_support.svg)](https://pub.dev/packages/sm_ai_support)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.8.1-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0.0-blue.svg)](https://dart.dev)

**A comprehensive Flutter package for integrating AI-powered customer support into your mobile applications**

*Real-time chat • Media sharing • Multi-language • Tenant-based customization*

[Features](#-features) • [Installation](#-installation) • [Quick Start](#-quick-start) • [Documentation](#-documentation) • [Examples](#-examples)

</div>

---

## ✨ Features

### 🎯 **Core Functionality**
- 💬 **Real-time Chat** - WebSocket-powered instant messaging with delivery status and typing indicators
- 🤖 **AI-Powered Support** - Intelligent responses and automated assistance
- 📱 **Advanced Media Support** - Share images, videos, files, and documents
  - Automatic image compression and optimization
  - Chunked file upload for large files
  - Support for multiple file types (PDF, DOC, DOCX, XLS, XLSX, images, videos)
  - Upload progress tracking with cancellation support
- 🌍 **Multi-language** - Built-in English and Arabic support with RTL layout
- 👤 **Flexible Authentication** - Anonymous and authenticated user flows
- 📊 **Session Management** - Organized conversation history with persistence and search

### 🏢 **Enterprise Ready**
- 🏗️ **Multi-tenant Architecture** - Perfect for SaaS applications
- 🎨 **Dynamic Theming** - Automatic branding fetch from tenant configuration
- 🔐 **Secure Communications** - End-to-end encryption and HMAC signatures
- 📈 **Analytics Ready** - Built-in tracking and monitoring capabilities
- ⚡ **High Performance** - Optimized for large-scale deployments

### 🎨 **User Experience**
- 📱 **Responsive Design** - Optimized for all screen sizes and orientations
- 🎭 **Customizable UI** - Tenant-specific branding and color schemes
- ✨ **Smooth Animations** - Polished transitions and loading states
- ♿ **Accessibility** - Screen reader compatibility and semantic labels
- 🌙 **Theme Support** - Light and dark mode compatibility

---

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  sm_ai_support: ^0.0.1
```

Then run:

```bash
flutter pub get
```

### Platform Requirements

| Platform | Minimum Version |
|----------|----------------|
| **Flutter** | 1.17.0+ |
| **Dart** | 3.8.1+ |
| **iOS** | 12.0+ |
| **Android** | API 21+ (Android 5.0) |

### Required Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take photos for support</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select images for support</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone for audio messages</string>
```

---

## 🚀 Quick Start

### 1. Import the package

```dart
import 'package:sm_ai_support/sm_ai_support.dart';
```

### 2. Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SMSupport(
      parentContext: context,
      smSupportData: SMSupportData(
        appName: 'Your App Name',
        locale: SMSupportLocale.en, // or SMSupportLocale.ar
        tenantId: 'your_tenant_id',
        apiKey: 'your_api_key_here', // Required for authentication
        secretKey: 'your_secret_key_here', // Required: For HMAC request signing
        baseUrl: 'https://your-api-server.com/api/core', // REST API base URL
        socketBaseUrl: 'wss://your-api-server.com/ws', // WebSocket base URL
      ),
    );
  }
}
```

### 3. Navigate to Support

```dart
// From anywhere in your app
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SupportPage()),
);

```

---

## 📖 Documentation

### Configuration Options

#### SMSupportData Parameters

| Parameter | Type | Required | Description | Default |
|-----------|------|----------|-------------|---------|
| `appName` | `String` | ✅ | Your application name | - |
| `locale` | `SMSupportLocale` | ✅ | Language preference (en/ar) | - |
| `tenantId` | `String` | ✅ | Your unique tenant identifier | - |
| `apiKey` | `String` | ✅ | API key for authentication (stored securely) | - |
| `secretKey` | `String` | ✅ | Secret key for HMAC request signing (stored securely) | - |
| `baseUrl` | `String` | ✅ | Base URL for REST API endpoints (e.g., `https://api.example.com/api/core`) | - |
| `socketBaseUrl` | `String` | ✅ | Base URL for WebSocket connections (e.g., `wss://api.example.com/ws`) | - |

#### Available Locales

```dart
// English interface (LTR)
SMSupportLocale.en

// Arabic interface (RTL)
SMSupportLocale.ar
```

### Advanced Configuration

#### Secure Configuration

```dart
SMSupport(
  parentContext: context,
  smSupportData: SMSupportData(
    appName: 'My App',
    locale: SMSupportLocale.en,
    tenantId: 'tenant_123',
    apiKey: 'your_secure_api_key', 
    secretKey: 'your_hmac_secret',
    baseUrl: 'https://your-api-server.com/api/core', 
    socketBaseUrl: 'wss://your-api-server.com/ws',
  ),
)
```

#### Security Features

The package automatically handles secure storage of sensitive data and request signing:

- **API Key**: Stored using `flutter_secure_storage` for secure authentication
- **Secret Key**: Used for HMAC-SHA256 request signing to ensure request integrity
- **HMAC Signatures**: All API requests are automatically signed with HMAC-SHA256
- **Automatic Cleanup**: Keys are cleared when the app is uninstalled
- **Secure Storage**: Uses platform-specific secure storage (iOS Keychain, Android EncryptedSharedPreferences)

```dart
// Check if configuration is initialized
final hasApiKey = await SMConfig.hasAPIKey();
final hasSecretKey = await SMConfig.hasSecretKey();

// Get stored keys (if needed for debugging)
final apiKey = await SMConfig.getAPIKey();
final secretKey = await SMConfig.getSecretKey();

// Clear individual keys
await SMConfig.clearAPIKey();
await SMConfig.clearSecretKey();

// Clear all secure data (for logout/reset)
await SMConfig.clearAllSecureData();
```

**HMAC Request Signing:**

All HTTP requests are automatically signed using HMAC-SHA256. The signature is computed from:
- Request timestamp (Unix timestamp in seconds)
- HTTP method (GET, POST, etc.)
- Request path
- Request body (for POST/PUT requests)

The signature is sent in the `X-Signature` header, and the timestamp in the `X-Timestamp` header. This ensures:
- Request authenticity
- Protection against replay attacks
- Request integrity verification

---

## 💡 Examples

### Complete Integration Example

```dart
import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SM AI Support Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Awesome App'),
        actions: [
          // Support button in app bar
          IconButton(
            icon: const Icon(Icons.support_agent),
            onPressed: () => _openSupport(context),
            tooltip: 'Get Support',
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Welcome to My App!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Need help? Tap the support icon above.'),
          ],
        ),
      ),
      // Floating support button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSupport(context),
        icon: const Icon(Icons.chat),
        label: const Text('Support'),
      ),
    );
  }

  void _openSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SMSupport(
          parentContext: context,
          smSupportData: SMSupportData(
            appName: 'My Awesome App',
            locale: SMSupportLocale.en,
            tenantId: 'your_tenant_id',
            apiKey: 'your_api_key_here',
            secretKey: 'your_secret_key_here', // Required
            baseUrl: 'https://your-api-server.com/api/core',
            socketBaseUrl: 'wss://your-api-server.com/ws',
          ),
        ),
      ),
    );
  }
}
```

### Multi-language Support

```dart
class LocalizedSupportPage extends StatelessWidget {
  final bool isArabic;
  
  const LocalizedSupportPage({super.key, this.isArabic = false});

  @override
  Widget build(BuildContext context) {
    return SMSupport(
      parentContext: context,
      smSupportData: SMSupportData(
        appName: isArabic ? 'تطبيقي الرائع' : 'My Awesome App',
        locale: isArabic ? SMSupportLocale.ar : SMSupportLocale.en,
        tenantId: 'your_tenant_id',
        apiKey: 'your_api_key_here',
        secretKey: 'your_secret_key_here', // Required
        baseUrl: 'https://your-api-server.com/api/core',
        socketBaseUrl: 'wss://your-api-server.com/ws',
      ),
    );
  }
}
```

### Real-World Integration Example

```dart
class ProductionSupportPage extends StatelessWidget {
  final String userLocale;
  
  const ProductionSupportPage({super.key, required this.userLocale});

  @override
  Widget build(BuildContext context) {
    return SMSupport(
      parentContext: context,
      smSupportData: SMSupportData(
        appName: 'Production App',
        locale: userLocale == 'ar' ? SMSupportLocale.ar : SMSupportLocale.en,
        tenantId: 'prod_tenant_123',
        apiKey: const String.fromEnvironment('SM_SUPPORT_API_KEY'),
        secretKey: const String.fromEnvironment('SM_SUPPORT_SECRET_KEY'),
        baseUrl: const String.fromEnvironment(
          'SM_SUPPORT_BASE_URL',
          defaultValue: 'https://api.example.com/api/core',
        ),
        socketBaseUrl: const String.fromEnvironment(
          'SM_SUPPORT_SOCKET_URL',
          defaultValue: 'wss://api.example.com/ws',
        ),
      ),
    );
  }
}

// Usage with environment variables:
// flutter run --dart-define=SM_SUPPORT_API_KEY=your_key \
//             --dart-define=SM_SUPPORT_SECRET_KEY=your_secret \
//             --dart-define=SM_SUPPORT_BASE_URL=https://api.example.com/api/core \
//             --dart-define=SM_SUPPORT_SOCKET_URL=wss://api.example.com/ws
```

---

## 🏗️ Architecture

### Package Structure

```
sm_ai_support/
├── 📱 Core Components
│   ├── 🎨 UI Widgets & Themes
│   ├── 🌐 Network Layer (Dio + Socket.IO)
│   ├── 💾 Data Models & Storage
│   ├── 🔐 Security & Authentication (HMAC + Secure Storage)
│   └── 📤 Media Upload (Chunked & Streaming)
├── 🚀 Features
│   ├── 💬 Real-time Chat (WebSocket)
│   ├── 📁 Media Management (Image, Video, File)
│   ├── 📊 Session Handling
│   └── 🏷️ Category System
└── 🌍 Internationalization
    ├── 🇺🇸 English (LTR)
    └── 🇸🇦 Arabic (RTL)
```

### Key Dependencies

- **State Management**: `flutter_bloc` - BLoC pattern for reactive state management
- **Networking**: `dio` - HTTP client with interceptors and request signing
- **WebSocket**: `socket_io_client` - Real-time bidirectional communication
- **Secure Storage**: `flutter_secure_storage` - Platform-specific encrypted storage
- **Media Handling**: `image_picker`, `file_picker`, `cached_network_image`
- **Video Playback**: `video_player`, `chewie` - Video player with controls
- **Localization**: `flutter_localizations`, `intl` - Multi-language support

### State Management

The package uses **BLoC pattern** for reactive state management:

- `SMSupportCubit` - Main application state
- `SingleSessionCubit` - Individual chat session state
- Automatic state persistence and restoration

### Network Architecture

- **REST API (Dio)** - Configuration, authentication, file uploads with HMAC signing
- **WebSocket (Socket.IO)** - Real-time messaging, typing indicators, and status updates
- **Automatic Reconnection** - Handles network interruptions gracefully
- **Request Signing** - All requests are automatically signed with HMAC-SHA256
- **Error Handling** - Comprehensive error handling with user-friendly messages
- **Retry Logic** - Automatic retry for failed requests with exponential backoff

---

## 🔧 Advanced Features

### Security Features

- 🔒 **HMAC-SHA256 Signatures** - Automatic request signing for authentication and integrity
- 🔐 **Secure Storage** - Platform-specific encrypted storage (iOS Keychain, Android EncryptedSharedPreferences)
- 🛡️ **Input Validation** - XSS and injection protection
- 🔑 **API Key Management** - Secure credential storage and retrieval
- ⏱️ **Replay Attack Prevention** - Timestamp-based request validation
- 📱 **Transport Security** - HTTPS/WSS encrypted communications

### Media Upload Features

- 📤 **Chunked Upload** - Large files are automatically split into chunks for reliable upload
- 📊 **Progress Tracking** - Real-time upload progress with percentage and cancel option
- 🖼️ **Image Optimization** - Automatic compression and resizing for faster uploads
- 📹 **Video Support** - Upload and playback of video files with custom player
- 📄 **Document Support** - PDF, DOC, DOCX, XLS, XLSX file uploads
- ⚡ **Upload Queue** - Multiple files can be queued and uploaded sequentially
- 🔄 **Retry Logic** - Automatic retry on failed uploads with exponential backoff
- ❌ **Cancellation** - Users can cancel ongoing uploads at any time

### Performance Optimizations

- ⚡ **Lazy Loading** - On-demand resource loading
- 🖼️ **Image Caching** - Efficient media management with `cached_network_image`
- 📦 **Minimal Dependencies** - Optimized package size
- 🔄 **Connection Pooling** - Optimized network usage with Dio
- 📱 **Memory Management** - Efficient handling of large media files
- ⚙️ **Background Processing** - Media compression and upload in isolates

### Monitoring & Analytics

- 📊 **Usage Metrics** - Built-in analytics hooks
- 🐛 **Error Tracking** - Comprehensive error reporting
- 📈 **Performance Monitoring** - Real-time performance metrics
- 🔍 **Debug Tools** - Development and testing utilities

---

## 🛠️ Development

### Running the Example

```bash
cd example
flutter pub get
flutter run
```

### Testing

```bash
flutter test
```

### Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

---

## 📚 API Reference

### Core Classes

#### SMSupport Widget

The main widget that provides the support interface.

```dart
SMSupport({
  required BuildContext parentContext,
  required SMSupportData smSupportData,
  Key? key,
})
```

#### SMSupportData Model

Configuration data for the support system.

```dart
SMSupportData({
  required String appName,          // Your application name
  required SMSupportLocale locale,  // UI language (en or ar)
  required String tenantId,         // Your tenant identifier
  required String apiKey,           // API authentication key
  required String secretKey,        // HMAC signing secret key
  required String baseUrl,          // REST API base URL (e.g., 'https://api.example.com/api/core')
  required String socketBaseUrl,    // WebSocket base URL (e.g., 'wss://api.example.com/ws')
})
```

### Services

#### SMConfig

Manages secure configuration and API keys.

```dart
// Check if configuration is initialized
final hasApiKey = await SMConfig.hasAPIKey();
final hasSecretKey = await SMConfig.hasSecretKey();

// Get stored keys (if needed)
final apiKey = await SMConfig.getAPIKey();
final secretKey = await SMConfig.getSecretKey();

// Clear individual keys
await SMConfig.clearAPIKey();
await SMConfig.clearSecretKey();

// Clear all secure data (for logout/reset)
await SMConfig.clearAllSecureData();
```

#### AuthManager

Handles user authentication and session management.

```dart
// Initialize authentication system
await AuthManager.init();
```

#### WebSocketService

Manages real-time communication for chat functionality.

```dart
final wsService = WebSocketService();
// WebSocket connection is handled automatically by the package
```

---

## 🔍 Troubleshooting

### Common Issues

#### Build Errors

**Problem**: Compilation errors after installation
```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### Network Issues

**Problem**: Connection timeouts or SSL errors
```dart
// Solution: Ensure proper configuration with all required parameters
SMSupportData(
  appName: 'My App',
  locale: SMSupportLocale.en,
  tenantId: 'your_tenant_id',
  apiKey: 'valid_api_key_here',        // Required
  secretKey: 'valid_secret_key_here',   // Required
  baseUrl: 'https://api.example.com/api/core',  // Required
  socketBaseUrl: 'wss://api.example.com/ws',     // Required
)
```

#### Localization Issues

**Problem**: Text not displaying in correct language
```dart
// Solution: Ensure proper locale setup in your main app
MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en', 'US'),
    Locale('ar', 'SA'),
  ],
  // ... rest of config
)
```

#### Permission Issues

**Problem**: Camera or file picker not working

**Solution**: Ensure you've added the required permissions (see [Required Permissions](#required-permissions) section above)

For runtime permissions:
```dart
// The package automatically handles permission requests
// Just ensure the permissions are declared in your manifest files
```

**Problem**: Image picker crashes on Android 13+

**Solution**: Add the new photo picker permissions:
```xml
<!-- Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

#### Upload Issues

**Problem**: File upload fails or times out

**Solution**: 
- Check your network connection
- Verify your API key and secret key are correct
- Ensure your server's upload size limits are sufficient
- For large files, the package automatically uses chunked upload

### Getting Help

- 📖 [Full Documentation](https://github.com/unicode-org/sm_ai_support/tree/main/docs)
  - [Integration Guide](https://github.com/unicode-org/sm_ai_support/blob/main/docs/INTEGRATION_GUIDE.md)
  - [HMAC Signature Documentation](https://github.com/unicode-org/sm_ai_support/blob/main/docs/HMAC_SIGNATURE_DOCUMENTATION.md)
  - [Media Upload Guide](https://github.com/unicode-org/sm_ai_support/blob/main/MEDIA_UPLOAD.md)
  - [Support API Documentation](https://github.com/unicode-org/sm_ai_support/blob/main/docs/SUPPORT_API_DOCUMENTATION.md)
  - [WebSocket Streaming](https://github.com/unicode-org/sm_ai_support/blob/main/docs/WEBSOCKET_STREAMING.md)
- 🐛 [Issue Tracker](https://github.com/unicode-org/sm_ai_support/issues)
- 💬 [Discussions](https://github.com/unicode-org/sm_ai_support/discussions)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ by the [Unicode Team]
- Powered by Flutter and Dart
- Icons by [Material Design Icons](https://materialdesignicons.com/)

---

## 📈 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.

---

<div align="center">

**[⬆ Back to Top](#-sm-ai-support)**

Made with ❤️ by the Unicode Team

</div>