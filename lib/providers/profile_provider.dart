import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_intrument/services/avatar_service.dart';
import 'package:music_intrument/services/permission_serivce.dart';

enum PickResult { saved, cancelled, denied, permanentlyDenied }


class ProfileProvider extends ChangeNotifier {
  ProfileProvider({AvatarService? service, ImagePicker? picker})
    : _service = service ?? AvatarService(),
      _picker = picker ?? ImagePicker() {
    _load();
  }

  final AvatarService _service;
  final ImagePicker _picker;

  File? _avatar;
  bool _isSaving = false;

  File? get avatar => _avatar;
  bool get hasAvatar => _avatar != null;
  bool get isSaving => _isSaving;

  Future<void> _load() async {
    _avatar = await _service.load();
    notifyListeners();
  }

  Future<PickResult> pickFromGallery() async {
    if (_isSaving) return PickResult.cancelled;

    switch (await PermissionSerivce.requestGallery()) {
      case GalleryPermission.permanentlyDenied:
        return PickResult.permanentlyDenied;
      case GalleryPermission.denied:
        return PickResult.denied;
      case GalleryPermission.granted:
        break;
    }

    
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return PickResult.cancelled;

    _isSaving = true;
    notifyListeners();
    try {
      _avatar = await _service.save(picked.path);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
    return PickResult.saved;
  }

  Future<void> openSettings() => PermissionSerivce.openSettings();

  Future<void> remove() async {
    await _service.clear();
    _avatar = null;
    notifyListeners();
  }
}
