import 'dart:async';
import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sm_ai_support/src/core/models/webrtc_call_model.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Singleton service for WebRTC voice calling via Verto protocol.
///
/// Protocol logic mirrors the reference VertoService exactly.
class WebRTCService {
  static WebRTCService? _instance;
  static WebRTCService get instance => _instance ??= WebRTCService._();

  WebRTCService._();

  // ── Configuration (set via [configure] before [connect]) ──
  String? _jwtToken;
  String? _vertoCatchallPassword;
  String? _vertoUrl;
  String? _destination;
  String? _smSessionId;
  List<Map<String, dynamic>>? _iceServers;

  // ── Connection state ──
  WebSocketChannel? _channel;
  String? _sessionId;
  int _messageId = 1;
  Completer<bool>? _loginCompleter;
  int? _loginMessageId;
  bool _wsConnected = false;

  // ── Call state ──
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  String? _callId;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  DateTime? _callStartTime;

  // ── Stream controllers for reactive state ──
  final StreamController<WebRTCCallPhase> _callPhaseController = StreamController<WebRTCCallPhase>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();
  final StreamController<MediaStream?> _remoteStreamController = StreamController<MediaStream?>.broadcast();

  // ── Public streams ──
  Stream<WebRTCCallPhase> get callPhaseStream => _callPhaseController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<MediaStream?> get remoteStreamStream => _remoteStreamController.stream;

  // ── Public getters ──
  bool get isConnected => _wsConnected;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  String? get callId => _callId;
  DateTime? get callStartTime => _callStartTime;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  String? get smSessionId => _smSessionId;
  WebRTCCallPhase _currentPhase = WebRTCCallPhase.idle;
  WebRTCCallPhase get currentPhase => _currentPhase;

  // ── Configuration ──

  /// Configure the service with credentials obtained from `start-call-session`.
  void configure({
    required String jwtToken,
    required String vertoCatchallPassword,
    required String vertoUrl,
    required String destination,
    required String callId,
    required String smSessionId,
    List<Map<String, dynamic>>? iceServers,
  }) {
    _jwtToken = jwtToken;
    _vertoCatchallPassword = vertoCatchallPassword;
    _vertoUrl = vertoUrl;
    _destination = destination;
    _iceServers = iceServers;
    _callId = callId;
    _smSessionId = smSessionId;
  }

  // ── Connection ──

