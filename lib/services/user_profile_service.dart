import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_service.dart';

class UserProfileData {
  String nama;
  String email;
  String jenisKelamin;
  String ttl;
  String alamat;
  String telepon;

  // Data Kesehatan
  String golonganDarah;
  String tinggiBadan;
  String beratBadan;
  String alergi;
  String penyakitDiderita;
  String riwayatOperasi;

  // Foto Profil (bisa berupa path file lokal atau string data Base64)
  String fotoProfil;

  UserProfileData({
    required this.nama,
    required this.email,
    this.jenisKelamin = '',
    this.ttl = '',
    this.alamat = '',
    this.telepon = '',
    this.golonganDarah = '',
    this.tinggiBadan = '',
    this.beratBadan = '',
    this.alergi = '',
    this.penyakitDiderita = '',
    this.riwayatOperasi = '',
    this.fotoProfil = '',
  });

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'email': email,
        'jenisKelamin': jenisKelamin,
        'ttl': ttl,
        'tanggalLahir': ttl,
        'alamat': alamat,
        'telepon': telepon,
        'golonganDarah': golonganDarah,
        'tinggiBadan': tinggiBadan,
        'beratBadan': beratBadan,
        'alergi': alergi,
        'penyakitDiderita': penyakitDiderita,
        'riwayatOperasi': riwayatOperasi,
        'fotoProfil': fotoProfil,
      };

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    final rawNama = (json['nama'] as String?)?.trim() ?? '';
    final rawName = (json['name'] as String?)?.trim() ?? '';
    final resolvedNama = rawNama.isNotEmpty ? rawNama : rawName;

    final rawTelepon = (json['telepon'] as String?)?.trim() ?? '';
    final rawPhone = (json['phone'] as String?)?.trim() ??
        (json['noHp'] as String?)?.trim() ??
        '';
    final resolvedTelepon = rawTelepon.isNotEmpty ? rawTelepon : rawPhone;

    final rawTtl = (json['ttl'] as String?)?.trim() ?? '';
    final rawTanggalLahir = (json['tanggalLahir'] as String?)?.trim() ??
        (json['tanggal_lahir'] as String?)?.trim() ??
        '';
    final resolvedTtl = rawTtl.isNotEmpty ? rawTtl : rawTanggalLahir;

    final rawFoto = (json['fotoProfil'] as String?)?.trim() ??
        (json['photoUrl'] as String?)?.trim() ??
        (json['profileImage'] as String?)?.trim() ??
        '';

    return UserProfileData(
      nama: resolvedNama,
      email: (json['email'] as String?)?.trim() ?? '',
      jenisKelamin: (json['jenisKelamin'] as String?)?.trim() ??
          (json['gender'] as String?)?.trim() ??
          '',
      ttl: resolvedTtl,
      alamat: (json['alamat'] as String?)?.trim() ?? '',
      telepon: resolvedTelepon,
      golonganDarah: (json['golonganDarah'] as String?)?.trim() ?? '',
      tinggiBadan: (json['tinggiBadan'] as String?)?.trim() ?? '',
      beratBadan: (json['beratBadan'] as String?)?.trim() ?? '',
      alergi: (json['alergi'] as String?)?.trim() ?? '',
      penyakitDiderita: (json['penyakitDiderita'] as String?)?.trim() ?? '',
      riwayatOperasi: (json['riwayatOperasi'] as String?)?.trim() ?? '',
      fotoProfil: rawFoto,
    );
  }

  bool get isDataPribadiComplete =>
      nama.trim().isNotEmpty &&
      jenisKelamin.trim().isNotEmpty &&
      ttl.trim().isNotEmpty &&
      alamat.trim().isNotEmpty &&
      telepon.trim().isNotEmpty &&
      email.trim().isNotEmpty;

  bool get isDataKesehatanComplete =>
      golonganDarah.trim().isNotEmpty &&
      tinggiBadan.trim().isNotEmpty &&
      beratBadan.trim().isNotEmpty &&
      alergi.trim().isNotEmpty &&
      penyakitDiderita.trim().isNotEmpty &&
      riwayatOperasi.trim().isNotEmpty;

  bool get isProfileFullyComplete =>
      isDataPribadiComplete && isDataKesehatanComplete;
}

