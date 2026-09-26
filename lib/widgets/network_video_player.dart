import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/consts/themes/apptext.dart';
import 'package:video_player/video_player.dart';

/// A video streamed from [url], with its own play/seek/fullscreen controls —
/// video_player draws the picture only.
class NetworkVideoPlayer extends StatefulWidget {
  const NetworkVideoPlayer({super.key, required this.url, this.onPlay});

  final String url;

  /// Called whenever playback starts, so other audio can make way.
  final VoidCallback? onPlay;

  @override
  State<NetworkVideoPlayer> createState() => _NetworkVideoPlayerState();
}

class _NetworkVideoPlayerState extends State<NetworkVideoPlayer> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    setState(() {
      _controller = controller;
      _failed = false;
    });
    try {
      await controller.initialize();
    } catch (error) {
      debugPrint('Video failed to load: $error');
      // Left the page, or retried, while it was still loading.
      if (!mounted || _controller != controller) return;
      setState(() => _failed = true);
      return;
    }
    if (mounted && _controller == controller) setState(() {});
  }

  void _retry() {
    final old = _controller;
    _controller = null;
    old?.dispose();
    _load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ColoredBox(
        color: Appcolors.black,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: controller == null
              ? const SizedBox.shrink()
              : ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    // Errors can also arrive mid-stream, after initialize.
                    if (_failed || value.hasError) {
                      return _LoadError(onRetry: _retry);
                    }
                    if (!value.isInitialized) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Appcolors.white,
                          strokeWidth: 2.5,
                        ),
                      );
                    }
                    return _VideoSurface(
                      controller: controller,
                      onPlay: widget.onPlay,
                      isFullscreen: false,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

/// The picture plus its controls, shared by the inline and fullscreen views.
class _VideoSurface extends StatefulWidget {
  const _VideoSurface({
    required this.controller,
    required this.onPlay,
    required this.isFullscreen,
  });

  final VideoPlayerController controller;
  final VoidCallback? onPlay;
  final bool isFullscreen;

  @override
  State<_VideoSurface> createState() => _VideoSurfaceState();
}

class _VideoSurfaceState extends State<_VideoSurface> {
  bool _controlsVisible = true;
  Timer? _hideTimer;

  VideoPlayerController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    // Opening full screen mid-playback: show the controls, then fade them.
    if (_controller.value.isPlaying) _scheduleHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showControls() {
    setState(() => _controlsVisible = true);
    // Out of the way while watching; they stay up while paused.
    if (_controller.value.isPlaying) {
      _scheduleHide();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    if (_controlsVisible) {
      _hideTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _showControls();
    }
  }

  Future<void> _togglePlay() async {
    final value = _controller.value;
    if (value.isPlaying) {
      await _controller.pause();
    } else {
      // From the end, play again from the start.
      if (value.isCompleted || value.position >= value.duration) {
        await _controller.seekTo(Duration.zero);
      }
      widget.onPlay?.call();
      await _controller.play();
    }
    if (mounted) _showControls();
  }

  Future<void> _toggleFullscreen() async {
    if (widget.isFullscreen) {
      Navigator.of(context).pop();
      return;
    }
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, _, _) =>
            _FullscreenVideo(controller: _controller, onPlay: widget.onPlay),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
    if (mounted) _showControls();
  }

  static String _format(Duration d) {
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              final visible = _controlsVisible || !value.isPlaying;
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (value.isBuffering && value.isPlaying)
                    Center(
                      child: CircularProgressIndicator(
                        color: Appcolors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  IgnorePointer(
                    ignoring: !visible,
                    child: AnimatedOpacity(
                      opacity: visible ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: _controls(value),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _controls(VideoPlayerValue value) {
    final timeStyle = Apptext.inter.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Appcolors.white,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return DecoratedBox(
      // Keeps white controls legible over a bright frame.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Appcolors.black.withValues(alpha: 0.05),
            Appcolors.black.withValues(alpha: 0.55),
          ],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Material(
              color: Appcolors.white.withValues(alpha: 0.92),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _togglePlay,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(
                    value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 32,
                    color: Appcolors.grey900,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 4,
            bottom: widget.isFullscreen ? 16 : 4,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Text(_format(value.position), style: timeStyle),
                  Expanded(
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      colors: VideoProgressColors(
                        playedColor: Appcolors.primaryColor,
                        bufferedColor: Appcolors.white.withValues(alpha: 0.4),
                        backgroundColor: Appcolors.white.withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ),
                  ),
                  Text(_format(value.duration), style: timeStyle),
                  IconButton(
                    onPressed: _toggleFullscreen,
                    tooltip: widget.isFullscreen
                        ? 'Exit full screen'
                        : 'Full screen',
                    icon: Icon(
                      widget.isFullscreen
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      color: Appcolors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.isFullscreen)
            Positioned(
              top: 8,
              left: 8,
              child: SafeArea(
                child: IconButton(
                  onPressed: _toggleFullscreen,
                  tooltip: 'Close',
                  icon: Icon(Icons.close_rounded, color: Appcolors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The same controller, edge to edge and turned sideways for wide videos.
class _FullscreenVideo extends StatefulWidget {
  const _FullscreenVideo({required this.controller, required this.onPlay});

  final VideoPlayerController controller;
  final VoidCallback? onPlay;

  @override
  State<_FullscreenVideo> createState() => _FullscreenVideoState();
}

class _FullscreenVideoState extends State<_FullscreenVideo> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(
      widget.controller.value.aspectRatio >= 1
          ? const [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : const [DeviceOrientation.portraitUp],
    );
  }

  @override
  void dispose() {
    // Back to whatever the app allows (Info.plist / the manifest).
    SystemChrome.setPreferredOrientations(const []);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.black,
      body: _VideoSurface(
        controller: widget.controller,
        onPlay: widget.onPlay,
        isFullscreen: true,
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: Appcolors.white.withValues(alpha: 0.7),
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            "Couldn't load the video.",
            style: Apptext.inter.copyWith(
              fontSize: 13,
              color: Appcolors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Try again',
              style: Apptext.inter.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Appcolors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
