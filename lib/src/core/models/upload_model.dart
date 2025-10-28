import 'package:equatable/equatable.dart';

/// Request model for storage upload API
class StorageUploadRequest extends Equatable {
  final String category;
  final String referenceId;
  final List<String> filesName;

  const StorageUploadRequest({
    required this.category,
    required this.referenceId,
    required this.filesName,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'referenceId': referenceId,
      'filesName': filesName,
    };
  }

  @override
  List<Object?> get props => [category, referenceId, filesName];
}

/// Response model for storage upload API
class StorageUploadResponse extends Equatable {
  final List<UploadResult> result;
  final int statusCode;

  const StorageUploadResponse({
    required this.result,
    required this.statusCode,
  });

  factory StorageUploadResponse.fromJson(Map<String, dynamic> json) {
    return StorageUploadResponse(
      result: (json['result'] as List<dynamic>)
          .map((item) => UploadResult.fromJson(item as Map<String, dynamic>))
          .toList(),
      statusCode: json['statusCode'] as int,
    );
  }

  @override
  List<Object?> get props => [result, statusCode];
}

/// Individual upload result containing presigned URL details
class UploadResult extends Equatable {
  final String url;
  final UploadFields fields;
  final String fileName;

  const UploadResult({
    required this.url,
    required this.fields,
    required this.fileName,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      url: json['url'] as String,
      fields: UploadFields.fromJson(json['fields'] as Map<String, dynamic>),
      fileName: json['fileName'] as String,
    );
  }

  @override
  List<Object?> get props => [url, fields, fileName];
}

/// Upload fields containing all the necessary data for cloud upload
class UploadFields extends Equatable {
  final String contentType;
  final String bucket;
  final String xAmzAlgorithm;
  final String xAmzCredential;
  final String xAmzDate;
  final String key;
  final String policy;
  final String xAmzSignature;

  const UploadFields({
    required this.contentType,
    required this.bucket,
    required this.xAmzAlgorithm,
    required this.xAmzCredential,
    required this.xAmzDate,
    required this.key,
    required this.policy,
    required this.xAmzSignature,
  });

  factory UploadFields.fromJson(Map<String, dynamic> json) {
    return UploadFields(
      contentType: json['Content-Type'] as String,
      bucket: json['bucket'] as String,
      xAmzAlgorithm: json['X-Amz-Algorithm'] as String,
      xAmzCredential: json['X-Amz-Credential'] as String,
      xAmzDate: json['X-Amz-Date'] as String,
      key: json['key'] as String,
      policy: json['Policy'] as String,
      xAmzSignature: json['X-Amz-Signature'] as String,
    );
  }

  /// Convert to form data fields for the cloud upload
  Map<String, String> toFormFields() {
    return {
      'Content-Type': contentType,
      'bucket': bucket,
      'X-Amz-Algorithm': xAmzAlgorithm,
      'X-Amz-Credential': xAmzCredential,
      'X-Amz-Date': xAmzDate,
      'key': key,
      'Policy': policy,
      'X-Amz-Signature': xAmzSignature,
    };
  }

  @override
  List<Object?> get props => [
        contentType,
        bucket,
        xAmzAlgorithm,
        xAmzCredential,
        xAmzDate,
        key,
        policy,
        xAmzSignature,
      ];
}

/// File upload categories as defined in the API
enum FileUploadCategory {
  messageImage('MESSAGE_IMAGE'),
  sessionAudio('SESSION_AUDIO'),
  sessionVideo('SESSION_VIDEO'),
  sessionFile('SESSION_FILE'),
  profilePicture('PROFILE_PICTURE');

  const FileUploadCategory(this.value);
  final String value;

  /// Get allowed extensions for the category
  List<String> get allowedExtensions {
    switch (this) {
      case FileUploadCategory.messageImage:
        return ['jpg', 'jpeg', 'png']; // MESSAGE_IMAGE extensions from instructions
      case FileUploadCategory.sessionAudio:
        return ['mp3', 'wav']; // SESSION_AUDIO extensions from instructions
      case FileUploadCategory.sessionVideo:
        return ['mp4', 'mov', 'avi', 'webm']; // SESSION_VIDEO extensions
      case FileUploadCategory.sessionFile:
        return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'zip']; // SESSION_FILE extensions
      case FileUploadCategory.profilePicture:
        return ['jpg', 'jpeg', 'png', 'svg']; // PROFILE_PICTURE extensions (tenant logos)
    }
  }

  /// Get all allowed extensions across all categories (for media picker)
  static List<String> get allMediaExtensions {
    return [
      ...FileUploadCategory.messageImage.allowedExtensions,
      ...FileUploadCategory.sessionVideo.allowedExtensions,
    ];
  }

  /// Get all allowed file extensions (for file picker)
  static List<String> get allFileExtensions {
    return FileUploadCategory.sessionFile.allowedExtensions;
  }

  /// Determine the upload category from a file extension
  /// Returns null if the extension is not supported
  static FileUploadCategory? fromExtension(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    
    // Check each category
    if (FileUploadCategory.messageImage.allowedExtensions.contains(extension)) {
      return FileUploadCategory.messageImage;
    } else if (FileUploadCategory.sessionAudio.allowedExtensions.contains(extension)) {
      return FileUploadCategory.sessionAudio;
    } else if (FileUploadCategory.sessionVideo.allowedExtensions.contains(extension)) {
      return FileUploadCategory.sessionVideo;
    } else if (FileUploadCategory.sessionFile.allowedExtensions.contains(extension)) {
      return FileUploadCategory.sessionFile;
    } else if (FileUploadCategory.profilePicture.allowedExtensions.contains(extension)) {
      return FileUploadCategory.profilePicture;
    }
    
    return null;
  }

  /// Check if a file extension is allowed in any category
  static bool isExtensionAllowed(String filePath) {
    return fromExtension(filePath) != null;
  }
}

/// Request model for storage download API
class StorageDownloadRequest extends Equatable {
  final String category;
  final String referenceId;
  final List<String> filesName;

  const StorageDownloadRequest({
    required this.category,
    required this.referenceId,
    required this.filesName,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'referenceId': referenceId,
      'filesName': filesName,
    };
  }

  @override
  List<Object?> get props => [category, referenceId, filesName];
}

/// Response model for storage download API
class StorageDownloadResponse extends Equatable {
  final List<DownloadResult> result;
  final int statusCode;

  const StorageDownloadResponse({
    required this.result,
    required this.statusCode,
  });

  factory StorageDownloadResponse.fromJson(Map<String, dynamic> json) {
    return StorageDownloadResponse(
      result: (json['result'] as List<dynamic>)
          .map((item) => DownloadResult.fromJson(item as Map<String, dynamic>))
          .toList(),
      statusCode: json['statusCode'] as int,
    );
  }

  @override
  List<Object?> get props => [result, statusCode];
}

/// Individual download result containing the download URL
class DownloadResult extends Equatable {
  final String url;
  final String fileName;

  const DownloadResult({
    required this.url,
    required this.fileName,
  });

  factory DownloadResult.fromJson(Map<String, dynamic> json) {
    return DownloadResult(
      url: json['url'] as String,
      fileName: json['fileName'] as String,
    );
  }

  @override
  List<Object?> get props => [url, fileName];
}
