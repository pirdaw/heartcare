import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Kategori jadwal pengingat kesehatan
enum HealthReminderCategory {
  water,    // Minum Air Putih
  activity, // Aktivitas Fisik & Peregangan
  habit,    // Kebiasaan Sehat & Kiat Jantung
}

/// Model untuk jadwal pengingat kesehatan bawaan HeartCare
class ScheduledHealthReminder {
  final int id;
  final HealthReminderCategory category;
  final String title;
  final String body;
  final int hour;
  final int minute;
  bool isEnabled;

  ScheduledHealthReminder({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
  });

  String get timeFormatted {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h.$m WIB';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'title': title,
        'body': body,
        'hour': hour,
        'minute': minute,
        'isEnabled': isEnabled,
      };

  factory ScheduledHealthReminder.fromJson(Map<String, dynamic> json) {
    return ScheduledHealthReminder(
      id: json['id'] as int,
      category: HealthReminderCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => HealthReminderCategory.habit,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }
}

/// Service scheduler notifikasi lokal Android otomatis
/// Mengaktifkan reminder bawaan (air putih, aktivitas fisik, kebiasaan sehat)
/// berjalan di latar belakang (background) meskipun aplikasi sedang ditutup.
class HealthReminderSchedulerService extends ChangeNotifier {
  HealthReminderSchedulerService._internal();
  static final HealthReminderSchedulerService instance =
      HealthReminderSchedulerService._internal();
  factory HealthReminderSchedulerService() => instance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _prefKeyMaster = 'heartcare_auto_reminder_master_v1';
  static const String _prefKeyWater = 'heartcare_auto_reminder_water_v1';
  static const String _prefKeyActivity = 'heartcare_auto_reminder_activity_v1';
  static const String _prefKeyHabit = 'heartcare_auto_reminder_habit_v1';
  static const String _prefKeyAutoActivated = 'heartcare_auto_reminder_activated_v1';

  static const String scheduledChannelId = 'heartcare_scheduled_reminders_v1';
  static const String scheduledChannelName = 'Pengingat Kesehatan Rutin';
  static const String scheduledChannelDesc =
      'Jadwal pengingat otomatis minum air, aktivitas fisik, dan kebiasaan sehat jantung';

  bool _isInitialized = false;
  bool _isAutoActivated = false;
  bool _masterEnabled = true;
  bool _waterEnabled = true;
  bool _activityEnabled = true;
  bool _habitEnabled = true;

  bool get masterEnabled => _masterEnabled;
  bool get waterEnabled => _waterEnabled;
  bool get activityEnabled => _activityEnabled;
  bool get habitEnabled => _habitEnabled;
  bool get isAutoActivated => _isAutoActivated;

