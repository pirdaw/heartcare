import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';
import 'widgets/auth_gate.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'services/chat_service.dart';
import 'services/call_service.dart';
import 'services/webrtc_view_factory.dart';
import 'services/language_service.dart';
import 'services/doctor_service.dart';
import 'services/chat_notification_service.dart';
import 'widgets/chat_notification_banner.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    NotificationService.navigatorKey;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Daftarkan view factory kamera WebRTC (Web)
  registerWebRtcViewFactories();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await LanguageService.init();

  if (!kIsWeb) {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    } catch (_) {}
  }

  // Bersihkan akun dokter lama / duplikat secara otomatis
  DoctorService.instance.cleanupDummyDoctors();

  // Inisialisasi service percakapan dan notifikasi chat
  await ChatNotificationService.instance.init();

  // Aktifkan listener notifikasi chat real-time multi-port & multi-device
  ChatService.instance.initGlobalChatNotificationListener();

  // Aktifkan listener panggilan video real-time masuk (WhatsApp Call)
  CallService.instance.initGlobalCallListener();

  // Minta izin notifikasi sistem pada Android (Android 13/14+)
  if (!kIsWeb) {
    try {
      await Permission.notification.request();
    } catch (_) {}
  }

  runApp(const HeartCareApp());
}

class HeartCareApp extends StatefulWidget {
  const HeartCareApp({super.key});

  @override
  State<HeartCareApp> createState() => _HeartCareAppState();
}

class _HeartCareAppState extends State<HeartCareApp> {
  StreamSubscription<ChatNotificationItem>? _notifSub;

  @override
  void initState() {
    super.initState();
    // Dengarkan event notifikasi chat baru secara global untuk menampilkan banner in-app
    _notifSub = ChatNotificationService.instance.onNewNotification.listen((
      notif,
    ) {
      if (!mounted) return;
      if (!ChatNotificationService.instance.isNotificationForCurrentAccount(
        notif,
      )) {
        return;
      }
      ChatNotificationBannerManager.showWithNavigatorKey(
        navigatorKey: rootNavigatorKey,
        notification: notif,
      );
    });
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: LanguageService.languageNotifier,
          builder: (context, lang, _) {
            return MaterialApp(
              navigatorKey: rootNavigatorKey,
              builder: (context, child) {
                NotificationService.setContext(context);
                return child ?? const SizedBox();
              },
              debugShowCheckedModeBanner: false,
              title: 'HeartCare',
              locale: LanguageService.isEnglish
                  ? const Locale('en', 'US')
                  : const Locale('id', 'ID'),
              themeMode: themeMode,
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: const Color(0xFFF8FAFC),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF0284C7),
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF0F172A),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF0284C7),
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              home: const AuthGate(),
            );
          },
        );
      },
    );
  }
}
