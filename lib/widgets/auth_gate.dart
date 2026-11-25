import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/call_service.dart';
import '../pages/welcome_page.dart';
import '../pages/home_page.dart';
import '../pages/doctor_dashboard_page.dart';

/// Gerbang autentikasi otomatis yang menjaga sesi login pengguna
/// Jika sudah pernah login, tidak perlu memasukkan email & password lagi setiap aplikasi dibuka
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0284C7),
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const WelcomePage();
        }

        return FutureBuilder<String>(
          future: AuthService.instance.getUserRole(),
          builder: (context, roleSnapshot) {
            if (!roleSnapshot.hasData) {
              return const Scaffold(
                backgroundColor: Color(0xFF0F172A),
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0284C7),
                  ),
                ),
              );
            }

            final role = roleSnapshot.data ?? 'patient';
            ChatService.instance.setActiveRole(role);
            CallService.instance.setActiveRole(role);

            if (role == 'doctor') {
              return const DoctorDashboardPage();
            } else {
              return const HomePage();
            }
          },
        );
      },
    );
  }
}

