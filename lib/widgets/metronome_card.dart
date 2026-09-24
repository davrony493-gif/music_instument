import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/gen/assets.gen.dart';
import 'package:music_intrument/providers/metronome_provider.dart';
import 'package:provider/provider.dart';

class MetronomeCard extends StatelessWidget {
  const MetronomeCard({super.key});

  static const List<({String name, int bpm})> _marks = [
    (name: 'Largo', bpm: 40),
    (name: 'Andante', bpm: 90),
    (name: 'Allegro', bpm: 120),
    (name: 'Presto', bpm: 200),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final metronome = context.watch<MetronomeProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? Appcolors.grey900 : Appcolors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Appcolors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Assets.icons.metronome.svg(
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  Appcolors.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Metronom',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Appcolors.white : Appcolors.grey900,
                ),
              ),
              const Spacer(),
              Text(
                '${metronome.bpm}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Appcolors.primaryColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'BPM',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Appcolors.grey500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 10,
              activeTrackColor: Appcolors.primaryColor.withValues(alpha: 0.55),
              inactiveTrackColor: isDark
                  ? Appcolors.grey800
                  : Appcolors.blueSurface,
              thumbColor: Appcolors.primaryColor,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: metronome.bpm.toDouble(),
              min: MetronomeProvider.minBpm.toDouble(),
              max: MetronomeProvider.maxBpm.toDouble(),
              onChanged: (value) =>
                  context.read<MetronomeProvider>().setBpm(value.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final mark in _marks)
                Text(
                  '${mark.name} (${mark.bpm})',
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    fontWeight: _isNearest(metronome.bpm, mark.bpm)
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: _isNearest(metronome.bpm, mark.bpm)
                        ? Appcolors.primaryColor
                        : Appcolors.grey500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < MetronomeProvider.signatures.length; i++) ...[
                _SignatureChip(
                  label: MetronomeProvider.signatures[i].label,
                  selected: metronome.signatureIndex == i,
                  onTap: () =>
                      context.read<MetronomeProvider>().setSignature(i),
                ),
                const SizedBox(width: 10),
              ],
              const Spacer(),
              _PlayPill(
                isRunning: metronome.isRunning,
                onTap: context.read<MetronomeProvider>().toggle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bolds whichever tempo marking the current bpm sits closest to.
  static bool _isNearest(int bpm, int markBpm) {
    var best = _marks.first.bpm;
    for (final mark in _marks) {
      if ((bpm - mark.bpm).abs() < (bpm - best).abs()) best = mark.bpm;
    }
    return best == markBpm;
  }
}

class _SignatureChip extends StatelessWidget {
  const _SignatureChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? (isDark
                    ? Appcolors.primaryColor.withValues(alpha: 0.22)
                    : Appcolors.blueSurface)
              : (isDark ? Appcolors.grey800 : Appcolors.grey100),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: selected ? Appcolors.primaryColor : Appcolors.grey500,
          ),
        ),
      ),
    );
  }
}

class _PlayPill extends StatelessWidget {
  const _PlayPill({required this.isRunning, required this.onTap});

  final bool isRunning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Appcolors.primaryColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Appcolors.white,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              isRunning ? 'To‘xtatish' : 'Ijro',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Appcolors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
