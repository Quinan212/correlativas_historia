import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

import '../firebase/firebase_app.dart';

class AppPerformance {
  AppPerformance._();

  static bool get _enabled => !kDebugMode;
  static const bool diagnosticsEnabled = bool.fromEnvironment(
    'ENABLE_PERFORMANCE_DIAGNOSTICS',
    defaultValue: false,
  );
  static bool _frameDiagnosticsInstalled = false;

  static Future<void> configureCollection() async {
    await ensureFirebaseApp();
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(
      _enabled,
    );
  }

  static void installFrameDiagnostics() {
    if (!diagnosticsEnabled || _frameDiagnosticsInstalled) return;
    _frameDiagnosticsInstalled = true;
    WidgetsBinding.instance.addTimingsCallback(_handleFrameTimings);
    debugPrint(
      '[perf] Diagnostico activado. Se mostraran logs de frames lentos.',
    );
  }

  static void _handleFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildMs = timing.buildDuration.inMicroseconds / 1000;
      final rasterMs = timing.rasterDuration.inMicroseconds / 1000;
      final totalMs = buildMs + rasterMs;
      if (buildMs < 8 && rasterMs < 8) continue;

      final bottleneck = rasterMs > buildMs ? 'GPU/raster' : 'CPU/UI';
      debugPrint(
        '[perf] frame '
        'build=${buildMs.toStringAsFixed(1)}ms '
        'raster=${rasterMs.toStringAsFixed(1)}ms '
        'total=${totalMs.toStringAsFixed(1)}ms '
        'cuello=$bottleneck',
      );
    }
  }

  static Future<Trace?> startTrace(
    String name, {
    Map<String, String>? attributes,
  }) async {
    if (!_enabled) return null;

    await ensureFirebaseApp();
    final trace = FirebasePerformance.instance.newTrace(name);
    await trace.start();

    for (final entry
        in attributes?.entries ?? const <MapEntry<String, String>>[]) {
      final value = entry.value.trim();
      if (value.isEmpty) continue;
      trace.putAttribute(entry.key, value);
    }

    return trace;
  }

  static Future<void> stopTrace(
    Trace? trace, {
    Map<String, String>? attributes,
    Map<String, int>? metrics,
  }) async {
    if (trace == null) return;

    for (final entry
        in attributes?.entries ?? const <MapEntry<String, String>>[]) {
      final value = entry.value.trim();
      if (value.isEmpty) continue;
      trace.putAttribute(entry.key, value);
    }

    for (final entry in metrics?.entries ?? const <MapEntry<String, int>>[]) {
      trace.setMetric(entry.key, entry.value);
    }

    await trace.stop();
  }
}
