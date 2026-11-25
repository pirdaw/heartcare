/// Konfigurasi Agora RTC Engine untuk Telekonsultasi Video Call Real-time
class AgoraConfig {
  AgoraConfig._();

  /// App ID Agora Console resmi dari akun pengguna
  static const String appId = 'c491ba3311ed431a845b4970e17d51a3';

  /// Token keamanan: kosongkan jika proyek Agora menggunakan mode "App ID only" (Testing mode)
  /// Jika Primary Certificate aktif, masukkan token sementara atau token server di sini.
  static const String token = '';

  /// Helper untuk memastikan nama channel valid sesuai aturan Agora
  /// (Hanya karakter alfanumerik dan simbol dasar, maks 64 karakter)
  static String formatChannelName(String rawId) {
    final sanitized = rawId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    if (sanitized.length > 64) {
      return sanitized.substring(0, 64);
    }
    return sanitized.isEmpty ? 'heartcare_default_channel' : sanitized;
  }
}

