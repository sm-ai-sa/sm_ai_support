import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/primary_snack_bar.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

class PickerHelper {
  PickerHelper._();

  static Future<File?> pickMedia(BuildContext context) async {
    final media = await ImagePicker().pickMedia();
    if (media == null) return null;
    File mediaFile = File(media.path);
    final isValidSize = await sizeValidation(file: mediaFile);
    if (!isValidSize) {
      primarySnackBar(context, message: 'حجم الملف كبير لا يمكن رفعه');
      return null;
    }
    return mediaFile;
  }

  static pickImageFromCamera(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return null;
    File file = File(image.path);

    final isValidSize = await sizeValidation(file: file);
    if (!isValidSize) {
      primarySnackBar(context, message: 'حجم الملف كبير لا يمكن رفعه');
      return null;
    }
    return file;
  }

  //* Size Image Validation -----------------------------------
  static Future<bool> sizeValidation({required File file}) async {
    bool isValid = false;
    //* check file size
    int fileSizeInBytes = await file.length();
    //* Convert the size to megabytes
    double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    smPrint('fileSizeInMB : $fileSizeInMB');
    if (fileSizeInMB > 20) {
      isValid = false;
    } else {
      isValid = true;
    }

    return isValid;
  }

  //* Pick File ----------------------------------------------
  /// Pick a file (document) with allowed extensions
  /// Returns the file along with its detected category
  static Future<({File file, FileUploadCategory category})?> pickFile(BuildContext context) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        return null;
      }
    }

    final allowedExtensions = FileUploadCategory.allFileExtensions;

    final selectedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (selectedFile != null && selectedFile.files.single.path != null) {
      final file = File(selectedFile.files.single.path!);
      
      // Determine category from extension
      final category = FileUploadCategory.fromExtension(file.path);
      
      if (category == null) {
        primarySnackBar(context, message: 'File type not supported. Allowed: ${allowedExtensions.join(", ")}');
        return null;
      }

      // Validate file size
      final isValidSize = await sizeValidation(file: file);
      if (!isValidSize) {
        primarySnackBar(context, message: 'File size is too large (max 20MB)');
        return null;
      }

      return (file: file, category: category);
    }
    
    return null;
  }

  //* Pick Media (Image/Video) with automatic category detection
  /// Pick media from gallery with automatic category detection based on extension
  /// Returns the file along with its detected category
  static Future<({File file, FileUploadCategory category})?> pickMediaWithValidation(BuildContext context) async {
    // Use pickMedia for images and videos
    File? selectedFile = await pickMedia(context);
    
    if (selectedFile == null) return null;

    // Determine category from extension
    final category = FileUploadCategory.fromExtension(selectedFile.path);
    
    if (category == null) {
      final allowedExtensions = FileUploadCategory.allMediaExtensions;
      primarySnackBar(context, message: 'File type not supported. Allowed: ${allowedExtensions.join(", ")}');
      return null;
    }

    // Validate that it's actually media (image or video)
    if (category != FileUploadCategory.messageImage && category != FileUploadCategory.sessionVideo) {
      primarySnackBar(context, message: 'Please select an image or video file');
      return null;
    }

    // Size validation already done in pickMedia
    return (file: selectedFile, category: category);
  }

  //* Pick Image from camera with automatic category detection
  /// Returns the file with messageImage category
  static Future<({File file, FileUploadCategory category})?> pickImageFromCameraWithCategory(BuildContext context) async {
    final File? file = await pickImageFromCamera(context);
    if (file == null) return null;
    
    return (file: file, category: FileUploadCategory.messageImage);
  }
}
