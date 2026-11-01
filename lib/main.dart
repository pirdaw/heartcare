import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'pages/welcome_page.dart';
import 'services/theme_service.dart';
import 'services/language_service.dart';
import 'services/doctor_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LanguageService.init();

  if (!kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  // Bersihkan akun dokter lama / duplikat secara otomatis
  DoctorService.instance.cleanupDummyDoctors();

  runApp(const HeartCareApp());
}

class HeartCareApp extends StatelessWidget {
  const HeartCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: LanguageService.languageNotifier,
          builder: (context, lang, _) {
            return MaterialApp(
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
              home: const WelcomePage(),
            );
          },
        );
      },
    );
  }
}

