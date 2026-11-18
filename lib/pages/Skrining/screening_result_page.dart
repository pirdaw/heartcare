import 'package:flutter/material.dart';
import 'screening_model.dart';
import 'heart_risk_badge_illustration.dart';
import 'custom_bottom_nav_bar.dart';
import 'screening_background.dart';
import '../dokter_page.dart';
import '../home_page.dart';
import '../../services/theme_service.dart';

/// Halaman Hasil Skrining AI
/// Didesain modern & elegan dengan gradasi bertema Welcome & Home,
/// kartu hasil bertingkat dengan visual status yang jelas dan menarik.
class ScreeningResultPage extends StatelessWidget {
  final HeartRiskResult result;
  final ScreeningData data;

  const ScreeningResultPage({
    super.key,
    required this.result,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;

        return ScreeningBackground(
          showEkg: true,
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
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            size: 26,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Hasil Skrining',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF111827),
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
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. HERO RESULT CARD DENGAN GRADASI INDAH
                      _buildHeroResultCard(context, isDark),

                      const SizedBox(height: 18),

                      // 2. KARTU ANALISIS KLINIS & PARAMETER KUNCI
                      _buildAnalysisCard(isDark),

                      const SizedBox(height: 18),

                      // 3. KARTU SARAN & TINDAKAN DOKTER
                      _buildAdviceCard(isDark),

                      const SizedBox(height: 24),

                      // 4. TOMBOL "KONSULTASI DOKTER" (GRADASI UTAMA)
                      Container(
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
                              color: const Color(0xFF0284C7)
                                  .withValues(alpha: 0.35),
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
                                builder: (context) => PilihDokterPage(
                                  initialScreeningData: data,
                                  initialRiskResult: result,
                                ),
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
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Konsultasi Dokter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 5. TOMBOL "BERANDA" (KARTU KONTUR MODERN)
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFBAE6FD),
                            width: 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(
                                  alpha: isDark ? 0.2 : 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
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
                            backgroundColor: Colors.transparent,
                            foregroundColor: isDark
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFF0284C7),
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home_rounded,
                                size: 20,
                                color: isDark
                                    ? const Color(0xFF38BDF8)
                                    : const Color(0xFF0284C7),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Beranda',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFF38BDF8)
                                      : const Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ----------------------------------------------------
              // BOTTOM NAVIGATION BAR (Home aktif sesuai Figma layar 4)
              // ----------------------------------------------------
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
        );
      },
    );
  }

  // ============================================================
  // 1. HERO RESULT CARD (GRADASI DAN GLOWING BADGE)
  // ============================================================
  Widget _buildHeroResultCard(BuildContext context, bool isDark) {
    // Menentukan skema gradasi berdasarkan tingkat risiko
    final List<Color> cardGradientColors;
    final List<Color> badgeGradientColors;
    final Color borderColor;
    final Color shadowColor;

    switch (result.level) {
      case RiskLevel.high:
        cardGradientColors = isDark
            ? const [Color(0xFF3A121A), Color(0xFF240E14)]
            : const [Color(0xFFFFF1F2), Color(0xFFFFE4E6), Color(0xFFFFF5F5)];
        badgeGradientColors = const [
          Color(0xFFFF4D6D),
          Color(0xFFE11D48),
          Color(0xFFBE123C),
        ];
        borderColor = isDark
            ? const Color(0xFFE11D48).withValues(alpha: 0.5)
            : const Color(0xFFFECDD3);
        shadowColor = const Color(0xFFE11D48);
        break;

      case RiskLevel.moderate:
        cardGradientColors = isDark
            ? const [Color(0xFF3A2510), Color(0xFF26190B)]
            : const [Color(0xFFFFFBEB), Color(0xFFFEF3C7), Color(0xFFFFFDF5)];
        badgeGradientColors = const [
          Color(0xFFFBBF24),
          Color(0xFFF59E0B),
          Color(0xFFD97706),
        ];
        borderColor = isDark
            ? const Color(0xFFD97706).withValues(alpha: 0.5)
            : const Color(0xFFFDE68A);
        shadowColor = const Color(0xFFD97706);
        break;

      case RiskLevel.low:
        cardGradientColors = isDark
            ? const [Color(0xFF0D2823), Color(0xFF091D1A)]
            : const [Color(0xFFF0FDF4), Color(0xFFDCFCE7), Color(0xFFF7FEE7)];
        badgeGradientColors = const [
          Color(0xFF34D399),
          Color(0xFF10B981),
          Color(0xFF059669),
        ];
        borderColor = isDark
            ? const Color(0xFF10B981).withValues(alpha: 0.5)
            : const Color(0xFFA7F3D0);
        shadowColor = const Color(0xFF10B981);
        break;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cardGradientColors,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: isDark ? 0.25 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Lingkaran aksen halus di sudut kartu
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.35),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: isDark ? 0.03 : 0.25),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 26,
              horizontal: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Pill Branding: AI CLINICAL ASSESSMENT
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: result.statusColor.withValues(alpha: 0.3),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: result.statusColor.withValues(alpha: 0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 13,
                        color: result.statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'AI RISK ASSESSMENT',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: result.statusColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Lencana Ilustrasi Hati
                Center(
                  child: HeartRiskBadgeIllustration(
                    size: 120,
                    heartColor: result.level == RiskLevel.low
                        ? const Color(0xFF0D9488)
                        : (result.level == RiskLevel.moderate
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFFEF4444)),
                    accentColor: const Color(0xFF7CD3DF),
                  ),
                ),

                const SizedBox(height: 18),

                // Badge Gradasi Judul Risiko (contoh: RISIKO TINGGI)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: badgeGradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    result.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle Indikasi
                Text(
                  result.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFF1E293B),
                  ),
                ),

                // Indikator Estimasi Probabilitas AI (jika tersedia)
                if (result.probability != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A).withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insights_rounded,
                          size: 16,
                          color: result.statusColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Probabilitas Risiko AI: ${(result.probability! * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFE2E8F0)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 2. KARTU ANALISIS KLINIS & PARAMETER KUNCI
  // ============================================================
  Widget _buildAnalysisCard(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Analisis Data Kesehatan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Teks Penjelasan Detail (Preserved for tests)
          Text(
            result.description,
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 14),

          // Parameter Kunci Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildParamChip('Usia: ${data.displayAge}', isDark),
              _buildParamChip('Gender: ${data.displayGender}', isDark),
              _buildParamChip('TD: ${data.displayBloodPressure}', isDark),
              _buildParamChip('Kolesterol: ${data.displayCholesterol}', isDark),
              if (data.maxHeartRate.isNotEmpty)
                _buildParamChip('Detak Maks: ${data.displayMaxHeartRate}', isDark),
              if (data.chestPainType != null)
                _buildParamChip('Nyeri Dada: ${data.displayChestPainType}', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParamChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
        ),
      ),
    );
  }

  // ============================================================
  // 3. KARTU SARAN & REKOMENDASI DOKTER
  // ============================================================
  Widget _buildAdviceCard(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFBAE6FD),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              // Judul "Saran" (Preserved for tests)
              Text(
                'Saran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Teks Saran (Preserved for tests)
          Text(
            result.advice,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 14),

          // Actionable Doctor Recommendations
          _buildAdviceBullet(
            'Konsultasikan hasil skrining dengan dokter spesialis jantung.',
            isDark,
          ),
          const SizedBox(height: 8),
          _buildAdviceBullet(
            'Pantau tekanan darah dan detak jantung Anda secara rutin.',
            isDark,
          ),
          const SizedBox(height: 8),
          _buildAdviceBullet(
            'Jaga pola makan bergizi seimbang dan kelola tingkat stres.',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceBullet(String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0284C7),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
