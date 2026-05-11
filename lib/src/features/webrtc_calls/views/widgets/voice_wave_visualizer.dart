import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/services/webrtc_service.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

class VoiceWaveVisualizer extends StatefulWidget {
  final bool isActive;
  final bool isMuted;

  const VoiceWaveVisualizer({super.key, this.isActive = true, this.isMuted = false});

  @override
  State<VoiceWaveVisualizer> createState() => _VoiceWaveVisualizerState();
}

class _VoiceWaveVisualizerState extends State<VoiceWaveVisualizer> with SingleTickerProviderStateMixin {
  static const Duration _pollInterval = Duration(milliseconds: 100);
  static const double _smoothing = 0.25; // 0..1 — higher = snappier
  static const double _minIntensity = 0.3;
  static const double _maxIntensity = 2.0;

  late final AnimationController _controller;
  final ValueNotifier<double> _intensity = ValueNotifier<double>(_minIntensity);
  Timer? _levelTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant VoiceWaveVisualizer old) {
    super.didUpdateWidget(old);
    if (old.isActive != widget.isActive || old.isMuted != widget.isMuted) {
      _sync();
    }
  }

  void _sync() {
    final shouldRun = widget.isActive && !widget.isMuted;
    if (shouldRun) {
      if (!_controller.isAnimating) _controller.repeat();
      _startLevelPolling();
    } else {
      if (_controller.isAnimating) _controller.stop();
      _stopLevelPolling();
      _intensity.value = _minIntensity;
    }
  }

  void _startLevelPolling() {
    if (_levelTimer != null) return;
    _levelTimer = Timer.periodic(_pollInterval, (_) async {
      final level = await sl<WebRTCService>().getLocalAudioLevel();
      final target = (level * 10).clamp(_minIntensity, _maxIntensity);
      // Exponential smoothing toward target — avoids jumpy waves
      _intensity.value = _intensity.value + (target - _intensity.value) * _smoothing;
    });
  }

  void _stopLevelPolling() {
    _levelTimer?.cancel();
    _levelTimer = null;
  }

  @override
  void dispose() {
    _stopLevelPolling();
    _controller.dispose();
    _intensity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150.rh,
      width: double.infinity,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _VoiceWavePainter(
            repaint: Listenable.merge([_controller, _intensity]),
            intensity: _intensity,
          ),
        ),
      ),
    );
  }
}

class _WaveLayer {
  final double offset;
  final Color color;
  final double alpha;
  final double blur;
  final double heightScale;
  final double speed;

  const _WaveLayer({
    required this.offset,
    required this.color,
    required this.alpha,
    required this.blur,
    required this.heightScale,
    required this.speed,
  });
}

class _VoiceWavePainter extends CustomPainter {
  final ValueListenable<double> intensity;

  _VoiceWavePainter({required Listenable repaint, required this.intensity}) : super(repaint: repaint);

  static const List<_WaveLayer> _layers = [
    _WaveLayer(offset: 20, color: Color(0xFF643CC8), alpha: 0.2, blur: 10, heightScale: 0.8, speed: 1.2),
    _WaveLayer(offset: 40, color: Color(0xFF7850DC), alpha: 0.3, blur: 8, heightScale: 0.9, speed: 1.0),
    _WaveLayer(offset: 60, color: Color(0xFF8C64F0), alpha: 0.5, blur: 7, heightScale: 1.0, speed: 0.8),
    _WaveLayer(offset: 80, color: Color(0xFFA078FF), alpha: 0.6, blur: 6, heightScale: 1.1, speed: 0.9),
    _WaveLayer(offset: 50, color: Color(0xFFB48CFF), alpha: 0.7, blur: 5, heightScale: 0.95, speed: 1.1),
    _WaveLayer(offset: 30, color: Color(0xFFC8A0FF), alpha: 0.8, blur: 4, heightScale: 0.85, speed: 1.3),
  ];

  static const int _numPoints = 200;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final baseY = height * 0.75;
    final time = DateTime.now().millisecondsSinceEpoch * 0.001;
    final currentIntensity = intensity.value;

    for (final layer in _layers) {
      _drawWaveMesh(canvas, width, height, baseY, time, layer, currentIntensity);
    }
  }

  void _drawWaveMesh(
    Canvas canvas,
    double width,
    double height,
    double baseY,
    double time,
    _WaveLayer layer,
    double intensity,
  ) {
    final points = List<Offset>.filled(_numPoints + 1, Offset.zero);
    for (var i = 0; i <= _numPoints; i++) {
      final x = (i / _numPoints) * width;
      final normalizedX = i / _numPoints - 0.5;
      final wave1 = math.sin(i * 0.05 + time * layer.speed) * 40 * intensity * layer.heightScale;
      final wave2 = math.sin(i * 0.08 - time * layer.speed * 0.7) * 25 * intensity * layer.heightScale;
      final wave3 = math.cos(i * 0.03 + time * layer.speed * 0.5) * 15 * intensity * layer.heightScale;
      final envelope = math.pow(1 - (normalizedX * 2).abs(), 1.5).toDouble();
      final y = baseY - layer.offset - (wave1 + wave2 + wave3) * envelope;
      points[i] = Offset(x, y);
    }

    final strokePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      final xc = (points[i].dx + points[i - 1].dx) / 2;
      final yc = (points[i].dy + points[i - 1].dy) / 2;
      strokePath.quadraticBezierTo(points[i - 1].dx, points[i - 1].dy, xc, yc);
    }

    final fillPath = Path.from(strokePath)..close();

    final fillRect = Rect.fromLTWH(0, baseY - 150, width, 150);
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          layer.color.withValues(alpha: 0.3 * layer.alpha),
          Colors.transparent,
        ],
      ).createShader(fillRect);
    canvas.drawPath(fillPath, fillPaint);

    final strokeRect = Rect.fromLTWH(0, 0, width, height);
    final strokeShader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: const [0, 0.2, 0.5, 0.8, 1],
      colors: [
        Colors.transparent,
        layer.color.withValues(alpha: layer.alpha),
        layer.color.withValues(alpha: layer.alpha),
        layer.color.withValues(alpha: layer.alpha),
        Colors.transparent,
      ],
    ).createShader(strokeRect);

    // Outer glow — wide blurred stroke
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer.blur)
      ..shader = strokeShader;
    canvas.drawPath(strokePath, glowPaint);

    // Sharp core — thin non-blurred stroke over the glow
    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..shader = strokeShader;
    canvas.drawPath(strokePath, corePaint);
  }

  @override
  bool shouldRepaint(covariant _VoiceWavePainter old) => false;
}
