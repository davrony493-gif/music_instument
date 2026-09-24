import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:music_intrument/gen/assets.gen.dart';

class TimeSignature {
  const TimeSignature(this.label, this.beats);

  final String label;
  final int beats;
}

class MetronomeProvider extends ChangeNotifier {
  static const int minBpm = 40;
  static const int maxBpm = 200;

  static const List<TimeSignature> signatures = [
    TimeSignature('4/4', 4),
    TimeSignature('3/4', 3),
    TimeSignature('6/8', 6),
  ];

  final AudioPlayer _click = AudioPlayer(playerId: 'metronome_click');
  final AudioPlayer _accent = AudioPlayer(playerId: 'metronome_accent');

  final Stopwatch _clock = Stopwatch();
  Timer? _next;

  // Beats counted since the clock was last rebased, used only for scheduling.
  int _beatsElapsed = 0;

  // Position in the bar, kept across tempo changes.
  int _barBeat = 0;

  int _bpm = 112;
  int _signatureIndex = 0;
  bool _isRunning = false;
  int _beat = 0;

  int get bpm => _bpm;
  int get signatureIndex => _signatureIndex;
  TimeSignature get signature => signatures[_signatureIndex];
  bool get isRunning => _isRunning;

  /// 1-based position in the bar, or 0 while stopped.
  int get beat => _beat;

  Duration get interval =>
      Duration(microseconds: (60000000 / _bpm).round());

  void setBpm(int value) {
    final clamped = value.clamp(minBpm, maxBpm);
    if (clamped == _bpm) return;
    _bpm = clamped;
    notifyListeners();
    // The clock has to be rebased, not just re-read: scheduling is relative
    // to total elapsed time, so keeping the old base would place every past
    // beat at the new tempo and fire a burst of catch-up ticks.
    if (_isRunning) _rebase();
  }

  void _rebase() {
    _next?.cancel();
    _beatsElapsed = 0;
    _clock
      ..reset()
      ..start();
    _next = Timer(interval, _tick);
  }

  void setSignature(int index) {
    if (index == _signatureIndex) return;
    _signatureIndex = index;
    _barBeat = 0;
    _beat = 0;
    notifyListeners();
    if (_isRunning) _rebase();
  }

  void toggle() => _isRunning ? stop() : start();

  Future<void> start() async {
    if (_isRunning) return;

    for (final player in [_click, _accent]) {
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setPlayerMode(PlayerMode.lowLatency);
    }

    _isRunning = true;
    _beat = 0;
    _barBeat = 0;
    _beatsElapsed = 0;
    _clock
      ..reset()
      ..start();
    notifyListeners();
    _tick();
  }

  void stop() {
    if (!_isRunning) return;
    _next?.cancel();
    _next = null;
    _clock.stop();
    _isRunning = false;
    _beat = 0;
    _barBeat = 0;
    notifyListeners();
  }

  void _tick() {
    if (!_isRunning) return;

    _beat = _barBeat + 1;
    _barBeat = (_barBeat + 1) % signature.beats;
    _beatsElapsed++;
    notifyListeners();

    unawaited(_play(_beat == 1));

    // Each beat is scheduled against total elapsed time rather than a fixed
    // repeating interval, so a late tick does not push every later beat back
    // with it. Without this the tempo drifts audibly within a minute.
    final target = interval * _beatsElapsed;
    var wait = target - _clock.elapsed;
    if (wait < Duration.zero) wait = Duration.zero;
    _next = Timer(wait, _tick);
  }

  Future<void> _play(bool isDownbeat) async {
    try {
      final player = isDownbeat ? _accent : _click;
      final asset = isDownbeat ? Assets.audio.accent : Assets.audio.click;
      await player.stop();
      await player.play(AssetSource(_stripAssets(asset)));
    } catch (_) {
      // A dropped click must not take the whole metronome down.
    }
  }

  // AssetSource paths are relative to the assets/ folder.
  String _stripAssets(String path) =>
      path.startsWith('assets/') ? path.substring(7) : path;

  @override
  void dispose() {
    _next?.cancel();
    _click.dispose();
    _accent.dispose();
    super.dispose();
  }
}
