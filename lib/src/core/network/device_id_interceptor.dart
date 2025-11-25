import 'package:dio/dio.dart';
import '../services/device_id_manager.dart';
import '../utils/utils.dart';

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
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Get device ID synchronously first to avoid blocking if already available
    String? deviceId = _deviceIdManager.getDeviceIdSync();

    // CRITICAL: If device ID is null or empty, initialize it now
    // This ensures device-id header is ALWAYS sent with every API request
    if (deviceId == null || deviceId.isEmpty) {
      smPrint('⚠️ DeviceIdInterceptor: Device ID not initialized, initializing now...');

      // Initialize device ID asynchronously - this will generate and save it
      deviceId = await _deviceIdManager.getDeviceId();

      smPrint('✅ DeviceIdInterceptor: Device ID initialized: ${deviceId.substring(0, 8)}...');
    }

    // Add device-id header to the request (always required)
    options.headers['device-id'] = deviceId;

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
