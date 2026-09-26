import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';

class TrackProvider extends ChangeNotifier {
  TrackProvider() {
    _subs.addAll([
     
      _player.onPositionChanged.listen((p) {
        if (!hasTrack) return;
        _position = p;
        notifyListeners();
      }),
      _player.onDurationChanged.listen((d) {
        if (!hasTrack) return;
        _duration = d;
        notifyListeners();
      }),
      _player.onPlayerStateChanged.listen((state) {
        _isPlaying = state == PlayerState.playing;
        notifyListeners();
      }),
    ]);
  }

  static const Duration skip = Duration(seconds: 10);

  final AudioPlayer _player = AudioPlayer(playerId: 'backing_track');
  final List<StreamSubscription<dynamic>> _subs = [];

  String? _path;
  String? _title;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  String? get title => _title;
  bool get hasTrack => _path != null;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;

  String get positionLabel => _format(_position);
  String get durationLabel => _format(_duration);

  static const XTypeGroup _audio = XTypeGroup(
    label: 'Audio',
    extensions: ['mp3', 'm4a', 'wav', 'aac', 'flac', 'ogg'],
    uniformTypeIdentifiers: ['public.audio'],
    mimeTypes: ['audio/*'],
  );

  Future<void> choose() async {
    final file = await openFile(acceptedTypeGroups: [_audio]);
    if (file == null) return;

    await _player.stop();
    _path = file.path;
    _title = _nameOf(file.name);
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();

    await _player.setSourceDeviceFile(_path!);
  }

  
  Future<void> clear() async {
    if (_path == null) return;
    _path = null;
    _title = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    _isPlaying = false;
    notifyListeners();

    await _player.release();
  }

  Future<void> toggle() async {
    if (_path == null) return;
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(DeviceFileSource(_path!));
    }
  }

 
  Future<void> pause() async {
    if (_isPlaying) await _player.pause();
  }

  Future<void> back() => _seekBy(-skip);

  Future<void> forward() => _seekBy(skip);

  Future<void> _seekBy(Duration delta) async {
    if (_path == null) return;
    var target = _position + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (_duration > Duration.zero && target > _duration) target = _duration;
    await _player.seek(target);
  }

  static String _nameOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot > 0 ? fileName.substring(0, dot) : fileName;
  }

  static String _format(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _player.dispose();
    super.dispose();
  }
}