  /// Connect to the Verto WebSocket and perform login handshake.
  Future<bool> connect() async {
    if (_jwtToken == null || _vertoUrl == null || _vertoCatchallPassword == null) {
      const error = 'Missing config — call configure() first';
      smLog('WebRTCService: $error');
      _errorController.add(error);
      return false;
    }

    try {
      _sessionId = 'flutter-${DateTime.now().millisecondsSinceEpoch}';
      _channel = WebSocketChannel.connect(Uri.parse(_vertoUrl!));

      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          smLog('WebRTCService: WebSocket error: $error');
          _wsConnected = false;
          _authError = 'WebSocket error: $error';
          if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
            _loginCompleter!.complete(false);
          }
          _errorController.add('WebSocket error: $error');
        },
        onDone: () {
          smLog('WebRTCService: WebSocket closed');
          _wsConnected = false;
          if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
            _authError ??= 'WebSocket closed before login completed';
            _loginCompleter!.complete(false);
          }
          if (_currentPhase != WebRTCCallPhase.idle) {
            _cleanupCall();
          }
        },
      );

      // Send Verto login with type-prefixed JWT (matches reference)
      _loginCompleter = Completer<bool>();
      _loginMessageId = _messageId;
      _sendMessage({
        'jsonrpc': '2.0',
        'method': 'login',
        'params': {
          'login': 'client:$_jwtToken',
          'passwd': _vertoCatchallPassword,
          'sessid': _sessionId,
        },
        'id': _messageId++,
      });
      smLog('WebRTCService: Login sent to $_vertoUrl');

      // Wait for login response with timeout
      final loginResult = await _loginCompleter!.future.timeout(const Duration(seconds: 10), onTimeout: () {
        smLog('WebRTCService: Login timeout — proceeding');
        return true; // Proceed on timeout (server may not send explicit response)
      });

      if (!loginResult) {
        _wsConnected = false;
        _errorController.add(_authError ?? 'Login failed');
        return false;
      }

      _wsConnected = true;

      // Subscribe to network_quality channel for RTCP monitoring
      _subscribeToChannel('network_quality');
      smLog('WebRTCService: Connected and subscribed to network_quality');

      return true;
    } catch (e) {
      smLog('WebRTCService: Connection failed: $e');
      _errorController.add('Connection failed: $e');
      _wsConnected = false;
      return false;
    }
  }

  void _subscribeToChannel(String channel) {
    _sendMessage({
      'jsonrpc': '2.0',
      'method': 'verto.subscribe',
      'params': {
        'sessid': _sessionId,
        'eventChannel': [channel],
      },
      'id': _messageId++,
    });
  }

  // ── Call ──

  /// Make a call to [dest] (or the configured destination).
  Future<void> makeCall([String? dest]) async {
    if (_currentPhase != WebRTCCallPhase.idle || _peerConnection != null) {
      smLog('WebRTCService: makeCall ignored — already in $_currentPhase');
      return;
    }
    final target = dest ?? _destination ?? 'human';
    _setCallPhase(WebRTCCallPhase.connecting);
    _callStartTime = null;
    smLog('WebRTCService: Calling "$target"');

    try {
      _peerConnection = await createPeerConnection({
        'iceServers': _iceServers ?? [],
        'iceCandidatePoolSize': 0,
      });

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        smLog('WebRTCService: Remote track received');
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          _remoteStreamController.add(_remoteStream);
        }
      };

      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        smLog('WebRTCService: Peer connection: ${state.name}');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          _callStartTime = DateTime.now();
          _setCallPhase(WebRTCCallPhase.active);
        } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
          if (_currentPhase == WebRTCCallPhase.active) {
            smLog('WebRTCService: Peer connection lost');
            _cleanupCall();
          }
        }
      };

      _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
        smLog('WebRTCService: ICE: ${state.name}');
      };

      // Request microphone permission before accessing media
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        throw Exception('Microphone permission denied — cannot start voice call');
      }

      // Microphone with audio processing (matches reference)
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': false,
      });

      for (var track in _localStream!.getTracks()) {
        _peerConnection!.addTrack(track, _localStream!);
      }

      // SDP offer
      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      });
      await _peerConnection!.setLocalDescription(offer);

      await _waitForIceGathering();

      // Bail out if connection was lost during ICE gathering (e.g. auth_rejected)
      if (_peerConnection == null || _channel == null) {
        smLog('WebRTCService: Connection lost during call setup');
        return;
      }

      final localDesc = await _peerConnection!.getLocalDescription();

      // verto.invite (matches reference)
      _sendMessage({
        'jsonrpc': '2.0',
        'method': 'verto.invite',
        'params': {
          'sessid': _sessionId,
          'sdp': localDesc?.sdp ?? offer.sdp,
          'dialogParams': {
            'callID': _callId,
            'destination_number': target,
            'caller_id_name': 'Flutter Client',
            'caller_id_number': '1000',
            'userVariables': {
              'smSessionId': _smSessionId,
            },
          },
        },
        'id': _messageId++,
      });

      _setCallPhase(WebRTCCallPhase.ringing);
      smLog('WebRTCService: Invite sent');
    } catch (e) {
      smLog('WebRTCService: Call failed: $e');
      _errorController.add('Call failed: $e');
      _cleanupCall();
    }
  }

  Future<void> _waitForIceGathering() async {
    if (_peerConnection?.iceGatheringState == RTCIceGatheringState.RTCIceGatheringStateComplete) {
      return;
    }

    final completer = Completer<void>();
    Timer? timeout;

    _peerConnection!.onIceGatheringState = (state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        if (!completer.isCompleted) completer.complete();
      }
    };

    timeout = Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        smLog('WebRTCService: ICE gathering timeout — using partial candidates');
        completer.complete();
      }
    });

    await completer.future;
    timeout.cancel();
  }

  // ── Message handling ──

  String? _authError;

  void _handleMessage(dynamic message) async {
    try {
      final data = jsonDecode(message);
      final method = data['method'] as String?;
      final id = data['id'];

      // Handle JSON-RPC responses (login result, etc.)
      if (method == null && id != null) {
        _handleResponse(data);
        return;
      }

      switch (method) {
        case 'verto.answer':
          _handleAnswer(data);
          break;

        case 'verto.media':
          _handleMedia(data);
          break;

        case 'verto.bye':
          _handleBye(data);
          break;

        case 'verto.event':
          _handleEvent(data);
          break;

        case 'verto.ping':
          _sendMessage({
            'jsonrpc': '2.0',
            'method': 'verto.ping',
            'params': {'sessid': _sessionId},
            'id': data['id'],
          });
          break;

        case 'verto.display':
          smLog('WebRTCService: Display update: ${data['params']}');
          break;
      }
    } catch (e) {
      smLog('WebRTCService: Message parse error: $e');
    }
  }

  void _handleResponse(Map<String, dynamic> data) {
    final id = data['id'];
    final error = data['error'];

    if (id == _loginMessageId) {
      if (error != null) {
        _authError = error['message'] ?? 'Login failed';
        smLog('WebRTCService: Login rejected: $_authError');
        if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
          _loginCompleter!.complete(false);
        }
      } else {
        smLog('WebRTCService: Login successful');
        if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
          _loginCompleter!.complete(true);
        }
      }
      return;
    }

    // Generic response logging
    if (error != null) {
      smLog('WebRTCService: RPC error [id=$id]: ${error['message']}');
    }
  }

  void _handleAnswer(Map<String, dynamic> data) {
    final sdp = data['params']?['sdp'];
    if (sdp != null) {
      _peerConnection?.setRemoteDescription(
        RTCSessionDescription(sdp, 'answer'),
      );
      _callStartTime = DateTime.now();
      _setCallPhase(WebRTCCallPhase.active);
      smLog('WebRTCService: Call answered');
    }
  }

  void _handleMedia(Map<String, dynamic> data) {
    final sdp = data['params']?['sdp'];
    if (sdp != null) {
      _peerConnection?.setRemoteDescription(
        RTCSessionDescription(sdp, 'answer'),
      );
      smLog('WebRTCService: Early media received');
    }
  }

  Future<void> _handleBye(Map<String, dynamic> data) async {
    final cause = data['params']?['cause'] ?? 'NORMAL_CLEARING';
    smLog('WebRTCService: Remote hangup: $cause');

    // Acknowledge (matches reference)
    _sendMessage({
      'jsonrpc': '2.0',
      'method': 'verto.bye',
      'params': {
        'sessid': _sessionId,
        'dialogParams': {'callID': _callId},
        'cause': 'NORMAL_CLEARING',
      },
      'id': _messageId++,
    });

    await disconnect();
  }

  void _handleEvent(Map<String, dynamic> data) {
    final eventChannel = data['params']?['eventChannel'] as String?;
    final eventData = data['params']?['data'] as Map<String, dynamic>?;

    if (eventChannel == null) return;

    if (eventChannel == 'auth_rejected') {
      _authError = eventData?['reason'] ?? 'Authentication rejected';
      smLog('WebRTCService: Auth rejected: $_authError');
      _wsConnected = false;
      _cleanupCall();
      _channel?.sink.close();
      _channel = null;
      _errorController.add('Auth rejected: $_authError');
      return;
    }

    if (eventChannel == 'network_quality') {
      if (eventData != null) {
        smLog('WebRTCService: Network quality: ${jsonEncode(eventData)}');
      }
      return;
    }

    // Log other events
    smLog('WebRTCService: Event [$eventChannel]: ${jsonEncode(eventData)}');
  }

  // ── Call controls ──

  void toggleMute() {
    if (_localStream == null) return;
    final tracks = _localStream!.getAudioTracks();
    if (tracks.isNotEmpty) {
      _isMuted = !_isMuted;
      tracks[0].enabled = !_isMuted;
      smLog('WebRTCService: ${_isMuted ? 'Muted' : 'Unmuted'}');
    }
  }

  Future<void> toggleSpeaker() async {
    _isSpeakerOn = !_isSpeakerOn;
    try {
      await Helper.setSpeakerphoneOn(_isSpeakerOn);
      smLog('WebRTCService: ${_isSpeakerOn ? 'Speaker on' : 'Speaker off'}');
    } catch (e) {
      _isSpeakerOn = !_isSpeakerOn; // revert on failure
      smLog('WebRTCService: Speaker toggle failed: $e');
    }
  }

  /// Read the current local mic audio level (RMS, 0.0–1.0) from WebRTC stats.
  /// Returns 0.0 when there's no active peer connection or stats are unavailable.
  Future<double> getLocalAudioLevel() async {
    final pc = _peerConnection;
    if (pc == null) return 0.0;
    try {
      final reports = await pc.getStats();
      for (final report in reports) {
        if (report.type == 'media-source' && report.values['kind'] == 'audio') {
          final level = report.values['audioLevel'];
          if (level is num) return level.toDouble().clamp(0.0, 1.0);
        }
      }
    } catch (_) {
      // Swallow — stats polling is best-effort for UI animation
    }
    return 0.0;
  }

  /// Hang up the current call and disconnect from the server.
  Future<void> hangup() async {
    smLog('WebRTCService: Hanging up');
    _sendMessage({
      'jsonrpc': '2.0',
      'method': 'verto.bye',
      'params': {
        'sessid': _sessionId,
        'dialogParams': {'callID': _callId},
        'cause': 'NORMAL_CLEARING',
      },
      'id': _messageId++,
    });
    await disconnect();
  }

  Future<void> _cleanupCall() async {
    _setCallPhase(WebRTCCallPhase.ending);
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.close();
    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;
    _callId = null;
    _isMuted = false;
    _isSpeakerOn = false;
    _callStartTime = null;
    _remoteStreamController.add(null);
    _setCallPhase(WebRTCCallPhase.idle);
  }

  /// Disconnect from the Verto server entirely.
  Future<void> disconnect() async {
    smLog('WebRTCService: Disconnecting');
    await _cleanupCall();
    _channel?.sink.close();
    _channel = null;
    _wsConnected = false;
  }

  // ── Internal ──

  void _sendMessage(Map<String, dynamic> message) {
    final encoded = jsonEncode(message);
    _channel?.sink.add(encoded);
  }

  void _setCallPhase(WebRTCCallPhase phase) {
    _currentPhase = phase;
    _callPhaseController.add(phase);
  }

  /// Dispose of the service and release all resources.
  Future<void> dispose() async {
    await disconnect();
    await _callPhaseController.close();
    await _errorController.close();
    await _remoteStreamController.close();
    _instance = null;
  }
}
