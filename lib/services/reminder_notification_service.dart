import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'system_notification_service.dart';
import '../pages/pengingat_kesehatan_page.dart';

/// Tipe pengingat notifikasi bergaya Gojek
enum ReminderType {
  consultation, // Pengingat Jadwal Konsultasi Dokter
  medicine,     // Pengingat Minum Obat
  general,      // Pengingat Pola Hidup / Skrining
}

/// Model data pengingat HeartCare
class HeartCareReminder {
  final String id;
  final ReminderType type;
  final String title;
  final String body;
  final String time; // Misal: "10.00 WIB" atau "Dalam 15 menit"
  final String? doctorName;
  final String? doctorSpecialty;
  final String? doctorPhoto;
  final String? doctorId;
  final String? chatId;
  final String? patientName;
  final String? patientId;
  final bool isDoctorView;
  final String? medicineName;
  final String? medicineDosage;
  final String? actionLabel;
  final DateTime timestamp;

  HeartCareReminder({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.doctorName,
    this.doctorSpecialty,
    this.doctorPhoto,
    this.doctorId,
    this.chatId,
    this.patientName,
    this.patientId,
    this.isDoctorView = false,
    this.medicineName,
    this.medicineDosage,
    this.actionLabel,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'body': body,
        'time': time,
        'doctorName': doctorName,
        'doctorSpecialty': doctorSpecialty,
        'doctorPhoto': doctorPhoto,
        'doctorId': doctorId,
        'chatId': chatId,
        'patientName': patientName,
        'patientId': patientId,
        'isDoctorView': isDoctorView,
        'medicineName': medicineName,
        'medicineDosage': medicineDosage,
        'actionLabel': actionLabel,
        'timestamp': timestamp.toIso8601String(),
      };

  factory HeartCareReminder.fromJson(Map<String, dynamic> json) {
    return HeartCareReminder(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: ReminderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReminderType.consultation,
      ),
      title: json['title'] as String? ?? 'Pengingat HeartCare',
      body: json['body'] as String? ?? '',
      time: json['time'] as String? ?? '',
      doctorName: json['doctorName'] as String?,
      doctorSpecialty: json['doctorSpecialty'] as String?,
      doctorPhoto: json['doctorPhoto'] as String?,
      doctorId: json['doctorId'] as String?,
      chatId: json['chatId'] as String?,
      patientName: json['patientName'] as String?,
      patientId: json['patientId'] as String?,
      isDoctorView: json['isDoctorView'] as bool? ?? false,
      medicineName: json['medicineName'] as String?,
      medicineDosage: json['medicineDosage'] as String?,
      actionLabel: json['actionLabel'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Layanan terpusat untuk mengelola notifikasi reminder bergaya Gojek
/// yang muncul di semua halaman aplikasi (In-App floating banner) dan juga status bar HP (System Notification).
class ReminderNotificationService {
  ReminderNotificationService._internal();
  static final ReminderNotificationService instance =
      ReminderNotificationService._internal();
  factory ReminderNotificationService() => instance;

  static const String _prefKeyReminders = 'heartcare_saved_reminders_v1';
  final StreamController<HeartCareReminder> _reminderStreamController =
      StreamController<HeartCareReminder>.broadcast();

  Stream<HeartCareReminder> get onReminder => _reminderStreamController.stream;

  final List<HeartCareReminder> _activeReminders = [];
  List<HeartCareReminder> get activeReminders => List.unmodifiable(_activeReminders);

  HeartCareReminder? _latestReminder;
  HeartCareReminder? get latestReminder => _latestReminder;

  bool _isInitialized = false;

  /// Inisialisasi service reminder
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString(_prefKeyReminders);
      if (savedStr != null && savedStr.isNotEmpty) {
        final List decoded = jsonDecode(savedStr) as List;
        _activeReminders.clear();
        for (var item in decoded) {
          if (item is Map<String, dynamic>) {
            _activeReminders.add(HeartCareReminder.fromJson(item));
          } else if (item is Map) {
            _activeReminders.add(HeartCareReminder.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      // Hubungkan pemantau pengingat obat dari HealthReminderController
      _listenToHealthReminderController();

      _isInitialized = true;
      debugPrint('[ReminderNotificationService] Berhasil diinisialisasi');
    } catch (e) {
      debugPrint('[ReminderNotificationService] Gagal inisialisasi: $e');
    }
  }

  /// Pantau trigger pengingat obat dari controller agar memicu notifikasi bergaya Gojek secara global
  void _listenToHealthReminderController() {
    HealthReminderController controller = HealthReminderController();
    controller.onReminderTriggered = (med, timeStr) {
      triggerMedicineReminder(
        medicineName: med.name,
        dosage: '${med.amount} ${med.unit}',
        scheduleInfo: med.schedule,
        time: timeStr.contains('WIB') ? timeStr : '$timeStr WIB',
        note: med.note,
      );
    };
  }

  /// Picu notifikasi reminder secara langsung (banner melayang di semua halaman + notifikasi status bar)
  Future<void> triggerReminder(HeartCareReminder reminder) async {
    _latestReminder = reminder;
    _activeReminders.insert(0, reminder);
    if (_activeReminders.length > 20) {
      _activeReminders.removeLast();
    }
    _saveReminders();

    // Haptic & suara peringatan ramah ala aplikasi Gojek
    try {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}

    // 1. Pancarkan ke stream agar In-App Banner Gojek muncul di layar mana pun
    _reminderStreamController.add(reminder);

    // 2. Tampilkan di Status Bar / Notification Tray HP (Native Push/Heads-Up)
    try {
      await SystemNotificationService.instance.showReminderNotification(reminder);
    } catch (e) {
      debugPrint('[ReminderNotificationService] Gagal kirim notif sistem: $e');
    }
  }

  /// Jadwalkan / simpan pengingat jadwal konsultasi dokter
  Future<void> scheduleConsultationReminder({
    required String doctorName,
    required String doctorSpecialty,
    required String timeSlot,
    required String dateDisplay,
    String? doctorPhoto,
    String? doctorId,
    String? chatId,
    String? timingLabel, // Misal: "15 menit sebelumnya", "1 jam sebelumnya"
    bool notifyImmediately = true,
  }) async {
    final cleanTiming = timingLabel ?? 'Pengingat Jadwal Aktif';

    final reminder = HeartCareReminder(
      id: 'rem_cons_${DateTime.now().millisecondsSinceEpoch}',
      type: ReminderType.consultation,
      title: 'Pengingat Konsultasi: $doctorName',
      body: 'Jadwal konsultasi ($cleanTiming) akan dimulai pada $dateDisplay pukul $timeSlot. Masuk ruang konsultasi tepat waktu.',
      time: timeSlot.contains('WIB') ? timeSlot : '$timeSlot WIB',
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      doctorPhoto: doctorPhoto ?? 'assets/images/dokter_nurlitta.jpg',
      doctorId: doctorId,
      chatId: chatId,
      actionLabel: 'Buka Chat',
    );

    if (notifyImmediately) {
      await triggerReminder(reminder);
    } else {
      _activeReminders.insert(0, reminder);
      _saveReminders();
    }
  }

  /// Picu pengingat minum obat
  Future<void> triggerMedicineReminder({
    required String medicineName,
    required String dosage,
    required String scheduleInfo,
    required String time,
    String? note,
  }) async {
    final reminder = HeartCareReminder(
      id: 'rem_med_${DateTime.now().millisecondsSinceEpoch}',
      type: ReminderType.medicine,
      title: 'Waktunya Minum Obat!',
      body: '$medicineName ($dosage) - $scheduleInfo${note != null && note.isNotEmpty ? ". Catatan: $note" : ""}',
      time: time,
      medicineName: medicineName,
      medicineDosage: dosage,
      actionLabel: 'Sudah Minum',
    );

    await triggerReminder(reminder);
  }

  /// Tandai obat sudah diminum dari banner
  void markMedicineTaken(String medicineName) {
    try {
      final controller = HealthReminderController();
      final med = controller.medicines.firstWhere(
        (m) => m.name.toLowerCase().contains(medicineName.toLowerCase()),
        orElse: () => controller.medicines.first,
      );
      controller.markAsTaken(med.id);
    } catch (_) {}
  }

  /// Simulasikan contoh notifikasi pengingat ala Gojek untuk pengetesan langsung
  Future<void> simulateGojekReminderDemo({ReminderType type = ReminderType.consultation}) async {
    if (type == ReminderType.consultation) {
      await triggerReminder(
        HeartCareReminder(
          id: 'demo_cons_${DateTime.now().millisecondsSinceEpoch}',
          type: ReminderType.consultation,
          title: 'Jadwal Konsultasi Dokter',
          body: 'dr. Nurlitta Dwi (Spesialis Jantung) siap berkonsultasi. Sesi Anda dimulai dalam 15 menit.',
          time: '09.00 WIB',
          doctorName: 'dr. Nurlitta Dwi',
          doctorSpecialty: 'Spesialis Jantung',
          doctorPhoto: 'assets/images/dokter_nurlitta.jpg',
          actionLabel: 'Masuk Chat',
        ),
      );
    } else {
      await triggerReminder(
        HeartCareReminder(
          id: 'demo_med_${DateTime.now().millisecondsSinceEpoch}',
          type: ReminderType.medicine,
          title: 'Waktunya Minum Obat!',
          body: 'Amlodipine 5 mg (1 Tablet) - Setelah makan siang untuk menjaga tekanan darah stabil.',
          time: '13.00 WIB',
          medicineName: 'Amlodipine 5 mg',
          medicineDosage: '1 Tablet',
          actionLabel: 'Sudah Minum',
        ),
      );
    }
  }

  Future<void> _saveReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _activeReminders.map((r) => r.toJson()).toList();
      await prefs.setString(_prefKeyReminders, jsonEncode(list));
    } catch (_) {}
  }

  void dispose() {
    _reminderStreamController.close();
  }
}
