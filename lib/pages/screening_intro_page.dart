import 'package:flutter/material.dart';
import 'home_page.dart';
import 'Skrining/medical_clipboard_illustration.dart';
import 'Skrining/custom_bottom_nav_bar.dart';
import 'Skrining/screening_input_page.dart';
import 'Skrining/screening_background.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';

/// Halaman Pertama: Pengantar Skrining Risiko Penyakit Jantung
class ScreeningIntroPage extends StatelessWidget {
  const ScreeningIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.languageNotifier,
      builder: (context, _, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.themeModeNotifier,
          builder: (context, themeMode, _) {
            final isDark = themeMode == ThemeMode.dark;

            return ScreeningBackground(
              showEkg: true,
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
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                  alpha: isDark ? 0.25 : 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            color:
                                isDark ? Colors.white : const Color(0xFF1E293B),
                            size: 26,
                          ),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Pill AI Screening Assessment (Selaras dengan Home Page)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B).withValues(alpha: 0.9)
                          : Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF1E3A5F)
                            : const Color(0xFFBAE6FD),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF0284C7).withValues(alpha: 0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : const Color(0xFF0284C7),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'AI SCREENING ASSESSMENT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Judul Halaman: Skrining Risiko Penyakit Jantung
                  Text(
                    tr('Skrining Risiko\nPenyakit Jantung',
                        'Heart Disease\nRisk Screening'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      height: 1.25,
                      letterSpacing: -0.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Deskripsi Penjelasan
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      tr(
                        'Sistem menganalisis data kesehatan Anda\nuntuk menilai risiko penyakit jantung.',
                        'The system analyzes your health data\nto assess heart disease risk.',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF475569),
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

                  // Tombol "Mulai Skrining" dengan Gradasi Indah
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF38BDF8),
                            Color(0xFF0EA5E9),
                            Color(0xFF0284C7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF0284C7).withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
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
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tr('Mulai Skrining', 'Start Screening'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Navigation Bar (Tab "Skrining" aktif)
                  const HeartCareBottomNavBar(currentIndex: 1),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
