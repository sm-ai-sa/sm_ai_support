import 'package:sm_ai_support/src/core/models/verto_auth_response.dart';
import 'package:sm_ai_support/src/core/network/error/error_handler.dart';
import 'package:sm_ai_support/src/core/network/network_result.dart';
import 'package:sm_ai_support/src/core/network/network_services.dart';
import 'package:sm_ai_support/src/core/services/webrtc_service.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

class WebRTCRepo {
  /// Call `in-app/start-call-session` to get JWT, vertoPassword, vertoUrl, iceServers
  Future<NetworkResult<VertoAuthResponse>> startCallSession() async {
    try {
      final response = await networkServices.startCallSession();
      final data = response.data as Map<String, dynamic>;
      final authResponse = VertoAuthResponse.fromJson(data["result"]);
      smPrint('WebRTC startCallSession: Success');
      return Success(authResponse);
    } catch (e) {
      smPrint('WebRTC startCallSession Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Connect to the Verto WebSocket (service must be configured first)
  Future<NetworkResult<bool>> connect() async {
    try {
      final result = await WebRTCService.instance.connect();
      smPrint('WebRTC Connect: $result');
      return Success(result);
    } catch (e) {
      smPrint('WebRTC Connect Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Make a call to a destination
  Future<NetworkResult<bool>> makeCall(String destination) async {
    try {
      await WebRTCService.instance.makeCall(destination);
      smPrint('WebRTC MakeCall: Success - destination: $destination');
      return Success(true);
    } catch (e) {
      smPrint('WebRTC MakeCall Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Hang up the current call
  Future<NetworkResult<bool>> hangup() async {
    try {
      await WebRTCService.instance.hangup();
      smPrint('WebRTC Hangup: Success');
      return Success(true);
    } catch (e) {
      smPrint('WebRTC Hangup Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Disconnect from the Verto server entirely
  Future<NetworkResult<bool>> disconnect() async {
    try {
      await WebRTCService.instance.disconnect();
      smPrint('WebRTC Disconnect: Success');
      return Success(true);
    } catch (e) {
      smPrint('WebRTC Disconnect Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }
}
