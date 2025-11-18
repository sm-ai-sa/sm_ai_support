import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/global/components/dynamic_network_image.dart';
import 'package:sm_ai_support/src/core/models/session_messages_model.dart';
import 'package:sm_ai_support/src/core/models/upload_model.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/image_url_resolver.dart';
import 'package:sm_ai_support/src/features/support/views/image_preview.dart';

/// Image message widget with preview functionality
class ImageMessageWidget extends StatelessWidget {
  final SessionMessage message;
  final bool isMyMessage;
  final String sessionId;
  final Color? tenantColor;

  const ImageMessageWidget({
    super.key,
    required this.message,
    required this.isMyMessage,
    required this.sessionId,
    this.tenantColor,
  });

  @override
  Widget build(BuildContext context) {
    final adminBgColor = (tenantColor ?? ColorsPallets.primaryColor).withValues(alpha: .2);
    final adminBorderColor = (tenantColor ?? ColorsPallets.primaryColor).withValues(alpha: .25);

    return InkWell(
      onTap: () => _openImagePreview(context),
      child: Container(
        // padding: EdgeInsets.all(8.rSp),
        decoration: BoxDecoration(
          color: isMyMessage ? ColorsPallets.normal25 : adminBgColor,
          border: Border.all(color: isMyMessage ? ColorsPallets.borderColor : adminBorderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DynamicNetworkImage(
          imageSource: message.content,
          sessionId: sessionId,
          width: 200.rw,
          height: 150.rh,
          fit: BoxFit.contain,
          borderRadius: BorderRadius.circular(8),
          category: FileUploadCategory.sessionMedia,
        ),
      ),
    );
  }

  /// Opens image in full-screen preview
  Future<void> _openImagePreview(BuildContext context) async {
    String? imageUrl = message.content;

    // If it's not a direct URL, resolve it first
    if (!ImageUrlResolver.isDirectDownloadUrl(message.content)) {
      final fileName = ImageUrlResolver.extractFileName(message.content);
      imageUrl = await ImageUrlResolver.resolveImageUrl(
        fileName: fileName,
        sessionId: sessionId,
        category: FileUploadCategory.sessionMedia,
      );
    }

    if (imageUrl != null && context.mounted) {
      context.smPush(ImagePreview(imageUrl: imageUrl));
    }
  }
}

