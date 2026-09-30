import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/welcome_page.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

<<<<<<< HEAD
void main() async {
  // Wajib dipanggil sebelum menggunakan plugin Flutter apa pun
  // (termasuk Firebase) di dalam main().
  WidgetsFlutterBinding.ensureInitialized();

  // Menghubungkan aplikasi ke project Firebase sesuai platform
  // (android/ios/web/dst) menggunakan firebase_options.dart.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

=======
>>>>>>> a00283c708b1bbb7d146aabf5e55656be1c38c85
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
          debugShowCheckedModeBanner: false,
          title: 'HeartCare',
          themeMode: themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0098B9),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0098B9),
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

