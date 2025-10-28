import 'package:flutter/material.dart';

/// Helper class for detecting text direction based on content
class TextDirectionHelper {
  TextDirectionHelper._();

  /// Detects if the text is primarily English (or LTR language)
  /// Returns true if the text contains primarily English characters
  static bool isEnglish(String text) {
    if (text.isEmpty) return true;

    // Remove URLs, numbers, and special characters for better detection
    final cleanText = text
        .replaceAll(RegExp(r'https?://[^\s]+'), '')
        .replaceAll(RegExp(r'[0-9]'), '')
        .replaceAll(RegExp(r'[^\p{L}]', unicode: true), '');

    if (cleanText.isEmpty) return true;

    int englishCount = 0;
    int arabicCount = 0;

    for (int i = 0; i < cleanText.length; i++) {
      final code = cleanText.codeUnitAt(i);

      // Check if character is English (Latin alphabet)
      if ((code >= 65 && code <= 90) || (code >= 97 && code <= 122)) {
        englishCount++;
      }
      // Check if character is Arabic
      else if (code >= 0x0600 && code <= 0x06FF) {
        arabicCount++;
      }
    }

    // If more than 50% of characters are English, consider it English
    return englishCount > arabicCount;
  }

  /// Gets the text direction based on the content
  static TextDirection getTextDirection(String text) {
    return isEnglish(text) ? TextDirection.ltr : TextDirection.rtl;
  }

  /// Gets the text alignment based on the content and message ownership
  static TextAlign getTextAlign(String text, bool isMyMessage) {
    if (isEnglish(text)) {
      return isMyMessage ? TextAlign.right : TextAlign.left;
    } else {
      return isMyMessage ? TextAlign.left : TextAlign.right;
    }
  }
}

