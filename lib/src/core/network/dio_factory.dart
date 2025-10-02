import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/config/sm_support_config.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

class DioFactory {
  //* Singleton __________________________________
  DioFactory._();
  static DioFactory? _instance;
  static final _lock = Completer<void>();

  static DioFactory get instance {
    if (_instance == null) {
      if (!_lock.isCompleted) _lock.complete();
      _instance = DioFactory._();
    }
    return _instance!;
  }
  //* _____________________________________________

  static Dio? dio;

  static Dio getDio() {
    Duration timeOut = const Duration(seconds: 60); // Increased timeout for better Android compatibility

    if (dio == null) {
      dio = Dio();

      // Configure timeouts
      dio!
        ..options.connectTimeout = timeOut
        ..options.receiveTimeout = timeOut
        ..options.sendTimeout = timeOut; // Added missing sendTimeout

      // Android-specific configurations
      _configureAndroidSpecific();

      addDioHeaders();
      addSMSecretInterceptor(); // Add SM Secret interceptor FIRST
      addAuthInterceptor(); // Add auth interceptor
      addDioInterceptor(); // Add logging interceptor AFTER headers are set
      addAppInterceptor();
      return dio!;
    } else {
      return dio!;
    }
  }

  /// Force recreate Dio instance (useful when locale or other global settings change)
  static void resetDio({String? newLocale}) {
    dio?.close();
    dio = null;
    _pendingLocale = newLocale; // Store the new locale temporarily
  }

  /// Update locale and refresh headers (alternative to full reset)
  static void updateLocale() {
    if (dio != null) {
      // The AppInterceptor will handle the locale update on the next request
      // This method is provided for potential future use if immediate header update is needed
      addDioHeaders();
    }
  }

  // Temporary storage for locale during reset
  static String? _pendingLocale;

  //* ANDROID SPECIFIC CONFIGURATION -------------------------
  static void _configureAndroidSpecific() {
    if (Platform.isAndroid) {
      // Configure HttpClient for Android with better connection handling
      (dio!.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();

        // Increase connection timeout for Android
        client.connectionTimeout = const Duration(seconds: 60);
        client.idleTimeout = const Duration(seconds: 30);

        // Better connection management for Android
        client.maxConnectionsPerHost = 5;

        // Allow bad certificates for debugging (only in debug mode)
        if (kDebugMode) {
          client.badCertificateCallback = (cert, host, port) => true;
        }

        return client;
      };
    }
  }

  //* ADD : DIO INTERCEPTORS -------------------------------------
  static void addDioInterceptor() {
    if (!kReleaseMode) {
      dio?.interceptors.add(PrettyDioLogger(requestBody: true, requestHeader: true, responseHeader: true));
    }

    // Add retry interceptor for Android connection issues
    dio?.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Handle specific Android network errors
          if (Platform.isAndroid && _shouldRetryRequest(error)) {
            _retryRequest(error, handler);
            return;
          }
          handler.next(error);
        },
      ),
    );
  }

  //* RETRY LOGIC FOR ANDROID NETWORK ISSUES -------------------------
  static bool _shouldRetryRequest(DioException error) {
    // Retry on connection timeout or socket exceptions
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        (error.type == DioExceptionType.unknown && error.error?.toString().contains('SocketException') == true);
  }

  static void _retryRequest(DioException error, ErrorInterceptorHandler handler) async {
    try {
      // Wait a bit before retrying
      await Future.delayed(const Duration(milliseconds: 1000));

      // Clone the request options
      final requestOptions = error.requestOptions;

      // Retry the request
      final response = await dio!.request(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: Options(
          method: requestOptions.method,
          headers: requestOptions.headers,
          responseType: requestOptions.responseType,
          contentType: requestOptions.contentType,
        ),
      );

      handler.resolve(response);
    } catch (e) {
      // If retry fails, pass the original error
      handler.next(error);
    }
  }

  //* ADD : AUTH INTERCEPTOR -------------------------------------
  static void addAuthInterceptor() {
    dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Automatically add auth token to all requests if user is authenticated
          final token = AuthManager.getTokenForRequest();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          // Handle 401 errors (unauthorized) - could trigger logout
          if (error.response?.statusCode == 401) {
            // Token might be expired, clear auth data
            AuthManager.logout().then((_) {
              if (kDebugMode) {
                print('Auth token expired, user logged out automatically');
              }
            });
          }
          handler.next(error);
        },
      ),
    );
  }

  //* ADD : SM SECRET INTERCEPTOR -------------------------------------
  static void addSMSecretInterceptor() {
    dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add SMSecret to all requests
          try {
            smPrint('🔐 SMSecret Interceptor: Attempting to retrieve SMSecret...');
            final smSecret = await SMConfig.getSMSecret();
            smPrint(
              '🔐 SMSecret Retrieved: ${smSecret != null ? "✅ Found (${smSecret.length} chars)" : "❌ Not found"}',
            );

            if (smSecret != null && smSecret.isNotEmpty) {
              options.headers['X-API-Key'] = smSecret;
              smPrint('🔐 SMSecret Header Added: SM-Secret = ${smSecret.substring(0, 4)}...');
              smPrint('🔐 All Headers: ${options.headers}');
            } else {
              smPrint('🔐 SMSecret NOT added - secret is null or empty');
            }
          } catch (e) {
            smPrint('🔐 Error retrieving SMSecret for request: $e');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  //* ADD : DIO HEADERS -------------------------------------
  static void addDioHeaders() {
    String tenantId = SMConfig.smData.tenantId;

    // Get current language with fallback, prioritizing pending locale
    String language = 'ar'; // Default fallback

    // First, check if we have a pending locale from reset
    if (_pendingLocale != null) {
      language = _pendingLocale!;
      _pendingLocale = null; // Clear it after use
    } else {
      // Fall back to smCubit state
      try {
        language = smCubit.state.currentLocale ?? 'ar';
      } catch (e) {
        // Use default fallback if smCubit not ready
      }
    }

    dio?.options.headers = {
      "Content-Type": 'application/json',
      "Accept": 'application/json',
      "Accept-Language": language,
      "Accept-Encoding": "gzip, deflate, br",
      "tenant-id": tenantId,
      "Connection": "keep-alive",
      // Note: Authorization header is handled by the auth interceptor
    };
  }

  //* ADD : APP INTERCEPTOR -------------------------------------
  static void addAppInterceptor() {
    dio?.interceptors.add(AppInterceptors());
  }
}

class AppInterceptors extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Get current language from headers first, then fallback to smCubit state
    String language = 'ar'; // Default fallback

    // Try to get from existing headers first (preferred)
    String? headerLanguage = options.headers["Accept-Language"];
    if (headerLanguage != null && headerLanguage.isNotEmpty) {
      language = headerLanguage;
    } else {
      // Fall back to smCubit state if no header exists
      try {
        language = smCubit.state.currentLocale ?? 'ar';
      } catch (e) {
        // Use default fallback if smCubit not available
      }
    }

    // Update the Accept-Language header
    final updatedHeaders = Map<String, dynamic>.from(options.headers);
    updatedHeaders["Accept-Language"] = language;
    options.headers = updatedHeaders;

    handler.next(options);
  }
}
