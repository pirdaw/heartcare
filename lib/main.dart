import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/welcome_page.dart';

void main() async {
  // Wajib dipanggil sebelum menggunakan plugin Flutter apa pun
  // (termasuk Firebase) di dalam main().
  WidgetsFlutterBinding.ensureInitialized();

  // Menghubungkan aplikasi ke project Firebase sesuai platform
  // (android/ios/web/dst) menggunakan firebase_options.dart.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HeartCareApp());
}

class HeartCareApp extends StatelessWidget {
  const HeartCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HeartCare',
      home: const WelcomePage(),
    );
  }
}