import 'dart:math';

/// Utility class for file operations and formatting
class FileUtils {
  FileUtils._();

  /// Get file extension from URL or filename
  /// Handles URLs with query parameters (extracts extension before '?')
  static String getFileExtensionFromUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) return '';
    
    // Remove query parameters if present (everything after '?')
    String cleanFileName = fileName;
    final queryParamIndex = fileName.indexOf('?');
    if (queryParamIndex != -1) {
      cleanFileName = fileName.substring(0, queryParamIndex);
    }
    
    // Extract the extension
    final lastDotIndex = cleanFileName.lastIndexOf('.');
    if (lastDotIndex == -1) return '';
    
    return cleanFileName.substring(lastDotIndex + 1);
  }

  /// Get file icon name based on file extension
  /// Returns the icon name to use with SvgIcon component from assets/icons/files/
  static String getFileIcon(String? fileName) {
    if (fileName == null || fileName.isEmpty) return 'file-icons-general';
    final fileExtension = getFileExtensionFromUrl(fileName).toLowerCase();

    // Document files
    if (['docx', 'doc'].contains(fileExtension)) return 'ms-word';

    // Spreadsheet files
    if (['xlsx', 'xls', 'csv'].contains(fileExtension)) return 'ms-excel';

    // PDF files
    if (fileExtension == 'pdf') return 'pdf';

    // Image files
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp', 'ico'].contains(fileExtension)) {
      return 'ms-img';
    }

    // Presentation files
    if (['ppt', 'pptx'].contains(fileExtension)) return 'doc';

    // Text files
    if (['txt', 'md', 'json', 'xml'].contains(fileExtension)) return 'doc';

    // Archive files
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(fileExtension)) return 'file-icons-general';

    // Audio files
    if (['mp3', 'wav', 'ogg', 'm4a', 'flac', 'amr'].contains(fileExtension)) {
      return 'file-icons-general';
    }

    // Default for unknown types
    return 'file-icons-general';
  }

  /// Check if file is a video based on extension
  static bool isVideoFile(String? fileName) {
    if (fileName == null || fileName.isEmpty) return false;
    const videoExtensions = ['mp4', 'mov', 'avi', 'wmv', 'flv', 'webm'];
    final fileExtension = getFileExtensionFromUrl(fileName);
    return videoExtensions.contains(fileExtension.toLowerCase());
  }

  /// Format file size from bytes to human readable format
  /// Example: 1024 bytes => "1.0 KB", 1048576 bytes => "1.0 MB"
  static String formatFileSize(int? bytes) {
    if (bytes == null || bytes == 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    final i = (log(bytes) / log(k)).floor();
    final value = bytes / pow(k, i);

    // Format with 1 decimal place
    final formattedValue = value.toStringAsFixed(1);
    return '$formattedValue ${sizes[i]}';
  }

  /// Check if file is an image based on extension
  static bool isImageFile(String? fileName) {
    if (fileName == null || fileName.isEmpty) return false;
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp', 'ico'];
    final fileExtension = getFileExtensionFromUrl(fileName);
    return imageExtensions.contains(fileExtension.toLowerCase());
  }

  /// Check if file is an audio file based on extension
  static bool isAudioFile(String? fileName) {
    if (fileName == null || fileName.isEmpty) return false;
    const audioExtensions = ['mp3', 'wav', 'ogg', 'm4a', 'flac', 'amr'];
    final fileExtension = getFileExtensionFromUrl(fileName);
    return audioExtensions.contains(fileExtension.toLowerCase());
  }

  /// Get display name from filename or URL
  /// Handles URLs with query parameters (extracts filename before '?')
  static String getFileDisplayName(String? fileName) {
    if (fileName == null || fileName.isEmpty) return 'Unknown File';
    
    // Remove query parameters if present (everything after '?')
    String cleanFileName = fileName;
    final queryParamIndex = fileName.indexOf('?');
    if (queryParamIndex != -1) {
      cleanFileName = fileName.substring(0, queryParamIndex);
    }
    
    // Extract filename from path (last segment after '/')
    final lastSlashIndex = cleanFileName.lastIndexOf('/');
    final nameWithoutPath = lastSlashIndex == -1 ? cleanFileName : cleanFileName.substring(lastSlashIndex + 1);
    
    return nameWithoutPath;
  }
}

