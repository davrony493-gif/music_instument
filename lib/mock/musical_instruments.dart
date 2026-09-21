class MockData {
  
  static const List<String> instruments = [
    'Violin',
    'Guitar',
    'Piano',
  ];

  static Future<List<String>> getCachedInstruments() async {
    await Future.delayed(const Duration(seconds: 1));
    return instruments;
  }
}