// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

class MediaUpload {
  MediaUpload._();

  /// Upload file using the new storage API flow
  /// [file] - The file to upload
  /// [sessionId] - The session ID as reference
  /// [category] - Upload category (MESSAGE_IMAGE, SESSION_AUDIO)
  static Future<String?> uploadFile({
    required File file,
    required String sessionId,
    FileUploadCategory category = FileUploadCategory.messageImage,
  }) async {
    try {
      final fileName = path.basename(file.path);
      
      // Validate file extension
      if (!Utils.isValidFileExtension(file.path, category.allowedExtensions)) {
        smPrint('Invalid file extension for category ${category.value}. Allowed: ${category.allowedExtensions}');
        return null;
      }

      // Validate file size based on category
      final isValidSize = await _validateFileSize(file, category);
      if (!isValidSize) {
        final maxSize = category == FileUploadCategory.messageImage ? '1 MB' : '10 MB';
        smPrint('File size exceeds limit for category ${category.value}. Maximum allowed: $maxSize');
        return null;
      }

      smPrint('Starting upload for file: $fileName in session: $sessionId');

      // Step 1: Request upload URL and presigned data
      final uploadResult = await sl<SupportRepo>().requestStorageUpload(
        category: category.value,
        referenceId: sessionId,
        filesName: [fileName],
      );

      late UploadResult uploadData;
      uploadResult.when(
        success: (response) {
          if (response.result.isNotEmpty) {
            uploadData = response.result.first;
            smPrint('Received upload URL: ${uploadData.url}');
          } else {
            throw Exception('No upload data received');
          }
        },
        error: (error) {
          throw Exception('Failed to get upload URL: ${error.failure.error}');
        },
      );

      // Step 2: Upload to cloud storage using presigned URL
      final cloudUploadResult = await sl<SupportRepo>().uploadToCloud(
        uploadUrl: uploadData.url,
        fields: uploadData.fields.toFormFields(),
        filePath: file.path,
        fileName: fileName,
      );

      bool uploadSuccess = false;
      cloudUploadResult.when(
        success: (response) {
          uploadSuccess = true;
          smPrint('File uploaded successfully to cloud storage');
        },
        error: (error) {
          throw Exception('Failed to upload to cloud: ${error.failure.error}');
        },
      );

      if (uploadSuccess) {
        // Construct the final file URL
        final fileUrl = '${uploadData.url}/${uploadData.fields.key}';
        smPrint('Upload completed successfully. File URL: $fileUrl');
        return fileUrl;
      } else {
        return null;
      }
    } catch (e) {
      smPrint('Upload failed: $e');
      return null;
    }
  }

  /// Validates file size based on upload category
  /// Images: 1 MB limit, Audio: 10 MB limit
  static Future<bool> _validateFileSize(File file, FileUploadCategory category) async {
    try {
      final fileSizeInBytes = await file.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      
      smPrint('File size: ${fileSizeInMB.toStringAsFixed(2)} MB for category: ${category.value}');
      
      switch (category) {
        case FileUploadCategory.messageImage:
          return fileSizeInMB <= 1.0; // 1 MB limit for images
        case FileUploadCategory.sessionAudio:
          return fileSizeInMB <= 10.0; // 10 MB limit for audio
        case FileUploadCategory.profilePicture:
          return fileSizeInMB <= 1.0; // 1 MB limit for profile picture
      }
    } catch (e) {
      smPrint('Error checking file size: $e');
      return false;
    }
  }

  /// Legacy method for backward compatibility
  @Deprecated('Use uploadFile with sessionId and category parameters')
  static Future<String?> uploadFileLegacy({
    required File file,
  }) async {
    // Keep the old implementation commented for reference
    return null;
  }
}

String getContentType(File file) {
  final String mimeType = lookupMimeType(file.path) ?? 'application/json';
  smPrint('>>>> mimeType:$mimeType');
  return mimeType;
  // final fileExtension = path.extension(file.path);
  // switch (fileExtension) {
  //   case '.mp4':
  //     return 'video/mp4';
  //   case '.mov':
  //     return 'video/quicktime';
  //   case '.png':
  //     return 'image/png';
  //   case '.jpg':
  //     return 'image/jpg';
  //   default:
  //     return 'application/json';
  // }
}
