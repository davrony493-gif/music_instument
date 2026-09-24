import 'package:flutter/foundation.dart';
import 'package:music_intrument/models/practice_session.dart';
import 'package:music_intrument/services/database_service.dart';

/// Saved practice sessions, plus the weekly figures the home screen shows.
class SessionsProvider extends ChangeNotifier {
  SessionsProvider({SessionRepository? repository})
    : _repository = repository ?? DatabaseService() {
    load();
  }

  final SessionRepository _repository;

  List<PracticeSession> _sessions = const [];
  bool _isLoading = true;

  /// Newest first.
  List<PracticeSession> get sessions => List.unmodifiable(_sessions);

  bool get isLoading => _isLoading;

  bool get isEmpty => !_isLoading && _sessions.isEmpty;

  /// The most recent [count] sessions, for the home screen list.
  List<PracticeSession> recent([int count = 3]) =>
      _sessions.take(count).toList();

  /// Title matches for [query], or the [count] most recent when it is blank.
  /// Searching spans every session, not just the ones already on screen.
  List<PracticeSession> matching(String query, [int count = 3]) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return recent(count);
    return _sessions
        .where((s) => s.title.toLowerCase().contains(q))
        .toList();
  }

  /// Hours practised since Monday, for the weekly progress card.
  double get hoursThisWeek {
    final total = _thisWeek().fold(
      Duration.zero,
      (sum, session) => sum + session.duration,
    );
    return total.inMinutes / 60;
  }

  /// Distinct days practised since Monday.
  int get daysPractisedThisWeek => _thisWeek()
      .map((s) => DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day))
      .toSet()
      .length;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _sessions = await _repository.all();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> save(PracticeSession session) async {
    final stored = await _repository.add(session);
    // Keep the in-memory list newest-first without a round trip.
    _sessions = [stored, ..._sessions]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    notifyListeners();
  }

  Future<void> remove(int id) async {
    await _repository.remove(id);
    _sessions = _sessions.where((s) => s.id != id).toList();
    notifyListeners();
  }

  Iterable<PracticeSession> _thisWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // weekday: Monday == 1, so this lands on the most recent Monday.
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return _sessions.where((s) => !s.startedAt.isBefore(monday));
  }
}
