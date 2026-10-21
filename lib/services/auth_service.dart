import 'package:firebase_auth/firebase_auth.dart';

/// Wrapper sederhana di atas FirebaseAuth.
///
/// Setiap method mengembalikan `null` jika berhasil, atau pesan error
/// (dalam Bahasa Indonesia) jika gagal — supaya halaman UI cukup
/// menampilkan pesannya lewat SnackBar tanpa perlu tahu detail
/// FirebaseAuthException.
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

  /// Daftar akun baru dengan nama, email & password.
  /// Return null jika sukses, atau pesan error jika gagal.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    if (trimmedName.isEmpty || trimmedEmail.isEmpty || password.isEmpty) {
      return 'Mohon lengkapi semua data.';
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      if (trimmedName.isNotEmpty) {
        await credential.user?.updateDisplayName(trimmedName);
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

  /// Kirim email reset password (berisi link, bukan kode OTP).
  /// Return null jika sukses, atau pesan error jika gagal.
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
  /// Return null jika sukses, atau pesan error jika gagal.
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
