import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_service.dart';
import 'user_profile_service.dart';
import 'platform_file_helper.dart';

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
          if (platformFileExists(savedPath)) {
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

      // Sinkronkan ke semua ruang chat aktif pasien ini secara real-time
      ChatService.instance.updatePatientPhotoInAllChats(key, base64String).catchError((_) {});

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
      ChatService.instance.updatePatientPhotoInAllChats(key, '').catchError((_) {});
    } catch (e) {
      debugPrint('[ProfileService] Error removing profile image: $e');
    }
  }

  /// Helper untuk mendapatkan ImageProvider baik dari path File lokal maupun data string Base64
  static ImageProvider? getImageProvider(String? source) {
    if (source == null || source.trim().isEmpty) return null;

    final trimmed = source.trim();

    // 1. Coba sebagai asset path
    if (trimmed.startsWith('assets/')) {
      return AssetImage(trimmed);
    }

    // 2. Coba sebagai URL Internet
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }

    // 3. Coba sebagai path file lokal (di platform non-web)
    final fileProvider = getPlatformFileImage(trimmed);
    if (fileProvider != null) return fileProvider;

    // 4. Coba sebagai string Base64 (dengan atau tanpa prefix data URI)
    try {
      String cleanBase64 = trimmed;
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

  /// Cache foto profil pasien berdasarkan patientId / UID
  static final ValueNotifier<Map<String, String>> patientPhotosNotifier =
      ValueNotifier<Map<String, String>>({});
  static final Set<String> _pendingPatientFetches = {};

  /// Mengambil foto profil pasien dari Firestore (dokumen users/UID) jika belum tersedia
  static Future<void> fetchPatientPhotoFromFirestore(String patientId) async {
    final cleanId = patientId.trim();
    if (cleanId.isEmpty || _pendingPatientFetches.contains(cleanId)) return;
    _pendingPatientFetches.add(cleanId);

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(cleanId)
          .get()
          .timeout(const Duration(seconds: 4));

      if (snap.exists && snap.data() != null) {
        final data = snap.data()!;
        final photo = (data['fotoProfil'] as String?)?.trim() ??
            (data['photoUrl'] as String?)?.trim() ??
            (data['profileImage'] as String?)?.trim() ??
            '';

        if (photo.isNotEmpty) {
          final currentMap =
              Map<String, String>.from(patientPhotosNotifier.value);
          currentMap[cleanId] = photo;
          patientPhotosNotifier.value = currentMap;
        }
      }
    } catch (e) {
      debugPrint('[ProfileService] fetchPatientPhotoFromFirestore error: $e');
    } finally {
      _pendingPatientFetches.remove(cleanId);
    }
  }

  /// Helper serbaguna untuk menampilkan foto profil pasien (Base64, Network, Asset, atau File)
  /// Mendukung sinkronisasi real-time dengan profil pasien kustom.
  static Widget buildPatientImage(
    String? photo, {
    String? patientId,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    bool isDark = false,
  }) {
    return ValueListenableBuilder<String?>(
      valueListenable: profileImageNotifier,
      builder: (context, localPhoto, _) {
        return ValueListenableBuilder<Map<String, String>>(
          valueListenable: patientPhotosNotifier,
          builder: (context, photoMap, _) {
            String resolved = (photo != null && photo.trim().isNotEmpty)
                ? photo.trim()
                : '';

            // Jika foto belum ada, cari berdasarkan patientId
            if (resolved.isEmpty &&
                patientId != null &&
                patientId.trim().isNotEmpty) {
              final cleanPId = patientId.trim();
              if (photoMap.containsKey(cleanPId) &&
                  photoMap[cleanPId]!.trim().isNotEmpty) {
                resolved = photoMap[cleanPId]!.trim();
              } else {
                String? currentUid;
                try {
                  currentUid = FirebaseAuth.instance.currentUser?.uid;
                } catch (_) {}

                if (currentUid != null &&
                    (cleanPId == currentUid || cleanPId.contains(currentUid))) {
                  if (localPhoto != null && localPhoto.trim().isNotEmpty) {
                    resolved = localPhoto.trim();
                  } else {
                    try {
                      final curr = UserProfileService
                          .instance.currentProfile.fotoProfil
                          .trim();
                      if (curr.isNotEmpty) resolved = curr;
                    } catch (_) {}
                  }
                } else {
                  fetchPatientPhotoFromFirestore(cleanPId);
                }
              }
            }

            // Jika masih kosong, coba fallback ke foto pengguna aktif di perangkat lokal
            if (resolved.isEmpty) {
              if (localPhoto != null && localPhoto.trim().isNotEmpty) {
                resolved = localPhoto.trim();
              } else {
                try {
                  final curr = UserProfileService
                      .instance.currentProfile.fotoProfil
                      .trim();
                  if (curr.isNotEmpty) resolved = curr;
                } catch (_) {}
              }
            }

            return _renderImageWidget(
              resolved,
              width: width,
              height: height,
              fit: fit,
              isDark: isDark,
            );
          },
        );
      },
    );
  }

  static Widget _renderImageWidget(
    String source, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    bool isDark = false,
  }) {
    if (source.isEmpty) {
      return _fallbackPatientAvatar(
          width: width, height: height, isDark: isDark, fit: fit);
    }

    // 1. URL Internet
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _fallbackPatientAvatar(
            width: width, height: height, isDark: isDark, fit: fit),
      );
    }

    // 2. Base64
    if (source.startsWith('data:image') || source.length > 80) {
      try {
        String clean = source;
        if (clean.contains(',')) {
          clean = clean.split(',').last;
        }
        final bytes = base64Decode(clean);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _fallbackPatientAvatar(
              width: width, height: height, isDark: isDark, fit: fit),
        );
      } catch (_) {}
    }

    // 3. Asset Image
    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _fallbackPatientAvatar(
            width: width, height: height, isDark: isDark, fit: fit),
      );
    }

    // 4. File lokal perangkat (di platform non-web)
    final fileWidget = buildPlatformFileImageWidget(
      source,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _fallbackPatientAvatar(
          width: width, height: height, isDark: isDark, fit: fit),
    );
    if (fileWidget != null) return fileWidget;

    return _fallbackPatientAvatar(
        width: width, height: height, isDark: isDark, fit: fit);
  }

  static Widget _fallbackPatientAvatar({
    double? width,
    double? height,
    bool isDark = false,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.asset(
      'assets/images/profile_woman.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: isDark ? const Color(0xFF0F2B3E) : const Color(0xFFE0F2FE),
        child: Icon(
          Icons.person_rounded,
          size: width != null ? width * 0.6 : 26,
          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
        ),
      ),
    );
  }
}
