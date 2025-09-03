# Socket.IO Streaming Documentation

## Overview

The SM AI Support package now includes comprehensive real-time Socket.IO streaming functionality for instant message delivery, unread session counts, and session statistics. This feature ensures that admin responses, session updates, and unread counts are received immediately without the need for polling, providing a seamless chat experience.

## Architecture

### Components

1. **WebSocketService** - Core service managing Socket.IO connections for multiple stream types
2. **SingleSessionCubit** - Enhanced to handle real-time message streams  
3. **SMSupportCubit** - Manages unread session counts and session statistics streams
4. **ChatPage** - Integrates message streaming lifecycle management
5. **SMSupportCategoriesBs** - Integrates unread sessions count streaming
6. **MySessions** - Integrates session statistics streaming

## Socket.IO Service

### Connection Details

- **Base URL**: `wss://sandbox.unicode.team/ws/customer/room`
- **Connection Method**: Socket.IO client with automatic WebSocket/polling fallback
- **Channel Format**: `message_[tenantId][sessionId][customerIdentifier]`
- **Protocol**: Socket.IO with event-based communication

### Connection Flow

1. Connect to `wss://sandbox.unicode.team/ws/customer/room` using Socket.IO client
2. Send subscribe event: `socket.emit('subscribe', {'channel': 'channelName'})`
3. Listen for incoming events on the subscribed channel

### Channel Naming Convention

The WebSocket channel name follows this pattern:
```
message_[tenantId][sessionId][customerIdentifier]
```

Where:
- `tenantId`: The current tenant's ID
- `sessionId`: The chat session ID
- `customerIdentifier`: Customer ID if authenticated, otherwise "anonymous"

### Example Channel Names and Connection

```
Channel: message_tenant123session456customer789    (Authenticated user)
Connection: wss://sandbox.unicode.team/ws/customer/room (Socket.IO)
Subscribe Event: socket.emit('subscribe', {'channel': 'message_tenant123session456customer789'})

Channel: message_tenant123session456anonymous      (Anonymous user)  
Connection: wss://sandbox.unicode.team/ws/customer/room (Socket.IO)
Subscribe Event: socket.emit('subscribe', {'channel': 'message_tenant123session456anonymous'})
```

### Socket.IO Message Format

The server sends messages in this wrapped format:

```json
{
    "type": "new_message",
    "data": {
        "createdAt": "2025-08-20T15:51:02.783Z",
        "updatedAt": "2025-08-20T15:51:02.784Z",
        "isRead": false,
        "isFailed": false,
        "id": "0198c82d-357f-706f-912e-3fb17ece2758",
        "externalId": "0198c82d-357f-706f-912e-3fb17ece2758",
        "sessionId": "0198c82a-36e7-77ed-ac06-8b43714c4dcb",
        "tenantId": 1,
        "senderId": "0197f511-81d5-77cc-8ff7-f9749180c3e6",
        "content": "hello, sir 3",
        "contentType": "TEXT",
        "isDelivered": true,
        "senderType": "ADMIN",
        "reply": null,
        "deletedAt": null,
        "admin": {
            "id": "0197f511-81d5-77cc-8ff7-f9749180c3e6",
            "firstName": "Body",
            "lastName": "Ahmed"
        }
    }
}
```

#### Supported Socket.IO Events

- `new_message`: New message received from admin
- `typing`: Typing indicator (implementation available)
- `message_read`: Message read status update (future implementation)
- `subscribe`: Subscribe to a specific channel
- `subscribed`: Confirmation of successful subscription
- `subscription_error`: Error during subscription

## Additional WebSocket Streams

The package now supports multiple WebSocket streams for different real-time features:

### 1. Unread Sessions Count Stream

**Purpose**: Real-time updates for the number of unread sessions in SMSupportCategoriesBs

**Channel Format**: `unread_sessions_count_[tenantId][customerId]`

**Data Format**: Simple integer representing the unread count
```
5
```

**Usage**: 
- **When**: Active only in SMSupportCategoriesBs 
- **Lifecycle**: Started when categories screen opens, stopped when screen closes
- **Authentication**: Requires authenticated user

**Example Channel Names**:
```
unread_sessions_count_tenant123customer789
```

### 2. Session Statistics Stream

**Purpose**: Real-time updates for session metadata in MySessions page

**Channel Format**: `session_stats_[tenantId][customerId]`

