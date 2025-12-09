# WebSocket Implementation Guide for React Native

## Overview
This document provides comprehensive documentation for implementing Socket.IO WebSocket connections in a React Native package, based on the Flutter implementation in `sm_ai_support`.

## Table of Contents
1. [Configuration](#configuration)
2. [Socket.IO Setup](#socketio-setup)
3. [Channel Implementations](#channel-implementations)
4. [Message Models](#message-models)
5. [Connection Management](#connection-management)
6. [Error Handling](#error-handling)
7. [React Native Specific Considerations](#react-native-specific-considerations)

---

## Configuration

### Required Configuration Data
```typescript
interface SMSupportConfig {
  appName: string;
  tenantId: string;
  apiKey: string;
  secretKey: string;
  baseUrl: string;           // REST API base URL
  socketBaseUrl: string;     // WebSocket base URL
  locale: string;
  customer?: CustomerData;
}
```

### Socket.IO Connection Endpoint
**Base URL**: `{socketBaseUrl}/customer/room`
**Example**: `https://your-socket-server.com/customer/room`

### Socket.IO Configuration Options
```typescript
const socketConfig = {
  transports: ['websocket', 'polling'],  // Try websocket first, fallback to polling
  autoConnect: true,
  reconnection: true,
  reconnectionAttempts: 3,
  reconnectionDelay: 1000,               // 1 second
  timeout: 20000,                        // 20 seconds
  path: '/socket.io/',
  extraHeaders: {
    'device-id': deviceId || ''          // Optional device ID for anonymous tracking
  }
};
```

---

## Socket.IO Setup

### Installation
```bash
npm install socket.io-client
# or
yarn add socket.io-client
```

### Basic Connection Implementation
```typescript
import io, { Socket } from 'socket.io-client';

class WebSocketService {
  private socket: Socket | null = null;
  private baseUrl: string;
  private isConnected: boolean = false;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  connect(deviceId?: string): Promise<void> {
    return new Promise((resolve, reject) => {
      this.socket = io(`${this.baseUrl}/customer/room`, {
        transports: ['websocket', 'polling'],
        autoConnect: true,
        reconnection: true,
        reconnectionAttempts: 3,
        reconnectionDelay: 1000,
        timeout: 20000,
        path: '/socket.io/',
        extraHeaders: deviceId ? { 'device-id': deviceId } : {}
      });

      this.setupConnectionListeners(resolve, reject);
    });
  }

  private setupConnectionListeners(
    resolve: () => void,
    reject: (error: any) => void
  ): void {
    if (!this.socket) return;

    this.socket.on('connect', () => {
      console.log('✅ Socket.IO connected');
      this.isConnected = true;
      resolve();
    });

    this.socket.on('connect_error', (error) => {
      console.error('❌ Socket.IO connection error:', error);
      this.isConnected = false;
      reject(error);
    });

    this.socket.on('disconnect', (reason) => {
      console.log('🔌 Socket.IO disconnected:', reason);
      this.isConnected = false;
    });
  }

  disconnect(): void {
    if (this.socket) {
      this.socket.disconnect();
      this.socket.removeAllListeners();
      this.socket = null;
      this.isConnected = false;
    }
  }
}
```

---

## Channel Implementations

There are **3 main channels** in the system:

### 1. Message Channel
**Format**: `message_{tenantId}{sessionId}{customerId}`
**Purpose**: Real-time message delivery for a specific chat session
**Customer Identifier**: Use `customerId` for authenticated users, `'anonymous'` for guests

#### Channel Subscription
```typescript
subscribeToMessageChannel(
  tenantId: string,
  sessionId: string,
  customerId?: string
): void {
  const customerIdentifier = customerId || 'anonymous';
  const channelName = `message_${tenantId}${sessionId}${customerIdentifier}`;

  console.log(`📡 Subscribing to message channel: ${channelName}`);

  // Send subscribe event
  this.socket?.emit('subscribe', { channel: channelName });

  // Listen for confirmation
  this.socket?.on('subscribed', (data) => {
    console.log('✅ Successfully subscribed to channel:', data);
  });

  // Listen for subscription errors
  this.socket?.on('subscription_error', (error) => {
    console.error('❌ Subscription error:', error);
  });
}
```

#### Message Event Listeners
```typescript
setupMessageListeners(channelName: string): void {
  // Primary event: new_message
  this.socket?.on('new_message', (data: any) => {
    console.log('📨 Received new_message event:', data);
    this.handleNewMessage(data);
  });

  // Fallback: channel-specific listener
  this.socket?.on(channelName, (data: any) => {
    console.log(`📨 Received message on channel ${channelName}:`, data);
    this.handleMessage(data);
  });

  // Fallback: generic message listener
  this.socket?.on('message', (data: any) => {
    console.log('📨 Received generic message:', data);
    this.handleMessage(data);
  });
}
```

#### Message Handling
```typescript
private handleNewMessage(data: any): void {
  try {
    // Check if data is wrapped
    const messageData = data.data ? data.data : data;

    if (typeof messageData === 'object') {
      const message = this.parseSessionMessage(messageData);
      this.messageSubject.next(message); // Emit to observers
    }
  } catch (error) {
    console.error('❌ Error parsing new_message:', error);
  }
}

private handleMessage(data: any): void {
  try {
    let jsonData: any;

    // Parse if string
    if (typeof data === 'string') {
      jsonData = JSON.parse(data);
    } else {
      jsonData = data;
    }

    const eventType = jsonData.type;

    // Handle wrapped new_message format
    if (eventType === 'new_message' && jsonData.data) {
      const message = this.parseSessionMessage(jsonData.data);
      this.messageSubject.next(message);
      return;
    }

    // Handle rating_request format
    if (eventType === 'rating_request') {
      this.ratingRequestSubject.next(true);
      return;
    }

    // Handle direct SessionMessage format
    if (jsonData.id && jsonData.content) {
      const message = this.parseSessionMessage(jsonData);
      this.messageSubject.next(message);
    }
  } catch (error) {
    console.error('❌ Error parsing message:', error);
  }
}
```

---

### 2. Unread Sessions Count Channel
**Format**: `unread_sessions_count_{tenantId}{customerId}`
**Purpose**: Real-time updates for the number of unread sessions
**Used For**: Badge count on sessions list, notification indicators

#### Channel Subscription
```typescript
subscribeToUnreadSessionsCount(
  tenantId: string,
  customerId: string
): void {
  const channelName = `unread_sessions_count_${tenantId}${customerId}`;

  console.log(`📊 Subscribing to unread count channel: ${channelName}`);

  // Subscribe to channel
  this.socket?.emit('subscribe', { channel: channelName });

  // Listen for unread count updates
  this.socket?.on(channelName, (data: any) => {
    this.handleUnreadCountUpdate(data);
  });
}

private handleUnreadCountUpdate(data: any): void {
  try {
    let count: number;

    if (typeof data === 'number') {
      count = data;
    } else if (typeof data === 'string') {
      count = parseInt(data, 10) || 0;
    } else {
      console.warn('⚠️ Invalid unread count format:', data);
      return;
    }

    console.log(`📊 Unread sessions count: ${count}`);
    this.unreadCountSubject.next(count); // Emit to observers
  } catch (error) {
    console.error('❌ Error handling unread count:', error);
  }
}
```

#### Disconnection
```typescript
disconnectFromUnreadSessionsCount(
  tenantId: string,
  customerId: string
): void {
  const channelName = `unread_sessions_count_${tenantId}${customerId}`;

  console.log(`📊 Unsubscribing from unread count channel: ${channelName}`);

  // Remove listener
  this.socket?.off(channelName);
}
```

---

### 3. Session Stats Channel
**Format**: `session_stats_{tenantId}{customerId}`
**Purpose**: Real-time updates for session statistics (e.g., in "My Sessions" page)
**Used For**: Live updates to session list, status changes, new sessions

#### Channel Subscription
```typescript
subscribeToSessionStats(
  tenantId: string,
  customerId: string
): void {
  const channelName = `session_stats_${tenantId}${customerId}`;

  console.log(`📈 Subscribing to session stats channel: ${channelName}`);

  // Subscribe to channel
  this.socket?.emit('subscribe', { channel: channelName });

  // Listen for session stats updates
  this.socket?.on(channelName, (data: any) => {
    this.handleSessionStatsUpdate(data);
  });
}

private handleSessionStatsUpdate(data: any): void {
  try {
    if (typeof data === 'object') {
      console.log('📈 Session stats update:', data);
      console.log('  Type:', data.type);

      if (data.data) {
        const count = Array.isArray(data.data) ? data.data.length : 1;
        console.log('  Data count:', count);
      }

      this.sessionStatsSubject.next(data); // Emit to observers
    } else {
      console.warn('⚠️ Invalid session stats format:', data);
    }
  } catch (error) {
    console.error('❌ Error handling session stats:', error);
  }
}
```

#### Disconnection
```typescript
disconnectFromSessionStats(
  tenantId: string,
  customerId: string
): void {
  const channelName = `session_stats_${tenantId}${customerId}`;

  console.log(`📈 Unsubscribing from session stats channel: ${channelName}`);

  // Remove listener
  this.socket?.off(channelName);
}
```

---

## Message Models

### SessionMessage Interface
```typescript
interface SessionMessage {
  id: string;
  content: string;
  contentType: 'TEXT' | 'IMAGE' | 'VIDEO' | 'AUDIO' | 'FILE';
  senderType: 'customer' | 'admin' | 'system';
  isRead: boolean;
  isDelivered: boolean;
  isFailed: boolean;
  createdAt: string; // ISO 8601 date string
  reply?: SessionMessageReply | null;
  admin?: any;
  metadata?: Record<string, any>;
}

interface SessionMessageReply {
  message: string;
  messageId: string;
  contentType: string;
}
```

### Message Parsing
```typescript
parseSessionMessage(json: any): SessionMessage {
  return {
    id: json.id,
    content: json.content,
    contentType: json.contentType,
    senderType: json.senderType,
    isRead: json.isRead ?? false,
    isDelivered: json.isDelivered ?? false,
    isFailed: json.isFailed ?? false,
    createdAt: json.createdAt,
    reply: json.reply ? {
      message: json.reply.message,
      messageId: json.reply.messageId,
      contentType: json.reply.contentType
    } : null,
    admin: json.admin,
    metadata: json.metadata
  };
}
```

---

## Connection Management

### Heartbeat Implementation
Keep the connection alive with periodic ping:

```typescript
private pingTimer: NodeJS.Timer | null = null;

startHeartbeat(): void {
  this.stopHeartbeat(); // Clear existing timer

  // Send ping every 30 seconds
  this.pingTimer = setInterval(() => {
    if (this.socket && this.isConnected) {
      this.socket.emit('ping');
      console.log('💓 Heartbeat ping sent');
    } else {
      this.stopHeartbeat();
    }
  }, 30000); // 30 seconds

  console.log('💓 Heartbeat started');
}

stopHeartbeat(): void {
  if (this.pingTimer) {
    clearInterval(this.pingTimer);
    this.pingTimer = null;
    console.log('💓 Heartbeat stopped');
  }
}
```

### Reconnection with Exponential Backoff
```typescript
private reconnectAttempts = 0;
private readonly maxReconnectAttempts = 5;
private readonly initialReconnectDelay = 1000; // 1 second
private readonly maxReconnectDelay = 30000;    // 30 seconds
private reconnectTimer: NodeJS.Timer | null = null;

private handleDisconnection(): void {
  console.log('🔌 Connection closed');
  console.log(`Reconnect attempts: ${this.reconnectAttempts}/${this.maxReconnectAttempts}`);

  this.isConnected = false;

  if (this.reconnectAttempts < this.maxReconnectAttempts) {
    this.reconnectAttempts++;

    // Calculate exponential backoff delay
    const delay = Math.min(
      this.initialReconnectDelay * Math.pow(2, this.reconnectAttempts - 1),
      this.maxReconnectDelay
    );

    console.log(`⏱️ Scheduling reconnection in ${delay}ms`);

    this.reconnectTimer = setTimeout(() => {
      console.log('🔄 Attempting reconnection...');
      this.attemptReconnection();
    }, delay);
  } else {
    console.log('❌ Max reconnection attempts reached');
    // Consider fallback to HTTP polling here
  }
}

private attemptReconnection(): void {
  // Store connection parameters and reconnect
  this.connect(this.deviceId)
    .then(() => {
      console.log('✅ Reconnection successful');
      this.reconnectAttempts = 0;
      // Re-subscribe to all active channels
      this.resubscribeToChannels();
    })
    .catch((error) => {
      console.error('❌ Reconnection failed:', error);
      // handleDisconnection will be called again
    });
}
```

### Cleanup on Disconnect
```typescript
async disconnect(): Promise<void> {
  console.log('🧹 Cleaning up WebSocket connection');

  // Stop heartbeat
  this.stopHeartbeat();

  // Clear reconnection timer
  if (this.reconnectTimer) {
    clearTimeout(this.reconnectTimer);
    this.reconnectTimer = null;
  }

  // Remove all listeners
  if (this.socket) {
    this.socket.removeAllListeners();
    this.socket.disconnect();
    this.socket = null;
  }

  // Reset state
  this.isConnected = false;
  this.reconnectAttempts = 0;

  console.log('✅ Cleanup completed');
}
```

---

## Error Handling

### Connection Error Handling
```typescript
private handleConnectionError(error: any): void {
  console.error('❌ Connection error:', error);

  // Provide specific error messages
  const errorMessage = error.toString();

  if (errorMessage.includes('502')) {
    console.error('Server returned 502 - Check Socket.IO endpoint configuration');
  } else if (errorMessage.includes('timeout')) {
    console.error('Connection timeout - Check server availability');
  } else if (errorMessage.includes('Connection refused')) {
    console.error('Connection refused - Check server availability');
  }

  // Emit error to observers
  this.errorSubject.next(error);
}
```

### Message Parsing Error Handling
```typescript
private safeParseMessage(data: any): SessionMessage | null {
  try {
    return this.parseSessionMessage(data);
  } catch (error) {
    console.error('❌ Failed to parse message:', error);
    console.error('Raw data:', data);
    return null;
  }
}
```

---

## React Native Specific Considerations

### 1. Using RxJS for Reactive Streams
```typescript
import { Subject, Observable } from 'rxjs';

class WebSocketService {
  private messageSubject = new Subject<SessionMessage>();
  private unreadCountSubject = new Subject<number>();
  private sessionStatsSubject = new Subject<any>();
  private errorSubject = new Subject<any>();

  // Expose as observables
  public message$ = this.messageSubject.asObservable();
  public unreadCount$ = this.unreadCountSubject.asObservable();
  public sessionStats$ = this.sessionStatsSubject.asObservable();
  public error$ = this.errorSubject.asObservable();
}

// Usage in React component
useEffect(() => {
  const subscription = webSocketService.message$.subscribe(
    (message) => {
      console.log('New message:', message);
      // Update UI
    }
  );

  return () => subscription.unsubscribe();
}, []);
```

### 2. Using React Hooks
```typescript
import { useState, useEffect } from 'react';

function useWebSocket(
  tenantId: string,
  sessionId: string,
  customerId?: string
) {
  const [messages, setMessages] = useState<SessionMessage[]>([]);
  const [isConnected, setIsConnected] = useState(false);

  useEffect(() => {
    const ws = new WebSocketService(socketBaseUrl);

    ws.connect(deviceId)
      .then(() => {
        setIsConnected(true);
        ws.subscribeToMessageChannel(tenantId, sessionId, customerId);
      })
      .catch((error) => {
        console.error('Connection failed:', error);
      });

    const subscription = ws.message$.subscribe((message) => {
      setMessages((prev) => [...prev, message].sort(
        (a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()
      ));
    });

    return () => {
      subscription.unsubscribe();
      ws.disconnect();
    };
  }, [tenantId, sessionId, customerId]);

  return { messages, isConnected };
}
```

### 3. Background State Handling
```typescript
import { AppState, AppStateStatus } from 'react-native';

class WebSocketService {
  private appStateSubscription: any;

  setupAppStateHandling(): void {
    this.appStateSubscription = AppState.addEventListener(
      'change',
      this.handleAppStateChange.bind(this)
    );
  }

  private handleAppStateChange(nextAppState: AppStateStatus): void {
    if (nextAppState === 'active') {
      console.log('📱 App came to foreground - reconnecting socket');
      if (!this.isConnected) {
        this.attemptReconnection();
      }
    } else if (nextAppState === 'background') {
      console.log('📱 App went to background - maintaining connection');
      // Keep connection alive for notifications
      // Or disconnect to save battery
    }
  }

  cleanup(): void {
    this.appStateSubscription?.remove();
    this.disconnect();
  }
}
```

### 4. Device ID Management
```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';
import { v4 as uuidv4 } from 'uuid';

class DeviceIdManager {
  private static DEVICE_ID_KEY = '@sm_support_device_id';

  static async getDeviceId(): Promise<string> {
    try {
      let deviceId = await AsyncStorage.getItem(this.DEVICE_ID_KEY);

      if (!deviceId) {
        deviceId = uuidv4();
        await AsyncStorage.setItem(this.DEVICE_ID_KEY, deviceId);
        console.log('🆔 Generated new device ID:', deviceId);
      }

      return deviceId;
    } catch (error) {
      console.error('Error managing device ID:', error);
      return uuidv4(); // Fallback to temporary ID
    }
  }

  static async clearDeviceId(): Promise<void> {
    await AsyncStorage.removeItem(this.DEVICE_ID_KEY);
  }
}
```

---

## Complete Implementation Example

```typescript
import io, { Socket } from 'socket.io-client';
import { Subject } from 'rxjs';

class WebSocketService {
  private socket: Socket | null = null;
  private baseUrl: string;
  private isConnected = false;
  private deviceId?: string;

  // Observables
  private messageSubject = new Subject<SessionMessage>();
  private unreadCountSubject = new Subject<number>();
  private sessionStatsSubject = new Subject<any>();
  private ratingRequestSubject = new Subject<boolean>();

  public message$ = this.messageSubject.asObservable();
  public unreadCount$ = this.unreadCountSubject.asObservable();
  public sessionStats$ = this.sessionStatsSubject.asObservable();
  public ratingRequest$ = this.ratingRequestSubject.asObservable();

  // Active channels
  private currentMessageChannel?: string;
  private currentUnreadCountChannel?: string;
  private currentSessionStatsChannel?: string;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  async connect(deviceId?: string): Promise<void> {
    this.deviceId = deviceId;

    return new Promise((resolve, reject) => {
      this.socket = io(`${this.baseUrl}/customer/room`, {
        transports: ['websocket', 'polling'],
        autoConnect: true,
        reconnection: true,
        reconnectionAttempts: 3,
        reconnectionDelay: 1000,
        timeout: 20000,
        path: '/socket.io/',
        extraHeaders: deviceId ? { 'device-id': deviceId } : {}
      });

      this.socket.on('connect', () => {
        console.log('✅ Socket.IO connected');
        this.isConnected = true;
        this.startHeartbeat();
        resolve();
      });

      this.socket.on('connect_error', (error) => {
        console.error('❌ Connection error:', error);
        this.isConnected = false;
        reject(error);
      });

      this.socket.on('disconnect', (reason) => {
        console.log('🔌 Disconnected:', reason);
        this.isConnected = false;
        this.stopHeartbeat();
      });
    });
  }

  subscribeToMessageChannel(
    tenantId: string,
    sessionId: string,
    customerId?: string
  ): void {
    const customerIdentifier = customerId || 'anonymous';
    const channelName = `message_${tenantId}${sessionId}${customerIdentifier}`;

    // Skip if already subscribed
    if (this.currentMessageChannel === channelName) {
      console.log('Already subscribed to:', channelName);
      return;
    }

    // Unsubscribe from previous channel
    if (this.currentMessageChannel) {
      this.socket?.off(this.currentMessageChannel);
    }

    this.currentMessageChannel = channelName;

    console.log('📡 Subscribing to message channel:', channelName);

    // Subscribe
    this.socket?.emit('subscribe', { channel: channelName });

    // Setup listeners
    this.socket?.on('new_message', this.handleNewMessage.bind(this));
    this.socket?.on(channelName, this.handleMessage.bind(this));
    this.socket?.on('message', this.handleMessage.bind(this));
  }

  subscribeToUnreadSessionsCount(
    tenantId: string,
    customerId: string
  ): void {
    const channelName = `unread_sessions_count_${tenantId}${customerId}`;

    if (this.currentUnreadCountChannel === channelName) {
      return;
    }

    if (this.currentUnreadCountChannel) {
      this.socket?.off(this.currentUnreadCountChannel);
    }

    this.currentUnreadCountChannel = channelName;

    console.log('📊 Subscribing to unread count channel:', channelName);

    this.socket?.emit('subscribe', { channel: channelName });
    this.socket?.on(channelName, this.handleUnreadCountUpdate.bind(this));
  }

  subscribeToSessionStats(
    tenantId: string,
    customerId: string
  ): void {
    const channelName = `session_stats_${tenantId}${customerId}`;

    if (this.currentSessionStatsChannel === channelName) {
      return;
    }

    if (this.currentSessionStatsChannel) {
      this.socket?.off(this.currentSessionStatsChannel);
    }

    this.currentSessionStatsChannel = channelName;

    console.log('📈 Subscribing to session stats channel:', channelName);

    this.socket?.emit('subscribe', { channel: channelName });
    this.socket?.on(channelName, this.handleSessionStatsUpdate.bind(this));
  }

  private handleNewMessage(data: any): void {
    try {
      const messageData = data.data || data;
      if (typeof messageData === 'object') {
        const message = this.parseSessionMessage(messageData);
        this.messageSubject.next(message);
      }
    } catch (error) {
      console.error('Error parsing new_message:', error);
    }
  }

  private handleMessage(data: any): void {
    try {
      const jsonData = typeof data === 'string' ? JSON.parse(data) : data;

      if (jsonData.type === 'new_message' && jsonData.data) {
        const message = this.parseSessionMessage(jsonData.data);
        this.messageSubject.next(message);
      } else if (jsonData.type === 'rating_request') {
        this.ratingRequestSubject.next(true);
      } else if (jsonData.id && jsonData.content) {
        const message = this.parseSessionMessage(jsonData);
        this.messageSubject.next(message);
      }
    } catch (error) {
      console.error('Error parsing message:', error);
    }
  }

  private handleUnreadCountUpdate(data: any): void {
    try {
      const count = typeof data === 'number' ? data : parseInt(data, 10) || 0;
      this.unreadCountSubject.next(count);
    } catch (error) {
      console.error('Error handling unread count:', error);
    }
  }

  private handleSessionStatsUpdate(data: any): void {
    try {
      if (typeof data === 'object') {
        this.sessionStatsSubject.next(data);
      }
    } catch (error) {
      console.error('Error handling session stats:', error);
    }
  }

  private parseSessionMessage(json: any): SessionMessage {
    return {
      id: json.id,
      content: json.content,
      contentType: json.contentType,
      senderType: json.senderType,
      isRead: json.isRead ?? false,
      isDelivered: json.isDelivered ?? false,
      isFailed: json.isFailed ?? false,
      createdAt: json.createdAt,
      reply: json.reply,
      admin: json.admin,
      metadata: json.metadata
    };
  }

  private pingTimer: NodeJS.Timer | null = null;

  private startHeartbeat(): void {
    this.stopHeartbeat();

    this.pingTimer = setInterval(() => {
      if (this.socket && this.isConnected) {
        this.socket.emit('ping');
        console.log('💓 Heartbeat sent');
      }
    }, 30000);
  }

  private stopHeartbeat(): void {
    if (this.pingTimer) {
      clearInterval(this.pingTimer);
      this.pingTimer = null;
    }
  }

  disconnect(): void {
    console.log('🧹 Disconnecting...');

    this.stopHeartbeat();

    if (this.socket) {
      this.socket.removeAllListeners();
      this.socket.disconnect();
      this.socket = null;
    }

    this.isConnected = false;
    this.currentMessageChannel = undefined;
    this.currentUnreadCountChannel = undefined;
    this.currentSessionStatsChannel = undefined;

    console.log('✅ Disconnected');
  }
}

export default WebSocketService;
```

---

## Testing Checklist

- [ ] Socket.IO connection to `{socketBaseUrl}/customer/room` works
- [ ] Device ID is sent in headers for anonymous users
- [ ] Message channel subscription with format `message_{tenantId}{sessionId}{customerId}`
- [ ] Unread count channel subscription with format `unread_sessions_count_{tenantId}{customerId}`
- [ ] Session stats channel subscription with format `session_stats_{tenantId}{customerId}`
- [ ] `new_message` events are received and parsed correctly
- [ ] Rating request events are received
- [ ] Heartbeat ping is sent every 30 seconds
- [ ] Reconnection with exponential backoff works
- [ ] App state changes (background/foreground) are handled
- [ ] Cleanup on disconnect removes all listeners
- [ ] Duplicate messages are prevented
- [ ] Message sorting by `createdAt` works correctly

---

## Additional Notes

1. **Channel Naming**: Channel names are formed by direct concatenation without separators (e.g., `message_tenant123session456customer789`)

2. **Anonymous vs Authenticated**:
   - Anonymous users use `'anonymous'` as customerId in message channels
   - Authenticated users must provide their actual customerId
   - Unread count and session stats channels require authenticated users

3. **Message Events**: The server sends messages through multiple events (`new_message`, channel-specific, `message`) - listen to all for reliability

4. **Error Handling**: Always implement try-catch blocks when parsing socket data as format may vary

5. **Connection States**: Track connection state and inform UI to show online/offline indicators

6. **Polling Fallback**: Consider implementing HTTP polling fallback if WebSocket connection fails repeatedly

---

## References

- Socket.IO Client Documentation: https://socket.io/docs/v4/client-api/
- Flutter Implementation: `lib/src/core/services/websocket_service.dart`
- Message Models: `lib/src/core/models/session_messages_model.dart`
- Cubit Usage: `lib/src/features/support/cubit/single_session_cubit.dart`
