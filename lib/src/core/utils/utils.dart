import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

class Utils {
  Utils._();

  ///* Generate `UUID` for document or files
  static String get getUID => _uuid.v4();

  static String getMessage({required String en, required String ar}) {
    return (SMText.isEnglish) ? en : ar;
  }

  static String getUrlExtension(String url) {
    return url.split('.').isNotEmpty ? url.split('.').last : '';
  }

  static String getFileNameFromUrl(String url) {
    smPrint('URL: $url');
    return url.split('/').isNotEmpty ? url.split('/').last : '';
  }

  static bool isVideoFile(File file) => file.path.endsWith('.mp4') || file.path.endsWith('.mov');

  static bool isImageFile(File file) => file.path.endsWith('.jpg') || file.path.endsWith('.png');

  static bool isVideoUrl(String url) => url.endsWith('.mp4') || url.endsWith('.mov');

  static bool isImageUrl(String url) => url.endsWith('.jpg') || url.endsWith('.png');
  static bool isFileUrl(String url) => url.endsWith('.pdf') || url.endsWith('.docx') || url.endsWith('.doc');

  static MediaType getMediaType(File file) {
    if (isVideoFile(file)) {
      return MediaType.video;
    } else if (isImageFile(file)) {
      return MediaType.image;
    } else {
      return MediaType.other;
    }
  }

  static MediaType getMediaTypeFromUrl(String url) {
    if (isVideoUrl(url)) {
      return MediaType.video;
    } else if (isImageUrl(url)) {
      return MediaType.image;
    } else if (isFileUrl(url)) {
      return MediaType.file;
    } else {
      return MediaType.other;
    }
  }

  /// Get file extension from file path
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// Validate if file extension is allowed for upload category
  static bool isValidFileExtension(String filePath, List<String> allowedExtensions) {
    final extension = getFileExtension(filePath);
    return allowedExtensions.contains(extension);
  }
}

///* Print shortcuts `print()`
void smPrint(dynamic data) {
  if (kDebugMode) {
    debugPrint(data.toString());
  }
}

void smLog(dynamic data) {
  if (kDebugMode) {
    log(data.toString());
  }
}

void printFullText(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
}
