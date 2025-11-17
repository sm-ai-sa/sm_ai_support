import 'package:dio/dio.dart';
import '../services/device_id_manager.dart';

/// Dio interceptor that adds device ID to all HTTP requests.
///
/// This interceptor automatically injects the 'device-id' header into every
/// outgoing HTTP request. The device ID is retrieved synchronously from the
/// DeviceIdManager to avoid blocking the request.
///
/// Header format: `device-id: <uuid>`
///
/// If the device ID is not available (not initialized), the header will not be added.
/// This should not happen in normal operation since DeviceIdManager is initialized
/// during app startup.
class DeviceIdInterceptor extends Interceptor {
  final DeviceIdManager _deviceIdManager;

  DeviceIdInterceptor({DeviceIdManager? deviceIdManager})
      : _deviceIdManager = deviceIdManager ?? DeviceIdManager.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Get device ID synchronously to avoid blocking the request
    final deviceId = _deviceIdManager.getDeviceIdSync();

    if (deviceId != null && deviceId.isNotEmpty) {
      // Add device-id header to the request
      options.headers['device-id'] = deviceId;
    } else {
      // Device ID not initialized - this shouldn't happen in normal operation
      // Log warning but don't block the request
      // In production, you might want to initialize synchronously here as fallback
    }

    // Continue with the request
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Pass through errors unchanged
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Pass through responses unchanged
    handler.next(response);
  }
}
