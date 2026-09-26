import 'package:flutter/material.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/consts/themes/apptext.dart';
import 'package:music_intrument/providers/metronome_provider.dart';
import 'package:music_intrument/providers/notes_provider.dart';
import 'package:music_intrument/providers/track_provider.dart';
import 'package:music_intrument/widgets/network_video_player.dart';
import 'package:provider/provider.dart';

/// One piece from the Notes tab, with its video lesson.
class NoteDetail extends StatelessWidget {
  const NoteDetail({super.key, required this.note});

  final Map<String, dynamic> note;

  /// Practice audio and the video would talk over each other.
  void _silenceOtherAudio(BuildContext context) {
    context.read<TrackProvider>().pause();
    context.read<MetronomeProvider>().stop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? Appcolors.black : Appcolors.groupedBackground;
    final notes = context.watch<NotesProvider>();
    final isFavorite = notes.isFavorite(note);
    final isChord = note['type'] == 'chord';
    final videoUrl = note['videoUrl'] as String?;
    final pages = note['pages'] as int?;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Video lesson',
          style: Apptext.inter.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: isDark ? Appcolors.white : Appcolors.grey900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: isFavorite
                ? 'Remove from favourites'
                : 'Add to favourites',
            onPressed: () => context.read<NotesProvider>().toggleFavorite(note),
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFavorite ? const Color(0xFFF2C14B) : Appcolors.grey500,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          if (videoUrl != null) ...[
            NetworkVideoPlayer(
              url: videoUrl,
              onPlay: () => _silenceOtherAudio(context),
            ),
            if (note['videoCaption'] != null || note['videoCredit'] != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                child: Text(
                  // The credit is a condition of the video's licence.
                  [
                    note['videoCaption'],
                    note['videoCredit'],
                  ].whereType<String>().join('\n'),
                  style: Apptext.inter.copyWith(
                    fontSize: 11,
                    height: 1.45,
                    color: Appcolors.grey500,
                  ),
                ),
              ),
          ] else
            _NoVideo(isDark: isDark),
          const SizedBox(height: 20),
          Text(
            note['title'] as String,
            style: Apptext.inter.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Appcolors.white : Appcolors.grey900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            note['details'] as String,
            style: Apptext.inter.copyWith(
              fontSize: 14,
              color: Appcolors.grey500,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                label: isChord ? 'Chords' : 'Sheet music (PDF)',
                color: isChord ? Appcolors.primaryColor : Appcolors.red,
                isDark: isDark,
              ),
              if (pages != null)
                _Chip(
                  label: pages == 1 ? '1 page' : '$pages pages',
                  color: Appcolors.grey500,
                  isDark: isDark,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, required this.isDark});

  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Apptext.inter.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _NoVideo extends StatelessWidget {
  const _NoVideo({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? Appcolors.grey900 : Appcolors.controlFill,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'No video for this piece yet.',
          style: Apptext.inter.copyWith(fontSize: 14, color: Appcolors.grey500),
        ),
      ),
    );
  }
}
