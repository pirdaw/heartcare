import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile_service.dart';

class ProfileService {
  ProfileService._() {
    _init();
  }
  static final ProfileService instance = ProfileService._();

  final ImagePicker _picker = ImagePicker();

  /// Menyimpan path file foto profil atau Base64 image data yang dipilih pengguna.
  /// Null jika masih menggunakan foto bawaan/default.
  static final ValueNotifier<String?> profileImageNotifier =
      ValueNotifier<String?>(null);

  String? get currentImagePath => profileImageNotifier.value;

  void _init() {
    loadSavedImage();

    // Pantau perubahan user login/logout agar foto profil sesuai dengan akun aktif
    try {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        loadSavedImage();
      });
    } catch (_) {}
  }

  String _getUserKey() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid.isNotEmpty) {
        return user.uid;
      }
      if (user != null && (user.email ?? '').isNotEmpty) {
        return user.email!;
      }
    } catch (_) {}
    return 'guest_user';
  }

  /// Memuat foto profil tersimpan untuk user saat ini dari SharedPreferences / Firestore
  Future<void> loadSavedImage() async {
    try {
      final key = _getUserKey();
      final prefs = await SharedPreferences.getInstance();

      // 1. Cek path file lokal terlebih dahulu jika file fisik masih tersedia di perangkat
      final savedPath = prefs.getString('user_profile_photo_path_$key');
      if (savedPath != null && savedPath.isNotEmpty) {
        try {
          final file = File(savedPath);
          if (file.existsSync()) {
            profileImageNotifier.value = savedPath;
            return;
          }
        } catch (_) {}
      }

      // 2. Cek base64 dari SharedPreferences
      final savedBase64 = prefs.getString('user_profile_photo_base64_$key');
      if (savedBase64 != null && savedBase64.isNotEmpty) {
        profileImageNotifier.value = savedBase64;
        return;
      }

      // 3. Cek dari UserProfileService (yang tersinkron dengan Firestore)
      final userProfile = UserProfileService.instance.currentProfile;
      if (userProfile.fotoProfil.isNotEmpty) {
        profileImageNotifier.value = userProfile.fotoProfil;
        return;
      }

      // Jika tidak ada foto profil tersimpan
      profileImageNotifier.value = null;
    } catch (e) {
      debugPrint('[ProfileService] Error loading saved image: $e');
    }
  }

  /// Sinkronisasi foto yang datang dari Firestore / Preferences
  void syncFromProfile(String? fotoProfil) {
    if (fotoProfil != null && fotoProfil.trim().isNotEmpty) {
      if (profileImageNotifier.value != fotoProfil) {
        profileImageNotifier.value = fotoProfil;
      }
      _saveBase64ToPrefs(fotoProfil);
    }
  }

  Future<void> _saveBase64ToPrefs(String base64Data) async {
    try {
      final key = _getUserKey();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_photo_base64_$key', base64Data);
    } catch (_) {}
  }

  /// Memproses penyimpanan foto (baik dari galeri maupun kamera)
  Future<String?> _savePickedImage(XFile pickedFile) async {
    try {
      final key = _getUserKey();
      final path = pickedFile.path;

      // Konversi ke base64 agar foto aman tersimpan permanen dan tersinkron ke Firestore
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);

      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_photo_path_$key', path);
      await prefs.setString('user_profile_photo_base64_$key', base64String);

      // Update notifier langsung agar UI berubah seketika
      profileImageNotifier.value = path;

      // Simpan juga ke UserProfileService (otomatis simpan ke Firestore & preferences)
      await UserProfileService.instance.updateFotoProfil(base64String);

      return path;
    } catch (e) {
      debugPrint('[ProfileService] Gagal menyimpan foto profil: $e');
      return null;
    }
  }

  /// Memilih foto profil dari Galeri
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        return await _savePickedImage(pickedFile);
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
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        return await _savePickedImage(pickedFile);
      }
      return null;
    } catch (e) {
      debugPrint('Error taking photo with camera: $e');
      return null;
    }
  }

  /// Menghapus foto profil kustom (kembali ke default)
  Future<void> removeProfileImage() async {
    try {
      final key = _getUserKey();
      profileImageNotifier.value = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_profile_photo_path_$key');
      await prefs.remove('user_profile_photo_base64_$key');

      await UserProfileService.instance.updateFotoProfil('');
    } catch (e) {
      debugPrint('[ProfileService] Error removing profile image: $e');
    }
  }

  /// Helper untuk mendapatkan ImageProvider baik dari path File lokal maupun data string Base64
  static ImageProvider? getImageProvider(String? source) {
    if (source == null || source.trim().isEmpty) return null;

    // Coba sebagai path file lokal
    try {
      final file = File(source);
      if (file.existsSync()) {
        return FileImage(file);
      }
    } catch (_) {}

    // Coba sebagai string Base64 (dengan atau tanpa prefix data URI)
    try {
      String cleanBase64 = source.trim();
      if (cleanBase64.contains(',')) {
        cleanBase64 = cleanBase64.split(',').last;
      }
      final bytes = base64Decode(cleanBase64);
      if (bytes.isNotEmpty) {
        return MemoryImage(bytes);
      }
    } catch (_) {}

    return null;
  }
}
