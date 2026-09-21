# CLAUDE.md

Flutter app (`music_intrument`, note the spelling — it is the package name used in all imports) for musicians: a profile/sign-up flow plus planned audio playback, a metronome, and local storage. **Early-stage**: only the sign-up screen is implemented; several files are empty placeholders (see below).

## Commands

```sh
flutter pub get
flutter run
flutter analyze                                   # lints: flutter_lints (analysis_options.yaml)
flutter test
dart run build_runner build --delete-conflicting-outputs   # regenerate lib/gen/ after adding assets
dart run flutter_launcher_icons                   # regenerate app icons from assets/images/logo.png
```

Dart SDK `^3.11.4`. Targets: android, ios, web (macOS/Windows icon config exists in pubspec but those platform folders do not).

## Architecture

Simple layered layout, no architecture framework yet:

- `lib/main.dart` — `runApp(Myapp())`. `Myapp` wraps `MaterialApp` in `AdaptiveTheme` (light/dark, initial mode = system). `home` is currently `Signup`.
- `lib/screens/` — one file per screen, widgets are `StatefulWidget`/`StatelessWidget` classes.
  - `signup.dart` (~430 lines) — the only implemented screen.
  - `homescreen.dart`, `mainscreen.dart` — **empty**, intended for the post-login UI.
- `lib/services/` — non-UI logic. `audio_service.dart` and `database_service.dart` are **empty** placeholders (planned for `audio_service` + `sqflite`).
- `lib/consts/colors/appcolors.dart` — `Appcolors` static color palette (`primaryColor` = `#2563EB`, greys, etc.).
- `lib/consts/themes/appthemes.dart` — `Appthemes.light` / `Appthemes.dark` `ThemeData`, seeded only with the primary color.
- `lib/mock/musical_instruments.dart` — `MockData` (hardcoded instrument list: Violin, Guitar, Piano). Stand-in for a future DB/API.
- `lib/gen/` — **generated** by `flutter_gen` (`assets.gen.dart`, `fonts.gen.dart`). Never hand-edit.

## State management

- `provider` is a declared dependency but **not used yet**. Current state is local: `setState` in `_SignupState` (selected instrument, reorderable list, focus flags) with `TextEditingController`/`FocusNode` disposed in `dispose()`.
- Theme mode state is handled by `adaptive_theme` (`AdaptiveTheme.of(context)`), which persists the choice.
- When adding shared state (current user, player state), prefer `provider` (`ChangeNotifier` + `ChangeNotifierProvider` above `MaterialApp`) rather than introducing another package.

## Dependencies of note

`adaptive_theme` (theming), `provider` (state, planned), `sqflite` + `path` + `path_provider` (local DB, planned), `audio_service` (background audio, planned), `video_player`, `image_picker` + `permission_handler` (profile photo, planned — the avatar upload buttons in `signup.dart` are still empty `onTap`/`onPressed` stubs), `connectivity_plus`, `flutter_svg`, `lottie`, `animate_do`, `dotted_border`.

## Assets

- `assets/images/`, `assets/icons/` (SVGs), `assets/lotties/` (empty), `assets/fonts/inter.ttf` (family `Inter`).
- Always reference assets through the generated accessors, not string paths: `Assets.images.logo.path`, `Assets.icons.user.svg(...)`, `Assets.icons.disc.path`. After adding a file, run build_runner.
- Icons are single-color SVGs tinted via `colorFilter: ColorFilter.mode(color, BlendMode.srcIn)`.

## Conventions (observed)

- Imports use the package form: `package:music_intrument/...` (no relative imports).
- Class names are capitalized-first-letter only (`Appcolors`, `Appthemes`, `Myapp`); files are lowercase without separators (`appcolors.dart`, `homescreen.dart`). Match this for consistency in new code, even though standard Dart would use `AppColors` / `home_screen.dart`.
- Colors: use `Appcolors.*`. Some hardcoded hex values remain in `signup.dart` (`0xFF8E9BAE`, `0xFF6EA8FE`, `0xFF2563EB`) — prefer moving these into `Appcolors` when touching them.
- Text: `fontFamily: 'Inter'` set inline on `TextStyle`s (not via the theme). Consider moving to `ThemeData(fontFamily: FontFamily.inter)`.
- Spacing via `SizedBox(height: n)`; screens wrap content in `SafeArea` + `SingleChildScrollView`; tapping outside fields unfocuses via a root `GestureDetector`.
- Inputs use rounded `OutlineInputBorder`s, focus-driven icon/border color changes (`FocusNode` listeners + `setState`).
- UI copy is mixed: English labels with Uzbek button text (`'Tizimga kirish'` = "Log in"). No localization setup yet.
- `signup.dart` starts with `// ignore_for_file: deprecated_member_use, prefer_final_fields, unused_field`; don't spread this to new files.

## Known gaps / TODO

- Sign-up submit, image upload, and navigation are stubs (`// Navigation or submit logic`).
- Signup screen ignores dark theme in places (`Appcolors.white`, `Colors.white` fills).
- `Appthemes` only sets `primary`; no typography, input, or button themes, which is why styling is repeated inline.
- No tests exist (`test/` is absent). README is a stub.