**Data Format**: JSON with session updates
```json
{
    "type": "new_message",
    "data": [
        {
            "id": "0198cc34-577f-71a4-913a-4459563faf43",
            "category": {
                "id": 2,
                "nameEn": "Service Issues",
                "nameAr": "مشاكل الخدمات",
                "icon": "folder-close"
            },
            "metadata": {
                "customerUnreadCount": 1,
                "lastMessageAt": "2025-08-21T11:16:38.273Z",
                "lastMessageContent": "hello, sir 1"
            }
        }
    ]
}
```

**Usage**: 
- **When**: Active only in MySessions page
- **Lifecycle**: Started when sessions page opens, stopped when page closes
- **Authentication**: Requires authenticated user

**Example Channel Names**:
```
session_stats_tenant123customer789
```

## Implementation

### WebSocketService API

```dart
// Get the singleton instance
final webSocketService = WebSocketService.instance;

// Connect to a session (Socket.IO)
await webSocketService.connectToSession(
  tenantId: 'tenant123',
  sessionId: 'session456', 
  customerId: 'customer789', // null for anonymous
);

// Listen to incoming messages
webSocketService.messageStream?.listen((message) {
  // Handle new SessionMessage
  print('New message: ${message.content}');
});

// Connect to unread sessions count stream
await webSocketService.connectToUnreadSessionsCountStream(
  tenantId: 'tenant123',
  customerId: 'customer789',
);

// Listen to unread sessions count updates
webSocketService.unreadSessionsCountStream?.listen((count) {
  print('Unread sessions count: $count');
});

// Connect to session stats stream
await webSocketService.connectToSessionStatsStream(
  tenantId: 'tenant123',
  customerId: 'customer789',
);

// Listen to session stats updates
webSocketService.sessionStatsStream?.listen((sessionData) {
  print('Session stats update: $sessionData');
});

// Disconnect from specific streams
webSocketService.disconnectFromUnreadSessionsCountStream();
webSocketService.disconnectFromSessionStatsStream();

// Send typing indicator
webSocketService.sendTypingIndicator(isTyping: true);

// Send custom Socket.IO events
webSocketService.sendMessage('custom_event', {'data': 'value'});

// Subscribe to additional channels
webSocketService.subscribeToChannel('additional_channel');

// Check connection status
bool isConnected = webSocketService.isConnected;

// Disconnect
await webSocketService.disconnect();
```

### SingleSessionCubit Integration

The cubit now includes WebSocket streaming methods:

```dart
// Start message stream
await sessionCubit.startMessageStream(
  tenantId: tenantId,
  customerId: customerId,
);

// Stop message stream  
await sessionCubit.stopMessageStream();

// Check if stream is connected
bool connected = sessionCubit.isStreamConnected;
```

### SMSupportCubit Integration

The cubit now includes additional WebSocket streaming methods for unread counts and session stats:

```dart
// Start unread sessions count stream (for SMSupportCategoriesBs)
await smCubit.startUnreadSessionsCountStream();

// Stop unread sessions count stream
smCubit.stopUnreadSessionsCountStream();

// Start session stats stream (for MySessions page)
await smCubit.startSessionStatsStream();

// Stop session stats stream
smCubit.stopSessionStatsStream();

// Listen to state changes for unread count updates
BlocBuilder<SMSupportCubit, SMSupportState>(
  builder: (context, state) {
    return Text('Unread: ${state.myUnreadSessionsCount}');
  },
);

// Listen to state changes for session updates
BlocBuilder<SMSupportCubit, SMSupportState>(
  builder: (context, state) {
    return ListView.builder(
      itemCount: state.mySessions.length,
      itemBuilder: (context, index) {
        final session = state.mySessions[index];
        return SessionItem(session: session);
      },
    );
  },
);
```

### Message Flow

1. **Incoming Messages**: Received via WebSocket, parsed as `SessionMessage`, and added to the session state
2. **Duplicate Prevention**: Messages are checked by ID to prevent duplicates
3. **Auto-sorting**: Messages are sorted by creation time
4. **Auto-read**: Admin messages are automatically marked as read when received

## Lifecycle Management

### Message Streaming

**When Streaming Starts**:
1. **Existing Session**: When opening ChatPage for an existing session
2. **New Session**: After sending the first message in a new session

**When Streaming Stops**:
1. **Page Disposal**: When ChatPage is disposed
2. **Cubit Closure**: When SingleSessionCubit is closed
3. **Manual Stop**: When explicitly calling `stopMessageStream()`

### Unread Sessions Count Streaming

**When Streaming Starts**:
1. **Categories Screen**: When SMSupportCategoriesBs opens and user is authenticated

**When Streaming Stops**:
1. **Page Disposal**: When SMSupportCategoriesBs is disposed
2. **Navigation**: When user navigates away from categories screen

