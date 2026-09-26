import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum GalleryPermission { granted, denied, permanentlyDenied }

class PermissionSerivce {
 
  static Future<GalleryPermission> requestGallery() async {
    try {
      final permission = await _galleryPermission();

      final status = await permission.status;
      debugPrint('gallery permission status -> $status');
      if (status.isGranted || status.isLimited) return GalleryPermission.granted;

      
      if (status.isPermanentlyDenied) return GalleryPermission.permanentlyDenied;

      final result = await permission.request();
      debugPrint('gallery permission result -> $result');
      return _map(result);
    } catch (_) {
      return GalleryPermission.denied;
    }
  }

  static Future<void> openSettings() => openAppSettings();

  
  static Future<Permission> _galleryPermission() async {
    if (!Platform.isAndroid) return Permission.photos;

    final info = await DeviceInfoPlugin().androidInfo;
    return info.version.sdkInt < 33 ? Permission.storage : Permission.photos;
  }

  
  static GalleryPermission _map(PermissionStatus status) {
    if (status.isGranted || status.isLimited) return GalleryPermission.granted;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return GalleryPermission.permanentlyDenied;
    }
    return GalleryPermission.denied;
  }
}