class UserProfileService extends ChangeNotifier {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, UserProfileData> _cache = {};
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _firestoreSubscription;
  String? _subscribedUid;

  UserProfileService._internal() {
    final initialUser = _auth.currentUser;
    if (initialUser != null && initialUser.uid.isNotEmpty) {
      _subscribeToFirestore(initialUser.uid);
    }

    _auth.authStateChanges().listen((user) {
      if (user != null && user.uid.isNotEmpty) {
        _subscribeToFirestore(user.uid);
      } else {
        _unsubscribeFromFirestore();
      }
    });
  }

  static UserProfileService get instance => _instance;

  String _getUserKey() {
    try {
      final user = _auth.currentUser;
      if (user != null && user.uid.isNotEmpty) {
        return user.uid;
      }
      if (user != null && (user.email ?? '').isNotEmpty) {
        return user.email!;
      }
    } catch (_) {}
    return 'guest_user';
  }

  /// Dapatkan profil pengguna yang sedang login.
  /// Jika pengguna baru, nama diambil dari akun terdaftar (displayName) dan email dari akun.
  /// Field data pribadi & data kesehatan lainnya berstatus kosong (belum diisi) agar diisi sendiri.
  UserProfileData get currentProfile {
    final key = _getUserKey();
    User? user;
    try {
      user = _auth.currentUser;
    } catch (_) {}

    if (user != null && user.uid.isNotEmpty && _subscribedUid != user.uid) {
      _subscribeToFirestore(user.uid);
    }

    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    String name = (user?.displayName ?? '').trim();
    if (name.isEmpty && user?.email != null && user!.email!.isNotEmpty) {
      final prefix = user.email!.split('@').first;
      name = prefix.isNotEmpty
          ? '${prefix[0].toUpperCase()}${prefix.substring(1)}'
          : 'Pengguna';
    }
    if (name.isEmpty) {
      name = 'Nadea';
    }

    final email = user?.email ?? '';
    final phone = user?.phoneNumber ?? '';

    final newProfile = UserProfileData(
      nama: name.isNotEmpty && name != 'Pengguna'
          ? (name == 'Nadea' ? 'Nadea Fieldzah Putri' : name)
          : 'Nadea Fieldzah Putri',
      email: email.isNotEmpty ? email : 'nadea123@gmail.com',
      telepon: phone.isNotEmpty ? phone : '+62 123 456 799',
      jenisKelamin: 'Perempuan',
      ttl: 'Jakarta, 29 Februari 2004',
      alamat: 'Jl. Merdeka No. 45, Jakarta Selatan',
      golonganDarah: 'O',
      tinggiBadan: '167 cm',
      beratBadan: '51 kg',
      alergi: 'Tidak Ada',
      penyakitDiderita: 'Tidak Ada',
      riwayatOperasi: 'Tidak Ada',
      fotoProfil: '',
    );

    _cache[key] = newProfile;
    _loadFromPrefs(key);
    return newProfile;
  }

