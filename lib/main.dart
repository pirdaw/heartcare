import 'package:flutter/material.dart';
import 'pages/pengingat_kesehatan_page.dart';

void main() {
  runApp(const HeartCareApp());
}

class HeartCareApp extends StatelessWidget {
  const HeartCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HeartCare',
      // Mengarahkan langsung ke halaman Pengingat Kesehatan yang baru dibuat
      home: const PengingatKesehatanPage(),
    );
  }
}