### Session Statistics Streaming

**When Streaming Starts**:
1. **Sessions Screen**: When MySessions page opens and user is authenticated

**When Streaming Stops**:
1. **Page Disposal**: When MySessions page is disposed
2. **Navigation**: When user navigates away from sessions screen

### ChatPage Integration

```dart
class _ChatPageState extends State<ChatPage> {
  bool _streamStarted = false; // Prevent duplicate stream starts
  
  @override
  void initState() {
    super.initState();
    
    // For existing sessions, start stream immediately
    if (!widget.initTicket && widget.sessionId.isNotEmpty) {
      _startMessageStream();
      _streamStarted = true;
    }
  }
  
  @override
  void dispose() {
    // Always stop stream on disposal
    _sessionCubit.stopMessageStream();
    super.dispose();
  }
  
  void _startMessageStream() {
    final tenantId = context.read<SMSupportCubit>().state.currentTenant?.tenantId;
    final customerId = AuthManager.isAuthenticated 
        ? AuthManager.currentCustomer?.id 
        : null;
        
    _sessionCubit.startMessageStream(
      tenantId: tenantId!,
      customerId: customerId,
    );
  }
  
  // In MessageInput onSend callback:
  onSend: (isSuccess) {
    if (isSuccess) {
      _scrollToBottom();
      // Start stream after first message (only once!)
      if (widget.initTicket && !_streamStarted) {
        _startMessageStream();
        _streamStarted = true;
      }
    }
  },
}
```

### SMSupportCategoriesBs Integration

```dart
class _SMSupportCategoriesBsState extends State<SMSupportCategoriesBs> {
  @override
  void initState() {
    super.initState();
    smCubit.getCategories();
    if (AuthManager.isAuthenticated) {
      smCubit.getMyUnreadSessions();
      // Start the unread sessions count stream for real-time updates
      smCubit.startUnreadSessionsCountStream();
    }
  }

  @override
  void dispose() {
    // Stop the unread sessions count stream when leaving the page
    if (AuthManager.isAuthenticated) {
      smCubit.stopUnreadSessionsCountStream();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SMSupportCubit, SMSupportState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.rw),
          child: Column(
            children: [
              // My Chats section with real-time unread count
              Container(
                child: Row(
                  children: [
                    Text('My Messages'),
                    if (state.myUnreadSessionsCount != 0) ...[
                      CircleAvatar(
                        child: Text(state.myUnreadSessionsCount.toString()),
                      ),
                    ],
                  ],
                ),
              ),
              // Categories and other content...
            ],
          ),
        );
      },
    );
  }
}
```

### MySessions Integration

```dart
class _MySessionsState extends State<MySessions> {
  @override
  void initState() {
    super.initState();
    smCubit.getMySessions();
    // Start the session stats stream for real-time updates
    smCubit.startSessionStatsStream();
  }

  @override
  void dispose() {
    // Stop the session stats stream when leaving the page
    smCubit.stopSessionStatsStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SMSupportCubit, SMSupportState>(
      builder: (context, state) {
        return Scaffold(
          body: Column(
            children: [
              // Sessions list with real-time updates
              if (state.sortedSessions.isNotEmpty) ...[
                ...List.generate(state.sortedSessions.length, (index) {
                  return SessionItem(
                    session: state.sortedSessions[index],
                    isLast: index == state.sortedSessions.length - 1,
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}
```

## Error Handling

### Connection Failures
- Non-blocking: App continues to work with existing message loading
- Logged but not shown to user to avoid disrupting UX
- Automatic cleanup on connection errors

### Message Parsing Errors
- Invalid messages are logged and ignored
- Stream continues to operate normally
- Error events are emitted to stream listeners

### Network Issues
- WebSocket automatically handles reconnection attempts
- Connection state can be checked via `isConnected` property
- Graceful degradation to polling-based message updates

## Performance Considerations

### Memory Management
- Automatic cleanup of subscriptions and controllers
- Singleton pattern prevents multiple WebSocket connections
- Proper disposal in cubit and service destructors

### Connection Efficiency
- Single WebSocket connection per session
- Prevents duplicate connections with channel-based checking
- Automatic disconnection when not needed
- Smart reconnection prevention for same channel

### Message Deduplication
- Prevents duplicate messages from being added to UI
- Uses message ID for unique identification
- Maintains message ordering by timestamp

## Usage Examples

### Basic Usage