  void _subscribeToFirestore(String uid) {
    if (_subscribedUid == uid && _firestoreSubscription != null) return;

    _unsubscribeFromFirestore();
    _subscribedUid = uid;

    try {
      _firestoreSubscription = _firestore
          .collection('users')
          .doc(uid)
          .snapshots()
          .listen(
        (snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            final data = snapshot.data()!;
            final loaded = UserProfileData.fromJson(data);

            // Fallback nama & email jika belum tersimpan di Firestore
            final currentUser = _auth.currentUser;
            if (loaded.nama.trim().isEmpty &&
                (currentUser?.displayName ?? '').isNotEmpty) {
              loaded.nama = currentUser!.displayName!.trim();
            }
            if (loaded.email.trim().isEmpty &&
                (currentUser?.email ?? '').isNotEmpty) {
              loaded.email = currentUser!.email!;
            }

            _cache[uid] = loaded;
            _saveToPrefs(uid, loaded);

            // Sinkronkan foto profil dengan ProfileService jika tersedia
            if (loaded.fotoProfil.isNotEmpty) {
              ProfileService.instance.syncFromProfile(loaded.fotoProfil);
            }

            notifyListeners();
          } else {
            // Jika dokumen belum ada di Firestore, buat dokumen awal
            final current = currentProfile;
            _saveToFirestore(uid, current);
          }
        },
        onError: (error) {
          debugPrint('[UserProfileService] Firestore stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('[UserProfileService] Failed to listen to Firestore: $e');
    }
  }

  void _unsubscribeFromFirestore() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    _subscribedUid = null;
  }

  Future<void> _loadFromPrefs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('user_profile_$key');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        final loaded = UserProfileData.fromJson(data);
        final user = _auth.currentUser;
        if (loaded.nama.trim().isEmpty && (user?.displayName ?? '').isNotEmpty) {
          loaded.nama = user!.displayName!.trim();
        }
        if (loaded.email.trim().isEmpty && (user?.email ?? '').isNotEmpty) {
          loaded.email = user!.email!;
        }
        _cache[key] = loaded;

        // Sinkronkan foto profil jika tersimpan di prefs
        if (loaded.fotoProfil.isNotEmpty) {
          ProfileService.instance.syncFromProfile(loaded.fotoProfil);
        }

        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveToPrefs(String key, UserProfileData profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_$key', jsonEncode(profile.toJson()));
    } catch (_) {}
  }

  Future<void> _saveToFirestore(String uid, UserProfileData profile) async {
    try {
      await _firestore.collection('users').doc(uid).set(
        {
          ...profile.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('[UserProfileService] Gagal menyimpan ke Firestore: $e');
    }
  }

  Future<void> saveProfile(UserProfileData profile) async {
    final key = _getUserKey();
    _cache[key] = profile;

    final user = _auth.currentUser;
    if (user != null &&
        profile.nama.trim().isNotEmpty &&
        user.displayName != profile.nama.trim()) {
      try {
        await user.updateDisplayName(profile.nama.trim());
      } catch (_) {}
    }

    notifyListeners();

    await _saveToPrefs(key, profile);

    if (user != null && user.uid.isNotEmpty) {
      await _saveToFirestore(user.uid, profile);
    }
  }

  Future<void> updateFotoProfil(String fotoProfil) async {
    final profile = currentProfile;
    profile.fotoProfil = fotoProfil;
    await saveProfile(profile);
  }

  Future<void> updateDataPribadi({
    required String nama,
    required String jenisKelamin,
    required String ttl,
    required String alamat,
    required String telepon,
    required String email,
  }) async {
    final profile = currentProfile;
    profile.nama = nama.trim();
    profile.jenisKelamin = jenisKelamin.trim();
    profile.ttl = ttl.trim();
    profile.alamat = alamat.trim();
    profile.telepon = telepon.trim();
    profile.email = email.trim();
    await saveProfile(profile);
  }

  Future<void> updateDataKesehatan({
    required String golonganDarah,
    required String tinggiBadan,
    required String beratBadan,
    required String alergi,
    required String penyakitDiderita,
    required String riwayatOperasi,
  }) async {
    final profile = currentProfile;
    profile.golonganDarah = golonganDarah.trim();
    profile.tinggiBadan = tinggiBadan.trim();
    profile.beratBadan = beratBadan.trim();
    profile.alergi = alergi.trim();
    profile.penyakitDiderita = penyakitDiderita.trim();
    profile.riwayatOperasi = riwayatOperasi.trim();
    await saveProfile(profile);
  }
}
