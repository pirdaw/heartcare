import 'package:flutter/material.dart';
import 'Skrining/medical_clipboard_illustration.dart';
import 'Skrining/custom_bottom_nav_bar.dart';
import 'Skrining/screening_input_page.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';

/// Halaman Pertama: Pengantar Skrining Risiko Penyakit Jantung
class ScreeningIntroPage extends StatelessWidget {
  const ScreeningIntroPage({super.key});

  static const Color primaryBlue = Color(0xFF079BC1);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.languageNotifier,
      builder: (context, _, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.themeModeNotifier,
          builder: (context, themeMode, _) {
            final isDark = themeMode == ThemeMode.dark;

            return Scaffold(
              backgroundColor:
                  isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.28, 0.65, 1.0],
                    colors: isDark
                        ? const [
                            Color(0xFF1E293B),
                            Color(0xFF162032),
                            Color(0xFF111927),
                            Color(0xFF0F172A),
                          ]
                        : const [
                            Color(0xFFE0F2FE),
                            Color(0xFFEDF6FD),
                            Color(0xFFF3F8FD),
                            Color(0xFFF8FAFC),
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      // Ornamen ambient glow lembut agar layar selaras dengan menu Home
                      Positioned(
                        top: -40,
                        right: -30,
                        child: IgnorePointer(
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF38BDF8)
                                  .withValues(alpha: isDark ? 0.04 : 0.16),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 280,
                        left: -60,
                        child: IgnorePointer(
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0EA5E9)
                                  .withValues(alpha: isDark ? 0.03 : 0.08),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 140,
                        right: -50,
                        child: IgnorePointer(
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0284C7)
                                  .withValues(alpha: isDark ? 0.03 : 0.06),
                            ),
                          ),
                        ),
                      ),
                      Column(
                    children: [
                      // Top Bar dengan Tombol Back Melingkar
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.chevron_left,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                                size: 26,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Judul Halaman: Skrining Risiko Penyakit Jantung
                      Text(
                        tr('Skrining Risiko\nPenyakit Jantung', 'Heart Disease\nRisk Screening'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                          height: 1.25,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Deskripsi Penjelasan
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          tr(
                            'Sistem menganalisis data kesehatan Anda\nuntuk menilai risiko penyakit jantung.',
                            'The system analyzes your health data\nto assess heart disease risk.',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF4B5563),
                            height: 1.45,
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Ilustrasi Clipboard Medis dengan Jantung EKG
                      const Center(
                        child: MedicalClipboardIllustration(
                          width: 220,
                          height: 275,
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Tombol "Mulai Skrining"
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ScreeningInputPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              tr('Mulai Skrining', 'Start Screening'),
                              style: const TextStyle(
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
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}