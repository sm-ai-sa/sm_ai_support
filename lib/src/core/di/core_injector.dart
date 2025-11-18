import 'package:get_it/get_it.dart';
import 'package:sm_ai_support/src/core/network/network_services.dart';
import 'package:sm_ai_support/src/core/services/websocket_service.dart';
import 'package:sm_ai_support/src/core/services/device_id_manager.dart';

Future<void> init(GetIt instance) async {
  // Register DeviceIdManager singleton
  if (!instance.isRegistered<DeviceIdManager>()) {
    instance.registerLazySingleton<DeviceIdManager>(() => DeviceIdManager.instance);
  }

  if (!instance.isRegistered<NetworkServices>()) {
    instance.registerLazySingleton<NetworkServices>(() => NetworkServices());
  }

  if (!instance.isRegistered<WebSocketService>()) {
    instance.registerLazySingleton<WebSocketService>(() => WebSocketService.instance);
  }
}
