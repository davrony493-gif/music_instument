import 'package:flutter/cupertino.dart';

class NotesProvider extends ChangeNotifier {
  NotesProvider() {
    // Rebuild when the search field gains or loses focus (icon/border color).
    searchFocusNode.addListener(notifyListeners);
  }

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  String quest = '';
  int tab = 0;

  final List<Map<String, dynamic>> notes = [
    {
      'title': 'Beethoven — Moonlight Sonata',
      'details': 'C# minor · 1.4 MB',
      'type': 'pdf',
      'pages': 4,
      'favorite': false,
    },
    {
      'title': 'Vivaldi — Summer (Presto)',
      'details': 'G minor · 2.8 MB',
      'type': 'pdf',
      'pages': 8,
      'favorite': false,
    },
    {
      'title': 'Mozart — Eine kleine Nachtmusik',
      'details': 'G major · 950 KB',
      'type': 'pdf',
      'pages': 2,
      'favorite': false,
    },
    {
      'title': 'Uzbek National Melodies (Set)',
      'details': 'Tanovar, Munojot · 3.1 MB',
      'type': 'chord',
      'favorite': false,
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

  void setTab(int value) {
    tab = value;
    notifyListeners();
  }

  void toggleFavorite(int index) {
    notes[index]['favorite'] = !notes[index]['favorite'];
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }
}
