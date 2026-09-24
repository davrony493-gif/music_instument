import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/gen/assets.gen.dart';
import 'package:music_intrument/providers/track_provider.dart';
import 'package:provider/provider.dart';

class TrackCard extends StatelessWidget {
  const TrackCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final track = context.watch<TrackProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark
                      ? Appcolors.primaryColor.withValues(alpha: 0.18)
                      : Appcolors.blueSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Assets.icons.disc.svg(width: 26, height: 26),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title ?? 'Musiqa tanlanmagan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: track.hasTrack
                            ? (isDark ? Appcolors.white : Appcolors.grey900)
                            : Appcolors.grey500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${track.positionLabel} / ${track.durationLabel}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 13,
                        color: Appcolors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: context.read<TrackProvider>().choose,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Appcolors.primaryColor.withValues(alpha: 0.18)
                        : Appcolors.blueSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Musiqa tanlash',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Appcolors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SkipButton(
                icon: Icons.skip_previous_rounded,
                enabled: track.hasTrack,
                onTap: context.read<TrackProvider>().back,
              ),
              const SizedBox(width: 28),
              GestureDetector(
                onTap: context.read<TrackProvider>().toggle,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: track.hasTrack
                        ? (isDark ? Appcolors.white : Appcolors.grey900)
                        : Appcolors.grey300,
                  ),
                  child: Icon(
                    track.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 28,
                    color: isDark && track.hasTrack
                        ? Appcolors.grey900
                        : Appcolors.white,
                  ),
                ),
              ),
              const SizedBox(width: 28),
              _SkipButton(
                icon: Icons.skip_next_rounded,
                enabled: track.hasTrack,
                onTap: context.read<TrackProvider>().forward,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Icon(
        icon,
        size: 32,
        color: enabled ? Appcolors.grey500 : Appcolors.grey300,
      ),
    );
  }
}
