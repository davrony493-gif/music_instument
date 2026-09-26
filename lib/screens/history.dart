import 'package:flutter/material.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/consts/themes/apptext.dart';
import 'package:music_intrument/gen/assets.gen.dart';
import 'package:music_intrument/models/practice_session.dart';
import 'package:music_intrument/providers/sessions_provider.dart';
import 'package:music_intrument/widgets/history_card.dart';
import 'package:music_intrument/widgets/week_calendar_card.dart';
import 'package:provider/provider.dart';


class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late DateTime _selected = _today;

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  
  DateTime get _monday => DateTime(
    _selected.year,
    _selected.month,
    _selected.day - (_selected.weekday - 1),
  );

  void _select(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    final today = _today;
    setState(() => _selected = date.isAfter(today) ? today : date);
  }

  void _shiftWeek(int weeks) {
    final target = DateTime(
      _selected.year,
      _selected.month,
      _selected.day + 7 * weeks,
    );
   
    if (target.isAfter(_today) && _selected == _today) return;
    _select(target);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2020),
      lastDate: _today,
    );
    if (picked != null && mounted) _select(picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessions = context.watch<SessionsProvider>();
    final today = _today;
    final practised = sessions.practisedDays;
    final entries = sessions.on(_selected).map(_entryFor).toList();

    final monday = _monday;
    final week = [
      for (var i = 0; i < 7; i++)
        DateTime(monday.year, monday.month, monday.day + i),
    ];
    final daysPractised = week.where(practised.contains).length;

    return Scaffold(
      backgroundColor: isDark ? Appcolors.black : Appcolors.groupedBackground,
      body: SafeArea(
       
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              sliver: SliverList.list(
                children: [
                  _Header(
                    total: sessions.totalDuration,
                    onCalendarTap: _pickDate,
                  ),
                  const SizedBox(height: 19),
                  WeekCalendarCard(
                    month:
                        '${_capitalized(HistoryEntry.months[_selected.month - 1])} '
                        '${_selected.year}',
                    summary: week.contains(today)
                        ? 'Ushbu hafta ($daysPractised kun)'
                        : 'Tanlangan hafta ($daysPractised kun)',
                    days: [
                      for (final day in week)
                        WeekDay(
                          day.day,
                          day == _selected
                              ? WeekDayLook.selected
                              : practised.contains(day)
                              ? WeekDayLook.marked
                              : day == today
                              ? WeekDayLook.plain
                              : WeekDayLook.faded,
                          enabled: !day.isAfter(today),
                        ),
                    ],
                    onDayTap: (index) => _select(week[index]),
                    onPreviousWeek: () => _shiftWeek(-1),
                    onNextWeek: () => _shiftWeek(1),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      "MASHQLAR RO'YXATI",
                      style: Apptext.inter.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Appcolors.grey500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (sessions.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (entries.isEmpty)
                    _EmptyDay(day: _selected, isToday: _selected == today),
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                24,
                0,
                24,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              sliver: SliverList.separated(
                itemCount: sessions.isLoading ? 0 : entries.length,
                itemBuilder: (context, index) =>
                    HistoryCard(entry: entries[index]),
                separatorBuilder: (_, _) => const SizedBox(height: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _capitalized(String word) =>
      word[0].toUpperCase() + word.substring(1);

 
  static HistoryEntry _entryFor(PracticeSession session) {
    final withTrack = session.title != PracticeSession.untitled;
    
    final variant =
        (session.id ?? session.startedAt.millisecondsSinceEpoch) % 3;
    final (icon, tone) = !withTrack
        ? (Assets.icons.activity, HistoryTone.orange)
        : switch (variant) {
            0 => (Assets.icons.musicNotesDouble, HistoryTone.blue),
            1 => (Assets.icons.musicNotes, HistoryTone.indigo),
            _ => (Assets.icons.musicNote, HistoryTone.purple),
          };

    return HistoryEntry(
      title: session.title,
      startedAt: session.startedAt,
      duration: session.duration,
      category: withTrack ? 'Musiqa bilan' : 'Texnika',
      icon: icon,
      iconTone: tone,
      // Green once a session reaches half an hour.
      badgeTone: session.duration.inMinutes >= 30
          ? HistoryTone.green
          : HistoryTone.blue,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.total, required this.onCalendarTap});

  final Duration total;
  final VoidCallback onCalendarTap;

  /// '42 soat', '1 soat 20 daqiqa', '35 daqiqa'.
  static String _totalLabel(Duration total) {
    final minutes = total.inMinutes;
    if (minutes < 60) return '$minutes daqiqa';
    final rest = minutes % 60;
    return rest == 0
        ? '${total.inHours} soat'
        : '${total.inHours} soat $rest daqiqa';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mashg'ulotlar tarixi",
                style: Apptext.inter.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  // Inter's display cut at this size, as the design uses;
                  // without it the title comes out ~20pt wider.
                  fontVariations: const [FontVariation('opsz', 26)],
                  color: isDark ? Appcolors.white : Appcolors.grey900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Jami: ${_totalLabel(total)} mashq qilindi',
                style: Apptext.inter.copyWith(
                  fontSize: 13,
                  color: Appcolors.grey500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filled(
          onPressed: onCalendarTap,
          tooltip: 'Sanani tanlash',
          style: IconButton.styleFrom(
            backgroundColor: isDark ? Appcolors.grey800 : Appcolors.controlFill,
            fixedSize: const Size(40, 40),
            minimumSize: const Size(40, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
          ),
          icon: Assets.icons.calendarDays.svg(
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(
              isDark ? Appcolors.grey300 : Appcolors.grey700,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.day, required this.isToday});

  final DateTime day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final date = '${day.day}-${HistoryEntry.months[day.month - 1]}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Assets.icons.calendarDays.svg(
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(Appcolors.grey400, BlendMode.srcIn),
          ),
          const SizedBox(height: 12),
          Text(
            isToday
                ? 'Bugun hali mashq qilinmadi.'
                : '$date kuni mashq qilinmagan.',
            textAlign: TextAlign.center,
            style: Apptext.inter.copyWith(
              fontSize: 14,
              height: 1.5,
              color: Appcolors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}
