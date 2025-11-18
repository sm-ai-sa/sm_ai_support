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
  final String presignedUrl;
  final String fileName;

  const UploadResult({
    required this.presignedUrl,
    required this.fileName,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      presignedUrl: json['url'] as String,
      fileName: json['fileName'] as String,
    );
  }

  @override
  List<Object?> get props => [presignedUrl, fileName];
}

/// File upload categories as defined in the API
/// Now simplified to use SESSION_MEDIA for all media uploads
enum FileUploadCategory {
  sessionMedia('SESSION_MEDIA'),
  profilePicture('PROFILE_PICTURE'); // Keep for future use (tenant logos)

  const FileUploadCategory(this.value);
  final String value;

  /// Get all allowed media extensions (images, videos, audio, documents)
  static List<String> get allAllowedExtensions {
    return [
      // Images
      'jpg', 'jpeg', 'png',
      // Videos
      'mp4', 'avi', 'webm',
      // Audio
      'mp3', 'wav',
      // Documents
      'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'zip',
    ];
  }

  /// Get all allowed extensions for media picker (images + videos only)
  static List<String> get allMediaExtensions {
    return [
      'jpg', 'jpeg', 'png',
      'mp4', 'avi', 'webm',
    ];
  }

  /// Get all allowed file extensions for document picker
  static List<String> get allFileExtensions {
    return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'zip'];
  }

  /// Validate file extension - returns the category if valid, null if not supported
  /// All valid media files use SESSION_MEDIA category
  static FileUploadCategory? fromExtension(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    
    if (allAllowedExtensions.contains(extension)) {
      return FileUploadCategory.sessionMedia;
    }
    
    return null;
  }

  /// Check if a file extension is allowed
  static bool isExtensionAllowed(String filePath) {
    return fromExtension(filePath) != null;
  }
}

/// File media type enum for UI display and validation purposes
/// Separate from FileUploadCategory which is used for API calls
enum FileMediaType {
  image,
  video,
  audio,
  file,
  unknown;

  /// Detect media type from file extension
  static FileMediaType fromExtension(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    
    // Images
    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      return FileMediaType.image;
    }
    
    // Videos
    if (['mp4', 'mov', 'avi', 'webm'].contains(extension)) {
      return FileMediaType.video;
    }
    
    // Audio
    if (['mp3', 'wav'].contains(extension)) {
      return FileMediaType.audio;
    }
    
    // Documents
    if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'zip'].contains(extension)) {
      return FileMediaType.file;
    }
    
    return FileMediaType.unknown;
  }

  /// Get allowed extensions for this media type
  List<String> get allowedExtensions {
    switch (this) {
      case FileMediaType.image:
        return ['jpg', 'jpeg', 'png'];
      case FileMediaType.video:
        return ['mp4', 'mov', 'avi', 'webm'];
      case FileMediaType.audio:
        return ['mp3', 'wav'];
      case FileMediaType.file:
        return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'zip'];
      case FileMediaType.unknown:
        return [];
    }
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
