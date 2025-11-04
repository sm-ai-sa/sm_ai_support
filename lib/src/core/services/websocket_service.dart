import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/config/sm_support_config.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Socket.IO service for real-time messaging
class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance => _instance ??= WebSocketService._();

  WebSocketService._();

  IO.Socket? _socket;
  StreamController<SessionMessage>? _messageController;
  StreamController<int>? _unreadSessionsCountController;
  StreamController<Map<String, dynamic>>? _sessionStatsController;
  StreamController<bool>? _ratingRequestController;
  String? _currentChannelName;
  Timer? _pingTimer;
  Timer? _pollingTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;
  bool _usePollingFallback = false;
  String? _tenantId;
  String? _sessionId;
  String? _customerId;
  bool _isConnected = false;

  // Channel names for the new streams
  String? _unreadSessionsCountChannel;
  String? _sessionStatsChannel;

  /// Base Socket.IO URL - Get from SMConfig
  String get _baseUrl => SMConfig.smData.socketBaseUrl;

  /// Get the stream of incoming messages
  Stream<SessionMessage>? get messageStream => _messageController?.stream;

  /// Get the stream of unread sessions count updates
  Stream<int>? get unreadSessionsCountStream => _unreadSessionsCountController?.stream;

  /// Get the stream of session stats updates
  Stream<Map<String, dynamic>>? get sessionStatsStream => _sessionStatsController?.stream;

  /// Get the stream of rating request updates
  Stream<bool>? get ratingRequestStream => _ratingRequestController?.stream;

  /// Check if currently connected (Socket.IO or polling)
  bool get isConnected => _isConnected || _usePollingFallback;

  /// Get current channel name
  String? get currentChannel => _currentChannelName;

  /// Get current unread sessions count channel
  String? get currentUnreadSessionsCountChannel => _unreadSessionsCountChannel;

  /// Get current session stats channel
  String? get currentSessionStatsChannel => _sessionStatsChannel;

  /// Debug method to print current connection status
  void debugConnectionStatus() {
    // smLog('WebSocketService: === CONNECTION DEBUG ===');
    // smLog('WebSocketService: Is Connected: $_isConnected');
    // smLog('WebSocketService: Socket exists: ${_socket != null}');
    // smLog('WebSocketService: Current message channel: $_currentChannelName');
    // smLog('WebSocketService: Current unread count channel: $_unreadSessionsCountChannel');
    // smLog('WebSocketService: Current session stats channel: $_sessionStatsChannel');
    // smLog('WebSocketService: Message controller exists: ${_messageController != null}');
    // smLog('WebSocketService: Unread count controller exists: ${_unreadSessionsCountController != null}');
    // smLog('WebSocketService: Session stats controller exists: ${_sessionStatsController != null}');
    // smLog('WebSocketService: Rating request controller exists: ${_ratingRequestController != null}');
    // smLog('WebSocketService: ================================');
  }

  /// Connect to session (Socket.IO first, fallback to polling)
  Future<void> connectToSession({required String tenantId, required String sessionId, String? customerId}) async {
    // Store connection parameters for potential polling fallback
    _tenantId = tenantId;
    _sessionId = sessionId;
    _customerId = customerId;

    try {
      // Build channel name first
      final customerIdentifier = customerId ?? 'anonymous';
      final channelName = 'message_$tenantId$sessionId$customerIdentifier';

      // If already connected to the same channel, don't reconnect
      if ((isConnected || _usePollingFallback) && _currentChannelName == channelName) {
        // smLog('WebSocketService: Already connected to channel: $channelName');
        return;
      }

      // Close existing connection if any
      await disconnect();

      // smLog('WebSocketService: Connecting to channel: $channelName');

      // Initialize message controller
      _messageController = StreamController<SessionMessage>.broadcast();
      _ratingRequestController = StreamController<bool>.broadcast();
      _currentChannelName = channelName;

      // Try Socket.IO first
      if (!_usePollingFallback) {
        await _attemptSocketIOConnection(channelName);
      } else {
        await _startPollingFallback(channelName);
      }
    } catch (e) {
      // smLog('WebSocketService: Connection failed: $e');

      // If Socket.IO fails, try polling fallback
      if (!_usePollingFallback) {
        // smLog('WebSocketService: Attempting polling fallback...');
        _usePollingFallback = true;
        await _startPollingFallback(_currentChannelName);
      } else {
        await _cleanup();
        rethrow;
      }
    }
  }

  /// Attempt Socket.IO connection
  Future<void> _attemptSocketIOConnection(String channelName) async {
    // smLog('WebSocketService: Connecting to Socket.IO server: $_baseUrl/customer/room');

    // Create Socket.IO client with proper configuration
    _socket = IO.io(
      '$_baseUrl/customer/room',
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(3)
          .setReconnectionDelay(1000)
          .setTimeout(20000)
          .setPath('/socket.io/')
          .build(),
    );

    // Set up event listeners
    _setupSocketListeners(channelName);

    // Connect to the server
    _socket!.connect();

    // Wait for connection to establish
    await _waitForConnection();

    // smLog('WebSocketService: Connected successfully to Socket.IO server');
  }

  /// Setup Socket.IO event listeners
  void _setupSocketListeners(String channelName) {
    if (_socket == null) return;

    // Connection established
    _socket!.onConnect((_) {
      smLog('WebSocketService: Socket.IO connected');
      _isConnected = true;
      _reconnectAttempts = 0;

      // Subscribe to the specific channel
      _joinChannel(channelName);

      // Start heartbeat
      _startHeartbeat();
    });

    // Connection error
    _socket!.onConnectError((error) {
      smLog('WebSocketService: Socket.IO connection error: $error');
      _isConnected = false;
      _onError(error);
    });

    // Disconnection
    _socket!.onDisconnect((reason) {
      smLog('WebSocketService: Socket.IO disconnected: $reason');
      _isConnected = false;
      _onConnectionClosed();
    });

    // Listen for new messages on the subscribed channel
    _socket!.on('new_message', _onNewMessageReceived);

    // Listen for messages on the specific channel name
    _socket!.on(channelName, _onMessageReceived);

    // Listen for general message events
    _socket!.on('message', _onMessageReceived);

    // Listen for subscription confirmation
    _socket!.on('subscribed', (data) {
      smLog('WebSocketService: Successfully subscribed to channel: $data');
    });

    // Listen for subscription errors
    _socket!.on('subscription_error', (error) {
      smLog('WebSocketService: Subscription error: $error');
    });

    // Listen for typing indicators
    _socket!.on('typing', (data) {
      smLog('WebSocketService: Typing indicator: $data');
    });

    // Listen for message read status
    _socket!.on('message_read', (data) {
      smLog('WebSocketService: Message read: $data');
    });

    // Generic error handler
    _socket!.onError((error) {
      smLog('WebSocketService: Socket.IO error: $error');
      _messageController?.addError(error);
    });

    // Catch any channel-specific events
    _socket!.onAny((event, data) {
      // Only log non-system events for debugging
      if (!['connect', 'disconnect', 'ping', 'pong'].contains(event)) {
        smLog('WebSocketService: Received event: "$event"');
      }

      // Check if this event is our channel and contains message data
      if (event == channelName || event.startsWith('message_')) {
        smLog('WebSocketService: Processing channel event: "$event"');
        _onMessageReceived(data);
      }
    });
  }

  /// Wait for Socket.IO connection to establish
  Future<void> _waitForConnection() async {
    int attempts = 0;
    const maxAttempts = 20; // 10 seconds total

    while (!_isConnected && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    if (!_isConnected) {
      throw Exception('Socket.IO connection timeout after ${maxAttempts * 500}ms');
    }
  }

  /// Handle new message events from Socket.IO
  void _onNewMessageReceived(dynamic data) {
    try {
      smLog('WebSocketService: 📨 Received new_message event: $data');

      if (data is Map<String, dynamic>) {
        // Check if it's wrapped in a data field
        final messageData = data.containsKey('data') ? data['data'] : data;

        if (messageData is Map<String, dynamic>) {
          try {
            final message = SessionMessage.fromJson(messageData);
            _messageController?.add(message);
            smLog('WebSocketService: ✅ NEW MESSAGE RECEIVED AND EMITTED: ${message.id}');
            smLog('WebSocketService: Message content: ${message.content}');
            smLog('WebSocketService: Sender type: ${message.senderType}');
          } catch (parseError) {
            smLog('WebSocketService: ❌ Error parsing SessionMessage: $parseError');
            smLog('WebSocketService: Raw message data: $messageData');
          }
        }
      }
    } catch (e) {
      smLog('WebSocketService: Error handling new_message event: $e');
      smLog('WebSocketService: Raw data: $data');
      _messageController?.addError(e);
    }
  }

  /// Handle general message events (fallback)
  void _onMessageReceived(dynamic data) {
    try {
      smLog('WebSocketService: 📨 Received message event: $data');

      if (data is Map<String, dynamic>) {
        _handleDirectMessage(data);
      } else if (data is String) {
        try {
          final Map<String, dynamic> jsonData = json.decode(data);
          _handleDirectMessage(jsonData);
        } catch (e) {
          smLog('WebSocketService: ❌ Could not parse message as JSON: $data');
        }
      }
    } catch (e) {
      smLog('WebSocketService: Error parsing message: $e');
      smLog('WebSocketService: Raw data: $data');
      _messageController?.addError(e);
    }
  }

  /// Handle direct messages (fallback)
  void _handleDirectMessage(Map<String, dynamic> jsonData) {
    try {
      smLog('WebSocketService: Handling direct message: $jsonData');

      // Check for event type
      final eventType = jsonData['type'] as String?;

      // Handle new_message format: {"type": "new_message", "data": {...}}
      if (eventType == 'new_message' && jsonData['data'] != null) {
        final messageData = jsonData['data'] as Map<String, dynamic>;
        smLog('WebSocketService: Processing new_message from Admin: $messageData');

        try {
          final message = SessionMessage.fromJson(messageData);
          _messageController?.add(message);
          smLog('WebSocketService: ✅ ADMIN MESSAGE RECEIVED AND EMITTED: ${message.id}');
          smLog('WebSocketService: Message content: ${message.content}');
          smLog('WebSocketService: Sender type: ${message.senderType}');
          return;
        } catch (parseError) {
          smLog('WebSocketService: ❌ Error parsing SessionMessage: $parseError');
          smLog('WebSocketService: Raw message data: $messageData');
        }
      }

      // Handle rating_request format: {"type": "rating_request", "data": bool}
      if (eventType == 'rating_request') {
        smLog('WebSocketService: Processing rating_request: $jsonData');

        try {
          // The data should be a boolean indicating if rating is required
          final isRatingRequired = true;
          _ratingRequestController?.add(isRatingRequired);
          smLog('WebSocketService: ✅ RATING REQUEST RECEIVED AND EMITTED: $isRatingRequired');
          return;
        } catch (parseError) {
          smLog('WebSocketService: ❌ Error parsing rating request: $parseError');
          smLog('WebSocketService: Raw rating data: $jsonData');
        }
      }

      // Check if it's a direct SessionMessage format
      if (jsonData.containsKey('id') && jsonData.containsKey('content')) {
        try {
          final message = SessionMessage.fromJson(jsonData);
          _messageController?.add(message);
          smLog('WebSocketService: Direct message parsed and emitted: ${message.id}');
          return;
        } catch (parseError) {
          smLog('WebSocketService: Error parsing direct message: $parseError');
        }
      }

      smLog('WebSocketService: ❌ Unknown message format: $eventType');
      smLog('WebSocketService: Full message: $jsonData');
    } catch (e) {
      smLog('WebSocketService: ❌ Error handling direct message: $e');
      smLog('WebSocketService: Raw JSON data: $jsonData');
    }
  }

  /// Handle Socket.IO errors
  void _onError(dynamic error) {
    smLog('WebSocketService: Connection error: $error');

    // Provide more specific error information
    if (error.toString().contains('502')) {
      smLog('WebSocketService: Server returned 502 - Check Socket.IO endpoint configuration');
    } else if (error.toString().contains('timeout')) {
      smLog('WebSocketService: Connection timeout - Check server availability');
    } else if (error.toString().contains('Connection refused')) {
      smLog('WebSocketService: Connection refused - Check server availability');
    }

    _messageController?.addError(error);
  }

  /// Handle connection closed
  void _onConnectionClosed() {
    smLog('WebSocketService: Connection closed for channel: $_currentChannelName');
    smLog('WebSocketService: Reconnect attempts so far: $_reconnectAttempts/$_maxReconnectAttempts');
    smLog('WebSocketService: Using polling fallback: $_usePollingFallback');

    _isConnected = false;

    // Socket.IO has built-in reconnection, but we can add our own logic here if needed
    if (_currentChannelName != null && _reconnectAttempts < _maxReconnectAttempts && !_usePollingFallback) {
      smLog('WebSocketService: Socket.IO will handle reconnection...');
      _reconnectAttempts++;
    } else if (!_usePollingFallback) {
      // Switch to polling fallback
      smLog('WebSocketService: Max reconnection attempts reached, switching to polling fallback...');
      _usePollingFallback = true;
      if (_currentChannelName != null) {
        _startPollingFallback(_currentChannelName);
      }
    } else {
      smLog('WebSocketService: Already using polling fallback, cleaning up...');
      _cleanup();
    }
  }

  /// Subscribe to a specific channel using Socket.IO events
  void _joinChannel(String channelName) {
    try {
      smLog('WebSocketService: Joining Socket.IO channel: $channelName');
      smLog('WebSocketService: 🔍 CHANNEL NAME BEING SUBSCRIBED TO: $channelName');
      smLog('WebSocketService: Channel length: ${channelName.length}');

      if (_socket != null && _isConnected) {
        // Use Socket.IO event to subscribe to channel
        _socket!.emit('subscribe', {'channel': channelName});

        smLog('WebSocketService: 📤 Sent Socket.IO subscribe event for channel: $channelName');
      }
    } catch (e) {
      smLog('WebSocketService: Error subscribing to channel: $e');
    }
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _pingTimer?.cancel();

    // Send ping every 30 seconds (Socket.IO handles this automatically, but we can add custom logic)
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_socket != null && _isConnected) {
        // Send custom ping event
        _socket!.emit('ping');
        smLog('WebSocketService: Heartbeat ping sent');
      } else {
        timer.cancel();
      }
    });

    smLog('WebSocketService: Heartbeat started');
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = null;
    smLog('WebSocketService: Heartbeat stopped');
  }

  /// Subscribe to additional channels/events
  void subscribeToChannel(String channelName) {
    if (_socket != null && _isConnected) {
      try {
        _socket!.emit('subscribe', {'channel': channelName});
        smLog('WebSocketService: Subscribed to channel: $channelName');
      } catch (e) {
        smLog('WebSocketService: Error subscribing to channel: $e');
      }
    } else {
      smLog('WebSocketService: Cannot subscribe - not connected');
    }
  }

  /// Send a custom action message
  void sendAction(String action, Map<String, dynamic> data) {
    if (_socket != null && _isConnected) {
      try {
        _socket!.emit(action, data);
        smLog('WebSocketService: Sent action: $action');
      } catch (e) {
        smLog('WebSocketService: Error sending action: $e');
      }
    } else {
      smLog('WebSocketService: Cannot send action - not connected');
    }
  }

  /// Send a message through Socket.IO (for typing indicators, etc.)
  void sendMessage(String event, Map<String, dynamic> message) {
    if (_socket != null && _isConnected) {
      try {
        _socket!.emit(event, message);
        smLog('WebSocketService: Message sent on event: $event');
      } catch (e) {
        smLog('WebSocketService: Error sending message: $e');
      }
    } else {
      smLog('WebSocketService: Cannot send message - not connected');
    }
  }

  /// Send typing indicator
  void sendTypingIndicator({required bool isTyping}) {
    if (_isConnected) {
      sendMessage('typing', {
        'isTyping': isTyping,
        'channel': _currentChannelName,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Connect to unread sessions count stream
  /// This stream provides real-time updates for the number of unread sessions
  Future<void> connectToUnreadSessionsCountStream({required String tenantId, required String customerId}) async {
    try {
      // Connect to WebSocket if not already connected
      if (!_isConnected) {
        await _connectToWebSocketServer();
      }

      final channelName = 'unread_sessions_count_$tenantId$customerId';

      // Check if already connected to this channel
      if (_unreadSessionsCountChannel == channelName) {
        smLog('WebSocketService: Already connected to unread sessions count stream: $channelName');
        return;
      }

      // Disconnect from previous channel if any
      if (_unreadSessionsCountChannel != null) {
        _socket?.off(_unreadSessionsCountChannel!);
      }

      _unreadSessionsCountChannel = channelName;

      smLog('WebSocketService: Connecting to unread sessions count stream: $channelName');

      // Initialize the stream controller if not already done
      _unreadSessionsCountController ??= StreamController<int>.broadcast();

      // Subscribe to the channel
      subscribeToChannel(channelName);

      // Listen for unread count updates
      _socket?.on(channelName, _onUnreadSessionsCountReceived);

      smLog('WebSocketService: Successfully connected to unread sessions count stream');
    } catch (e) {
      smLog('WebSocketService: Error connecting to unread sessions count stream: $e');
      rethrow;
    }
  }

  /// Connect to session stats stream
  /// This stream provides real-time updates for session statistics in my sessions page
  Future<void> connectToSessionStatsStream({required String tenantId, required String customerId}) async {
    try {
      // Connect to WebSocket if not already connected
      if (!_isConnected) {
        await _connectToWebSocketServer();
      }

      final channelName = 'session_stats_$tenantId$customerId';

      // Check if already connected to this channel
      if (_sessionStatsChannel == channelName) {
        smLog('WebSocketService: Already connected to session stats stream: $channelName');
        return;
      }

      // Disconnect from previous channel if any
      if (_sessionStatsChannel != null) {
        _socket?.off(_sessionStatsChannel!);
      }

      _sessionStatsChannel = channelName;

      smLog('WebSocketService: Connecting to session stats stream: $channelName');

      // Initialize the stream controller if not already done
      _sessionStatsController ??= StreamController<Map<String, dynamic>>.broadcast();

      // Subscribe to the channel
      subscribeToChannel(channelName);

      // Listen for session stats updates
      _socket?.on(channelName, _onSessionStatsReceived);

      smLog('WebSocketService: Successfully connected to session stats stream');
    } catch (e) {
      smLog('WebSocketService: Error connecting to session stats stream: $e');
      rethrow;
    }
  }

  /// Disconnect from unread sessions count stream
  void disconnectFromUnreadSessionsCountStream() {
    if (_unreadSessionsCountChannel != null) {
      smLog('WebSocketService: Disconnecting from unread sessions count stream: $_unreadSessionsCountChannel');
      _socket?.off(_unreadSessionsCountChannel!);
      _unreadSessionsCountChannel = null;
    } else {
      smLog('WebSocketService: No unread sessions count stream to disconnect');
    }
  }

  /// Disconnect from session stats stream
  void disconnectFromSessionStatsStream() {
    if (_sessionStatsChannel != null) {
      smLog('WebSocketService: Disconnecting from session stats stream: $_sessionStatsChannel');
      _socket?.off(_sessionStatsChannel!);
      _sessionStatsChannel = null;
    } else {
      smLog('WebSocketService: No session stats stream to disconnect');
    }
  }

  /// Helper method to connect to WebSocket server without a specific session channel
  Future<void> _connectToWebSocketServer() async {
    if (_isConnected) return;

    try {
      smLog('WebSocketService: Connecting to Socket.IO server for additional streams');

      // Create Socket.IO client with proper configuration
      _socket = IO.io(
        '$_baseUrl/customer/room',
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(3)
            .setReconnectionDelay(1000)
            .setTimeout(20000)
            .setPath('/socket.io/')
            .build(),
      );

      // Set up basic connection listeners
      _setupBasicSocketListeners();

      // Connect to the server
      _socket!.connect();

      // Wait for connection to establish
      await _waitForConnection();

      smLog('WebSocketService: Connected successfully to Socket.IO server for additional streams');
    } catch (e) {
      smLog('WebSocketService: Error connecting to Socket.IO server: $e');
      rethrow;
    }
  }

  /// Setup basic Socket.IO event listeners for additional streams
  void _setupBasicSocketListeners() {
    if (_socket == null) return;

    // Connection established
    _socket!.onConnect((_) {
      smLog('WebSocketService: Socket.IO connected for additional streams');
      _isConnected = true;
      _reconnectAttempts = 0;

      // Start heartbeat
      _startHeartbeat();
    });

    // Connection error
    _socket!.onConnectError((error) {
      smLog('WebSocketService: Socket.IO connection error for additional streams: $error');
      _isConnected = false;
    });

    // Disconnection
    _socket!.onDisconnect((reason) {
      smLog('WebSocketService: Socket.IO disconnected for additional streams: $reason');
      _isConnected = false;
    });
  }

  /// Handle unread sessions count updates
  void _onUnreadSessionsCountReceived(dynamic data) {
    try {
      smLog('WebSocketService: 📊 Received unread sessions count update: $data');

      int count;
      if (data is int) {
        count = data;
      } else if (data is String) {
        count = int.tryParse(data) ?? 0;
      } else {
        smLog('WebSocketService: ❌ Invalid unread sessions count format: $data');
        return;
      }

      _unreadSessionsCountController?.add(count);
      smLog('WebSocketService: ✅ Unread sessions count updated: $count');
    } catch (e) {
      smLog('WebSocketService: Error handling unread sessions count: $e');
      _unreadSessionsCountController?.addError(e);
    }
  }

  /// Handle session stats updates
  void _onSessionStatsReceived(dynamic data) {
    try {
      smLog('WebSocketService: 📊 Received session stats update: $data');

      if (data is Map<String, dynamic>) {
        _sessionStatsController?.add(data);
        smLog('WebSocketService: ✅ Session stats updated successfully');
        smLog('WebSocketService: Session stats type: ${data['type']}');

        if (data['data'] != null) {
          smLog(
            'WebSocketService: Session stats data count: ${data['data'] is List ? (data['data'] as List).length : 1}',
          );
        }
      } else {
        smLog('WebSocketService: ❌ Invalid session stats format: $data');
      }
    } catch (e) {
      smLog('WebSocketService: Error handling session stats: $e');
      _sessionStatsController?.addError(e);
    }
  }

  /// Disconnect from Socket.IO
  Future<void> disconnect() async {
    smLog('WebSocketService: Disconnecting from channel: $_currentChannelName');

    // Disconnect from additional streams
    disconnectFromUnreadSessionsCountStream();
    disconnectFromSessionStatsStream();

    await _cleanup();
  }

  /// Start polling fallback mechanism
  Future<void> _startPollingFallback(String? channelName) async {
    try {
      smLog('WebSocketService: Starting polling fallback for channel: $channelName');

      _usePollingFallback = true;
      _stopPollingTimer();

      // Poll every 3 seconds for new messages
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        await _pollForMessages();
      });

      smLog('WebSocketService: Polling fallback started successfully');
    } catch (e) {
      smLog('WebSocketService: Error starting polling fallback: $e');
      rethrow;
    }
  }

  /// Poll for new messages using HTTP requests
  Future<void> _pollForMessages() async {
    try {
      if (_tenantId == null || _sessionId == null) return;

      smLog(
        'WebSocketService: Polling for messages for tenant: $_tenantId, session: $_sessionId, customer: ${_customerId ?? "anonymous"}',
      );

      // TODO: Implement actual polling by calling your messages API
      // You would implement this to call your actual messages API:
      // 1. Get latest messages from your REST API
      // 2. Compare with last received message
      // 3. If new messages found, emit them via _messageController

      // Example implementation:
      // final response = await yourApiService.getSessionMessages(
      //   tenantId: _tenantId!,
      //   sessionId: _sessionId!,
      //   since: lastPolledTimestamp,
      // );
      //
      // for (final messageData in response.newMessages) {
      //   final message = SessionMessage.fromJson(messageData);
      //   _messageController?.add(message);
      // }
    } catch (e) {
      smLog('WebSocketService: Error polling for messages: $e');
    }
  }

  /// Stop polling timer
  void _stopPollingTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    smLog('WebSocketService: Polling timer stopped');
  }

  /// Clean up resources
  Future<void> _cleanup() async {
    try {
      // Stop heartbeat and polling
      _stopHeartbeat();
      _stopPollingTimer();

      // Disconnect Socket.IO
      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
      }

      // Close all stream controllers
      await _messageController?.close();
      _messageController = null;

      await _unreadSessionsCountController?.close();
      _unreadSessionsCountController = null;

      await _sessionStatsController?.close();
      _sessionStatsController = null;

      await _ratingRequestController?.close();
      _ratingRequestController = null;

      // Clear state
      _currentChannelName = null;
      _unreadSessionsCountChannel = null;
      _sessionStatsChannel = null;
      _usePollingFallback = false;
      _reconnectAttempts = 0;
      _isConnected = false;

      smLog('WebSocketService: Cleanup completed');
    } catch (e) {
      smLog('WebSocketService: Error during cleanup: $e');
    }
  }

  /// Dispose of the service (call this when app is closing)
  Future<void> dispose() async {
    await disconnect();
    _instance = null;
  }
}
