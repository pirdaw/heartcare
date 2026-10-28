import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'pages/welcome_page.dart';
import 'services/theme_service.dart';
import 'services/chat_notification_service.dart';
import 'widgets/chat_notification_banner.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    } catch (_) {}
  }

  // Inisialisasi service percakapan dan notifikasi chat
  await ChatNotificationService.instance.init();

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
    _notifSub = ChatNotificationService.instance.onNewNotification.listen((notif) {
      if (!mounted) return;
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
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'HeartCare',
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
          home: const WelcomePage(),
        );
      },
    );
  }
}

