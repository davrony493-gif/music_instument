import 'package:flutter/cupertino.dart';
import 'package:music_intrument/services/database_service.dart';

class NotesProvider extends ChangeNotifier {
  NotesProvider({FavoritesRepository? repository})
    : _repository = repository ?? DatabaseService() {
    searchFocusNode.addListener(notifyListeners);
    _loadFavorites();
  }

  final FavoritesRepository _repository;

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  String quest = '';
  int tab = 0;

  Set<String> _favoriteIds = const {};
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  final List<Map<String, dynamic>> notes = [
    {
      'id': 'beethoven-moonlight-sonata',
      'title': 'Beethoven — Moonlight Sonata',
      'details': 'C# minor · 1.4 MB',
      'type': 'pdf',
      'pages': 4,
    },
    {
      'id': 'vivaldi-summer-presto',
      'title': 'Vivaldi — Summer (Presto)',
      'details': 'G minor · 2.8 MB',
      'type': 'pdf',
      'pages': 8,
    },
    {
      'id': 'mozart-eine-kleine-nachtmusik',
      'title': 'Mozart — Eine kleine Nachtmusik',
      'details': 'G major · 950 KB',
      'type': 'pdf',
      'pages': 2,
    },
    {
      'id': 'uzbek-national-melodies',
      'title': 'Uzbek National Melodies (Set)',
      'details': 'Tanovar, Munojot · 3.1 MB',
      'type': 'chord',
    },
  ];

  bool get isSearchFocused => searchFocusNode.hasFocus;

  void findInfo(String value) {
    quest = value;
    notifyListeners();
  }

  void findInfoDone(String value) {
    searchFocusNode.unfocus();
  }

  void clean() {
    searchController.clear();
    quest = '';
    notifyListeners();
    searchFocusNode.requestFocus();
  }

  List<Map<String, dynamic>> get _byTab {
    switch (tab) {
      case 1:
        return notes.where(isFavorite).toList();
      case 2:
        return const [];
      default:
        return notes;
    }
  }

  bool get isSearching => quest.trim().isNotEmpty;

  List<Map<String, dynamic>> get visibleNotes {
    final q = quest.trim().toLowerCase();
    if (q.isEmpty) return _byTab;
    return _byTab
        .where((n) => (n['title'] as String).toLowerCase().contains(q))
        .toList();
  }

  bool isFavorite(Map<String, dynamic> note) =>
      _favoriteIds.contains(note['id'] as String);

  Future<void> _loadFavorites() async {
    _favoriteIds = await _repository.favoriteIds();
    _isLoading = false;
    notifyListeners();
  }

  void setTab(int value) {
    tab = value;
    notifyListeners();
  }

  Future<void> toggleFavorite(Map<String, dynamic> note) async {
    final id = note['id'] as String;
    final wasFavorite = _favoriteIds.contains(id);
    final previous = _favoriteIds;

    final updated = {..._favoriteIds};
    wasFavorite ? updated.remove(id) : updated.add(id);
    _favoriteIds = updated;
    notifyListeners();

    try {
      if (wasFavorite) {
        await _repository.removeFavorite(id);
      } else {
        await _repository.addFavorite(id);
      }
    } catch (_) {
     
      _favoriteIds = previous;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }
}