  // Daftar default reminder kesehatan bawaan
  final List<ScheduledHealthReminder> _defaultReminders = [
    // 1. MINUM AIR PUTIH
    ScheduledHealthReminder(
      id: 101,
      category: HealthReminderCategory.water,
      title: '💧 Waktunya Minum Air Putih',
      body: 'Awali pagi dengan 1-2 gelas air putih untuk melancarkan sirkulasi darah dan kerja jantung.',
      hour: 8,
      minute: 0,
    ),
    ScheduledHealthReminder(
      id: 102,
      category: HealthReminderCategory.water,
      title: '💧 Jaga Hidrasi Siang Hari',
      body: 'Minum segelas air putih setelah beraktivitas agar volume darah optimal dan jantung tidak terbebani.',
      hour: 12,
      minute: 30,
    ),
    ScheduledHealthReminder(
      id: 103,
      category: HealthReminderCategory.water,
      title: '💧 Segarkan Tubuh Sore Ini',
      body: 'Cukupi kebutuhan cairan sore hari untuk menjaga stamina dan tekanan darah tetap stabil.',
      hour: 16,
      minute: 0,
    ),
    ScheduledHealthReminder(
      id: 104,
      category: HealthReminderCategory.water,
      title: '💧 Cukupi Cairan Malam',
      body: 'Minum segelas air putih sebelum beristirahat agar keseimbangan cairan tubuh tetap terjaga.',
      hour: 19,
      minute: 30,
    ),

    // 2. AKTIVITAS FISIK & PEREGANGAN
    ScheduledHealthReminder(
      id: 201,
      category: HealthReminderCategory.activity,
      title: '🏃 Waktunya Aktivitas Fisik Pagi',
      body: 'Luangkan 15–30 menit jalan santai atau peregangan ringan untuk memperkuat otot jantung Anda.',
      hour: 7,
      minute: 0,
    ),
    ScheduledHealthReminder(
      id: 202,
      category: HealthReminderCategory.activity,
      title: '🚶 Peregangan Sore Hari',
      body: 'Hindari duduk terlalu lama. Berdiri dan lakukan jalan santai 10 menit agar peredaran darah lancar.',
      hour: 17,
      minute: 0,
    ),

    // 3. KEBIASAAN SEHAT & KIAT JANTUNG
    ScheduledHealthReminder(
      id: 301,
      category: HealthReminderCategory.habit,
      title: '🧘 Rehat Sejenak & Relaksasi',
      body: 'Tarik napas dalam 5 menit. Menenangkan pikiran membantu menurunkan hormon stres dan menstabilkan detak jantung.',
      hour: 10,
      minute: 30,
    ),
    ScheduledHealthReminder(
      id: 302,
      category: HealthReminderCategory.habit,
      title: '🥗 Kiat Jantung: Batas Natrium',
      body: 'Pilih makan siang bergizi seimbang dan batasi garam (< 5g/hari) demi menjaga elastisitas pembuluh darah.',
      hour: 12,
      minute: 0,
    ),
    ScheduledHealthReminder(
      id: 303,
      category: HealthReminderCategory.habit,
      title: '🌙 Waktunya Istirahat Berkualitas',
      body: 'Beri jeda 2-3 jam setelah makan malam dan matikan layar gadget agar jantung beristirahat maksimal.',
      hour: 21,
      minute: 30,
    ),
  ];

  List<ScheduledHealthReminder> get allReminders =>
      List.unmodifiable(_defaultReminders);

  List<ScheduledHealthReminder> getRemindersByCategory(
      HealthReminderCategory category) {
    return _defaultReminders.where((r) => r.category == category).toList();
  }

  /// Inisialisasi otomatis saat aplikasi dibuka:
  /// 1. Siapkan Timezone
  /// 2. Minta izin notifikasi Android
  /// 3. Langsung aktifkan jadwal reminder bawaan secara otomatis
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Inisialisasi timezone database
      tz.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      } catch (_) {
        tz.setLocalLocation(tz.local);
      }

      // 2. Muat status pengaturan dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _isAutoActivated = prefs.getBool(_prefKeyAutoActivated) ?? false;
      _masterEnabled = prefs.getBool(_prefKeyMaster) ?? true;
      _waterEnabled = prefs.getBool(_prefKeyWater) ?? true;
      _activityEnabled = prefs.getBool(_prefKeyActivity) ?? true;
      _habitEnabled = prefs.getBool(_prefKeyHabit) ?? true;

