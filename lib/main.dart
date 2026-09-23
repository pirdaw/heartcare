import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';

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
      home: const WelcomePage(),
    );
  }
}