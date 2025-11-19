import 'package:sm_ai_support/src/core/models/session_messages_model.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

/// Helper utilities for session management
class SessionHelpers {
  /// Check if a session is closed based on the most recent message content type
  /// Returns true if the most recent message indicates the session was closed
  /// Note: API returns messages in descending order (newest first), so we check messages.first
  static bool isSessionClosed(List<SessionMessage> messages) {
    if (messages.isEmpty) {
      smPrint('[SessionHelpers] No messages to check, session not closed');
      return false;
    }

    // API returns messages in descending order (newest first)
    final mostRecentMessage = messages.first;
    final isClosed = mostRecentMessage.contentType.isCloseSession ||
                     mostRecentMessage.contentType.isCloseSessionBySystem;

    smPrint('[SessionHelpers] Checking if session is closed:');
    smPrint('  - Total messages: ${messages.length}');
    smPrint('  - Most recent message ID: ${mostRecentMessage.id}');
    smPrint('  - Most recent message contentType: ${mostRecentMessage.contentType}');
    smPrint('  - Most recent message createdAt: ${mostRecentMessage.createdAt}');
    smPrint('  - isCloseSession: ${mostRecentMessage.contentType.isCloseSession}');
    smPrint('  - isCloseSessionBySystem: ${mostRecentMessage.contentType.isCloseSessionBySystem}');
    smPrint('  - Result: isClosed = $isClosed');

    return isClosed;
  }

  /// Check if a session was closed by system
  static bool isSessionClosedBySystem(List<SessionMessage> messages) {
    if (messages.isEmpty) return false;

    // API returns messages in descending order (newest first)
    final mostRecentMessage = messages.first;
    return mostRecentMessage.contentType.isCloseSessionBySystem;
  }

  /// Check if a session was closed manually (by admin or user)
  static bool isSessionClosedManually(List<SessionMessage> messages) {
    if (messages.isEmpty) return false;

    // API returns messages in descending order (newest first)
    final mostRecentMessage = messages.first;
    return mostRecentMessage.contentType.isCloseSession;
  }

  /// Get the close message from a closed session
  /// Returns null if session is not closed
  static SessionMessage? getCloseMessage(List<SessionMessage> messages) {
    if (messages.isEmpty) return null;

    // API returns messages in descending order (newest first)
    final mostRecentMessage = messages.first;
    if (mostRecentMessage.contentType.isCloseSession ||
        mostRecentMessage.contentType.isCloseSessionBySystem) {
      return mostRecentMessage;
    }

    return null;
  }
}
