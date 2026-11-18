import 'package:flutter/material.dart';
import 'screening_model.dart';
import 'screening_ai_analysis_page.dart';
import 'custom_bottom_nav_bar.dart';
import 'screening_background.dart';
import '../../services/theme_service.dart';

/// Halaman Review & Koreksi Jawaban - Selaras dengan Home & Welcome
class ScreeningReviewPage extends StatelessWidget {
  final ScreeningData data;

  const ScreeningReviewPage({
    super.key,
    required this.data,
  });

  static const Color primaryTeal = Color(0xFF0284C7);
  static const Color reviewCardColor = Color(0xFFF0F9FF);
  static const Color dividerColor = Color(0xFFE0F2FE);

  void _showConfirmationDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: primaryTeal,
              size: 26,
            ),
            const SizedBox(width: 10),
            Text(
              'Konfirmasi Jawaban',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah seluruh data skrining Anda sudah benar? Data Anda akan dianalisis secara komprehensif oleh sistem HeartCare.',
          style: TextStyle(
            fontSize: 13.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
            height: 1.45,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Periksa Lagi',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 44,
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
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext); // Tutup dialog
                      // Lanjut ke Halaman Proses Analisis AI
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ScreeningAiAnalysisPage(data: data),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Ya, Analisis',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;

        return ScreeningBackground(
          showEkg: false,
          child: Column(
            children: [
              // ----------------------------------------------------
              // TOP BAR & HEADER
              // ----------------------------------------------------
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 8,
                ),
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

              // Judul: "Periksa kembali data Anda"
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Periksa kembali data Anda',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ----------------------------------------------------
              // TABEL DATA KARTU ELEGAN
              // ----------------------------------------------------
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(
                              alpha: isDark ? 0.2 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      children: [
                        _buildReviewRow(
                          context,
                          label: 'Usia',
                          value: data.displayAge,
                          targetStep: 1,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildReviewRow(
                          context,
                          label: 'Jenis Kelamin',
                          value: data.displayGender,
                          targetStep: 1,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildReviewRow(
                          context,
                          label: 'Jenis Nyeri Dada',
                          value: data.displayChestPainType,
                          targetStep: 2,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildReviewRow(
                          context,
                          label: 'Tekanan Darah',
                          value: data.displayBloodPressure,
                          targetStep: 2,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildReviewRow(
                          context,
                          label: 'Kolestrol Total',
                          value: data.displayCholesterol,
                          targetStep: 2,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildReviewRow(
                          context,
                          label: 'Gula Darah Puasa',
                          value: data.displayFastingBloodSugar,
                          targetStep: 3,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildReviewRow(
                          context,
                          label: 'EKG',
                          value: data.displayEcg,
                          targetStep: 3,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildReviewRow(
                          context,
                          label: 'Detak Jantung Maksimum',
                          value: data.displayMaxHeartRate,
                          targetStep: 3,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildReviewRow(
                          context,
                          label: 'Nyeri Dada Saat Aktivitas',
                          value: data.displayExerciseAngina,
                          targetStep: 4,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildReviewRow(
                          context,
                          label: 'Oldpeak',
                          value: data.displayOldpeak,
                          targetStep: 4,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildReviewRow(
                          context,
                          label: 'Kemiringan ST',
                          value: data.displayStSlope,
                          targetStep: 4,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildReviewRow(
                          context,
                          label: 'Pembuluh darah utama',
                          value: data.displayMajorVessels,
                          targetStep: 5,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildReviewRow(
                          context,
                          label: 'Hasil pemeriksaan thal',
                          value: data.displayThal,
                          targetStep: 5,
                          isDark: isDark,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ----------------------------------------------------
              // TOMBOL "LANJUTKAN" DENGAN GRADASI INDAH
              // ----------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
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
                        color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _showConfirmationDialog(context, isDark),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lanjutkan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Navigation
              const HeartCareBottomNavBar(currentIndex: 1),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewRow(
    BuildContext context, {
    required String label,
    required String value,
    required int targetStep,
    required bool isDark,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: () {
        // Mengembalikan target step agar user bisa langsung mengoreksi data
        Navigator.pop(context, targetStep);
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.edit_outlined,
              size: 14,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    );
  }
}
