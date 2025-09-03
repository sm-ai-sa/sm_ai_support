# SM AI Support

A comprehensive Flutter package for integrating AI-powered customer support into your mobile applications. Features real-time chat, media sharing, multi-language support, and tenant-based customization.

[![pub package](https://img.shields.io/pub/v/sm_ai_support.svg)](https://pub.dev/packages/sm_ai_support)

## Features

🚀 **Easy Integration** - Get started with just a few lines of code  
💬 **Real-time Chat** - WebSocket-powered instant messaging  
📱 **Media Support** - Share images, files, and documents  
🌍 **Multi-language** - Built-in English and Arabic support  
🎨 **Customizable UI** - Tenant-based theming and branding  
👤 **Flexible Authentication** - Support for both anonymous and authenticated users  
📊 **Session Management** - Organized conversation history  
🏢 **Multi-tenant** - Perfect for SaaS applications  

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  sm_ai_support:
```

Then run:

```bash
flutter pub get
```

## Usage

### 1. Import the package

```dart
import 'package:sm_ai_support/sm_ai_support.dart';
```

### 2. Create a support page

```dart
import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';

class SMSupportPage extends StatelessWidget {
  const SMSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SMSupport(
      parentContext: context,
      smSupportData: SMSupportData(
        appName: 'Your App Name',
        locale: SMSupportLocale.english, // or SMSupportLocale.ar for Arabic
        tenantId: 'your_tenant_id',
      ),
    );
  }
}
```

### 3. Navigate to the support page

```dart
// From any widget in your app
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SMSupportPage(),
  ),
);
```

### 4. Complete example

```dart
import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
        actions: [
          IconButton(
            icon: Icon(Icons.support_agent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SMSupportPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SMSupportPage(),
              ),
            );
          },
          child: Text('Get Support'),
        ),
      ),
    );
  }
}

class SMSupportPage extends StatelessWidget {
  const SMSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SMSupport(
      parentContext: context,
      smSupportData: SMSupportData(
        appName: 'My Awesome App',
        locale: SMSupportLocale.english,
        tenantId: 'your_tenant_id',
      ),
    );
  }
}
```

## Configuration

### SMSupportData Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `appName` | `String` | ✅ | Your application name |
| `locale` | `SMSupportLocale` | ✅ | Language preference |
| `tenantId` | `String` | ✅ | Your tenant identifier |

### Available Locales

```dart
SMSupportLocale.english  // English interface
SMSupportLocale.ar       // Arabic interface (RTL support)
```

## Requirements

- Flutter SDK: `>=3.8.1`
- Dart SDK: `>=3.0.0`
- iOS: `>=12.0`
- Android: `minSdkVersion 21`

## Example App

Check out the complete example in the [`example`](./example) directory:

```bash
cd example
flutter run
```

## License

This package is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.

---

**Made with ❤️ by the Unicode Team**