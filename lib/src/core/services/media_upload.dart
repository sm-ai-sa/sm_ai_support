// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

class MediaUpload {
  MediaUpload._();

  /// Upload file using the new storage API flow
  /// [file] - The file to upload
  /// [sessionId] - The session ID as reference
  /// All uploads now use SESSION_MEDIA category
  static Future<String?> uploadFile({
    required File file,
    required String sessionId,
  }) async {
    try {
      final fileName = path.basename(file.path);
      
      // Validate file extension
      if (!FileUploadCategory.isExtensionAllowed(file.path)) {
        smPrint('Invalid file extension. Allowed: ${FileUploadCategory.allAllowedExtensions}');
        return null;
      }

      // Validate file size (max 50 MB for all media)
      final isValidSize = await _validateFileSize(file);
      if (!isValidSize) {
        smPrint('File size exceeds limit. Maximum allowed: 50 MB');
        return null;
      }

      smPrint('Starting upload for file: $fileName in session: $sessionId');

      // Step 1: Request presigned upload URL from backend
      // Always use SESSION_MEDIA category for all uploads
      final uploadResult = await sl<SupportRepo>().requestStorageUpload(
        category: FileUploadCategory.sessionMedia.value,
        referenceId: sessionId,
        filesName: [fileName],
      );

      late UploadResult uploadData;
      uploadResult.when(
        success: (response) {
          if (response.result.isNotEmpty) {
            uploadData = response.result.first;
            smPrint('Received presigned URL for file: ${uploadData.fileName}');
          } else {
            throw Exception('No upload data received');
          }
        },
        error: (error) {
          throw Exception('Failed to get presigned URL: ${error.failure.error}');
        },
      );

      // Step 2: Upload file directly to R2 using presigned URL
      final r2UploadResult = await sl<SupportRepo>().uploadToR2(
        presignedUrl: uploadData.presignedUrl,
        filePath: file.path,
      );

      bool uploadSuccess = false;
      r2UploadResult.when(
        success: (response) {
          uploadSuccess = true;
          smPrint('File uploaded successfully to R2 storage');
        },
        error: (error) {
          throw Exception('Failed to upload to R2: ${error.failure.error}');
        },
      );

      if (uploadSuccess) {
        // Return the fileName from the upload result
        // The backend will construct the full URL when needed
        smPrint('Upload completed successfully. File name: ${uploadData.fileName}');
        return uploadData.fileName;
      } else {
        return null;
      }
    } catch (e) {
      smPrint('Upload failed: $e');
      return null;
    }
  }

  /// Validates file size - 50 MB limit for all media files
  static Future<bool> _validateFileSize(File file) async {
    try {
      final fileSizeInBytes = await file.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      
      smPrint('File size: ${fileSizeInMB.toStringAsFixed(2)} MB');
      
      // 50 MB limit for all media files
      return fileSizeInMB <= 10.0;
    } catch (e) {
      smPrint('Error checking file size: $e');
      return false;
    }
  }

}
