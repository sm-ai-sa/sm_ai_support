import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

/// Utility class for resolving media URLs (images, audio, etc.) through the download API
class ImageUrlResolver {
  ImageUrlResolver._();

  /// Cache to store resolved URLs to avoid repeated API calls
  static final Map<String, String> _urlCache = {};

  /// Resolves a media file name to its download URL
  /// [fileName] - The file name as stored in the message content (or direct URL)
  /// [sessionId] - The session ID where the media was sent
  /// [category] - The file category (MESSAGE_IMAGE, SESSION_AUDIO, etc.)
  static Future<String?> resolveImageUrl({
    required String fileName,
    required String sessionId,
    FileUploadCategory category = FileUploadCategory.messageImage,
  }) async {
    try {
      // If it's already a direct URL, return it immediately (no API call)
      if (isDirectDownloadUrl(fileName)) {
        smPrint('✅ Using direct URL (no API call): $fileName');
        return fileName;
      }

      // Create a cache key for non-direct URLs
      final cacheKey = '${category.value}_${sessionId}_$fileName';
      
      // Check if URL is already cached
      if (_urlCache.containsKey(cacheKey)) {
        smPrint('Image URL found in cache for: $fileName');
        return _urlCache[cacheKey];
      }

      smPrint('Resolving image URL for: $fileName in session: $sessionId');

      // Request download URL from API (fallback for file names)
      final downloadResult = await sl<SupportRepo>().requestStorageDownload(
        category: category.value,
        referenceId: sessionId,
        filesName: [fileName],
      );

      String? resolvedUrl;
      downloadResult.when(
        success: (response) {
          if (response.result.isNotEmpty) {
            resolvedUrl = response.result.first.url;
            smPrint('Successfully resolved image URL: $resolvedUrl');
            
            // Cache the resolved URL
            _urlCache[cacheKey] = resolvedUrl!;
          } else {
            smPrint('No download URL received for: $fileName');
          }
        },
        error: (error) {
          smPrint('Failed to resolve image URL: ${error.failure.error}');
        },
      );

      return resolvedUrl;
    } catch (e) {
      smPrint('Error resolving image URL: $e');
      return null;
    }
  }

  /// Checks if a URL is already a fully resolved download URL
  /// Returns true if the URL appears to be a direct download URL
  static bool isDirectDownloadUrl(String url) {
    // Check if it's already a valid HTTP/HTTPS URL
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return true;
    }
    
    // Check if URL contains common cloud storage patterns
    if (url.contains('digitaloceanspaces.com') ||
        url.contains('amazonaws.com') ||
        url.contains('X-Amz-Algorithm')) {
      return true;
    }

    return false;
  }

  /// Extracts the file name from a URL or returns the input if it's just a file name
  static String extractFileName(String urlOrFileName) {
    // If it's already just a file name, return it
    if (!urlOrFileName.contains('/')) {
      return urlOrFileName;
    }

    // Extract file name from URL
    final uri = Uri.tryParse(urlOrFileName);
    if (uri != null) {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return segments.last;
      }
    }

    // Fallback: get the last part after the last '/'
    return urlOrFileName.split('/').last.split('?').first;
  }

  /// Clears the URL cache (useful for memory management or testing)
  static void clearCache() {
    _urlCache.clear();
    smPrint('Image URL cache cleared');
  }

  /// Gets the current cache size
  static int get cacheSize => _urlCache.length;

  /// Alias for resolveImageUrl - more generic name for any media type
  static Future<String?> resolveMediaUrl({
    required String fileName,
    required String sessionId,
    FileUploadCategory category = FileUploadCategory.messageImage,
  }) => resolveImageUrl(
        fileName: fileName,
        sessionId: sessionId,
        category: category,
      );

  /// Resolves tenant logo URL using PROFILE_PICTURE category
  /// [logoFileName] - The logo file name from tenant data
  /// [tenantId] - The tenant ID as reference
  static Future<String?> resolveTenantLogo({
    required String logoFileName,
    required String tenantId,
  }) async {
    try {
      smPrint('Resolving tenant logo: $logoFileName for tenant: $tenantId');
      
      return await resolveImageUrl(
        fileName: logoFileName,
        sessionId: tenantId, // Using tenantId as reference
        category: FileUploadCategory.profilePicture,
      );
    } catch (e) {
      smPrint('Error resolving tenant logo: $e');
      return null;
    }
  }

  /// Resolves tenant logo URL with fallback to placeholder
  /// [logoFileName] - The logo file name from tenant data (can be null/empty)
  /// [tenantId] - The tenant ID as reference
  /// [fallbackUrl] - Fallback URL if resolution fails (optional)
  static Future<String> resolveTenantLogoWithFallback({
    required String? logoFileName,
    required String tenantId,
    String fallbackUrl = 'https://via.placeholder.com/80x80',
  }) async {
    // Return fallback immediately if logo file name is null or empty
    if (logoFileName == null || logoFileName.isEmpty) {
      smPrint('No logo file name provided for tenant: $tenantId, using fallback');
      return fallbackUrl;
    }

    // Try to resolve the logo URL
    final resolvedUrl = await resolveTenantLogo(
      logoFileName: logoFileName,
      tenantId: tenantId,
    );

    // Return resolved URL or fallback
    if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
      smPrint('Tenant logo resolved successfully: $resolvedUrl');
      return resolvedUrl;
    } else {
      smPrint('Failed to resolve tenant logo, using fallback: $fallbackUrl');
      return fallbackUrl;
    }
  }
}
