import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';



class TopSnackbar {
  TopSnackbar._(this._overlay);

  final OverlayState _overlay;

  static TopSnackbar of(BuildContext context) {
    return TopSnackbar._(Overlay.of(context, rootOverlay: true));
  }

  
  static OverlayEntry? _visibleEntry;

  void show(String message, {bool isError = false}) {
    _removeVisibleEntry();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _TopSnackbarView(
        message: message,
        isError: isError,
        onFinished: () {
          // Skip if a newer message has already replaced this one.
          if (_visibleEntry == entry) _removeVisibleEntry();
        },
      ),
    );

    _visibleEntry = entry;
    _overlay.insert(entry);
  }

  static void _removeVisibleEntry() {
    _visibleEntry?.remove();
    _visibleEntry?.dispose();
    _visibleEntry = null;
  }
}

class _TopSnackbarView extends StatefulWidget {
  const _TopSnackbarView({
    required this.message,
    required this.isError,
    required this.onFinished,
  });

  final String message;
  final bool isError;

  
  final VoidCallback onFinished;

  @override
  State<_TopSnackbarView> createState() => _TopSnackbarViewState();
}

class _TopSnackbarViewState extends State<_TopSnackbarView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Timer _hideTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // From one full height above its place (off screen) down into view.
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _hideTimer = Timer(const Duration(seconds: 3), _slideOut);
  }

  void _slideOut() {
    _hideTimer.cancel();
    _controller.reverse().then((_) => widget.onFinished());
  }

  @override
  void dispose() {
    _hideTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slide,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: GestureDetector(
              onTap: _slideOut, // Tapping hides it early.
              child: _buildCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: widget.isError ? Appcolors.red : Appcolors.green,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Appcolors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              widget.isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              size: 22,
              color: Appcolors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Appcolors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
