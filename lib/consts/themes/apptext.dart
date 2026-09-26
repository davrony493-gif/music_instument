import 'package:flutter/painting.dart';

class Apptext {
  /// Inter as the designs set it: the font's own line height (1.21em) and no
  /// tracking. Without these, Text inherits Material's body style — a 1.43
  /// line height and 0.25 letter spacing — and drifts from the mockups.
  static const TextStyle inter = TextStyle(
    fontFamily: 'Inter',
    height: 1.21,
    letterSpacing: 0,
  );
}
