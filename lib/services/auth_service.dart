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
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (_) {
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
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (name.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(name.trim());
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (_) {
      return 'Terjadi kesalahan tak terduga. Coba lagi.';
    }
  }

  /// Kirim email reset password (berisi link, bukan kode OTP).
  /// Return null jika sukses, atau pesan error jika gagal.
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (_) {
      return 'Terjadi kesalahan tak terduga. Coba lagi.';
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
      default:
        return e.message ?? 'Terjadi kesalahan (${e.code}).';
    }
  }
}
