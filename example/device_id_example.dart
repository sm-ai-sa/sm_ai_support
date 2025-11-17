// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';

/// Example demonstrating Device ID functionality
///
/// This example shows:
/// 1. How device ID is automatically initialized
/// 2. How to access device ID for debugging
/// 3. How to verify device ID persistence
/// 4. Testing methods (clear, regenerate)
///
/// The device ID is automatically included in all API requests and Socket.IO
/// connections. You don't need to manually add it anywhere.

void main() {
  runApp(const DeviceIdExampleApp());
}

class DeviceIdExampleApp extends StatelessWidget {
  const DeviceIdExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device ID Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DeviceIdDemoPage(),
    );
  }
}

class DeviceIdDemoPage extends StatefulWidget {
  const DeviceIdDemoPage({super.key});

  @override
  State<DeviceIdDemoPage> createState() => _DeviceIdDemoPageState();
}

class _DeviceIdDemoPageState extends State<DeviceIdDemoPage> {
  String? _deviceId;
  bool _isInitialized = false;
  bool _isUsingSecureStorage = false;
  Map<String, dynamic>? _debugInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeDeviceId();
  }

  /// Initialize device ID (normally done automatically by SMSupport)
  Future<void> _initializeDeviceId() async {
    setState(() => _isLoading = true);

    try {
      // In production, this is called automatically during SMSupport initialization
      // You don't need to call this manually
      final deviceId = await DeviceIdManager.instance.initialize();

      final isUsingSecure = await DeviceIdManager.instance.isUsingSecureStorage();
      final debugInfo = DeviceIdManager.instance.getDebugInfo();

      setState(() {
        _deviceId = deviceId;
        _isInitialized = DeviceIdManager.instance.isInitialized();
        _isUsingSecureStorage = isUsingSecure;
        _debugInfo = debugInfo;
        _isLoading = false;
      });

      print('✅ Device ID initialized: ${deviceId.substring(0, 8)}...');
    } catch (e) {
      print('❌ Error initializing device ID: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Refresh device ID info
  Future<void> _refreshDeviceIdInfo() async {
    setState(() => _isLoading = true);

    try {
      final deviceId = await DeviceIdManager.instance.getDeviceId();
      final isUsingSecure = await DeviceIdManager.instance.isUsingSecureStorage();
      final debugInfo = DeviceIdManager.instance.getDebugInfo();

      setState(() {
        _deviceId = deviceId;
        _isInitialized = DeviceIdManager.instance.isInitialized();
        _isUsingSecureStorage = isUsingSecure;
        _debugInfo = debugInfo;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device ID info refreshed')),
      );
    } catch (e) {
      print('❌ Error refreshing device ID: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Clear device ID (for testing only)
  Future<void> _clearDeviceId() async {
    setState(() => _isLoading = true);

    try {
      await DeviceIdManager.instance.clear();

      setState(() {
        _deviceId = null;
        _isInitialized = false;
        _debugInfo = DeviceIdManager.instance.getDebugInfo();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Device ID cleared (testing only)'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      print('🗑️ Device ID cleared');
    } catch (e) {
      print('❌ Error clearing device ID: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Regenerate device ID (for testing only)
  Future<void> _regenerateDeviceId() async {
    setState(() => _isLoading = true);

    try {
      final newDeviceId = await DeviceIdManager.instance.regenerate();

      final isUsingSecure = await DeviceIdManager.instance.isUsingSecureStorage();
      final debugInfo = DeviceIdManager.instance.getDebugInfo();

      setState(() {
        _deviceId = newDeviceId;
        _isInitialized = true;
        _isUsingSecureStorage = isUsingSecure;
        _debugInfo = debugInfo;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔄 Device ID regenerated (testing only)'),
            backgroundColor: Colors.blue,
          ),
        );
      }

      print('🔄 New device ID: ${newDeviceId.substring(0, 8)}...');
    } catch (e) {
      print('❌ Error regenerating device ID: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Get device ID synchronously
  void _getDeviceIdSync() {
    final deviceId = DeviceIdManager.instance.getDeviceIdSync();

    if (deviceId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync device ID: ${deviceId.substring(0, 8)}...'),
        ),
      );
      print('✅ Sync device ID: $deviceId');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device ID not initialized'),
          backgroundColor: Colors.red,
        ),
      );
      print('❌ Device ID not initialized');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device ID Demo'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDeviceIdInfo,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isInitialized ? Icons.check_circle : Icons.error,
                            color: _isInitialized ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Device ID Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Initialized',
                        _isInitialized ? 'Yes' : 'No',
                        _isInitialized ? Colors.green : Colors.red,
                      ),
                      _buildInfoRow(
                        'Storage Type',
                        _isUsingSecureStorage ? 'Secure Storage' : 'SharedPreferences',
                        _isUsingSecureStorage ? Colors.green : Colors.orange,
                      ),
                      if (_deviceId != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow('Device ID (Preview)', '${_deviceId!.substring(0, 8)}...', Colors.blue),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Debug Info Card
              if (_debugInfo != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Debug Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        ..._debugInfo!.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  entry.value.toString(),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // How It Works Card
              Card(
                color: Colors.blue.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'How It Works',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        '• Device ID is automatically initialized when you call SMSupport.instance.setConfig()\n\n'
                        '• All HTTP requests include the header: device-id: <uuid>\n\n'
                        '• All Socket.IO connections include device ID in auth headers\n\n'
                        '• Device ID persists across app launches (stored securely)\n\n'
                        '• No manual intervention required - fully automatic!',
                        style: TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              const Text(
                'Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _refreshDeviceIdInfo,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Device ID Info'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _getDeviceIdSync,
                icon: const Icon(Icons.flash_on),
                label: const Text('Get Device ID (Sync)'),
              ),
              const SizedBox(height: 24),

              // Testing Actions
              const Text(
                'Testing Actions (⚠️ Use with caution)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _clearDeviceId,
                icon: const Icon(Icons.delete_outline, color: Colors.orange),
                label: const Text('Clear Device ID'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _regenerateDeviceId,
                icon: const Icon(Icons.autorenew, color: Colors.blue),
                label: const Text('Regenerate Device ID'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
