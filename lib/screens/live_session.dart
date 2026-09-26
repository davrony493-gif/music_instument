import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/models/practice_session.dart';
import 'package:music_intrument/providers/live_session_provider.dart';
import 'package:music_intrument/providers/metronome_provider.dart';
import 'package:music_intrument/providers/track_provider.dart';
import 'package:music_intrument/widgets/metronome_card.dart';
import 'package:music_intrument/widgets/top_snackbar.dart';
import 'package:music_intrument/widgets/track_card.dart';
import 'package:music_intrument/providers/sessions_provider.dart';
import 'package:provider/provider.dart';

class LiveSession extends StatelessWidget {
  const LiveSession({super.key});

  Future<void> _confirmReset(BuildContext context) async {
    final session = context.read<LiveSessionProvider>();
    if (!session.hasSession) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart the session ?'),
        content: const Text('Hozirgi sessiya vaqti va belgilar o\'chiriladi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Restart', style: TextStyle(color: Appcolors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) session.reset();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? Appcolors.black : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        scrolledUnderElevation: 0,
        // A nav bar tab, not a pushed page: there is nothing to go back to.
        automaticallyImplyLeading: false,
        title: const Text('Train session'),
        actions: const [_SaveAction()],
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: isDark ? Appcolors.white : Appcolors.grey900,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom + 24,
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const _TimerFace(),
              const SizedBox(height: 40),
              _Controls(onReset: () => _confirmReset(context)),
              const SizedBox(height: 28),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: MetronomeCard(),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TrackCard(),
              ),
              const SizedBox(height: 28),
              const _LapList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerFace extends StatelessWidget {
  const _TimerFace();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRunning = context.select<LiveSessionProvider, bool>(
      (session) => session.isRunning,
    );

    return Container(
      width: 280,
      height: 280,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Appcolors.grey900 : Appcolors.white,
        border: Border.all(
          color: Appcolors.primaryColor.withValues(
            alpha: isRunning ? 0.18 : 0.08,
          ),
          width: 1.5,
        ),
        boxShadow: [
         
          BoxShadow(
            color: Appcolors.primaryColor.withValues(
              alpha: isRunning ? 0.14 : 0.04,
            ),
            blurRadius: 40,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: Appcolors.grey900.withValues(alpha: isDark ? 0.4 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'PASSED TIME',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Appcolors.grey500,
            ),
          ),
          const SizedBox(height: 8),
        //* A new widget 
          Selector<LiveSessionProvider, String>(
            selector: (_, session) => session.formatted,
            builder: (context, value, _) => Text(
              value,
              style: GoogleFonts.robotoMono(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: isDark ? Appcolors.white : Appcolors.grey900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _StatusChip(isRunning: isRunning),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isRunning});

  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final color = isRunning ? Appcolors.green : Appcolors.grey500;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isRunning
              ? Icons.local_fire_department_rounded
              : Icons.pause_circle_outline_rounded,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          isRunning ? 'Range is active' : 'Pause',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<LiveSessionProvider>();
    final isRunning = session.isRunning;
    final hasSession = session.hasSession;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ControlButton(
          icon: Icons.refresh_rounded,
          label: 'Restart',
          onTap: hasSession ? onReset : null,
        ),
        const SizedBox(width: 24),
        _ControlButton(
          icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          label: isRunning ? 'Pause' : (hasSession ? 'Continue' : 'Begin'),
          isPrimary: true,
          onTap: session.toggle,
        ),
        const SizedBox(width: 24),
        _ControlButton(
          icon: Icons.outlined_flag_rounded,
          label: 'Mark',
          onTap: hasSession ? session.lap : null,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onTap != null;
    final size = isPrimary ? 72.0 : 56.0;

    final fill = isPrimary
        ? Appcolors.primaryColor
        : (isDark
              ? Appcolors.white.withValues(alpha: 0.08)
              : Appcolors.grey900.withValues(alpha: 0.06));

    return Opacity(
      opacity: isEnabled ? 1 : 0.35,
      child: SizedBox(
        width: 88,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: fill,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Icon(
                    icon,
                    size: isPrimary ? 32 : 22,
                    color: isPrimary
                        ? Appcolors.white
                        : (isDark ? Appcolors.grey300 : Appcolors.grey500),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Appcolors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LapList extends StatelessWidget {
  const _LapList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Depend on the count, not the list, so the ticker doesn't rebuild this.
    final count = context.select<LiveSessionProvider, int>(
      (session) => session.laps.length,
    );

    if (count == 0) return const SizedBox.shrink();

    final session = context.read<LiveSessionProvider>();
    final laps = session.laps;

    return ListView.separated(
      // The page scrolls, so the list must size to its children instead of
      // asking for unbounded height.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: count,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: Appcolors.grey500.withValues(alpha: 0.15)),
      itemBuilder: (context, index) {
        // Newest flag on top, but keep the numbering in the order they happened.
        final lap = count - 1 - index;
        final numberStyle = TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Appcolors.grey500,
        );
        final timeStyle = GoogleFonts.robotoMono(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Appcolors.white : Appcolors.grey900,
          fontFeatures: const [FontFeature.tabularFigures()],
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text('#${lap + 1}', style: numberStyle),
              ),
              Expanded(
                child: Text(
                  '+${LiveSessionProvider.format(session.splitAt(lap))}',
                  style: numberStyle,
                ),
              ),
              Text(LiveSessionProvider.format(laps[lap]), style: timeStyle),
            ],
          ),
        );
      },
    );
  }
}


class _SaveAction extends StatefulWidget {
  const _SaveAction();

  @override
  State<_SaveAction> createState() => _SaveActionState();
}

class _SaveActionState extends State<_SaveAction> {
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;

    final live = context.read<LiveSessionProvider>();
    final messenger = TopSnackbar.of(context);

    if (!live.hasSession) {
      messenger.show(
        'Nothing to save yet — press play to start.',
        isError: true,
      );
      return;
    }

    live.pause();
    final elapsed = live.elapsed;
    final laps = live.laps;

    final track = context.read<TrackProvider>();
    final title = track.title ?? PracticeSession.untitled;

    final practice = PracticeSession(
      title: title,
      // The provider tracks elapsed, not the original start.
      startedAt: DateTime.now().subtract(elapsed),
      duration: elapsed,
      laps: laps,
    );

    // Read before the await: the user can switch tabs while it saves.
    final sessions = context.read<SessionsProvider>();
    final metronome = context.read<MetronomeProvider>();

    setState(() => _saving = true);
    try {
      await sessions.save(practice);
    } catch (error) {
      // Nothing has been reset, so the session is still there to retry.
      debugPrint('Saving the practice session failed: $error');
      messenger.show('Could not save the session. Try again.', isError: true);
      return;
    } finally {
      if (mounted) setState(() => _saving = false);
    }

    // The tab stays open, so empty it for the next session: timer and marks,
    // the chosen music, and the metronome's click.
    live.reset();
    metronome.stop();
    unawaited(track.clear());

    messenger.show('Session saved · ${practice.durationLabel}');
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _saving ? null : _save,
      child: const Text('Save'),
    );
  }
}
