import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'system_notification_service.dart';
import 'booking_service.dart';
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

/// Layanan terpusat untuk mengelola notifikasi reminder bergaya Gojek SECARA 100% OTOMATIS
/// tanpa mengharuskan pengguna mengatur notifikasi sendiri.
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

  // Set pencatat trigger notifikasi agar tidak duplikat di menit yang sama
  final Set<String> _triggeredKeys = {};

  Timer? _autoEngineTimer;
  bool _isInitialized = false;

  /// Inisialisasi service reminder dan mulai mesin otomatisasi latar belakang
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

      // 1. Hubungkan pemantau pengingat obat dari HealthReminderController
      _listenToHealthReminderController();

      // 2. Mulai mesin pengingat otomatis berkala (konsultasi & obat)
      final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
      if (!isTest) {
        _startAutomaticReminderEngine();
        // Beri sapaan reminder otomatis saat aplikasi baru dibuka jika ada jadwal
        _checkAndTriggerInitialUpcomingReminder();
      }

      _isInitialized = true;
      debugPrint('[ReminderNotificationService] Berhasil diinisialisasi otomatis');
    } catch (e) {
      debugPrint('[ReminderNotificationService] Gagal inisialisasi: $e');
    }
  }

  /// Mesin otomatisasi berkala (Auto Reminder Engine) yang memantau jadwal konsultasi & obat
  /// secara otomatis tanpa perlu pengguna melakukan pengaturan manual.
  void _startAutomaticReminderEngine() {
    _autoEngineTimer?.cancel();
    _autoEngineTimer = Timer.periodic(const Duration(seconds: 25), (timer) {
      _checkAutomaticReminders();
    });
  }

  void _checkAutomaticReminders() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final String currentMinuteKey = '${now.day}_${now.hour}_${now.minute}';

    // A. CEK JADWAL KONSULTASI DOKTER OTOMATIS
    final bookings = BookingService.instance.bookings;
    for (final booking in bookings) {
      if (booking.status != 'booked') continue;

      final int startMin = booking.startMinutes;
      final int diff = startMin - currentMinutes;

      // 1. Notifikasi otomatis 15 Menit sebelum konsultasi dimulai
      if (diff > 0 && diff <= 15) {
        final key15 = 'cons_${booking.id}_15m_${now.day}';
        if (!_triggeredKeys.contains(key15)) {
          _triggeredKeys.add(key15);
          triggerReminder(
            HeartCareReminder(
              id: key15,
              type: ReminderType.consultation,
              title: 'Jadwal Konsultasi Segera Dimulai',
              body: 'Sesi konsultasi Anda dengan ${booking.doctorName} dimulai dalam $diff menit (${booking.timeSlot}). Masuk sekarang agar siap berkonsultasi.',
              time: booking.timeSlot,
              doctorName: booking.doctorName,
              doctorSpecialty: booking.doctorSpecialty,
              doctorPhoto: booking.doctorPhoto,
              doctorId: booking.doctorId,
              actionLabel: 'Masuk Chat',
            ),
          );
        }
      }

      // 2. Notifikasi otomatis tepat saat sesi konsultasi dibuka
      if (diff <= 0 && diff >= -booking.durationMinutes) {
        final keyNow = 'cons_${booking.id}_now_${now.day}';
        if (!_triggeredKeys.contains(keyNow)) {
          _triggeredKeys.add(keyNow);
          triggerReminder(
            HeartCareReminder(
              id: keyNow,
              type: ReminderType.consultation,
              title: 'Sesi Konsultasi Sedang Berlangsung!',
              body: '${booking.doctorName} siap melayani konsultasi Anda sekarang (${booking.timeSlot}). Klik untuk langsung masuk ke ruang chat.',
              time: 'Sekarang',
              doctorName: booking.doctorName,
              doctorSpecialty: booking.doctorSpecialty,
              doctorPhoto: booking.doctorPhoto,
              doctorId: booking.doctorId,
              actionLabel: 'Buka Chat',
            ),
          );
        }
      }
    }

    // B. CEK JADWAL MINUM OBAT OTOMATIS
    final currentFormattedTime =
        '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';
    final currentFormattedColon =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final controller = HealthReminderController();
    for (final med in controller.medicines) {
      if (!med.isAlarmEnabled || med.isTaken) continue;
      for (final timeStr in med.reminderTimes) {
        final cleanTime = timeStr.trim().replaceAll(':', '.');
        if (cleanTime == currentFormattedTime ||
            cleanTime == currentFormattedColon.replaceAll(':', '.')) {
          final medKey = 'med_${med.id}_$currentMinuteKey';
          if (!_triggeredKeys.contains(medKey)) {
            _triggeredKeys.add(medKey);
            triggerMedicineReminder(
              medicineName: med.name,
              dosage: '${med.amount} ${med.unit}',
              scheduleInfo: med.schedule,
              time: timeStr.contains('WIB') ? timeStr : '$timeStr WIB',
              note: med.note,
            );
          }
        }
      }
    }
  }

  /// Cek saat aplikasi baru dibuka untuk menampilkan pengingat aktif hari ini secara otomatis
  void _checkAndTriggerInitialUpcomingReminder() {
    Future.delayed(const Duration(seconds: 3), () {
      final bookings = BookingService.instance.bookings;
      if (bookings.isNotEmpty) {
        final booking = bookings.first;
        final initialKey = 'initial_auto_booking_${booking.id}';
        if (!_triggeredKeys.contains(initialKey)) {
          _triggeredKeys.add(initialKey);
          triggerReminder(
            HeartCareReminder(
              id: initialKey,
              type: ReminderType.consultation,
              title: 'Pengingat Otomatis Konsultasi',
              body: 'Jadwal konsultasi Anda bersama ${booking.doctorName} pukul ${booking.timeSlot} (${booking.dateDisplay}) aktif otomatis.',
              time: booking.timeSlot,
              doctorName: booking.doctorName,
              doctorSpecialty: booking.doctorSpecialty,
              doctorPhoto: booking.doctorPhoto,
              doctorId: booking.doctorId,
              actionLabel: 'Masuk Chat',
            ),
          );
        }
      }
    });
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

  /// Daftarkan pengingat jadwal konsultasi secara otomatis
  Future<void> scheduleConsultationReminder({
    required String doctorName,
    required String doctorSpecialty,
    required String timeSlot,
    required String dateDisplay,
    String? doctorPhoto,
    String? doctorId,
    String? chatId,
    String? timingLabel,
    bool notifyImmediately = true,
  }) async {
    final cleanTiming = timingLabel ?? 'Otomatis Aktif';

    final reminder = HeartCareReminder(
      id: 'rem_cons_${DateTime.now().millisecondsSinceEpoch}',
      type: ReminderType.consultation,
      title: 'Pengingat Konsultasi: $doctorName',
      body: 'Jadwal konsultasi ($cleanTiming) pada $dateDisplay pukul $timeSlot. Notifikasi akan otomatis mengingatkan Anda.',
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

  /// Picu pengingat minum obat secara otomatis
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
          title: 'Pengingat Otomatis Konsultasi',
          body: 'dr. Nurlitta Dwi (Spesialis Jantung) siap berkonsultasi. Sesi Anda dimulai dalam 15 menit (Pukul 09.00 WIB).',
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
          body: 'Amlodipine 5 mg (1 Tablet) - Setelah makan siang untuk menjaga kestabilan tekanan darah Anda.',
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
    _autoEngineTimer?.cancel();
    _reminderStreamController.close();
  }
}
