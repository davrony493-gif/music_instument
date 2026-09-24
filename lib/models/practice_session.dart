/// One finished practice session, as stored in the local database.
class PracticeSession {
  const PracticeSession({
    this.id,
    required this.title,
    required this.startedAt,
    required this.duration,
    this.laps = const [],
  });

  final int? id;
  final String title;
  final DateTime startedAt;
  final Duration duration;
  final List<Duration> laps;

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// 'Today, 18:30' / 'Yesterday, 09:15' / 'Monday, 20:00' / '3 Sep, 20:00'.
  String whenLabel({DateTime? now}) {
    final today = _dayOf(now ?? DateTime.now());
    final day = _dayOf(startedAt);
    final daysAgo = today.difference(day).inDays;

    final hh = startedAt.hour.toString().padLeft(2, '0');
    final mm = startedAt.minute.toString().padLeft(2, '0');
    final time = '$hh:$mm';

    if (daysAgo == 0) return 'Today, $time';
    if (daysAgo == 1) return 'Yesterday, $time';
    if (daysAgo < 7) return '${_weekdays[startedAt.weekday - 1]}, $time';
    return '${startedAt.day} ${_months[startedAt.month - 1]}, $time';
  }

  /// Scales to the length of the session: '45 sec', '30 min', '1h 20m'.
  String get durationLabel {
    final minutes = duration.inMinutes;

    // Under a minute, minutes would read '0 min' and say nothing.
    if (minutes < 1) return '${duration.inSeconds} sec';
    if (minutes < 60) return '$minutes min';

    final remainder = minutes % 60;
    return remainder == 0
        ? '${duration.inHours}h'
        : '${duration.inHours}h ${remainder}m';
  }

  static DateTime _dayOf(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'started_at': startedAt.millisecondsSinceEpoch,
    'duration_ms': duration.inMilliseconds,
    // Laps are only ever read back as a whole, so a CSV column is enough.
    'laps': laps.map((lap) => lap.inMilliseconds).join(','),
  };

  factory PracticeSession.fromMap(Map<String, Object?> map) {
    final rawLaps = (map['laps'] as String?) ?? '';
    return PracticeSession(
      id: map['id'] as int?,
      title: map['title'] as String,
      startedAt: DateTime.fromMillisecondsSinceEpoch(map['started_at'] as int),
      duration: Duration(milliseconds: map['duration_ms'] as int),
      laps: rawLaps.isEmpty
          ? const []
          : rawLaps
                .split(',')
                .map((ms) => Duration(milliseconds: int.parse(ms)))
                .toList(),
    );
  }

  PracticeSession copyWith({int? id}) => PracticeSession(
    id: id ?? this.id,
    title: title,
    startedAt: startedAt,
    duration: duration,
    laps: laps,
  );
}
