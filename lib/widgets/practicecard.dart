import 'package:flutter/material.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';

/// Weekly practice summary: a progress ring next to the remaining time and
/// a day-by-day breakdown of the week.
class Practicecard extends StatelessWidget {
  const Practicecard({
    super.key,
    required this.completedHours,
    required this.goalHours,
    required this.daysCompleted,
    required this.totalDays,
    required this.dailyPlanMinutes,
  });

  final double completedHours;
  final double goalHours;
  final int daysCompleted;
  final int totalDays;
  final int dailyPlanMinutes;

  double get _progress => goalHours <= 0
      ? 0
      : (completedHours / goalHours).clamp(0.0, 1.0).toDouble();

 
  String _hours(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hoursLeft = (goalHours - completedHours).clamp(0.0, goalHours);

    final cardColor = isDark ? Appcolors.grey900 : Appcolors.white;
    final trackColor = isDark ? Appcolors.grey800 : Appcolors.grey100;
    final titleColor = isDark ? Appcolors.white : Appcolors.grey900;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Appcolors.grey800 : Appcolors.grey100),
        boxShadow: [
          BoxShadow(
            color: Appcolors.black.withValues(alpha: isDark ? 0.40 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Appcolors.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Weekly practice',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Appcolors.green.withValues(alpha: 0.18)
                      : Appcolors.greenSurface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Goal: ${(_progress * 100).round()}%',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Appcolors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 104,
                height: 104,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: _progress),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 10,
                            strokeCap: StrokeCap.round,
                            backgroundColor: trackColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Appcolors.primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_hours(completedHours)}/${_hours(goalHours)}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                            color: titleColor,
                          ),
                        ),
                        Text(
                          'hrs',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Appcolors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time left:',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Appcolors.grey500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_hours(hoursLeft.toDouble())} hours left',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: List.generate(totalDays, (index) {
                        final isDone = index < daysCompleted;
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == totalDays - 1 ? 0 : 6,
                          ),
                          child: Container(
                            width: 22,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? Appcolors.primaryColor
                                  : trackColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Daily plan: $dailyPlanMinutes min',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Appcolors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
