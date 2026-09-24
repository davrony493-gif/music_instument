// ignore_for_file: unused_element

import 'dart:async';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:music_intrument/consts/themes/appthemes.dart';
import 'package:music_intrument/providers/homescreen_provider.dart';
import 'package:music_intrument/providers/live_session_provider.dart';
import 'package:music_intrument/providers/metronome_provider.dart';
import 'package:music_intrument/providers/notes_provider.dart';
import 'package:music_intrument/providers/profile_provider.dart';
import 'package:music_intrument/providers/sessions_provider.dart';
import 'package:music_intrument/providers/track_provider.dart';
import 'package:music_intrument/screens/splashcreen.dart';
import 'package:music_intrument/services/database_service.dart';
import 'package:music_intrument/widgets/no_internetwidget.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> naviggatorkey = GlobalKey();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(Myapp());
}

class Myapp extends StatefulWidget {
  const Myapp({super.key});

  @override
  State<Myapp> createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  // One connection, shared by every provider that stores something.
  final DatabaseService _database = DatabaseService();
  StreamSubscription? _connectivitySubscription;
  Timer? _pollingTimer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NoInternet.onRetry = _verifyInternet;

      _verifyInternet();

      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
        status,
      ) {
        // ignore: avoid_print
        print('Connectivity status -> $status');
        _verifyInternet();
      });

      _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        _verifyInternet();
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyInternet() async {
    if (_isChecking) return;
    _isChecking = true;

    bool hasInternet = false;
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 2));
      hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      hasInternet = false;
    } finally {
      _isChecking = false;
    }

    if (!mounted) return;

    if (!hasInternet) {
      NoInternet.showWidget();
    } else {
      NoInternet.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: Appthemes.light,
      dark: Appthemes.dark,
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => NotesProvider(repository: _database),
          ),
          ChangeNotifierProvider(create: (_) => HomescreenProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => MetronomeProvider()),
          ChangeNotifierProvider(create: (_) => TrackProvider()),
          ChangeNotifierProvider(create: (_) => LiveSessionProvider()),
          ChangeNotifierProvider(
            create: (_) => SessionsProvider(repository: _database),
          ),
        ],
        child: MaterialApp(
          navigatorKey: naviggatorkey,
          // Above the navigator: nothing on the route stack can disturb it.
          builder: (context, child) => NoInternet.gate(child),
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          home: const Onborading(),
        ),
      ),
    );
  }
}
