import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:music_intrument/consts/themes/appthemes.dart';
import 'package:music_intrument/providers/notes_provider.dart';
import 'package:music_intrument/providers/sign_up_provider.dart';
import 'package:music_intrument/screens/signup.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: Appthemes.light,
      dark: Appthemes.dark,
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => ChangeNotifierProvider(
        create: (_) => NotesProvider(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          home: ChangeNotifierProvider(
            create: (_) => SignUpProvider(),
            child: Signup(),
          ),
        ),
      ),
    );
  }
}
