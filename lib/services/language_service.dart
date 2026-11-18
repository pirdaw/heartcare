import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  LanguageService._();
  static final LanguageService instance = LanguageService._();

  static const String _prefKey = 'selected_language';
  static const String indonesian = 'Bahasa Indonesia';
  static const String english = 'English (US)';

  static final ValueNotifier<String> languageNotifier =
      ValueNotifier<String>(indonesian);

  static String get currentLanguage => languageNotifier.value;
  static bool get isEnglish => languageNotifier.value == english;

  /// Inisialisasi bahasa tersimpan dari SharedPreferences
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && (saved == indonesian || saved == english)) {
        languageNotifier.value = saved;
      }
    } catch (e) {
      debugPrint('Error loading saved language: $e');
    }
  }

  /// Ubah bahasa dan simpan ke memori lokal
  static Future<void> setLanguage(String lang) async {
    if (lang != indonesian && lang != english) return;
    languageNotifier.value = lang;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, lang);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
  }

  /// Helper untuk mendapatkan string sesuai bahasa aktif
  static String tr(String idText, String enText) {
    return isEnglish ? enText : idText;
  }
}

/// Helper fungsi global untuk kemudahan akses di UI
String tr(String idText, String enText) => LanguageService.tr(idText, enText);
