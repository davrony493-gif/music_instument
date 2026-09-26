import 'package:flutter/material.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/consts/themes/apptext.dart';
import 'package:music_intrument/gen/assets.gen.dart';


enum HistoryTone {
  blue,
  indigo,
  orange,
  purple,
  green;

  Color get color => switch (this) {
    HistoryTone.blue => Appcolors.primaryColor,
    HistoryTone.indigo => Appcolors.indigo600,
    HistoryTone.orange => Appcolors.orange600,
    HistoryTone.purple => Appcolors.purple,
    HistoryTone.green => Appcolors.green,
  };

  
  Color surface({required bool isDark}) {
    if (isDark) return color.withValues(alpha: 0.18);
    return switch (this) {
      HistoryTone.blue => Appcolors.blueSurface,
      HistoryTone.indigo => Appcolors.indigoSurface,
      HistoryTone.orange => Appcolors.orangeSurface,
      HistoryTone.purple => Appcolors.purpleSurface,
      HistoryTone.green => Appcolors.greenSurface,
    };
  }
}

/// One row of the practice history.
class HistoryEntry {
  const HistoryEntry({
    required this.title,
    required this.startedAt,
    required this.duration,
    required this.category,
    required this.icon,
    required this.iconTone,
    required this.badgeTone,
  });

  final String title;
  final DateTime startedAt;
  final Duration duration;
  final String category;
  final SvgGenImage icon;
  final HistoryTone iconTone;
  final HistoryTone badgeTone;

  static const List<String> months = [
    'yanvar',
    'fevral',
    'mart',
    'aprel',
    'may',
    'iyun',
    'iyul',
    'avgust',
    'sentabr',
    'oktabr',
    'noyabr',
    'dekabr',
  ];

  /// '08-may'.
  String get dateLabel =>
      '${startedAt.day.toString().padLeft(2, '0')}-${months[startedAt.month - 1]}';

  /// '15:30'.
  String get timeLabel =>
      '${startedAt.hour.toString().padLeft(2, '0')}:'
      '${startedAt.minute.toString().padLeft(2, '0')}';

  /// '40 soniya', '30 daqiqa', '1 soat 20 daq'.
  String get durationLabel {
    final minutes = duration.inMinutes;
    // Under a minute, '0 daqiqa' would say nothing.
    if (minutes < 1) return '${duration.inSeconds} soniya';
    if (minutes < 60) return '$minutes daqiqa';
    final rest = minutes % 60;
    return rest == 0
        ? '${duration.inHours} soat'
        : '${duration.inHours} soat $rest daq';
  }
}

class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.entry});

  final HistoryEntry entry;

 
  static BoxDecoration decoration({required bool isDark}) {
    return BoxDecoration(
      color: isDark ? Appcolors.grey900 : Appcolors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: isDark ? Appcolors.grey800 : Appcolors.grey100),
      
      boxShadow: isDark
          ? null
          : [
              BoxShadow(
                color: Appcolors.white,
                blurRadius: 2,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Appcolors.white.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.5, vertical: 15.5),
      decoration: decoration(isDark: isDark),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: entry.iconTone.surface(isDark: isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: entry.icon.svg(
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                entry.iconTone.color,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Padding(
           
              padding: const EdgeInsets.only(top: 3.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Apptext.inter.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Appcolors.white : Appcolors.grey900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        entry.dateLabel,
                        style: Apptext.inter.copyWith(
                          fontSize: 12,
                          color: isDark ? Appcolors.grey300 : Appcolors.grey700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Appcolors.grey700 : Appcolors.grey300,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.timeLabel,
                        style: Apptext.inter.copyWith(
                          fontSize: 12,
                          color: Appcolors.grey500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: entry.badgeTone.surface(isDark: isDark),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    entry.durationLabel,
                    style: Apptext.inter.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: entry.badgeTone.color,
                    ),
                  ),
                ),
                const SizedBox(height: 3.5),
                Text(
                  entry.category,
                  style: Apptext.inter.copyWith(
                    fontSize: 11,
                    color: isDark ? Appcolors.grey500 : Appcolors.grey400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
