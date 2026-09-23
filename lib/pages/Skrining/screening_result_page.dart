import 'package:flutter/material.dart';
import 'screening_model.dart';
import 'heart_risk_badge_illustration.dart';
import 'custom_bottom_nav_bar.dart';
import '../dokter_page.dart';
import '../home_page.dart';

/// Halaman Hasil Skrining AI - Identik dengan Desain Figma (Layar 4)
class ScreeningResultPage extends StatelessWidget {
  final HeartRiskResult result;
  final ScreeningData data;

  const ScreeningResultPage({
    super.key,
    required this.result,
    required this.data,
  });

  static const Color primaryTeal = Color(0xFF079BC1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ----------------------------------------------------
            // TOP APP BAR
            // ----------------------------------------------------
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 8,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
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
                  const Center(
                    child: Text(
                      'Hasil Skrining',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------
            // KONTEN UTAMA
            // ----------------------------------------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KARTU HASIL SKRINING (Pink/Salmon pada Figma)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: result.backgroundColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ilustrasi Lencana Hati + EKG
                          HeartRiskBadgeIllustration(
                            size: 130,
                            heartColor: result.level == RiskLevel.low
                                ? const Color(0xFF0D9488)
                                : const Color(0xFFEF4444),
                            accentColor: const Color(0xFF7CD3DF),
                          ),

                          const SizedBox(height: 20),

                          // Judul Risiko (contoh: RISIKO TINGGI)
                          Text(
                            result.title,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: result.statusColor,
                              letterSpacing: 0.6,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Subtitle Indikasi
                          Text(
                            result.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Teks Penjelasan Detail
                    Text(
                      result.description,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF4B5563),
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Bagian Saran
                    const Text(
                      'Saran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      result.advice,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF4B5563),
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tombol "Konsultasi Dokter"
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PilihDokterPage(),
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
                          'Konsultasi Dokter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tombol "Beranda"
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                            (route) => false,
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
                          'Beranda',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar (Tab Home aktif pada Figma layar 4)
            HeartCareBottomNavBar(
              currentIndex: 0,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PilihDokterPage()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
