# SM AI Support - Easy Integration Guide

This guide shows the **simplest ways** to integrate SM AI Support into your Flutter app for maximum user adoption.

## 🚀 Quick Start (Recommended)

### Method 1: Simple Navigation (Most Popular)

```dart
import 'package:sm_ai_support/sm_ai_support.dart';

// In your widget (e.g., FloatingActionButton, AppBar action, etc.)
ElevatedButton(
  onPressed: () {
    SMSupport.show(
      context: context,
      supportData: SMSupportData(
        appName: "My Awesome App",
        locale: SMSupportLocale.english,
        tenantId: "your_tenant_id", // Required: Your tenant identifier
      ),
    );
  },
  child: Text('Get Support'),
)
```

### Method 2: Modal Overlay (Alternative)

```dart
// For when you want support to appear as an overlay
FloatingActionButton(
  onPressed: () {
    SMSupport.showModal(
      context: context,
      supportData: yourSupportData,
      isDismissible: true,
      enableDrag: true,
    );
  },
  child: Icon(Icons.help),
)
```

## 🏗️ Integration Patterns

### Pattern 1: Support Button in AppBar

```dart
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
        actions: [
          IconButton(
            icon: Icon(Icons.support),
            onPressed: () => _openSupport(context),
          ),
        ],
      ),
      body: YourContent(),
    );
  }

  void _openSupport(BuildContext context) {
    SMSupport.show(
      context: context,
      supportData: _createSupportData(),
    );
  }
}
```

### Pattern 2: Help & Support Menu Item

```dart
ListTile(
  leading: Icon(Icons.help_outline),
  title: Text('Help & Support'),
  onTap: () {
    SMSupport.show(
      context: context,
      supportData: yourSupportData,
      useFullscreenDialog: true, // Slides up from bottom
    );
  },
)
```

### Pattern 3: Floating Support Button

```dart
Scaffold(
  body: YourContent(),
  floatingActionButton: FloatingActionButton(
    onPressed: () => SMSupport.showModal(
      context: context,
      supportData: yourSupportData,
    ),
    child: Icon(Icons.chat),
    tooltip: 'Get Support',
  ),
)
```

## 📱 Complete Example App

```dart
import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App with Support',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
        actions: [
          IconButton(
            icon: Icon(Icons.support_agent),
            onPressed: () => _showSupport(context),
            tooltip: 'Customer Support',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to My App!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showSupport(context),
              child: Text('Need Help?'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupport(BuildContext context) {
    SMSupport.show(
      context: context,
      supportData: SMSupportData(
        appName: "My Awesome App",
        locale: SMSupportLocale.english,
        tenantId: "unicode", // Your tenant ID
      ),
    );
  }
}
```

## 🏢 Tenant Configuration System

The package now uses a **tenant-based configuration system**. Here's how it works:

### How It Works
1. **You provide**: `appName`, `locale`, and `tenantId`
2. **Package fetches**: colors, logos, working hours, and categories from the API
3. **If API fails**: Uses your fallback values or sensible defaults

### Required vs Optional Fields

**Required Fields:**
- `appName` - Your application name
- `locale` - Language/region (english or arabic)  
- `tenantId` - Your unique tenant identifier

**All other configuration** (colors, logos, working hours, categories) **is fetched from the API** based on your `tenantId`.

### API Integration
The package automatically calls:
```
GET /tenantI?id=your_tenant_id
```

Expected response:
```json
{
  "tenant": {
    "tenantId": "unicode",
    "color": "#1976D2",
    "name": "Unicode",
    "logo": "https://example.com/logo.png"
  }
}
```

## 🎨 Customization Options

### Tenant ID Setup
```dart
SMSupportData(
  appName: "My App",
  locale: SMSupportLocale.english,
  tenantId: "your_company_id", // Get this from your Unicode dashboard
)
```

### Brand Colors
Brand colors are automatically fetched from the tenant API based on your `tenantId`. No manual configuration needed.

### Localization
```dart
SMSupportData(
  // ... other fields
  locale: SMSupportLocale.arabic, // or SMSupportLocale.english
)
```

### Presentation Style
```dart
// Full screen (recommended for main support access)
SMSupport.show(
  context: context,
  supportData: data,
  useFullscreenDialog: true,
);

// Modal overlay (good for quick help)
SMSupport.showModal(
  context: context,
  supportData: data,
  isDismissible: true,
);
```

## ✅ Why Use This Approach?

1. **One-Line Integration** - Just call `SMSupport.show()`
2. **No Navigation Complexity** - Works with any navigation setup
3. **Zero Conflicts** - Uses isolated MaterialApp internally
4. **Consistent UI** - Same experience across all apps using the package
5. **Future Proof** - Package updates won't break your integration
6. **Easy Testing** - Clear separation between your app and support module

## 🚫 What You DON'T Need to Worry About

- ❌ Navigation routes configuration
- ❌ Theme conflicts
- ❌ State management setup
- ❌ Dependency injection
- ❌ Localization configuration
- ❌ Complex widget tree management

## 📞 Advanced Usage

For advanced customization or if you need more control, you can still use the traditional approach:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => SMSupport(
      parentContext: context,
      SMSupportData: yourSupportData,
    ),
  ),
);
```

But for 99% of use cases, the simplified `SMSupport.show()` method is recommended!
