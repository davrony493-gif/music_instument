import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// The picked avatar, kept as a file on disk with only its name in storage.
class AvatarService {
  static const String _key = 'avatarFile';

  // Only the file name is stored. The documents directory is a different
  // absolute path after an iOS update or reinstall, so a stored full path
  // would point at nothing.
  Future<File?> load() async {
    final name = GetStorage().read<String>(_key);
    if (name == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, name));
    if (!await file.exists()) {
      await GetStorage().remove(_key);
      return null;
    }
    return file;
  }

  /// [sourcePath] is the picker's own copy, which lives in a cache directory
  /// the system is free to empty, so the bytes are copied somewhere durable.
  Future<File> save(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    // A fresh name each time: Image.file caches by path, so reusing one name
    // would keep painting the previous picture.
    final name =
        'avatar_${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}';
    final saved = await File(sourcePath).copy(p.join(dir.path, name));

    final previous = GetStorage().read<String>(_key);
    await GetStorage().write(_key, name);
    if (previous != null && previous != name) {
      final old = File(p.join(dir.path, previous));
      if (await old.exists()) await old.delete();
    }
    return saved;
  }

  Future<void> clear() async {
    final name = GetStorage().read<String>(_key);
    if (name == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, name));
    if (await file.exists()) await file.delete();
    await GetStorage().remove(_key);
  }
}