```dart
// In your chat implementation
final sessionCubit = SingleSessionCubit(sessionId: 'session123');

// Start streaming for authenticated user
await sessionCubit.startMessageStream(
  tenantId: 'tenant456',
  customerId: 'customer789',
);

// Listen to state changes
BlocBuilder<SingleSessionCubit, SingleSessionState>(
  builder: (context, state) {
    return ListView.builder(
      itemCount: state.sessionMessages.length,
      itemBuilder: (context, index) {
        final message = state.sessionMessages[index];
        return MessageWidget(message: message);
      },
    );
  },
);
```

### Anonymous User

```dart
// For anonymous users, pass null as customerId
await sessionCubit.startMessageStream(
  tenantId: 'tenant456',
  customerId: null, // Will use 'anonymous' in channel name
);
```

### With Error Handling

```dart
try {
  await sessionCubit.startMessageStream(
    tenantId: tenantId,
    customerId: customerId,
  );
  print('Stream started successfully');
} catch (e) {
  print('Failed to start stream: $e');
  // App continues to work with polling-based updates
}
```

## Testing

### Unit Tests
- Mock WebSocketService for cubit testing
- Test message parsing and state updates
- Verify proper cleanup and disposal

### Integration Tests
- Test full WebSocket connection flow
- Verify message receiving and UI updates
- Test authentication scenarios (authenticated vs anonymous)

### Manual Testing
- Verify real-time message delivery
- Test connection recovery after network issues
- Confirm proper cleanup when navigating away

## Configuration

### Environment Setup

Update the WebSocket URL for different environments:

```dart
// In WebSocketService
static const String _baseWsUrl = 'wss://your-domain.com/ws';
```

### Dependencies

Required in `pubspec.yaml`:
```yaml
dependencies:
  web_socket_channel: ^3.0.1
```

## Migration Guide

### From Polling to Streaming

If you were previously using polling for message updates:

1. Remove manual refresh timers
2. Replace with WebSocket streaming calls
3. Update UI to listen to cubit state changes
4. Ensure proper cleanup in disposal methods

### Backward Compatibility

The streaming implementation is fully backward compatible:
- Existing polling-based message loading still works
- No breaking changes to existing APIs
- Streaming enhances but doesn't replace existing functionality

## Troubleshooting

### Common Issues

1. **Connection Fails**
   - Check WebSocket URL configuration
   - Verify network connectivity
   - Ensure tenant ID is available

2. **Messages Not Appearing**
   - Verify channel name format
   - Check message parsing logic
   - Ensure cubit state is being observed

3. **Memory Leaks**
   - Confirm proper disposal in cubit.close()
   - Verify WebSocket cleanup in page disposal
   - Check for uncanceled stream subscriptions

4. **Multiple Connections**
   - Ensure `_streamStarted` flag is used correctly
   - Verify channel-based duplicate prevention is working
   - Check that `startMessageStream` isn't called repeatedly

### Debug Logging

Enable debug logging to troubleshoot issues:

```dart
// WebSocket service includes comprehensive logging
// Check console for connection status and message flow
```

## Summary

The SM AI Support package now provides comprehensive real-time WebSocket streaming for:

### Features Implemented

1. **Message Streaming** (`message_[tenantId][sessionId][customerIdentifier]`)
   - Real-time admin message delivery in chat sessions
   - Automatic message parsing and state updates
   - Duplicate prevention and auto-sorting

2. **Unread Sessions Count Stream** (`unread_sessions_count_[tenantId][customerId]`)
   - Real-time unread count updates in SMSupportCategoriesBs
   - Simple integer payload for count updates
   - Automatic UI refresh when counts change

3. **Session Statistics Stream** (`session_stats_[tenantId][customerId]`)
   - Real-time session metadata updates in MySessions page
   - Rich JSON payload with session data
   - Automatic session list updates

### Key Benefits

- **Real-time Updates**: No more polling for changes
- **Better UX**: Instant feedback and data synchronization
- **Resource Efficient**: Event-driven updates only when needed
- **Non-blocking**: Graceful degradation if WebSocket fails
- **Easy Integration**: Simple APIs for starting/stopping streams

### Stream Lifecycle Management

Each stream is automatically managed by its corresponding UI component:
- Streams start when pages open (if user is authenticated)
- Streams stop when pages close or user navigates away
- Proper cleanup prevents memory leaks and duplicate connections

## Future Enhancements

### Planned Features
- Connection health monitoring
- Automatic reconnection with exponential backoff
- Message delivery acknowledgments
- Typing indicator improvements
- Multi-session support

### API Extensions
- Custom message types
- File upload progress via WebSocket
- Admin presence indicators
- Message read receipts in real-time

---

This streaming implementation provides a robust, performant, and user-friendly real-time messaging experience while maintaining backward compatibility and graceful error handling.
