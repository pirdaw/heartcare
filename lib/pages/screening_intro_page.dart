import 'package:flutter/material.dart';
import 'custom_bottom_nav_bar.dart';

/// Halaman Pengantar Skrining Risiko Penyakit Jantung
class ScreeningIntroPage extends StatelessWidget {
  const ScreeningIntroPage({super.key});

  static const Color primaryTeal = Color(0xFF0098B9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar dengan Tombol Back Melingkar
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F3F6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF1E293B),
                      size: 26,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Judul Halaman: Skrining Risiko Penyakit Jantung
            const Text(
              'Skrining Risiko\nPenyakit Jantung',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
                height: 1.25,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 14),

            // Deskripsi Penjelasan
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'AI menganalisis data kesehatan Anda\nuntuk menilai risiko penyakit jantung.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF4B5563),
                  height: 1.45,
                ),
              ),
            ),

            const Spacer(flex: 2),

            // Ilustrasi Medis Clipboard
            Center(
              child: Container(
                width: 200,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7FB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_turned_in_rounded,
                      size: 80,
                      color: primaryTeal,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'AI Health Screening',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 3),

            // Tombol "Mulai Skrining"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Memulai proses Skrining...'),
                        backgroundColor: primaryTeal,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Mulai Skrining',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Navigation Bar (Tab "Skrining" aktif)
            const HeartCareBottomNavBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }
}