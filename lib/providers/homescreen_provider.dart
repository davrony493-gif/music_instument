import 'package:flutter/cupertino.dart';

class HomescreenProvider extends ChangeNotifier {
  HomescreenProvider() {
    // Rebuild when the search field gains or loses focus (icon/border color).
    searchFocusNode.addListener(notifyListeners);
  }

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  String query = '';

  static const List<String> _months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  //* Gotta change down here !

  bool get isSearchFocused => searchFocusNode.hasFocus;

  String get todayLabel {
    final now = DateTime.now();
    return 'TODAY, ${now.day} ${_months[now.month - 1]}';
  }

  String initialOf(String userName) {
    final name = userName.trim();
    return name.isEmpty ? 'No name' : name[0].toUpperCase();
  }

  void onSearchChanged(String value) {
    query = value;
    notifyListeners();
  }

  void onSearchSubmitted(String value) {
    searchFocusNode.unfocus();
  }

  void clearSearch() {
    searchController.clear();
    query = '';
    notifyListeners();
    searchFocusNode.requestFocus();
  }

  void startVoiceSearch() {}

  // Mic while empty, clear button once there is text.
  void onSuffixTap() {
    if (query.isEmpty) {
      startVoiceSearch();
    } else {
      clearSearch();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }
}
