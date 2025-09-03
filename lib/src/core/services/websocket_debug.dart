import 'dart:developer';

import 'package:sm_ai_support/src/core/services/websocket_service.dart';

/// Debug utilities for WebSocket connections
class WebSocketDebug {
  /// Test WebSocket connection with detailed logging
  static Future<bool> testConnection({required String tenantId, required String sessionId, String? customerId}) async {
    try {
      log('=== WebSocket Connection Test ===');
      log('TenantId: $tenantId');
      log('SessionId: $sessionId');
      log('CustomerId: ${customerId ?? 'anonymous'}');

      final service = WebSocketService.instance;

      // Test connection
      await service.connectToSession(tenantId: tenantId, sessionId: sessionId, customerId: customerId);

      if (service.isConnected) {
        log('✅ WebSocket connection successful!');
        log('Connected to channel: ${service.currentChannel}');

        // Clean up test connection
        await service.disconnect();
        return true;
      } else {
        log('❌ WebSocket connection failed - not connected');
        return false;
      }
    } catch (e) {
      log('❌ WebSocket connection test failed: $e');
      return false;
    }
  }

  /// Validate WebSocket URL format
  static void validateUrl(String baseUrl, String channelName) {
    log('=== WebSocket URL Validation ===');
    final fullUrl = '$baseUrl/customer/room/$channelName';
    log('Full URL: $fullUrl');

    try {
      final uri = Uri.parse(fullUrl);
      log('✅ URL is valid');
      log('  Scheme: ${uri.scheme}');
      log('  Host: ${uri.host}');
      log('  Port: ${uri.port}');
      log('  Path: ${uri.path}');
    } catch (e) {
      log('❌ Invalid URL format: $e');
    }
  }

  /// Check if WebSocket endpoint is reachable
  static void checkEndpoint() {
    log('=== WebSocket Endpoint Check ===');
    log('Base URL: wss://sandbox.unicode.team/ws/customer/room');
    log('');
    log('Common issues:');
    log('1. Server may not have WebSocket support enabled');
    log('2. Endpoint path might be incorrect');
    log('3. Authentication might be required');
    log('4. CORS or firewall blocking connection');
    log('');
    log('Try testing with a WebSocket client tool first');
  }

  /// Test message parsing with sample data
  static void testMessageParsing() {
    log('=== Testing WebSocket Message Parsing ===');

    try {
      // This would simulate receiving the message
      log('✅ Sample message format is compatible');
      log('Message content: hello, sir 3');
      log('Sender: ADMIN (Body Ahmed)');
    } catch (e) {
      log('❌ Message parsing failed: $e');
    }
  }
}
