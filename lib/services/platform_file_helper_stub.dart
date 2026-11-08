import 'package:flutter/widgets.dart';

/// Stub implementasi untuk platform Web (tidak ada dart:io)
bool platformFileExists(String path) => false;

ImageProvider? getPlatformFileImage(String path) => null;

Widget? buildPlatformFileImageWidget(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) =>
    null;

