import 'package:flutter/material.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';

class Appthemes {
  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.light(primary: Appcolors.primaryColor),
    textButtonTheme: _textButtonTheme(Appcolors.grey500),
  );

  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.dark(primary: Appcolors.primaryColor),
    textButtonTheme: _textButtonTheme(Appcolors.grey300),
  );

  /// Text buttons rest in [idle] and turn primary while held down.
  static TextButtonThemeData _textButtonTheme(Color idle) {
    return TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return Appcolors.primaryColor;
          }
          return idle;
        }),
        overlayColor: WidgetStateProperty.all(
          Appcolors.primaryColor.withValues(alpha: 0.08),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
