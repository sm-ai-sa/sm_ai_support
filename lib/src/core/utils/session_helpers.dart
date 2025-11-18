import 'package:sm_ai_support/src/core/models/session_messages_model.dart';

/// Helper utilities for session management
class SessionHelpers {
  /// Check if a session is closed based on the last message content type
  /// Returns true if the last message indicates the session was closed
  static bool isSessionClosed(List<SessionMessage> messages) {
    if (messages.isEmpty) return false;

    final lastMessage = messages.last;
    return lastMessage.contentType.isCloseSession ||
           lastMessage.contentType.isCloseSessionBySystem;
  }

  /// Check if a session was closed by system
  static bool isSessionClosedBySystem(List<SessionMessage> messages) {
    if (messages.isEmpty) return false;

    final lastMessage = messages.last;
    return lastMessage.contentType.isCloseSessionBySystem;
  }

  /// Check if a session was closed manually (by admin or user)
  static bool isSessionClosedManually(List<SessionMessage> messages) {
    if (messages.isEmpty) return false;

    final lastMessage = messages.last;
    return lastMessage.contentType.isCloseSession;
  }

  /// Get the close message from a closed session
  /// Returns null if session is not closed
  static SessionMessage? getCloseMessage(List<SessionMessage> messages) {
    if (messages.isEmpty) return null;

    final lastMessage = messages.last;
    if (lastMessage.contentType.isCloseSession ||
        lastMessage.contentType.isCloseSessionBySystem) {
      return lastMessage;
    }

    return null;
  }
}
