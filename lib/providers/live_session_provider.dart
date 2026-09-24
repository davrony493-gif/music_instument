import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';

class LiveSessionProvider extends ChangeNotifier with WidgetsBindingObserver {
  LiveSessionProvider() {
    WidgetsBinding.instance.addObserver(this);
    _restore();
  }

  static const String _storageKey = 'liveSession';

  static const Duration maxDuration = Duration(hours: 8);

  final GetStorage _box = GetStorage();

  DateTime? _startedAt;
  Duration _accumulated = Duration.zero;
  final List<Duration> _laps = [];
  Timer? _ticker;

  bool get isRunning => _startedAt != null;

 
  bool get hasSession => isRunning || _accumulated > Duration.zero;

  Duration get elapsed => isRunning
      ? _accumulated + DateTime.now().difference(_startedAt!)
      : _accumulated;

  String get formatted => format(elapsed);

  List<Duration> get laps => List.unmodifiable(_laps);

  Duration splitAt(int index) =>
      index == 0 ? _laps[index] : _laps[index] - _laps[index - 1];

  static String format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void start() {
    if (isRunning) return;
    _startedAt = DateTime.now();
    _startTicker();
    _save();
    notifyListeners();
  }

  void pause() {
    if (!isRunning) return;
    _accumulated = elapsed;
    _startedAt = null;
    _stopTicker();
    _save();
    notifyListeners();
  }

  void toggle() => isRunning ? pause() : start();

  void lap() {
    if (!hasSession) return;
    _laps.add(elapsed);
    _save();
    notifyListeners();
  }

  void reset() {
    _startedAt = null;
    _accumulated = Duration.zero;
    _laps.clear();
    _stopTicker();
    _box.remove(_storageKey);
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => notifyListeners(),
    );
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _clampToMaxDuration();
      if (isRunning) _startTicker();
      notifyListeners();
    } else {
      _stopTicker();
      if (hasSession) _save();
    }
  }

  void _restore() {
    final raw = _box.read<Map>(_storageKey);
    if (raw == null) return;

    _accumulated = Duration(milliseconds: (raw['accumulated'] as int?) ?? 0);
    _laps.addAll(
      ((raw['laps'] as List?) ?? const []).map(
        (ms) => Duration(milliseconds: ms as int),
      ),
    );

    final startedAtMs = raw['startedAt'] as int?;
    if (startedAtMs != null) {
      final started = DateTime.fromMillisecondsSinceEpoch(startedAtMs);
      // A start in the future means the device clock moved backwards.
      _startedAt = started.isAfter(DateTime.now()) ? DateTime.now() : started;
      _clampToMaxDuration();
      if (isRunning) _startTicker();
    }
  }

  void _clampToMaxDuration() {
    if (!isRunning || elapsed <= maxDuration) return;
    _accumulated = maxDuration;
    _startedAt = null;
    _stopTicker();
    _save();
  }

  void _save() {
    _box.write(_storageKey, {
      'startedAt': _startedAt?.millisecondsSinceEpoch,
      'accumulated': _accumulated.inMilliseconds,
      'laps': _laps.map((lap) => lap.inMilliseconds).toList(),
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTicker();
    super.dispose();
  }
}
