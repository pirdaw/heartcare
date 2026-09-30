import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service untuk menghubungkan pengingat HeartCare ke aplikasi Jam / Alarm bawaan HP Android
class AlarmService {
  static const MethodChannel _channel = MethodChannel('com.example.heartcare/alarm');

  /// Memeriksa apakah perangkat mendukung alarm bawaan HP (Android)
  static bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// Membuka aplikasi Jam / Alarm di HP
  static Future<bool> openAlarmApp() async {
    if (!isSupported) {
      debugPrint('[AlarmService] openAlarmApp hanya didukung di Android.');
      return false;
    }
    try {
      final res = await _channel.invokeMethod<bool>('openAlarms');
      return res ?? false;
    } catch (e) {
      debugPrint('[AlarmService] Gagal membuka aplikasi alarm: $e');
      return false;
    }
  }

  /// Mengurai format jam string seperti "07.30", "07:30", "7.30", "15:00"
  static Map<String, int>? parseTimeString(String timeStr) {
    try {
      final clean = timeStr.trim().replaceAll(':', '.');
      final parts = clean.split('.');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0].trim());
        final minute = int.parse(parts[1].trim());
        if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
          return {'hour': hour, 'minute': minute};
        }
      }
    } catch (e) {
      debugPrint('[AlarmService] Format waktu salah "$timeStr": $e');
    }
    return null;
  }

  /// Memasang 1 alarm ke aplikasi Jam bawaan HP Android
  /// [hour] : 0-23
  /// [minute] : 0-59
  /// [title] : Pesan / label alarm (misal: "Minum Obat: Paracetamol")
  /// [skipUi] : Jika true, alarm dipasang tanpa membuka tampilan aplikasi jam
  static Future<bool> setAlarm({
    required int hour,
    required int minute,
    required String title,
    bool skipUi = false,
  }) async {
    if (!isSupported) {
      debugPrint('[AlarmService] setAlarm disimulasikan untuk: $hour:$minute "$title"');
      return true;
    }

    try {
      final result = await _channel.invokeMethod<bool>('setAlarm', {
        'hour': hour,
        'minute': minute,
        'title': title,
        'skipUi': skipUi,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('[AlarmService] Gagal memasang alarm: $e');
      return false;
    }
  }

  /// Memasang alarm berdasarkan string waktu (misal "07.30")
  static Future<bool> setAlarmFromTimeString({
    required String timeStr,
    required String title,
    bool skipUi = false,
  }) async {
    final parsed = parseTimeString(timeStr);
    if (parsed == null) return false;
    return await setAlarm(
      hour: parsed['hour']!,
      minute: parsed['minute']!,
      title: title,
      skipUi: skipUi,
    );
  }

  /// Memasang banyak alarm sekaligus (misal untuk jam: ["07.30", "15.30", "22.00"])
  static Future<int> setAlarmsForTimes({
    required List<String> times,
    required String title,
    bool skipUi = true,
  }) async {
    int successCount = 0;
    for (int i = 0; i < times.length; i++) {
      final timeStr = times[i];
      final parsed = parseTimeString(timeStr);
      if (parsed != null) {
        // Berikan jeda kecil antar intent agar sistem Android memproses tiap alarm
        if (i > 0) {
          await Future.delayed(const Duration(milliseconds: 350));
        }
        final ok = await setAlarm(
          hour: parsed['hour']!,
          minute: parsed['minute']!,
          title: title,
          skipUi: skipUi,
        );
        if (ok) successCount++;
      }
    }
    return successCount;
  }

  /// Memasang alarm otomatis untuk satu obat berdasarkan daftar jamnya
  static Future<int> setAlarmsForMedicine({
    required String name,
    required String amount,
    required String unit,
    required List<String> reminderTimes,
    bool skipUi = true,
  }) async {
    final title = 'Minum Obat: $name ($amount $unit)';
    return await setAlarmsForTimes(
      times: reminderTimes,
      title: title,
      skipUi: skipUi,
    );
  }
}

