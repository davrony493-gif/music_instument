import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';


class NoInternet extends StatelessWidget {
  const NoInternet({super.key});

  static final ValueNotifier<bool> _visible = ValueNotifier<bool>(false);

  static const Duration _duration = Duration(milliseconds: 250);

  
  static Future<void> Function()? onRetry;

  static bool get isOpen => _visible.value;

  static void showWidget() => _visible.value = true;

  static void dismiss() => _visible.value = false;

  
  static Widget gate(Widget? child) =>
      _NoInternetGate(child: child ?? const SizedBox.shrink());

  @override
  Widget build(BuildContext context) {
  
    return const Material(
      type: MaterialType.transparency,
      child: _OfflineSheet(),
    );
  }
}

class _OfflineSheet extends StatefulWidget {
  const _OfflineSheet();

  @override
  State<_OfflineSheet> createState() => _OfflineSheetState();
}

class _OfflineSheetState extends State<_OfflineSheet> {
  bool _retrying = false;

  Future<void> _openSettings() async {
    // Android can deep-link straight to the Wi-Fi panel. iOS does not allow
    // it, so the best available there is the app's own settings page.
    if (Platform.isAndroid) {
      await AppSettings.openAppSettings(type: AppSettingsType.wifi);
    } else {
      await AppSettings.openAppSettings();
    }
  }

  Future<void> _retry() async {
    final retry = NoInternet.onRetry;
    if (retry == null || _retrying) return;

    setState(() => _retrying = true);
    try {
      await retry();
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? Appcolors.grey900 : Appcolors.white;
    final onSurface = isDark ? Appcolors.white : Appcolors.grey900;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tappable on purpose — this is the route to the Wi-Fi
              // settings. Semantics rather than Tooltip: there is no Overlay
              // ancestor above the navigator for a tooltip to render into.
              Semantics(
                button: true,
                label: 'Open network settings',
                child: IconButton(
                  onPressed: _openSettings,
                  iconSize: 36,
                  padding: const EdgeInsets.all(18),
                  style: IconButton.styleFrom(
                    backgroundColor: Appcolors.primaryColor.withValues(
                      alpha: 0.10,
                    ),
                    foregroundColor: Appcolors.primaryColor,
                    shape: const CircleBorder(),
                  ),
                  icon: const Icon(CupertinoIcons.wifi_slash),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No internet connection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap the Wi-Fi icon to open settings and turn on Wi-Fi '
                'or your mobile data.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  height: 1.5,
                  color: Appcolors.grey500,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _retrying ? null : _retry,
                  style: FilledButton.styleFrom(
                    backgroundColor: Appcolors.primaryColor,
                    foregroundColor: Appcolors.white,
                    disabledBackgroundColor: Appcolors.primaryColor.withValues(
                      alpha: 0.6,
                    ),
                    disabledForegroundColor: Appcolors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: _retrying
                    
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Appcolors.white,
                          ),
                        )
                      : const Text('Try again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoInternetGate extends StatelessWidget {
  const _NoInternetGate({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: NoInternet._visible,
      builder: (context, visible, _) {
        return Stack(
          children: [
            // The app itself. Unpositioned, so it also sizes the Stack.
            child,
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !visible,
                child: AnimatedOpacity(
                  opacity: visible ? 1 : 0,
                  duration: NoInternet._duration,
                  child: const ColoredBox(color: Color(0x66000000)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              // Slides by its own height, so the sheet can size to content.
              child: AnimatedSlide(
                offset: visible ? Offset.zero : const Offset(0, 1),
                duration: NoInternet._duration,
                curve: Curves.easeOutCubic,
                child: const NoInternet(),
              ),
            ),
          ],
        );
      },
    );
  }
}