      // 3. Siapkan Notification Channel Android
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _notificationsPlugin.initialize(
        settings: const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );

      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          scheduledChannelId,
          scheduledChannelName,
          description: scheduledChannelDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );
        await androidPlugin.createNotificationChannel(channel);

        // Minta izin Android 13+ (POST_NOTIFICATIONS) dan izin Exact Alarm
        await androidPlugin.requestNotificationsPermission();
        try {
          await androidPlugin.requestExactAlarmsPermission();
        } catch (_) {}
      }

      // 4. OTOMATIS AKTIFKAN JADWAL BAWAAN TANPA USER PERLU MENYETEL
      // Jika baru pertama kali atau auto-activated belum tercatat, aktifkan secara otomatis
      if (!_isAutoActivated || _masterEnabled) {
        _isAutoActivated = true;
        _masterEnabled = true;
        await prefs.setBool(_prefKeyAutoActivated, true);
        await prefs.setBool(_prefKeyMaster, true);
        await scheduleAllActiveReminders();
      }

      _isInitialized = true;
      notifyListeners();
      debugPrint('[HealthReminderSchedulerService] Berhasil diaktifkan otomatis');
    } catch (e) {
      debugPrint('[HealthReminderSchedulerService] Gagal inisialisasi: $e');
    }
  }

  /// Jadwalkan ulang seluruh reminder aktif ke sistem Android menggunakan AlarmManager / zonedSchedule
  Future<void> scheduleAllActiveReminders() async {
    // Batalkan jadwal lama terlebih dahulu untuk mencegah duplikasi
    await cancelAllScheduledReminders();

    if (!_masterEnabled) {
      debugPrint('[HealthReminderSchedulerService] Master reminder nonaktif.');
      return;
    }

    int scheduledCount = 0;
    for (final reminder in _defaultReminders) {
      bool isCategoryActive = false;
      switch (reminder.category) {
        case HealthReminderCategory.water:
          isCategoryActive = _waterEnabled;
          break;
        case HealthReminderCategory.activity:
          isCategoryActive = _activityEnabled;
          break;
        case HealthReminderCategory.habit:
          isCategoryActive = _habitEnabled;
          break;
      }

      if (!isCategoryActive || !reminder.isEnabled) continue;

      try {
        await _scheduleSingleReminder(reminder);
        scheduledCount++;
      } catch (e) {
        debugPrint('[HealthReminderSchedulerService] Error scheduling ${reminder.id}: $e');
      }
    }

    debugPrint('[HealthReminderSchedulerService] $scheduledCount jadwal reminder otomatis terpasang di Android.');
  }

  /// Jadwalkan 1 reminder harian berulang menggunakan zonedSchedule
  Future<void> _scheduleSingleReminder(ScheduledHealthReminder reminder) async {
    final tz.TZDateTime scheduledDate =
        _nextInstanceOfTime(reminder.hour, reminder.minute);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      scheduledChannelId,
      scheduledChannelName,
      channelDescription: scheduledChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.zonedSchedule(
      id: reminder.id,
      title: reminder.title,
      body: reminder.body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // BERULANG SETIAP HARI PADA JAM INI!
    );
  }

  /// Menghitung instance waktu berikutnya (hari ini jika belum lewat, atau besok)
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Batalkan seluruh jadwal reminder lokal
  Future<void> cancelAllScheduledReminders() async {
    for (final reminder in _defaultReminders) {
      try {
        await _notificationsPlugin.cancel(id: reminder.id);
      } catch (_) {}
    }
  }

  /// Pengaturan: Mengaktifkan atau menonaktifkan master toggle
  Future<void> setMasterEnabled(bool value) async {
    _masterEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyMaster, value);
    notifyListeners();
    await scheduleAllActiveReminders();
  }

  /// Pengaturan: Mengaktifkan atau menonaktifkan kategori Minum Air Putih
  Future<void> setWaterEnabled(bool value) async {
    _waterEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyWater, value);
    notifyListeners();
    await scheduleAllActiveReminders();
  }

  /// Pengaturan: Mengaktifkan atau menonaktifkan kategori Aktivitas Fisik
  Future<void> setActivityEnabled(bool value) async {
    _activityEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyActivity, value);
    notifyListeners();
    await scheduleAllActiveReminders();
  }

  /// Pengaturan: Mengaktifkan atau menonaktifkan kategori Kebiasaan Sehat
  Future<void> setHabitEnabled(bool value) async {
    _habitEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyHabit, value);
    notifyListeners();
    await scheduleAllActiveReminders();
  }

  /// Pengaturan: Toggle per item reminder
  Future<void> toggleIndividualReminder(int id, bool value) async {
    final index = _defaultReminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _defaultReminders[index].isEnabled = value;
      notifyListeners();
      await scheduleAllActiveReminders();
    }
  }

  /// Uji coba notifikasi langsung (Instant Preview) untuk melihat tampilan notifikasi
  Future<void> triggerTestNotification(ScheduledHealthReminder reminder) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      scheduledChannelId,
      scheduledChannelName,
      channelDescription: scheduledChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      id: reminder.id + 9000,
      title: reminder.title,
      body: reminder.body,
      notificationDetails: details,
      payload: jsonEncode({'test': true, 'id': reminder.id}),
    );
  }
}
