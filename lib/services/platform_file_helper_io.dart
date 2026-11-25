import 'dart:io';
import 'package:flutter/widgets.dart';

/// Implementasi file IO untuk platform native (Android, iOS, Windows, macOS, Linux)
bool platformFileExists(String path) {
  try {
    return File(path).existsSync();
  } catch (_) {
    return false;
  }
}

ImageProvider? getPlatformFileImage(String path) {
  try {
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
  } catch (_) {}
  return null;
}

Widget? buildPlatformFileImageWidget(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  try {
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    }
  } catch (_) {}
  return null;
}

