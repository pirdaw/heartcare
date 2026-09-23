import 'package:flutter/material.dart';
import 'package:heartcare/pages/riwayat_model.dart';
import 'package:heartcare/pages/dokter_page.dart';
import 'package:heartcare/pages/Skrining/screening_model.dart';

class DetailRiwayatSkriningPage extends StatelessWidget {
  final RiwayatItem item;

  const DetailRiwayatSkriningPage({
    super.key,
    required this.item,
  });

  static const Color primaryTeal = Color(0xFF079BC1);

  @override
  Widget build(BuildContext context) {
    final data = item.screeningData;
    final risk = item.riskResult;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // APP BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF0F172A),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Detail Riwayat Skrining',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),

            // CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KARTU HASIL SKRINING (RENDAH / SEDANG / TINGGI)
                    _buildResultCard(item, risk),

                    const SizedBox(height: 20),

                    // SECTION TITLE: DATA YANG DIMASUKKAN
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: primaryTeal,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Data yang Dimasukkan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // KELOMPOK 1: DATA FISIK & VITAL
                    _buildGroupCard(
                      title: 'Data Diri & Pengukuran Vital',
                      icon: Icons.person_outline_rounded,
                      items: [
                        _DataItem('Usia', data?.displayAge ?? '-'),
                        _DataItem('Jenis Kelamin', data?.displayGender ?? '-'),
                        _DataItem('Tekanan Darah Istirahat', data?.displayBloodPressure ?? '-'),
                        _DataItem('Kolesterol Total', data?.displayCholesterol ?? '-'),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // KELOMPOK 2: KELUHAN & ELEKTROKARDIOGRAM
                    _buildGroupCard(
                      title: 'Keluhan & Uji Jantung',
                      icon: Icons.monitor_heart_outlined,
                      items: [
                        _DataItem('Tipe Nyeri Dada', data?.displayChestPainType ?? '-'),
                        _DataItem('Gula Darah Puasa (>120 mg/dL)', data?.displayFastingBloodSugar ?? '-'),
                        _DataItem('Hasil EKG Saat Istirahat', data?.displayEcg ?? '-'),
                        _DataItem('Detak Jantung Maksimum', data?.displayMaxHeartRate ?? '-'),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // KELOMPOK 3: UJI BEBAN & PEMBULUH DARAH
                    _buildGroupCard(
                      title: 'Uji Latihan & Pembuluh Darah',
                      icon: Icons.fitness_center_rounded,
                      items: [
                        _DataItem('Angina Akibat Aktivitas', data?.displayExerciseAngina ?? '-'),
                        _DataItem('Depresi Segmen ST (Oldpeak)', '${data?.displayOldpeak ?? '-'} mm'),
                        _DataItem('Kemiringan Segmen ST', data?.displayStSlope ?? '-'),
                        _DataItem('Pembuluh Darah Utama', data?.displayMajorVessels ?? '-'),
                        _DataItem('Kondisi Thalassemia', data?.displayThal ?? '-'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // TOMBOL AKSI
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PilihDokterPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                        label: const Text(
                          'Konsultasi Dokter Sekarang',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
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
    );
  }

  Widget _buildResultCard(RiwayatItem item, HeartRiskResult? risk) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.statusColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: item.statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item.status == 'TINGGI'
                    ? Icons.warning_amber_rounded
                    : (item.status == 'SEDANG'
                        ? Icons.info_outline_rounded
                        : Icons.check_circle_outline_rounded),
                color: item.statusColor,
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
                        color: item.statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      risk?.description ??
                          'Parameter yang dimasukkan menunjukkan tingkat risiko kardiovaskular ${item.status.toLowerCase()}.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard({
    required String title,
    required IconData icon,
    required List<_DataItem> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: primaryTeal),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final it = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Text(
                        it.label,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        it.value,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
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
  _DataItem(this.label, this.value);
}
