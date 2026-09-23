import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  /// Melakukan panggilan telepon langsung ke nomor darurat
  Future<void> _makePhoneCall(
    BuildContext context,
    String rawNumber, {
    String? title,
  }) async {
    final cleanNumber = rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      final canLaunch = await canLaunchUrl(phoneUri);
      if (canLaunch) {
        await launchUrl(phoneUri);
      } else {
        // Fallback percobaan peluncuran eksternal
        final fallbackSuccess = await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
        if (!fallbackSuccess && context.mounted) {
          _showErrorSnackBar(
            context,
            'Tidak dapat membuka aplikasi telepon untuk nomor: $rawNumber',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Gagal melakukan panggilan ($rawNumber): $e');
      }
    }
  }


  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0F172A),
                size: 18,
              ),
            ),
          ),
        ),
        title: const Text(
          'Panggilan Darurat Medis',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFECEF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFCDD2)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  color: Color(0xFFDC2626),
                  size: 9,
                ),
                SizedBox(width: 5),
                Text(
                  'Siaga 24 Jam',
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HERO BANNER: PANGGILAN 119
              _buildMainHotlineCard(context),

              const SizedBox(height: 20),

              // 2. NOMOR PANGGILAN CEPAT LAINNYA
              const Text(
                'Layanan Darurat Cepat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              _buildQuickContactsGrid(context),

              const SizedBox(height: 24),

              // 3. PANDUAN GEJALA SERANGAN JANTUNG
              _buildSymptomsGuideCard(),

              const SizedBox(height: 20),

              // 4. SOP PERTOLONGAN PERTAMA
              _buildFirstAidGuideCard(),

              const SizedBox(height: 20),

              // 5. FOOTER DISCLAIMER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Panggilan darurat 119 & 112 dapat dihubungi secara gratis (bebas pulsa) dari seluruh operator seluler dan telepon rumah di Indonesia.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Banner Hotline Utama 119
  Widget _buildMainHotlineCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative circular shapes
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -35,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_hospital_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'HOTLINE MEDIS NASIONAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone_in_talk_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  '119',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ambulans & Gawat Darurat Medis (SPGDT Kemenkes RI)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bebas Pulsa • Terkoneksi ke seluruh PSC 119 di Indonesia',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _makePhoneCall(
                      context,
                      '119',
                      title: 'Hotline Medis 119',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFDC2626),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 20,
                          color: Color(0xFFDC2626),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Panggil 119 Sekarang',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tombol-tombol Panggilan Cepat (112 & 118)
  Widget _buildQuickContactsGrid(BuildContext context) {
    return Row(
      children: [
        // Panggilan 112 (Darurat Terpadu)
        Expanded(
          child: _buildContactItem(
            context: context,
            number: '112',
            label: 'Darurat Terpadu',
            sublabel: 'Polisi / Damkar / SAR',
            icon: Icons.support_agent_rounded,
            iconColor: const Color(0xFF0284C7),
            bgColor: const Color(0xFFF0F9FF),
            borderColor: const Color(0xFFBAE6FD),
            onTap: () => _makePhoneCall(
              context,
              '112',
              title: 'Darurat Terpadu 112',
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Panggilan 118 (Ambulans AGD)
        Expanded(
          child: _buildContactItem(
            context: context,
            number: '118',
            label: 'Ambulans AGD',
            sublabel: 'Gawat Darurat Daerah',
            icon: Icons.airport_shuttle_rounded,
            iconColor: const Color(0xFFEA580C),
            bgColor: const Color(0xFFFFF7ED),
            borderColor: const Color(0xFFFFEDD5),
            onTap: () => _makePhoneCall(
              context,
              '118',
              title: 'Ambulans 118',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required String number,
    required String label,
    required String sublabel,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_rounded,
                      color: Color(0xFF059669),
                      size: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                number,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                sublabel,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Panduan Gejala Serangan Jantung
  Widget _buildSymptomsGuideCard() {
    final symptoms = [
      {
        'icon': Icons.monitor_heart_rounded,
        'title': 'Nyeri Dada Khas',
        'desc':
            'Dada terasa tertindih beban berat, diremas, atau panas terbakar lebih dari 15-20 menit.',
      },
      {
        'icon': Icons.fork_right_rounded,
        'title': 'Penjalaran Nyeri',
        'desc':
            'Nyeri menjalar ke bahu, lengan kiri, leher, rahang bawah, atau punggung.',
      },
      {
        'icon': Icons.air_rounded,
        'title': 'Sesak Napas',
        'desc':
            'Kesulitan bernapas atau terengah-engah mendadak, sering bersamaan dengan nyeri dada.',
      },
      {
        'icon': Icons.water_drop_rounded,
        'title': 'Keringat Dingin & Lemas',
        'desc':
            'Keringat dingin bercucuran, rasa mual, muntah, serta pusing melayang.',
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFCCD2), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFE11D48),
                size: 24,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gejala Darurat Serangan Jantung',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9F1239),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Segera hubungi bantuan medis jika merasakan satu atau lebih tanda di bawah ini:',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF881337),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          ...symptoms.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFCCD2)),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 16,
                      color: const Color(0xFFE11D48),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF881337),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['desc'] as String,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF4C0519),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// SOP Langkah Awal Pertolongan Pertama
  Widget _buildFirstAidGuideCard() {
    final steps = [
      {
        'num': '1',
        'title': 'Segera Hubungi 119 / Bantuan',
        'desc': 'Jangan tunda mencari pertolongan medis pertama.',
      },
      {
        'num': '2',
        'title': 'Hentikan Aktivitas & Istirahat',
        'desc':
            'Duduk setengah tegak (sandarkan punggung) untuk meringankan beban kerja jantung.',
      },
      {
        'num': '3',
        'title': 'Longgarkan Pakaian',
        'desc':
            'Buka kancing kerah atau ikat pinggang agar saluran pernapasan lebih leluasa.',
      },
      {
        'num': '4',
        'title': 'JANGAN Menyetir Sendiri',
        'desc':
            'Tunggu ambulans atau minta diantar oleh orang lain menuju IGD rumah sakit.',
      },
      {
        'num': '5',
        'title': 'Konsumsi Obat Jika Ada Resep Dokter',
        'desc':
            'Konsumsi obat darurat (seperti Nitrogliserin / Aspilet) hanya jika sebelumnya diresepkan oleh dokter.',
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                color: Color(0xFF0F766E),
                size: 22,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Langkah Pertolongan Pertama (SOP)',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCCFBF1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      step['num']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title']!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          step['desc']!,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}