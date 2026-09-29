import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  final ImagePicker _picker = ImagePicker();

  /// Menyimpan path file foto profil yang dipilih pengguna.
  /// Null jika masih menggunakan foto bawaan/default.
  static final ValueNotifier<String?> profileImageNotifier =
      ValueNotifier<String?>(null);

  String? get currentImagePath => profileImageNotifier.value;

  /// Memilih foto profil dari Galeri
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        profileImageNotifier.value = pickedFile.path;
        return pickedFile.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Mengambil foto profil dari Kamera
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        profileImageNotifier.value = pickedFile.path;
        return pickedFile.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error taking photo with camera: $e');
      return null;
    }
  }

  /// Menghapus foto profil kustom (kembali ke default)
  void removeProfileImage() {
    profileImageNotifier.value = null;
  }
}
