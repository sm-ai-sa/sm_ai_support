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
  static Future<File?> pickFile() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        return null;
      }
    }

    File? selectedAttachmentFile;
    FilePickerResult? selectedFile;

    selectedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'docx',
        'doc',
      ],
    );

    if (selectedFile != null && selectedFile.files.single.path != null) {
      selectedAttachmentFile = File(selectedFile.files.single.path!);
      return selectedAttachmentFile;
    } else {
      return null;
    }
  }

  //* Pick Media with Category Validation ----------------------------------------------
  static Future<File?> pickMediaWithValidation(BuildContext context, {
    required FileUploadCategory category,
  }) async {
    File? selectedFile;

    switch (category) {
      case FileUploadCategory.messageImage:
        selectedFile = await pickMedia(context);
        break;
      case FileUploadCategory.sessionAudio:
        selectedFile = await pickAudioFile(context);
        break;
      case FileUploadCategory.profilePicture:
        selectedFile = await pickMedia(context);
        break;
    }

    if (selectedFile == null) return null;

    // Validate file extension
    if (!Utils.isValidFileExtension(selectedFile.path, category.allowedExtensions)) {
      primarySnackBar(context, message: 'File type not allowed. Allowed extensions: ${category.allowedExtensions.join(", ")}');
      return null;
    }

    // Validate file size
    final isValidSize = await sizeValidation(file: selectedFile);
    if (!isValidSize) {
      primarySnackBar(context, message: 'File size is too large (max 20MB)');
      return null;
    }

    return selectedFile;
  }

  //* Pick Audio File ----------------------------------------------
  static Future<File?> pickAudioFile(BuildContext context) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        return null;
      }
    }

    File? selectedAudioFile;
    FilePickerResult? selectedFile;

    selectedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: FileUploadCategory.sessionAudio.allowedExtensions,
    );

    if (selectedFile != null && selectedFile.files.single.path != null) {
      selectedAudioFile = File(selectedFile.files.single.path!);
      return selectedAudioFile;
    } else {
      return null;
    }
  }
}
