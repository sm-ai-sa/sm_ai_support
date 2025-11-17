import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/models/session_messages_model.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/messages/auth_message_widget.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/messages/file_message_widget.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/messages/image_message_widget.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/messages/system_action_message_widget.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/messages/text_message_widget.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/messages/unsupported_media_widget.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/messages/video_message_widget.dart';

/// Factory class for creating message widgets based on content type
/// Handles routing and instantiation of appropriate message widget
class MessageFactory {
  MessageFactory._();

  /// Creates the appropriate message widget based on message content type
  static Widget createMessageWidget({
    required SessionMessage message,
    required bool isMyMessage,
    required String sessionId,
    Color? tenantColor,
  }) {
    // Handle authentication-related messages
    if (message.contentType.isNeedAuth || 
        message.contentType.isAuthorized || 
        message.contentType.isUnauthorized) {
      return AuthMessageWidget(
        message: message,
        sessionId: sessionId,
        tenantColor: tenantColor,
      );
    }

    // Handle system action messages
    if (message.contentType.isReopenSession ||
        message.contentType.isCloseSession ||
        message.contentType.isCloseSessionBySystem) {
      return SystemActionMessageWidget(
        message: message,
        tenantColor: tenantColor,
      );
    }

    // Handle media messages
    if (message.contentType.isText) {
      return TextMessageWidget(
        message: message,
        isMyMessage: isMyMessage,
        tenantColor: tenantColor,
      );
    } else if (message.contentType.isImage) {
      return ImageMessageWidget(
        message: message,
        isMyMessage: isMyMessage,
        sessionId: sessionId,
        tenantColor: tenantColor,
      );
    } else if (message.contentType.isVideo) {
      return VideoMessageWidget(
        message: message,
        isMyMessage: isMyMessage,
        sessionId: sessionId,
        tenantColor: tenantColor,
      );
    } else if (message.contentType.isAudio) {
      // Audio files are now treated as unsupported media
      return UnsupportedMediaWidget(
        message: message,
        isMyMessage: isMyMessage,
        tenantColor: tenantColor,
      );
    } else if (message.contentType.isFile) {
      return FileMessageWidget(
        message: message,
        isMyMessage: isMyMessage,
        sessionId: sessionId,
        tenantColor: tenantColor,
      );
    } else if (message.contentType.isUnsupportedMedia) {
      return UnsupportedMediaWidget(
        message: message,
        isMyMessage: isMyMessage,
        tenantColor: tenantColor,
      );
    }

    // Fallback to text message for unknown types
    return TextMessageWidget(
      message: message,
      isMyMessage: isMyMessage,
      tenantColor: tenantColor,
    );
  }
}

