import 'package:flutter/material.dart';
import 'screening_model.dart';
import 'screening_ai_analysis_page.dart';
import 'custom_bottom_nav_bar.dart';

/// Halaman Review & Koreksi Jawaban - Identik dengan Desain Figma (Layar 3)
class ScreeningReviewPage extends StatelessWidget {
  final ScreeningData data;

  const ScreeningReviewPage({
    super.key,
    required this.data,
  });

  static const Color primaryTeal = Color(0xFF079BC1);
  static const Color reviewCardColor = Color(0xFFE2F0F7);
  static const Color dividerColor = Color(0xFFCCE4F1);

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: primaryTeal,
              size: 26,
            ),
            SizedBox(width: 10),
            Text(
              'Konfirmasi Jawaban',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah seluruh data skrining Anda sudah benar? Data Anda akan dianalisis secara komprehensif oleh AI HeartCare.',
          style: TextStyle(
            fontSize: 13.5,
            color: Color(0xFF4B5563),
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
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Periksa Lagi',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
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
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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

            // Judul: "Periksa kembali data Anda"
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Periksa kembali data Anda',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ----------------------------------------------------
            // TABEL DATA KARTU CYAN (SESUAI FIGMA LAYAR 3)
            // ----------------------------------------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: reviewCardColor,
                    borderRadius: BorderRadius.circular(16),
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
                      ),
                      _buildDivider(),
                      _buildReviewRow(
                        context,
                        label: 'Jenis Kelamin',
                        value: data.displayGender,
                        targetStep: 1,
                      ),
                      _buildDivider(),
                      _buildReviewRow(
                        context,
                        label: 'Jenis Nyeri Dada',
                        value: data.displayChestPainType,
                        targetStep: 2,
                      ),
                      _buildDivider(),
                      _buildReviewRow(
                        context,
                        label: 'Tekanan Darah',
                        value: data.displayBloodPressure,
                        targetStep: 2,
                      ),
                      _buildDivider(),
                      _buildReviewRow(
                        context,
                        label: 'Kolestrol Total',
                        value: data.displayCholesterol,
                        targetStep: 2,
                      ),
                      _buildDivider(),
                      _buildReviewRow(
                        context,
                        label: 'Gula Darah Puasa',
                        value: data.displayFastingBloodSugar,
                        targetStep: 3,
                      ),
                      _buildDivider(),
                      _buildReviewRow(
                        context,
                        label: 'EKG',
                        value: data.displayEcg,
                        targetStep: 3,
                      ),
                      _buildDivider(),
                      _buildReviewRow(
                        context,
                        label: 'Detak Jantung Maksimum',
                        value: data.displayMaxHeartRate,
                        targetStep: 3,
                      ),
                      _buildDivider(),
                      _buildReviewRow(
                        context,
                        label: 'Nyeri Dada Saat Aktivitas',
                        value: data.displayExerciseAngina,
                        targetStep: 4,
                      ),
                      _buildDivider(),
                      _buildReviewRow(
                        context,
                        label: 'Oldpeak',
                        value: data.displayOldpeak,
                        targetStep: 4,
                      ),
                      _buildDivider(),
                      _buildReviewRow(
                        context,
                        label: 'Kemiringan ST',
                        value: data.displayStSlope,
                        targetStep: 4,
                      ),
                      _buildDivider(),
                      _buildReviewRow(
                        context,
                        label: 'Pembuluh darah utama',
                        value: data.displayMajorVessels,
                        targetStep: 5,
                      ),
                      _buildDivider(),
                      _buildReviewRow(
                        context,
                        label: 'Hasil pemeriksaan thal',
                        value: data.displayThal,
                        targetStep: 5,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ----------------------------------------------------
            // TOMBOL "LANJUTKAN" (MEMBUKA KONFIRMASI)
            // ----------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _showConfirmationDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lanjutkan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Navigation
            const HeartCareBottomNavBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(
    BuildContext context, {
    required String label,
    required String value,
    required int targetStep,
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
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: dividerColor,
      margin: const EdgeInsets.symmetric(vertical: 2),
    );
  }
}
