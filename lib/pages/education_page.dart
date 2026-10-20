import 'package:flutter/material.dart';

// ============================================================================
// HALAMAN UTAMA: EDUKASI KESEHATAN
// ============================================================================
class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  static const Color primaryTeal = Color(0xFF0098B9);
  static const Color darkSlate = Color(0xFF0F172A);
  static const Color subSlate = Color(0xFF475569);
  static const Color cardBorder = Color(0xFFD2EDF5);

  static Widget buildBackButton(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0098B9).withValues(alpha: 0.14),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFBCE7F5),
          width: 1.2,
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  int _currentTipIndex = 0;

  final List<Map<String, String>> _quickTips = [
    {
      'title': 'Tips Aktivitas Hari Ini',
      'desc':
          'Lakukan "Talk Test" saat berjalan kaki: Jika masih bisa berbicara nyaman tanpa terengah-engah, intensitas tersebut optimal dan aman bagi pompa jantung Anda.',
      'tag': 'Aktivitas Aman',
    },
    {
      'title': 'Tips Nutrisi Harian',
      'desc':
          'Batasi konsumsi garam maksimal 1 sendok teh (2.000 mg natrium) per hari untuk mencegah beban berlebih pada pembuluh darah dan otot jantung.',
      'tag': 'Nutrisi Terukur',
    },
    {
      'title': 'Tips Pemulihan & Istirahat',
      'desc':
          'Tidur 7-8 jam per malam memberi kesempatan biologis bagi denyut jantung dan tekanan darah untuk beristirahat dan menstabilkan ritme alami.',
      'tag': 'Kualitas Tidur',
    },
  ];

  void _nextTip() {
    setState(() {
      _currentTipIndex = (_currentTipIndex + 1) % _quickTips.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE2F4FA), // Soft sky teal mist
            Color(0xFFF1F8FB),
            Color(0xFFF8FAFC),
            Color(0xFFFFFFFF),
          ],
          stops: [0.0, 0.25, 0.65, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Ambient decorative glowing orbs (Multi-color yang lembut & harmonis)
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0098B9).withValues(alpha: 0.10), // Cyan-teal
              ),
            ),
          ),
          Positioned(
            top: 260,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withValues(alpha: 0.07), // Fresh Emerald Green
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.06), // Serene Lavender
              ),
            ),
          ),

          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  // HEADER BAR
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                    child: Row(
                      children: [
                        EducationPage.buildBackButton(context),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edukasi Kesehatan',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: EducationPage.darkSlate,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Panduan komprehensif pendukung kesehatan jantung',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: EducationPage.subSlate,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // KONTEN UTAMA
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HERO BANNER PENGANTAR (Brand Teal Unified)
                          _buildHeroBanner(),

                          const SizedBox(height: 16),

                          // KARTU INTERAKTIF: TIPS DOKTER HARI INI (Mengurangi rasa monoton)
                          _buildDailyTipCard(),

                          const SizedBox(height: 20),

                          // HEADER PILIHAN TOPIK (Terpadu Jadi 1, Tidak Dibeda-bedakan)
                          _buildTopicSectionHeader(),

                          const SizedBox(height: 14),

                          // DAFTAR KARTU TOPIK EDUKASI (Palet Warna Khas Sesuai Topik)
                          _buildTopicCard(
                            context,
                            number: '01',
                            title: 'Pola Makan Sehat',
                            categoryTag: 'Nutrisi & Makanan',
                            readTime: '⏱ 4 Menit Baca',
                            pointsCount: 4,
                            icon: Icons.restaurant_menu_rounded,
                            description:
                                'Panduan pemilihan bahan makanan alami bergizi, pembatasan natrium dan lemak jenuh, serta penjadwalan makan yang ramah jantung.',
                            keyHighlights: [
                              'Sayur & Ikan Segar',
                              'Rendah Natrium',
                              'Jadwal Makan Teratur',
                            ],
                            primaryColor: const Color(0xFF059669), // Emerald Green
                            secondaryColor: const Color(0xFF10B981),
                            softBgColor: const Color(0xFFECFDF5),
                            borderHighlightColor: const Color(0xFFA7F3D0),
                            tagTextColor: const Color(0xFF047857),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PolaMakanSehatPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),

                          _buildTopicCard(
                            context,
                            number: '02',
                            title: 'Aktivitas Fisik',
                            categoryTag: 'Latihan & Gerak',
                            readTime: '⏱ 3 Menit Baca',
                            pointsCount: 4,
                            icon: Icons.directions_walk_rounded,
                            description:
                                'Aktivitas gerak yang aman, terukur, dan bertahap disesuaikan dengan kapasitas pompa jantung tanpa risiko beban mendadak.',
                            keyHighlights: [
                              'Jalan Kaki 20 Menit',
                              'Latihan Pernapasan',
                              'Prinsip "Talk Test"',
                            ],
                            primaryColor: const Color(0xFF0284C7), // Dynamic Azure Blue
                            secondaryColor: const Color(0xFF2563EB),
                            softBgColor: const Color(0xFFEFF6FF),
                            borderHighlightColor: const Color(0xFFBFDBFE),
                            tagTextColor: const Color(0xFF1D4ED8),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AktivitasFisikPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),

                          _buildTopicCard(
                            context,
                            number: '03',
                            title: 'Kebiasaan Sehat',
                            categoryTag: 'Gaya Hidup & Relaksasi',
                            readTime: '⏱ 4 Menit Baca',
                            pointsCount: 4,
                            icon: Icons.spa_rounded,
                            description:
                                'Membiasakan pola istirahat cukup 7-8 jam, menghindari rokok aktif maupun pasif, manajemen stres, dan kepatuhan konsumsi obat.',
                            keyHighlights: [
                              'Bebas Paparan Rokok',
                              'Tidur Berkualitas',
                              'Disiplin Obat & Terapi',
                            ],
                            primaryColor: const Color(0xFF7C3AED), // Serene Royal Violet
                            secondaryColor: const Color(0xFF9333EA),
                            softBgColor: const Color(0xFFF5F3FF),
                            borderHighlightColor: const Color(0xFFDDD6FE),
                            tagTextColor: const Color(0xFF6D28D9),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const KebiasaanSehatPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),

                          // CATATAN KAKI INFORMASI MEDIS (Harmonis, bukan warna mencolok)
                          _buildMedicalDisclaimerBox(),

                          const SizedBox(height: 24),
                        ],
                      ),
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

  // HERO BANNER PENGANTAR
  // HERO BANNER PENGANTAR (Deep Teal & Sapphire dengan Ruby Heart dan Golden Accent)
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00758F), // Deep teal
            Color(0xFF0098B9), // Vibrant cyan-teal
            Color(0xFF1D4ED8), // Rich royal sapphire blue
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0098B9).withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFE11D48), // Ruby rose heart
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pusat Panduan Jantung',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Informasi berbasis bukti medis untuk mendampingi pemulihan dan menjaga kestabilan kardiovaskular.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFFE0F4FB),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Kolom Topik Edukasi Jantung (1 kolom terpadu dengan aksen emas yang elegan)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 13, color: Color(0xFFFDE047)),
                      SizedBox(width: 6),
                      Text(
                        'Pilihan Topik Edukasi Jantung',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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

  // KARTU INTERAKTIF: TIPS DOKTER HARI INI (Aksen Hangat Emas / Amber)
  Widget _buildDailyTipCard() {
    final tip = _quickTips[_currentTipIndex];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2), // Soft golden border
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.08), // Warm golden glow
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7), // Warm golden background
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFFD97706), // Warm amber gold
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip['title']!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      tip['tag']!,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB45309), // Amber tag
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _nextTip,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFDE68A),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Tip Lain (${_currentTipIndex + 1}/${_quickTips.length})',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB45309),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.refresh_rounded,
                        size: 12,
                        color: Color(0xFFB45309),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tip['desc']!,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF475569),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // HEADER PILIHAN TOPIK (1 Kolom Bersatu, Tanpa Kategori yang Membeda-bedakan)
  Widget _buildTopicSectionHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilihan Topik Edukasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: EducationPage.darkSlate,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Pilih materi yang ingin Anda pelajari di bawah ini:',
          style: TextStyle(
            fontSize: 12,
            color: EducationPage.subSlate,
          ),
        ),
      ],
    );
  }

  // KARTU TOPIK EDUKASI (Harmonis, Kaya Warna, Tidak Monoton)
  Widget _buildTopicCard(
    BuildContext context, {
    required String number,
    required String title,
    required String categoryTag,
    required String readTime,
    required int pointsCount,
    required IconData icon,
    required String description,
    required List<String> keyHighlights,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color secondaryColor,
    required Color softBgColor,
    required Color borderHighlightColor,
    required Color tagTextColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderHighlightColor.withValues(alpha: 0.7),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon Container dengan Gradient Khas Topik
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: softBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              categoryTag,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: tagTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            readTime,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                // Number Badge Selaras
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: softBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: borderHighlightColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    number,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF475569),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            // Key Highlight Pills
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: keyHighlights.map((highlight) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: softBgColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderHighlightColor.withValues(alpha: 0.8),
                      width: 0.9,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 12,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        highlight,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            // Separator & Action Row
            Container(
              height: 1,
              color: const Color(0xFFF1F5F9),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lihat panduan lengkap ($pointsCount materi)',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: softBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // DISCLAIMER BOX (Warna Lembut Medis)
  Widget _buildMedicalDisclaimerBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFCCE8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0098B9).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF0098B9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Informasi dalam edukasi ini bertujuan sebagai panduan umum. Selalu konsultasikan kondisi dan kebutuhan spesifik Anda dengan dokter atau tenaga kesehatan yang merawat.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.45,
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 1. DETAIL PAGE: POLA MAKAN SEHAT
// ============================================================================
class PolaMakanSehatPage extends StatelessWidget {
  const PolaMakanSehatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD1FAE5), // Soft fresh emerald mint
            Color(0xFFE8F9F1),
            Color(0xFFF6FCF9),
            Color(0xFFFFFFFF),
          ],
          stops: [0.0, 0.25, 0.65, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // HEADER BAR
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                child: Row(
                  children: [
                    EducationPage.buildBackButton(context),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pola Makan Sehat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Panduan makanan bergizi untuk kesehatan jantung',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BANNER RINGKASAN (Fresh Emerald Green)
                      _buildOverviewCard(
                        icon: Icons.restaurant_menu_rounded,
                        title: 'Pola Makan Bagi Pasien Jantung',
                        tag: 'Nutrisi Klinis',
                        readDuration: '4 Menit Baca',
                        description:
                            'Membahas pola makan sehat untuk orang yang sudah memiliki penyakit jantung, berfokus pada pemilihan makanan alami berkualitas dan pembiasaan waktu makan yang mendukung kerja jantung.',
                        gradientColors: const [
                          Color(0xFF047857),
                          Color(0xFF059669),
                          Color(0xFF10B981),
                        ],
                        iconColor: const Color(0xFF059669),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Materi Edukasi Nutrisi',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // MATERI A: Perbanyak Makanan Sehat (Emerald / Rekomendasi Hijau)
                      _buildDetailCard(
                        label: 'A',
                        title: 'Perbanyak Makanan Sehat',
                        categoryTag: 'Direkomendasikan',
                        icon: Icons.eco_rounded,
                        summary:
                            'Penuhi kebutuhan harian dengan makanan segar kaya serat, antioksidan, dan lemak baik yang menjaga elastisitas pembuluh darah.',
                        points: const [
                          'Memperbanyak buah dan sayuran segar aneka warna sebagai sumber serat larut dan vitamin.',
                          'Memilih ikan berlemak sehat kaya asam lemak Omega-3 (seperti salmon, kembung, tuna, tongkol).',
                          'Memilih kacang-kacangan dan biji-bijian utuh (seperti oatmeal, kedelai, kacang almond) untuk menekan kolesterol LDL.',
                          'Menjaga menu makanan tetap beragam dan seimbang agar kebutuhan nutrisi harian tercukupi.',
                        ],
                        primaryColor: const Color(0xFF059669),
                        secondaryColor: const Color(0xFF10B981),
                        softBgColor: const Color(0xFFECFDF5),
                        borderHighlightColor: const Color(0xFFA7F3D0),
                        tagTextColor: const Color(0xFF047857),
                      ),

                      const SizedBox(height: 14),

                      // MATERI B: Batasi Lemak, Gula, dan Garam (Amber / Peringatan Waspada)
                      _buildDetailCard(
                        label: 'B',
                        title: 'Batasi Lemak, Gula, dan Garam',
                        categoryTag: 'Perlu Dibatasi',
                        icon: Icons.tune_rounded,
                        summary:
                            'Konsumsi lemak jenuh, gula, dan natrium berlebih berpotensi menaikkan tekanan darah serta memperberat beban pompa jantung.',
                        points: const [
                          'Membatasi makanan tinggi lemak jenuh dan lemak trans yang dapat mempersempit rongga pembuluh darah.',
                          'Membatasi makanan dan minuman tinggi gula untuk mengontrol berat badan serta mencegah risiko diabetes.',
                          'Membatasi makanan tinggi garam (natrium maksimal 1 sendok teh atau 2.000 mg/hari) demi menjaga kestabilan tekanan darah.',
                          'Menghindari konsumsi camilan atau bumbu penyedap instan secara berlebihan.',
                        ],
                        primaryColor: const Color(0xFFD97706),
                        secondaryColor: const Color(0xFFF59E0B),
                        softBgColor: const Color(0xFFFFFBEB),
                        borderHighlightColor: const Color(0xFFFDE68A),
                        tagTextColor: const Color(0xFFB45309),
                      ),

                      const SizedBox(height: 14),

                      // MATERI C: Kurangi Makanan yang Kurang Sehat (Rose / Hindari)
                      _buildDetailCard(
                        label: 'C',
                        title: 'Kurangi Makanan yang Kurang Sehat',
                        categoryTag: 'Hindari / Kurangi',
                        icon: Icons.no_food_outlined,
                        summary:
                            'Beberapa jenis olahan makanan memicu peradangan pada pembuluh darah dan menaikkan kolesterol jahat dalam darah.',
                        points: const [
                          'Makanan yang digoreng (deep fried): Minyak goreng yang dipanaskan berulang kali menghasilkan lemak trans berbahaya.',
                          'Makanan tinggi lemak hewani: Daging merah berlemak tebal dan jeroan memicu penumpukan plak koroner.',
                          'Makanan bersantan kental: Masakan santan yang dihangatkan berulang dapat meningkatkan kadar kolesterol darah.',
                          'Makanan siap saji & olahan (ultra-processed): Mengandung kadar garam, pengawet, dan lemak tersembunyi yang tinggi.',
                        ],
                        primaryColor: const Color(0xFFE11D48),
                        secondaryColor: const Color(0xFFF43F5E),
                        softBgColor: const Color(0xFFFFF1F2),
                        borderHighlightColor: const Color(0xFFFECDD3),
                        tagTextColor: const Color(0xFFBE123C),
                      ),

                      const SizedBox(height: 14),

                      // MATERI D: Atur Waktu Makan (Teal / Rutin Seimbang)
                      _buildDetailCard(
                        label: 'D',
                        title: 'Atur Waktu Makan',
                        categoryTag: 'Kebiasaan Rutin',
                        icon: Icons.access_time_rounded,
                        summary:
                            'Jadwal makan yang tertata baik menjaga ritme metabolisme tubuh dan stabilitas energi jantung secara teratur.',
                        points: const [
                          'Menjaga waktu makan tetap teratur setiap hari (sarapan, makan siang, dan makan malam).',
                          'Tidak membiasakan makan dengan waktu yang tidak teratur atau sering melewatkan jam makan utama.',
                          'Menjaga pola makan secara konsisten agar tubuh tidak mengalami stres metabolisme.',
                          'Memberi jeda minimal 2-3 jam antara makan malam dan waktu tidur agar lambung tidak tertekan.',
                        ],
                        primaryColor: const Color(0xFF0089A5),
                        secondaryColor: const Color(0xFF0284C7),
                        softBgColor: const Color(0xFFE0F4FB),
                        borderHighlightColor: const Color(0xFFD2EDF5),
                        tagTextColor: const Color(0xFF00758F),
                      ),

                      const SizedBox(height: 20),

                      // CATATAN KHUSUS EDUKASI MEDIS
                      _buildMedicalNoteBox(
                        'Pola makan merupakan pilar utama kestabilan tekanan darah dan kolesterol. Selalu diskusikan rencana diet Anda bila memiliki kondisi penyerta seperti diabetes atau penyakit ginjal.',
                        primaryColor: const Color(0xFF059669),
                        softBgColor: const Color(0xFFECFDF5),
                        borderColor: const Color(0xFFA7F3D0),
                      ),

                      const SizedBox(height: 24),

                      // TOMBOL KEMBALI
                      _buildBackButtonBottom(
                        context,
                        gradientColors: const [Color(0xFF059669), Color(0xFF10B981)],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. DETAIL PAGE: AKTIVITAS FISIK
// ============================================================================
class AktivitasFisikPage extends StatelessWidget {
  const AktivitasFisikPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFC8E6FB), // Soft azure sky
            Color(0xFFE0F0FE),
            Color(0xFFF4F9FF),
            Color(0xFFFFFFFF),
          ],
          stops: [0.0, 0.25, 0.65, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // HEADER BAR
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                child: Row(
                  children: [
                    EducationPage.buildBackButton(context),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aktivitas Fisik',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Panduan aktivitas gerak aman bagi penderita jantung',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BANNER RINGKASAN (Ocean Azure & Royal Blue)
                      _buildOverviewCard(
                        icon: Icons.directions_walk_rounded,
                        title: 'Aktivitas Fisik Aman & Terukur',
                        tag: 'Kebugaran Jantung',
                        readDuration: '3 Menit Baca',
                        description:
                            'Aktivitas fisik sangat bermanfaat menjaga kekuatan pompa jantung dan kebugaran tubuh, asalkan dilakukan secara sederhana, bertahap, dan disesuaikan dengan kapasitas tubuh masing-masing.',
                        gradientColors: const [
                          Color(0xFF0369A1),
                          Color(0xFF0284C7),
                          Color(0xFF2563EB),
                        ],
                        iconColor: const Color(0xFF0284C7),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Pilihan Bentuk Aktivitas',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // MATERI A: Jalan Kaki (Ocean Azure)
                      _buildDetailCard(
                        label: 'A',
                        title: 'Jalan Kaki',
                        categoryTag: 'Aktivitas Dasar',
                        icon: Icons.directions_walk_rounded,
                        summary:
                            'Salah satu aktivitas fisik terbaik, minim risiko cedera, serta sangat mudah dilakukan untuk menjaga kelancaran aliran darah.',
                        points: const [
                          'Dilakukan secara bertahap mulai dari 10-15 menit per hari dengan langkah santai di lintasan yang rata.',
                          'Dapat ditingkatkan secara perlahan hingga 20-30 menit jika tidak ada keluhan sesak napas atau lelah berlebih.',
                          'Dianjurkan berjalan santai di waktu pagi atau sore hari saat suhu lingkungan sejuk dan segar.',
                          'Gunakan alas kaki yang nyaman dan tetap terhidrasi dengan air putih secukupnya.',
                        ],
                        primaryColor: const Color(0xFF0284C7),
                        secondaryColor: const Color(0xFF2563EB),
                        softBgColor: const Color(0xFFEFF6FF),
                        borderHighlightColor: const Color(0xFFBFDBFE),
                        tagTextColor: const Color(0xFF1D4ED8),
                      ),

                      const SizedBox(height: 14),

                      // MATERI B: Latihan Pernapasan (Fresh Teal / Cyan)
                      _buildDetailCard(
                        label: 'B',
                        title: 'Latihan Pernapasan',
                        categoryTag: 'Relaksasi Jantung',
                        icon: Icons.air_rounded,
                        summary:
                            'Latihan pernapasan dalam (deep breathing) yang tenang dan teratur membantu menstabilkan detak jantung serta meredakan ketegangan tubuh.',
                        points: const [
                          'Duduk dalam posisi tegak dan rileks di kursi yang nyaman, letakkan tangan di perut.',
                          'Tarik napas perlahan melalui hidung selama 3-4 detik hingga rongga dada dan perut mengembang.',
                          'Hembuskan napas perlahan melalui mulut secara tenang selama 4-6 detik.',
                          'Lakukan secara teratur 5-10 menit setiap hari atau saat merasa cemas dan tegang.',
                        ],
                        primaryColor: const Color(0xFF0D9488),
                        secondaryColor: const Color(0xFF14B8A6),
                        softBgColor: const Color(0xFFF0FDFA),
                        borderHighlightColor: const Color(0xFF99F6E4),
                        tagTextColor: const Color(0xFF0F766E),
                      ),

                      const SizedBox(height: 14),

                      // MATERI C: Mobilisasi Bertahap (Indigo / Gerak Terarah)
                      _buildDetailCard(
                        label: 'C',
                        title: 'Mobilisasi Bertahap',
                        categoryTag: 'Penyesuaian Gerak',
                        icon: Icons.accessibility_new_rounded,
                        summary:
                            'Gerak tubuh yang ditingkatkan secara bertingkat agar otot jantung beradaptasi dengan baik tanpa mengalami beban mendadak.',
                        points: const [
                          'Dimulai dari peregangan ringan sendi pergelangan tangan, kaki, dan leher saat duduk atau berbaring.',
                          'Lanjutkan dengan aktivitas berpindah posisi (duduk ke berdiri) secara perlahan untuk mencegah pusing.',
                          'Lakukan tugas harian ringan di rumah secara bertahap tanpa mengangkat beban berat.',
                          'Selalu beristirahat sejenak di antara aktivitas jika napas mulai terasa berat.',
                        ],
                        primaryColor: const Color(0xFF4F46E5),
                        secondaryColor: const Color(0xFF6366F1),
                        softBgColor: const Color(0xFFEEF2FF),
                        borderHighlightColor: const Color(0xFFC7D2FE),
                        tagTextColor: const Color(0xFF3730A3),
                      ),

                      const SizedBox(height: 14),

                      // MATERI D: Aktivitas Aerobik (Vibrant Azure)
                      _buildDetailCard(
                        label: 'D',
                        title: 'Aktivitas Aerobik',
                        categoryTag: 'Kebugaran Terukur',
                        icon: Icons.fitness_center_rounded,
                        summary:
                            'Latihan aerobik intensitas rendah hingga sedang membantu melatih efisiensi kerja otot jantung dan kapasitas paru.',
                        points: const [
                          'Pilihan aktivitas meliputi senam jantung ringan, bersepeda statis tanpa beban berat, atau jalan santai teratur.',
                          'Menyesuaikan intensitas latihan dengan kemampuan fisik (gunakan prinsip "Talk Test": masih dapat berbicara nyaman tanpa tersengal-sengal).',
                          'Awali selalu dengan pemanasan 5 menit dan akhiri dengan pendinginan 5 menit.',
                          'Hindari olahraga kompetitif atau latihan yang menahan napas (manuver valsalva).',
                        ],
                        primaryColor: const Color(0xFF0284C7),
                        secondaryColor: const Color(0xFF2563EB),
                        softBgColor: const Color(0xFFEFF6FF),
                        borderHighlightColor: const Color(0xFFBFDBFE),
                        tagTextColor: const Color(0xFF1D4ED8),
                      ),

                      const SizedBox(height: 18),

                      // CATATAN KHUSUS TENAGA KESEHATAN
                      _buildMedicalNoteBox(
                        'PENTING: Orang dengan penyakit jantung perlu menyesuaikan intensitas dan durasi aktivitas fisik dengan kondisi masing-masing serta selalu mengikuti rekomendasi dokter atau fisioterapis yang merawat.',
                        primaryColor: const Color(0xFF0284C7),
                        softBgColor: const Color(0xFFEFF6FF),
                        borderColor: const Color(0xFFBFDBFE),
                      ),

                      const SizedBox(height: 24),

                      // TOMBOL KEMBALI
                      _buildBackButtonBottom(
                        context,
                        gradientColors: const [Color(0xFF0284C7), Color(0xFF2563EB)],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 3. DETAIL PAGE: KEBIASAAN SEHAT
// ============================================================================
class KebiasaanSehatPage extends StatelessWidget {
  const KebiasaanSehatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE9D8FD), // Soft serene lavender
            Color(0xFFF3E8FF),
            Color(0xFFFAF5FF),
            Color(0xFFFFFFFF),
          ],
          stops: [0.0, 0.25, 0.65, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // HEADER BAR
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                child: Row(
                  children: [
                    EducationPage.buildBackButton(context),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kebiasaan Sehat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pola hidup sehari-hari untuk menjaga kondisi jantung',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BANNER RINGKASAN (Royal Violet & Purple)
                      _buildOverviewCard(
                        icon: Icons.spa_rounded,
                        title: 'Kebiasaan Baik Setiap Hari',
                        tag: 'Gaya Hidup & Relaksasi',
                        readDuration: '4 Menit Baca',
                        description:
                            'Membahas kebiasaan sehari-hari yang dapat membantu menjaga kondisi jantung tetap stabil, seperti menjaga pola istirahat, menghindari rokok, mengelola stres, dan mengikuti perawatan medis yang dianjurkan.',
                        gradientColors: const [
                          Color(0xFF6D28D9),
                          Color(0xFF7C3AED),
                          Color(0xFF9333EA),
                        ],
                        iconColor: const Color(0xFF7C3AED),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Pilar Kebiasaan Sehat',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // MATERI A: Hindari Rokok (Crimson Rose / Larangan Keras)
                      _buildDetailCard(
                        label: 'A',
                        title: 'Hindari Rokok',
                        categoryTag: 'Wajib Dihindari',
                        icon: Icons.smoke_free_rounded,
                        summary:
                            'Menghindari kebiasaan merokok dan paparan asap rokok adalah langkah paling efektif untuk mencegah kerusakan pembuluh darah koroner.',
                        points: const [
                          'Zat beracun dan nikotin dalam rokok merusak dinding arteri dan mempercepat penumpukan plak aterosklerosis.',
                          'Merokok menyempitkan pembuluh darah, menaikkan denyut nadi, serta menurunkan kadar oksigen yang dibawa ke otot jantung.',
                          'Hindari pula paparan sebagai perokok pasif karena memiliki dampak bahaya yang sama tingginya.',
                          'Berhenti merokok memberikan dampak perbaikan sirkulasi darah jantung secara signifikan dalam waktu singkat.',
                        ],
                        primaryColor: const Color(0xFFE11D48),
                        secondaryColor: const Color(0xFFF43F5E),
                        softBgColor: const Color(0xFFFFF1F2),
                        borderHighlightColor: const Color(0xFFFECDD3),
                        tagTextColor: const Color(0xFFBE123C),
                      ),

                      const SizedBox(height: 14),

                      // MATERI B: Istirahat yang Cukup (Royal Violet / Pemulihan Tidur)
                      _buildDetailCard(
                        label: 'B',
                        title: 'Istirahat yang Cukup',
                        categoryTag: 'Pemulihan Organ',
                        icon: Icons.bedtime_rounded,
                        summary:
                            'Waktu tidur yang berkualitas dan cukup memberi kesempatan bagi organ jantung untuk beristirahat dan menstabilkan tekanan darah.',
                        points: const [
                          'Menjaga kecukupan waktu istirahat dan tidur berkualitas selama 7-8 jam setiap malam.',
                          'Menjaga jam tidur dan bangun secara teratur setiap hari untuk keselarasan ritme sirkadian tubuh.',
                          'Kurang tidur kronis terbukti meningkatkan hormon stres dan memicu kenaikan tekanan darah tinggi.',
                          'Ciptakan suasana kamar tidur yang tenang, sejuk, dan hindari paparan layar gawai menjelang tidur.',
                        ],
                        primaryColor: const Color(0xFF7C3AED),
                        secondaryColor: const Color(0xFF8B5CF6),
                        softBgColor: const Color(0xFFF5F3FF),
                        borderHighlightColor: const Color(0xFFDDD6FE),
                        tagTextColor: const Color(0xFF6D28D9),
                      ),

                      const SizedBox(height: 14),

                      // MATERI C: Kelola Stres (Warm Amber / Ketenangan Emosi)
                      _buildDetailCard(
                        label: 'C',
                        title: 'Kelola Stres',
                        categoryTag: 'Kesehatan Emosional',
                        icon: Icons.self_improvement_rounded,
                        summary:
                            'Kondisi emosional yang terkendali melindungi jantung dari lonjakan hormon adrenalin dan kortisol yang memicu hipertensi.',
                        points: const [
                          'Mengenali pemicu stres harian dan meluangkan waktu untuk relaksasi, ibadah, meditasi, atau hobi santai.',
                          'Membiasakan berbincang dan berbagi cerita dengan keluarga atau sahabat saat menghadapi rasa cemas.',
                          'Mengatur ritme kerja dan beban pikiran agar tidak mengalami kelelahan mental yang berlebihan.',
                          'Menjaga pikiran positif dan menghindari reaksi kemarahan mendadak yang membebani kinerja pompa jantung.',
                        ],
                        primaryColor: const Color(0xFFD97706),
                        secondaryColor: const Color(0xFFF59E0B),
                        softBgColor: const Color(0xFFFFFBEB),
                        borderHighlightColor: const Color(0xFFFDE68A),
                        tagTextColor: const Color(0xFFB45309),
                      ),

                      const SizedBox(height: 14),

                      // MATERI D: Ikuti Perawatan (Teal / Kepatuhan Terapi)
                      _buildDetailCard(
                        label: 'D',
                        title: 'Ikuti Perawatan',
                        categoryTag: 'Kepatuhan Medis',
                        icon: Icons.medical_services_rounded,
                        summary:
                            'Kepatuhan terhadap rencana terapi dokter dan pemeriksaan berkala adalah jaminan terbaik untuk kestabilan kesehatan jantung.',
                        points: const [
                          'Meminum obat-obatan yang diresepkan oleh dokter secara teratur sesuai dosis dan jadwal yang telah ditentukan.',
                          'Melakukan kontrol atau pemeriksaan kesehatan berkala sesuai anjuran untuk memantau fungsi jantung.',
                          'Memantau parameter penting seperti tekanan darah dan denyut nadi secara mandiri di rumah jika dianjurkan.',
                          'Segera berkonsultasi kembali kepada dokter jika merasakan perubahan kondisi atau gejala baru yang mengganggu.',
                        ],
                        primaryColor: const Color(0xFF0089A5),
                        secondaryColor: const Color(0xFF0284C7),
                        softBgColor: const Color(0xFFE0F4FB),
                        borderHighlightColor: const Color(0xFFD2EDF5),
                        tagTextColor: const Color(0xFF00758F),
                      ),

                      const SizedBox(height: 20),

                      // CATATAN KHUSUS
                      _buildMedicalNoteBox(
                        'Kepatuhan terhadap pengobatan dan rutinitas kontrol kesehatan merupakan kunci utama mencegah komplikasi penyakit jantung. Jangan menghentikan atau mengubah dosis obat tanpa anjuran dokter.',
                        primaryColor: const Color(0xFF7C3AED),
                        softBgColor: const Color(0xFFF5F3FF),
                        borderColor: const Color(0xFFDDD6FE),
                      ),

                      const SizedBox(height: 24),

                      // TOMBOL KEMBALI
                      _buildBackButtonBottom(
                        context,
                        gradientColors: const [Color(0xFF7C3AED), Color(0xFF9333EA)],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SHARED HELPER WIDGETS DETAIL PAGES (Harmonious, Premium, Clean)
// ============================================================================

Widget _buildOverviewCard({
  required IconData icon,
  required String title,
  required String tag,
  required String readDuration,
  required String description,
  List<Color> gradientColors = const [
    Color(0xFF0089A5),
    Color(0xFF0098B9),
    Color(0xFF0284C7),
  ],
  Color iconColor = const Color(0xFF0089A5),
}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: gradientColors[0].withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned(
          right: -20,
          top: -20,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ),
        Positioned(
          right: 30,
          bottom: -30,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              readDuration,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.94),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDetailCard({
  required String label,
  required String title,
  required String categoryTag,
  required IconData icon,
  required String summary,
  required List<String> points,
  Color primaryColor = const Color(0xFF0089A5),
  Color secondaryColor = const Color(0xFF0284C7),
  Color softBgColor = const Color(0xFFE0F4FB),
  Color borderHighlightColor = const Color(0xFFD2EDF5),
  Color tagTextColor = const Color(0xFF00758F),
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: borderHighlightColor.withValues(alpha: 0.7),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.06),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.22),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: softBgColor.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: borderHighlightColor,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'Poin $label',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: softBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          categoryTag,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: tagTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Box Ringkasan yang rapi dan halus
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: softBgColor.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderHighlightColor.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Text(
            summary,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF334155),
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 1,
          color: const Color(0xFFF1F5F9),
        ),
        const SizedBox(height: 12),
        ...points.map((point) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: softBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ),
  );
}

Widget _buildMedicalNoteBox(
  String content, {
  Color primaryColor = const Color(0xFF0098B9),
  Color softBgColor = const Color(0xFFE0F4FB),
  Color borderColor = const Color(0xFFCCE8F0),
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: borderColor,
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: softBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.health_and_safety_rounded,
            color: primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CATATAN TIM MEDIS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.45,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildBackButtonBottom(
  BuildContext context, {
  List<Color> gradientColors = const [Color(0xFF0089A5), Color(0xFF0284C7)],
}) {
  return Container(
    width: double.infinity,
    height: 48,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: gradientColors[0].withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(14),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back_rounded,
                size: 19,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Kembali ke Edukasi Kesehatan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
