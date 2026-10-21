import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Wrapper di atas FirebaseAuth dengan penanganan peran Pasien dan Dokter.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// User yang sedang login, null jika belum login.
  User? get currentUser => _auth.currentUser;

  /// Stream status login — dipakai AuthGate untuk pindah halaman otomatis.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login dengan email & password.
  /// Return null jika sukses, atau pesan error jika gagal.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty && password.isEmpty) {
      return 'Harap masukkan email dan kata sandi.';
    }
    if (trimmedEmail.isEmpty) {
      return 'Harap masukkan email atau no. HP.';
    }
    if (password.isEmpty) {
      return 'Harap masukkan kata sandi.';
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (e) {
      final str = e.toString();
      if (str.contains('pigeon') || str.contains('FirebaseAuthHostApi')) {
        return 'Harap masukkan email dan kata sandi yang valid.';
      }
      return 'Terjadi kesalahan tak terduga. Coba lagi.';
    }
  }

  /// Login khusus dokter
  Future<String?> signInDoctor({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty && password.isEmpty) {
      return 'Harap masukkan email dan kata sandi dokter.';
    }
    if (trimmedEmail.isEmpty) {
      return 'Harap masukkan email dokter.';
    }
    if (password.isEmpty) {
      return 'Harap masukkan kata sandi.';
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );

      final user = _auth.currentUser;
      if (user != null) {
        final role = await getUserRole();
        if (role != 'doctor') {
          debugPrint('[AuthService] User login sebagai akun dengan role: $role');
        }
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (e) {
      return 'Gagal masuk akun dokter: $e';
    }
  }

  /// Mendapatkan role pengguna saat ini ('doctor' atau 'patient')
  Future<String> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return 'patient';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final role = doc.data()?['role'] as String?;
        if (role != null && role.isNotEmpty) {
          final r = role.toLowerCase();
          if (r == 'doctor' || r == 'dokter') return 'doctor';
        }
      }
    } catch (_) {}

    return 'patient';
  }

  /// Mendapatkan profil dokter yang sedang login
  Future<Map<String, dynamic>?> getCurrentDoctorProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        return {
          'uid': user.uid,
          'nama': data['nama'] ?? user.displayName ?? 'dr. Dokter HeartCare',
          'spesialis':
              data['spesialis'] ?? 'Spesialis Jantung & Pembuluh Darah',
          'foto': data['foto'] ?? 'assets/images/dokter_nurlitta.jpg',
          'sip': data['sip'] ?? 'SIP/2026',
          'lokasi': data['lokasi'] ?? 'Klinik Jantung HeartCare',
          'email': user.email ?? data['email'] ?? '',
          'isOnline': data['isOnline'] ?? true,
        };
      }
    } catch (_) {}

    return {
      'uid': user.uid,
      'nama': user.displayName ?? 'dr. Dokter HeartCare',
      'spesialis': 'Spesialis Jantung & Pembuluh Darah',
      'foto': 'assets/images/dokter_nurlitta.jpg',
      'sip': 'SIP/2026',
      'lokasi': 'Klinik Jantung HeartCare',
      'email': user.email ?? '',
      'isOnline': true,
    };
  }

  /// Ubah status online dokter
  Future<void> updateDoctorOnlineStatus(bool isOnline) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'isOnline': isOnline}, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Daftar akun khusus dokter dan simpan profil ke Firestore
  Future<String?> signUpDoctor({
    required String name,
    required String email,
    required String password,
    String telepon = '',
    String spesialis = 'Spesialis Jantung & Pembuluh Darah',
    String sip = '',
    String lokasi = '',
    String tentang = '',
    String foto = 'assets/images/dokter_nurlitta.jpg',
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedTelepon = telepon.trim();
    final trimmedSpesialis = spesialis.trim().isEmpty
        ? 'Spesialis Jantung & Pembuluh Darah'
        : spesialis.trim();
    final trimmedSip = sip.trim();
    final trimmedLokasi =
        lokasi.trim().isEmpty ? 'Klinik Jantung HeartCare' : lokasi.trim();

    if (trimmedName.isEmpty || trimmedEmail.isEmpty || password.isEmpty) {
      return 'Mohon lengkapi Nama Dokter, Email, dan Kata Sandi.';
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(trimmedName);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'nama': trimmedName,
          'email': trimmedEmail,
          'telepon': trimmedTelepon,
          'role': 'doctor',
          'spesialis': trimmedSpesialis,
          'sip': trimmedSip.isNotEmpty
              ? trimmedSip
              : 'SIP-${DateTime.now().millisecondsSinceEpoch % 10000}/2026',
          'lokasi': trimmedLokasi,
          'pengalaman': '10 tahun',
          'tentang': tentang.trim().isNotEmpty
              ? tentang.trim()
              : 'Berpengalaman dalam penanganan masalah jantung dan kardiovaskular secara profesional dan komprehensif.',
          'foto': foto,
          'isOnline': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint(
            '[AuthService] Berhasil mendaftarkan akun dokter di Firestore users/${user.uid}');
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (e) {
      return 'Gagal mendaftar akun dokter: $e';
    }
  }

  /// Daftar akun baru dengan nama, email, password, no. telepon, & tanggal lahir.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    String telepon = '',
    String tanggalLahir = '',
    String role = 'patient',
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedTelepon = telepon.trim();
    final trimmedTanggalLahir = tanggalLahir.trim();

    if (trimmedName.isEmpty || trimmedEmail.isEmpty || password.isEmpty) {
      return 'Mohon lengkapi semua data wajib.';
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      if (trimmedName.isNotEmpty) {
        await credential.user?.updateDisplayName(trimmedName);
      }
      final user = credential.user;
      if (user != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'nama': trimmedName,
            'email': trimmedEmail,
            'telepon': trimmedTelepon,
            'ttl': trimmedTanggalLahir,
            'tanggalLahir': trimmedTanggalLahir,
            'role': role,
            'jenisKelamin': '',
            'alamat': '',
            'golonganDarah': '',
            'tinggiBadan': '',
            'beratBadan': '',
            'alergi': '',
            'penyakitDiderita': '',
            'riwayatOperasi': '',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          debugPrint(
              '[AuthService] Berhasil menyimpan user ke Firestore users/${user.uid}');
        } catch (e) {
          debugPrint('[AuthService] Gagal menyimpan user ke Firestore: $e');
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (e) {
      final str = e.toString();
      if (str.contains('pigeon') || str.contains('FirebaseAuthHostApi')) {
        return 'Mohon periksa kembali data yang dimasukkan.';
      }
      return 'Terjadi kesalahan tak terduga. Coba lagi.';
    }
  }

  /// Kirim email reset password.
  Future<String?> sendPasswordResetEmail(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return 'Masukkan alamat email terlebih dahulu.';
    }

    try {
      await _auth.sendPasswordResetEmail(email: trimmedEmail);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (e) {
      final str = e.toString();
      if (str.contains('pigeon') || str.contains('FirebaseAuthHostApi')) {
        return 'Format email tidak valid.';
      }
      return 'Terjadi kesalahan tak terduga. Coba lagi.';
    }
  }

  /// Ubah kata sandi user yang sedang login.
  Future<String?> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Demi keamanan, silakan keluar dan masuk kembali sebelum mengubah kata sandi.';
      }
      return _mapError(e);
    } catch (_) {
      return 'Gagal memperbarui kata sandi. Coba lagi.';
    }
  }

  /// Keluar dari akun (logout).
  Future<void> signOut() => _auth.signOut();

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'user-not-found':
        return 'Akun dengan email ini tidak ditemukan.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau kata sandi salah.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan masuk.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah (minimal 6 karakter).';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat lagi.';
      case 'network-request-failed':
        return 'Gagal terhubung. Periksa koneksi internet kamu.';
      case 'channel-error':
        return 'Harap masukkan email dan kata sandi dengan benar.';
      default:
        final msg = e.message;
        if (msg != null &&
            (msg.contains('pigeon') ||
                msg.contains('FirebaseAuthHostApi') ||
                msg.contains('firebase_auth_platform_interface'))) {
          return 'Harap masukkan email dan kata sandi yang valid.';
        }
        return msg ?? 'Terjadi kesalahan (${e.code}).';
    }
  }
}
