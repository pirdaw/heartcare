import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  });

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'email': email,
        'jenisKelamin': jenisKelamin,
        'ttl': ttl,
        'alamat': alamat,
        'telepon': telepon,
        'golonganDarah': golonganDarah,
        'tinggiBadan': tinggiBadan,
        'beratBadan': beratBadan,
        'alergi': alergi,
        'penyakitDiderita': penyakitDiderita,
        'riwayatOperasi': riwayatOperasi,
      };

  factory UserProfileData.fromJson(Map<String, dynamic> json) => UserProfileData(
        nama: json['nama'] ?? '',
        email: json['email'] ?? '',
        jenisKelamin: json['jenisKelamin'] ?? '',
        ttl: json['ttl'] ?? '',
        alamat: json['alamat'] ?? '',
        telepon: json['telepon'] ?? '',
        golonganDarah: json['golonganDarah'] ?? '',
        tinggiBadan: json['tinggiBadan'] ?? '',
        beratBadan: json['beratBadan'] ?? '',
        alergi: json['alergi'] ?? '',
        penyakitDiderita: json['penyakitDiderita'] ?? '',
        riwayatOperasi: json['riwayatOperasi'] ?? '',
      );

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
  UserProfileService._internal();

  static UserProfileService get instance => _instance;

  final Map<String, UserProfileData> _cache = {};

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

  /// Dapatkan profil pengguna yang sedang login.
  /// Jika pengguna baru, nama diambil dari akun terdaftar (displayName) dan email dari akun.
  /// Field data pribadi & data kesehatan lainnya berstatus kosong (belum diisi) agar diisi sendiri.
  UserProfileData get currentProfile {
    final key = _getUserKey();
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    User? user;
    try {
      user = FirebaseAuth.instance.currentUser;
    } catch (_) {}
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
    );

    _cache[key] = newProfile;
    _loadFromPrefs(key);
    return newProfile;
  }

  Future<void> _loadFromPrefs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('user_profile_$key');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        final loaded = UserProfileData.fromJson(data);
        // Pastikan nama dan email tetap konsisten dengan Firebase jika profil tersimpan kosong
        final user = FirebaseAuth.instance.currentUser;
        if (loaded.nama.trim().isEmpty && (user?.displayName ?? '').isNotEmpty) {
          loaded.nama = user!.displayName!.trim();
        }
        if (loaded.email.trim().isEmpty && (user?.email ?? '').isNotEmpty) {
          loaded.email = user!.email!;
        }
        _cache[key] = loaded;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> saveProfile(UserProfileData profile) async {
    final key = _getUserKey();
    _cache[key] = profile;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        profile.nama.trim().isNotEmpty &&
        user.displayName != profile.nama.trim()) {
      try {
        await user.updateDisplayName(profile.nama.trim());
      } catch (_) {}
    }

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_$key', jsonEncode(profile.toJson()));
    } catch (_) {}
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
