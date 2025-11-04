import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sm_ai_support/src/core/security/hmac_signature_helper.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

/// Dio interceptor for adding HMAC signature authentication to requests
/// Automatically signs requests with timestamp and HMAC-SHA256 signature
class HmacInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Check if HMAC signature should be applied to this request
      // Use full URI to check for external domains and video URLs
      final fullUrl = options.uri.toString();
      if (!HmacSignatureHelper.shouldApplyHmacSignature(fullUrl)) {
        smPrint('🔐 HMAC Interceptor: Skipping signature for URL: $fullUrl');
        handler.next(options);
        return;
      }

      // Check if secret key is available
      final hasSecretKey = await HmacSignatureHelper.hasSecretKey();
      if (!hasSecretKey) {
        smPrint('🔐 HMAC Interceptor: No secret key found, skipping signature');
        handler.next(options);
        return;
      }

      smPrint('🔐 HMAC Interceptor: Generating signature for ${options.method} ${options.path}');

      // Check if this is a multipart/form-data request (file upload)
      if (options.data is FormData) {
        smPrint('🔐 HMAC Interceptor: FormData detected (file upload) - Skipping HMAC signature');
        smPrint('🔐 HMAC Interceptor: File uploads use presigned URLs, HMAC not required for actual upload');
        
        // Still add API key for the upload request endpoint (not the presigned URL upload)
        final apiKey = await HmacSignatureHelper.getSecretKey();
        if (apiKey != null) {
          options.headers['x-api-key'] = apiKey;
        }
        
        handler.next(options);
        return;
      }

      // Get request body as string for HMAC signature
      // For GET requests, use "GET" + query string instead of body
      String requestBody = '';
      if (options.method.toUpperCase() == 'GET') {
        // Extract query string from URI
        final uri = options.uri;
        final queryString = uri.query.isEmpty ? '' : uri.query;
        requestBody = 'GET$queryString';
        smPrint('🔐 HMAC Interceptor: Using "GET$queryString" for signature (GET request)');
      } else if (options.data != null) {
        if (options.data is String) {
          requestBody = options.data as String;
        } else if (options.data is Map || options.data is List) {
          requestBody = jsonEncode(options.data);
        } else {
          requestBody = options.data.toString();
        }
      }

      // Generate HMAC signature
      final authHeaders = await HmacSignatureHelper.generateAuthHeaders(requestBody);
      if (authHeaders == null) {
        smPrint('🔐 HMAC Interceptor: Failed to generate signature, proceeding without');
        handler.next(options);
        return;
      }

      // Add HMAC headers to request
      final updatedHeaders = Map<String, dynamic>.from(options.headers);
      updatedHeaders.addAll(authHeaders);
      options.headers = updatedHeaders;

      smPrint('🔐 HMAC Interceptor: Signature added to request headers');
      smPrint('🔐 Headers: X-Timestamp=${authHeaders['X-Timestamp']}, X-Signature=${authHeaders['X-Signature']?.substring(0, 8)}...');

      handler.next(options);
    } catch (e) {
      smPrint('🔐 HMAC Interceptor Error: $e');
      // Continue with request even if signature fails
      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log successful requests with HMAC signature
    if (response.requestOptions.headers.containsKey('X-Signature')) {
      smPrint('🔐 HMAC Interceptor: Request with signature completed successfully (${response.statusCode})');
    }
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    // Log errors for requests with HMAC signature
    if (error.requestOptions.headers.containsKey('X-Signature')) {
      smPrint('🔐 HMAC Interceptor: Request with signature failed (${error.response?.statusCode ?? 'No status'})');
      
      // Check for signature-related errors
      if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
        smPrint('🔐 HMAC Interceptor: Possible signature authentication failure');
      }
    }
    handler.next(error);
  }
}

/// Specialized HMAC interceptor for specific endpoints
/// Use this when you need different HMAC behavior for different API endpoints
class ConditionalHmacInterceptor extends HmacInterceptor {
  final List<String> includePaths;
  final List<String> excludePaths;
  final bool Function(RequestOptions)? customCondition;

  ConditionalHmacInterceptor({
    this.includePaths = const [],
    this.excludePaths = const [],
    this.customCondition,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Check custom condition first
    if (customCondition != null && !customCondition!(options)) {
      handler.next(options);
      return;
    }

    // Check exclude paths
    if (excludePaths.any((path) => options.path.contains(path))) {
      handler.next(options);
      return;
    }

    // Check include paths (if specified, only these paths will be signed)
    if (includePaths.isNotEmpty && !includePaths.any((path) => options.path.contains(path))) {
      handler.next(options);
      return;
    }

    // Apply HMAC signature
    super.onRequest(options, handler);
  }
}
