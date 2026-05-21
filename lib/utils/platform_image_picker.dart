import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Selector de imágenes: en escritorio usa [file_picker] (estable en Windows).
class PlatformImagePicker {
  PlatformImagePicker._();

  static final ImagePicker _picker = ImagePicker();

  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static Future<String?> pickFromGallery() async {
    try {
      if (isDesktop) {
        return _pickWithFilePicker();
      }
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      return _validatePath(file?.path);
    } catch (e) {
      debugPrint('PlatformImagePicker gallery error: $e');
      return null;
    }
  }

  static Future<String?> _pickWithFilePicker() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    return _validatePath(result.files.first.path);
  }

  static Future<String?> pickFromCamera() async {
    if (isDesktop) return null;
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      return _validatePath(file?.path);
    } catch (e) {
      debugPrint('PlatformImagePicker camera error: $e');
      return null;
    }
  }

  static String? _validatePath(String? path) {
    if (path == null || path.isEmpty) return null;
    if (kIsWeb) return path;
    final file = File(path);
    if (!file.existsSync()) return null;
    return path;
  }
}
