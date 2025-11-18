import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/models/session_messages_model.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/text_direction_helper.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// Text message widget with clickable links support and text direction detection
class TextMessageWidget extends StatelessWidget {
  final SessionMessage message;
  final bool isMyMessage;
  final Color? tenantColor;

  const TextMessageWidget({
    super.key,
    required this.message,
    required this.isMyMessage,
    this.tenantColor,
  });

  @override
  Widget build(BuildContext context) {
    // Detect text direction based on content
    final textDirection = TextDirectionHelper.getTextDirection(message.content);
    final adminBgColor = tenantColor ?? ColorsPallets.primaryColor;

    return Directionality(
      textDirection: textDirection,
      child: Container(
        padding: EdgeInsets.all(10.rSp),
        decoration: BoxDecoration(
          color: isMyMessage ? ColorsPallets.normal25 : adminBgColor.withValues(alpha: .2),
          border: Border.all(color: (isMyMessage ? ColorsPallets.borderColor : adminBgColor).withValues(alpha: .25)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _buildTextWithLinks(message.content),
      ),
    );
  }

  /// Build text with clickable links
  Widget _buildTextWithLinks(String text) {
    final urlRegex = RegExp(
      r'(https?:\/\/[^\s]+)',
      caseSensitive: false,
    );

    final matches = urlRegex.allMatches(text);
    if (matches.isEmpty) {
      // No links found, return plain text
      return Text(
        text,
        style: TextStyles.s_13_400.copyWith(color: ColorsPallets.muted600),
      );
    }

    // Build text with clickable links
    final spans = <TextSpan>[];
    int currentIndex = 0;

    for (final match in matches) {
      // Add text before the link
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: TextStyles.s_13_400.copyWith(color: ColorsPallets.muted600),
        ));
      }

      // Add the clickable link (black, bold, underlined)
      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: TextStyles.s_13_400.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => _launchUrl(url),
      ));

      currentIndex = match.end;
    }

    // Add remaining text after the last link
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: TextStyles.s_13_400.copyWith(color: ColorsPallets.muted600),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  /// Launch URL in browser using url_launcher package
  Future<void> _launchUrl(String urlString) async {
    try {
      smPrint('🔗 Launching URL: $urlString');
      
      final uri = Uri.parse(urlString);
      
      // Check if the URL can be launched
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in external browser
        );
        
        if (launched) {
          smPrint('✅ URL launched successfully');
        } else {
          smPrint('❌ Failed to launch URL');
        }
      } else {
        smPrint('❌ Cannot launch URL: $urlString');
      }
    } catch (e) {
      smPrint('❌ Error launching URL: $e');
    }
  }
}

