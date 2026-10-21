import 'package:flutter/material.dart';
import 'package:heartcare/pages/riwayat_model.dart';
import 'package:heartcare/pages/dokter_page.dart';
import 'package:heartcare/pages/Skrining/screening_model.dart';
import 'package:heartcare/services/theme_service.dart';

class DetailRiwayatSkriningPage extends StatelessWidget {
  final RiwayatItem item;

  const DetailRiwayatSkriningPage({
    super.key,
    required this.item,
  });

  static const Color primaryTeal = Color(0xFF0098B9);

  @override
  Widget build(BuildContext context) {
    final data = item.screeningData;
    final risk = item.riskResult;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          body: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.25, 0.6],
                colors: isDark
                    ? const [
                        Color(0xFF1E293B),
                        Color(0xFF131D2E),
                        Color(0xFF0F172A),
                      ]
                    : const [
                        Color(0xFFE8F6FA),
                        Color(0xFFF4FAFC),
                        Color(0xFFF8FAFC),
                      ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // 1. APP BAR (MATCHING HOME & RIWAYAT)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0),
                                width: 1,
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
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Detail Riwayat Skrining',
                          style: TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. CONTENT
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // KARTU HASIL SKRINING
                          _buildResultCard(item, risk, isDark),

                          const SizedBox(height: 20),

                          // SECTION TITLE: DATA YANG DIMASUKKAN
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0098B9),
                                      Color(0xFF0284C7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Data yang Dimasukkan',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // KELOMPOK 1: DATA FISIK & VITAL
                          _buildGroupCard(
                            isDark: isDark,
                            title: 'Data Diri & Pengukuran Vital',
                            icon: Icons.person_outline_rounded,
                            items: [
                              _DataItem('Usia', data?.displayAge ?? '-'),
                              _DataItem('Jenis Kelamin', data?.displayGender ?? '-'),
                              _DataItem(
                                  'Tekanan Darah Istirahat',
                                  data?.displayBloodPressure ?? '-'),
                              _DataItem(
                                  'Kolesterol Total',
                                  data?.displayCholesterol ?? '-'),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // KELOMPOK 2: KELUHAN & ELEKTROKARDIOGRAM
                          _buildGroupCard(
                            isDark: isDark,
                            title: 'Keluhan & Uji Jantung',
                            icon: Icons.monitor_heart_outlined,
                            items: [
                              _DataItem('Tipe Nyeri Dada',
                                  data?.displayChestPainType ?? '-'),
                              _DataItem('Gula Darah Puasa (>120 mg/dL)',
                                  data?.displayFastingBloodSugar ?? '-'),
                              _DataItem('Hasil EKG Saat Istirahat',
                                  data?.displayEcg ?? '-'),
                              _DataItem('Detak Jantung Maksimum',
                                  data?.displayMaxHeartRate ?? '-'),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // KELOMPOK 3: UJI BEBAN & PEMBULUH DARAH
                          _buildGroupCard(
                            isDark: isDark,
                            title: 'Uji Latihan & Pembuluh Darah',
                            icon: Icons.fitness_center_rounded,
                            items: [
                              _DataItem('Angina Akibat Aktivitas',
                                  data?.displayExerciseAngina ?? '-'),
                              _DataItem(
                                  'Depresi Segmen ST (Oldpeak)',
                                  '${data?.displayOldpeak ?? '-'} mm'),
                              _DataItem('Kemiringan Segmen ST',
                                  data?.displayStSlope ?? '-'),
                              _DataItem('Pembuluh Darah Utama',
                                  data?.displayMajorVessels ?? '-'),
                              _DataItem('Kondisi Thalassemia',
                                  data?.displayThal ?? '-'),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // TOMBOL KONSULTASI DOKTER SEKARANG (Gradient Button)
                          Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF0098B9),
                                  Color(0xFF0284C7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0098B9)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PilihDokterPage(),
                                    ),
                                  );
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Konsultasi Dokter Sekarang',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // TOMBOL KEMBALI
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                foregroundColor: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                side: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Kembali ke Riwayat',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultCard(
      RiwayatItem item, HeartRiskResult? risk, bool isDark) {
    final isHigh = item.status == 'TINGGI';

    final LinearGradient cardGradient;
    final Color borderColor;
    final Color shadowColor;
    final Color accentColor;

    if (isHigh) {
      cardGradient = isDark
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E151A),
                Color(0xFF1F0F13),
              ],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF5F5),
                Color(0xFFFFECEE),
              ],
            );
      borderColor =
          isDark ? const Color(0xFF881337) : const Color(0xFFFECDD3);
      shadowColor = const Color(0xFFE11D48);
      accentColor = const Color(0xFFE11D48);
    } else {
      cardGradient = isDark
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F2B1D),
                Color(0xFF0A1E14),
              ],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF0FDF4),
                Color(0xFFDCFCE7),
              ],
            );
      borderColor =
          isDark ? const Color(0xFF166534) : const Color(0xFFBBF7D0);
      shadowColor = const Color(0xFF16A34A);
      accentColor = const Color(0xFF16A34A);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: isDark ? 0.16 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background ambient circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.4),
              ),
            ),
          ),
          Positioned(
            right: 45,
            bottom: -25,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: isDark ? 0.03 : 0.25),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_note_rounded,
                          size: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3.5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isHigh
                              ? const [
                                  Color(0xFFF43F5E),
                                  Color(0xFFE11D48),
                                ]
                              : const [
                                  Color(0xFF22C55E),
                                  Color(0xFF16A34A),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isHigh
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.status,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF334155)
                      : borderColor.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),

                // EVALUATION BOX
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A).withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isHigh
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_rounded,
                        color: accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hasil Evaluasi: Risiko ${item.status.toLowerCase()}',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              risk?.description ??
                                  'Parameter yang dimasukkan menunjukkan tingkat risiko kardiovaskular ${item.status.toLowerCase()}.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF334155),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required List<_DataItem> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFE8F6FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 17, color: primaryTeal),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFF1F5F9),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 14,
              endIndent: 14,
              color: isDark
                  ? const Color(0xFF334155).withValues(alpha: 0.5)
                  : const Color(0xFFF8FAFC),
            ),
            itemBuilder: (context, index) {
              final row = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Text(
                        row.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: Text(
                        row.value,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DataItem {
  final String label;
  final String value;
  const _DataItem(this.label, this.value);
}
