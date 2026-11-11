import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'pages/welcome_page.dart';
import 'widgets/auth_gate.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'services/chat_service.dart';
import 'services/call_service.dart';
import 'services/webrtc_view_factory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Daftarkan view factory kamera WebRTC (Web)
  registerWebRtcViewFactories();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  // Aktifkan listener notifikasi chat real-time multi-port & multi-device
  ChatService.instance.initGlobalChatNotificationListener();

  // Aktifkan listener panggilan video real-time masuk (WhatsApp Call)
  CallService.instance.initGlobalCallListener();

  runApp(const HeartCareApp());
}

class HeartCareApp extends StatelessWidget {
  const HeartCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          navigatorKey: NotificationService.navigatorKey,
          builder: (context, child) {
            NotificationService.setContext(context);
            return child ?? const SizedBox();
          },
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
          home: const AuthGate(),
        );
      },
    );
  }
}

