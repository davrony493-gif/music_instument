import 'package:flutter/material.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/consts/themes/apptext.dart';
import 'package:music_intrument/widgets/history_card.dart';


enum WeekDayLook { faded, plain, marked, selected }

class WeekDay {
  const WeekDay(this.day, this.look, {this.enabled = true});

  final int day;
  final WeekDayLook look;

  
  final bool enabled;
}

class WeekCalendarCard extends StatelessWidget {
  const WeekCalendarCard({
    super.key,
    required this.month,
    required this.summary,
    required this.days,
    this.onDayTap,
    this.onPreviousWeek,
    this.onNextWeek,
  }) : assert(days.length == 7, 'One week, Monday first.');

  final String month;
  final String summary;
  final List<WeekDay> days;

 
  final ValueChanged<int>? onDayTap;

 
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;

  
  static const List<String> _weekdays = ['D', 'S', 'CH', 'P', 'J', 'SH', 'Y'];

  static const double _gap = 4.5;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
       
        if (velocity > 300) onPreviousWeek?.call();
        if (velocity < -300) onNextWeek?.call();
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        decoration: HistoryCard.decoration(isDark: isDark),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    month,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Apptext.inter.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Appcolors.white : Appcolors.grey900,
                    ),
                  ),
                ),
                Text(
                  summary,
                  style: Apptext.inter.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Appcolors.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            Row(
              spacing: _gap,
              children: [
                for (final label in _weekdays)
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Apptext.inter.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Appcolors.grey500 : Appcolors.grey400,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              spacing: _gap,
              children: [
                for (var i = 0; i < days.length; i++)
                  Expanded(
                    child: _DayPill(
                      day: days[i],
                      onTap: days[i].enabled && onDayTap != null
                          ? () => onDayTap!(i)
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({required this.day, required this.onTap});

  final WeekDay day;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (Color? fill, Color text, FontWeight weight) = switch (day.look) {
      WeekDayLook.faded => (
        null,
        isDark ? Appcolors.grey500 : Appcolors.grey400,
        FontWeight.w400,
      ),
      WeekDayLook.plain => (
        null,
        isDark ? Appcolors.white : Appcolors.grey800,
        FontWeight.w400,
      ),
      WeekDayLook.marked => (
        isDark
            ? Appcolors.primaryColor.withValues(alpha: 0.18)
            : Appcolors.blueSurface,
        Appcolors.primaryColor,
        FontWeight.w700,
      ),
      WeekDayLook.selected => (
        Appcolors.primaryColor,
        Appcolors.white,
        FontWeight.w700,
      ),
    };

    return Semantics(
      button: onTap != null,
      selected: day.look == WeekDayLook.selected,
      child: GestureDetector(
        // The whole pill, not just the digits, takes the tap.
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill ?? Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${day.day}',
            style: Apptext.inter.copyWith(
              fontSize: 12,
              fontWeight: weight,
              color: text,
            ),
          ),
        ),
      ),
    );
  }
}
