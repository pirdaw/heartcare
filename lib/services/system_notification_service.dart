import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import '../pages/konsultasi_dokter_page.dart';
import 'chat_notification_service.dart';

/// Layanan untuk menampilkan notifikasi sistem telepon asli (native push/local heads-up notification)
/// di luar aplikasi pada status bar / notification tray Android & iOS saat pesan konsultasi masuk.
class SystemNotificationService {
  SystemNotificationService._internal();
  static final SystemNotificationService instance =
      SystemNotificationService._internal();
  factory SystemNotificationService() => instance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool disableForTesting = false;

  static const String channelId = 'heartcare_chat_notifications_v1';
  static const String channelName = 'Pesan Konsultasi HeartCare';
  static const String channelDescription =
      'Notifikasi pesan konsultasi antara dokter dan pasien HeartCare';

  /// Inisialisasi plugin notifikasi sistem telepon
  Future<void> init() async {
    if (_isInitialized || disableForTesting) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Buat Android Notification Channel dengan prioritas Max (heads-up pop-up banner)
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );
        await androidPlugin.createNotificationChannel(channel);

        // Minta izin notifikasi (Android 13+ / API 33+)
        await androidPlugin.requestNotificationsPermission();
      }

      _isInitialized = true;
      debugPrint('[SystemNotificationService] Berhasil diinisialisasi');
    } catch (e) {
      if (e is Error && e.toString().contains('LateInitializationError')) {
        disableForTesting = true;
      }
      debugPrint('[SystemNotificationService] Gagal inisialisasi: $e');
    }
  }

  /// Menangani aksi saat notifikasi di status bar / sistem telepon diketuk pengguna
  void _onNotificationTapped(NotificationResponse response) {
    final payloadStr = response.payload;
    if (payloadStr == null || payloadStr.isEmpty) return;

    try {
      final Map<String, dynamic> data = jsonDecode(payloadStr);
      final doctorName = data['doctorName'] as String? ?? 'dr. Asya Catherine';
      final patientName = data['patientName'] as String? ?? 'Pasien';
      final patientId = data['patientId'] as String?;
      final doctorId = data['doctorId'] as String?;
      final chatId = data['chatId'] as String?;
      final isDoctorView = data['isDoctorView'] as bool? ?? false;

      final navContext = rootNavigatorKey.currentContext;
      if (navContext != null) {
        Navigator.of(navContext).push(
          MaterialPageRoute(
            builder: (context) => KonsultasiDokterPage(
              doctorName: doctorName,
              patientName: patientName,
              patientId: patientId,
              doctorId: doctorId,
              chatId: chatId,
              isDoctorView: isDoctorView,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('[SystemNotificationService] Error parsing payload: $e');
    }
  }

  /// Menampilkan pop-up notifikasi native di sistem telepon (luar aplikasi / status bar)
  Future<void> showNotification(ChatNotificationItem notif) async {
    if (disableForTesting) return;

    try {
      if (!_isInitialized) {
        await init();
        if (disableForTesting) return;
      }

      // ID unik integer untuk notifikasi sistem
      final int notifId = (notif.id.hashCode & 0x7FFFFFFF);

      final isDoctorRecipient = notif.recipientRole == ChatSenderRole.doctor;
      final subText = isDoctorRecipient
          ? 'Konsultasi Pasien (${notif.patientName})'
          : 'Konsultasi Dokter (${notif.conversationDoctorName})';

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.message,
        subText: subText,
        styleInformation: BigTextStyleInformation(
          notif.messageSnippet,
          contentTitle: notif.notificationTitle,
          summaryText: subText,
        ),
        ticker: notif.formattedNotificationText,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final payload = jsonEncode({
        'chatId': notif.chatId,
        'doctorName': notif.conversationDoctorName,
        'patientName': notif.patientName,
        'patientId': notif.patientId,
        'doctorId': notif.doctorId,
        'isDoctorView': isDoctorRecipient,
      });

      await _notificationsPlugin.show(
        id: notifId,
        title: notif.notificationTitle,
        body: notif.messageSnippet,
        notificationDetails: details,
        payload: payload,
      );
      debugPrint(
          '[SystemNotificationService] Notifikasi sistem telepon dikirim: ${notif.notificationTitle}');
    } catch (e) {
      debugPrint(
          '[SystemNotificationService] Gagal menampilkan notifikasi sistem: $e');
    }
  }

  /// Membatalkan seluruh notifikasi sistem yang sedang menggantung di tray
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }
}
