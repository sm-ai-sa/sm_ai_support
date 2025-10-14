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
- 💬 **Real-time Chat** - WebSocket-powered instant messaging with typing indicators
- 🤖 **AI-Powered Support** - Intelligent responses and automated assistance
- 📱 **Media Support** - Share images, files, documents with automatic compression
- 🌍 **Multi-language** - Built-in English and Arabic support with RTL layout
- 👤 **Flexible Authentication** - Anonymous and authenticated user flows
- 📊 **Session Management** - Organized conversation history with persistence

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
| **Flutter** | 3.8.1+ |
| **Dart** | 3.0.0+ |
| **iOS** | 12.0+ |
| **Android** | API 21+ (Android 5.0) |

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

// Or use a floating action button
FloatingActionButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SupportPage()),
  ),
  child: const Icon(Icons.support_agent),
)
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
    apiKey: 'your_secure_api_key', // Stored securely using flutter_secure_storage
    secretKey: 'your_hmac_secret', // Required: Enables HMAC request signing
  ),
)
```

#### Security Features

The package automatically handles secure storage of sensitive data:

- **API Key**: Stored using `flutter_secure_storage` for secure authentication
- **Secret Key**: Used for HMAC request signing to ensure request integrity
- **Automatic Cleanup**: Keys are cleared when the app is uninstalled

```dart
// Access secure configuration (if needed)
final hasApiKey = await SMConfig.hasAPIKey();
final hasSecretKey = await SMConfig.hasSecretKey();

// Clear secure data (for logout/reset)
await SMConfig.clearAllSecureData();
```

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
      ),
    );
  }
}

// Usage with environment variables
// flutter run --dart-define=SM_SUPPORT_API_KEY=your_key --dart-define=SM_SUPPORT_SECRET_KEY=your_secret
```

---

## 🏗️ Architecture

### Package Structure

```
sm_ai_support/
├── 📱 Core Components
│   ├── 🎨 UI Widgets & Themes
│   ├── 🌐 Network Layer (REST + WebSocket)
│   ├── 💾 Data Models & Storage
│   └── 🔐 Security & Authentication
├── 🚀 Features
│   ├── 💬 Real-time Chat
│   ├── 📁 Media Management
│   ├── 📊 Session Handling
│   └── 🏷️ Category System
└── 🌍 Internationalization
    ├── 🇺🇸 English (LTR)
    └── 🇸🇦 Arabic (RTL)
```

### State Management

The package uses **BLoC pattern** for reactive state management:

- `SMSupportCubit` - Main application state
- `SingleSessionCubit` - Individual chat session state
- Automatic state persistence and restoration

### Network Architecture

- **REST API** - Configuration, authentication, file uploads
- **WebSocket** - Real-time messaging and status updates
- **Automatic Reconnection** - Handles network interruptions
- **Offline Support** - Message queuing when disconnected

---

## 🔧 Advanced Features

### Security Features

- 🔒 **HMAC Signatures** - Request authentication and integrity
- 🔐 **Secure Storage** - Encrypted local data storage
- 🛡️ **Input Validation** - XSS and injection protection
- 📱 **Certificate Pinning** - Network security hardening

### Performance Optimizations

- ⚡ **Lazy Loading** - On-demand resource loading
- 🖼️ **Image Caching** - Efficient media management
- 📦 **Code Splitting** - Minimal bundle size
- 🔄 **Connection Pooling** - Optimized network usage

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
  required String appName,
  required SMSupportLocale locale,
  required String tenantId,
  required String apiKey,
  required String secretKey,
})
```

### Services

#### SMConfig

Manages secure configuration and API keys.

```dart
// Check if configuration is initialized
final hasApiKey = await SMConfig.hasAPIKey();
final hasSecretKey = await SMConfig.hasSecretKey();

// Clear secure data (for logout/reset)
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
// Solution: Ensure proper API key configuration
SMSupportData(
  appName: 'My App',
  locale: SMSupportLocale.en,
  tenantId: 'your_tenant_id',
  apiKey: 'valid_api_key_here', // Ensure this is correct
  secretKey: 'valid_secret_key', // Optional but recommended
)
```

#### Localization Issues

**Problem**: Text not displaying in correct language
```dart
// Solution: Ensure proper locale setup
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

### Getting Help

- 📖 [Documentation](https://github.com/unicode-org/sm_ai_support/tree/main/docs)
- 🐛 [Issue Tracker](https://github.com/unicode-org/sm_ai_support/issues)
- 💬 [Discussions](https://github.com/unicode-org/sm_ai_support/discussions)
- 📧 [Support Email](mailto:support@unicode.org)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ by the [Unicode Team](https://github.com/unicode-org)
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