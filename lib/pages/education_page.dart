import 'package:flutter/material.dart';
import 'package:heartcare/services/theme_service.dart';
import 'dokter_page.dart';

// ============================================================================
// MODEL UNTUK FAKTA STATISTIK CEPAT
// ============================================================================
class _StatFact {
  final String value;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatFact({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

// ============================================================================
// MODEL UNTUK MITOS VS FAKTA JANTUNG
// ============================================================================
class _HeartMyth {
  final String myth;
  final String fact;
  final String explanation;
  final String source;

  const _HeartMyth({
    required this.myth,
    required this.fact,
    required this.explanation,
    required this.source,
  });
}

// ============================================================================
// HALAMAN UTAMA: EDUKASI KESEHATAN
// ============================================================================
class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  static const Color primaryTeal = Color(0xFF0098B9);
  static const Color primaryBlue = Color(0xFF0284C7);
  static const Color darkSlate = Color(0xFF0F172A);
  static const Color subSlate = Color(0xFF475569);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color cardBorder = Color(0xFFE2E8F0);

  // Gradient background selaras dengan halaman utama lainnya (Home, Riwayat, Pengingat)
  static LinearGradient pageGradient(bool isDark) {
    return LinearGradient(
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
    );
  }

  // Notifier bersama untuk melacak topik yang sudah dipelajari
  static final ValueNotifier<Set<String>> completedTopicsNotifier =
      ValueNotifier<Set<String>>({});

  static Widget _buildBackButton(BuildContext context, {bool isDark = false}) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
    );
  }

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;
  int _currentTipIndex = 0;
  int _currentMythIndex = 0;

  final List<String> _categories = const [
    'Semua',
    'Nutrisi',
    'Aktivitas',
    'Gaya Hidup',
    'Mitos & Fakta',
  ];

  final List<String> _dailyTips = const [
    'Beri jeda minimal 2-3 jam antara makan malam dan waktu tidur agar lambung tidak tertekan dan kerja jantung tetap stabil.',
    'Jalan santai 15-30 menit per hari secara rutin dapat melancarkan aliran darah dan menjaga elastisitas pembuluh darah.',
    'Batasi natrium/garam maksimal 1 sendok teh (2.000 mg) per hari demi menjaga kestabilan tekanan darah arteri Anda.',
    'Latihan pernapasan dalam (tarik 4 detik, hembus 6 detik) terbukti membantu meredakan ketegangan dan menstabilkan irama jantung.',
    'Tidur cukup 7-8 jam tiap malam memberi kesempatan bagi organ vital dan pembuluh darah untuk beristirahat optimal.',
  ];

  final List<_StatFact> _facts = const [
    _StatFact(
      value: '100.000x',
      label: 'Detak / Hari',
      subtitle: 'Memompa ~7.500 liter darah',
      icon: Icons.monitor_heart_rounded,
      color: Color(0xFFE11D48),
      bgColor: Color(0xFFFFE4E6),
    ),
    _StatFact(
      value: '< 2.000 mg',
      label: 'Batas Garam',
      subtitle: 'Maks. 1 sdt natrium harian',
      icon: Icons.tune_rounded,
      color: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
    ),
    _StatFact(
      value: '15 - 30 Mnt',
      label: 'Aktivitas Fisik',
      subtitle: 'Jalan santai rutin harian',
      icon: Icons.directions_walk_rounded,
      color: Color(0xFF0284C7),
      bgColor: Color(0xFFE0F2FE),
    ),
    _StatFact(
      value: '7 - 8 Jam',
      label: 'Tidur Cukup',
      subtitle: 'Pemulihan organ vital',
      icon: Icons.bedtime_rounded,
      color: Color(0xFF7C3AED),
      bgColor: Color(0xFFF5F3FF),
    ),
  ];

  final List<_HeartMyth> _myths = const [
    _HeartMyth(
      myth: 'Mandi malam hari dapat memicu rematik dan serangan jantung mendadak.',
      fact: 'Mandi malam tidak menyebabkan penyakit jantung atau rematik.',
      explanation:
          'Suhu air yang terlalu dingin hanya memicu respon penyempitan pembuluh darah (vasokonstriksi) sementara. Gunakan air bersuhu suam-kuku bila Anda memiliki riwayat hipertensi atau penyakit jantung koroner.',
      source: 'PERKI & Kemenkes RI',
    ),
    _HeartMyth(
      myth: 'Penyakit jantung koroner hanya menyerang orang lanjut usia di atas 60 tahun.',
      fact: 'Penyakit jantung koroner kini semakin banyak dialami pada usia 25–40 tahun.',
      explanation:
          'Gaya hidup kurang gerak, konsumsi junk-food tinggi lemak trans, kebiasaan merokok/vape, serta stres kerja berkepanjangan memicu aterosklerosis lebih dini.',
      source: 'AHA Circulation',
    ),
    _HeartMyth(
      myth: 'Orang yang memiliki riwayat sakit jantung harus istirahat total dan tidak boleh berolahraga.',
      fact: 'Aktivitas fisik terukur justru memperkuat pompa jantung dan mempercepat pemulihan.',
      explanation:
          'Latihan aerobik intensitas ringan-sedang seperti jalan santai teratur sangat dianjurkan dalam protokol rehabilitasi kardiovaskular resmi.',
      source: 'ESC Clinical Guidelines',
    ),
    _HeartMyth(
      myth: 'Obat jantung hanya perlu diminum ketika dada terasa nyeri atau sesak napas.',
      fact: 'Obat kardiovaskular harus dikonsumsi rutin sesuai dosis dan resep dokter spesialis.',
      explanation:
          'Obat pengontrol tekanan darah dan pencegah bekuan darah bekerja menjaga perlindungan jangka panjang pembuluh darah dari risiko serangan jantung dan stroke.',
      source: 'AHA Heart Association',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _nextTip() {
    setState(() {
      _currentTipIndex = (_currentTipIndex + 1) % _dailyTips.length;
    });
  }

  void _nextMyth() {
    setState(() {
      _currentMythIndex = (_currentMythIndex + 1) % _myths.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: EducationPage.pageGradient(isDark),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // 1. TOP BAR DENGAN BADGE KLINIS & INFO
                  _buildTopBar(context, isDark: isDark),

                  // 2. SEARCH BAR MODERN
                  _buildSearchBar(isDark: isDark),

                  // 3. HORIZONTAL CATEGORY FILTER PILLS
                  _buildCategoryChips(isDark: isDark),

                  const SizedBox(height: 8),

                  // 4. KONTEN EDUKASI SCROLLABLE
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),
                      child: _searchQuery.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.search_rounded,
                                      size: 16,
                                      color: Color(0xFF0284C7),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Hasil pencarian "$_searchQuery"',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : EducationPage.darkSlate,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ..._buildFilteredTopicCards(
                                  context,
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 24),
                              ],
                            )
                          : _buildCategoryView(context, isDark: isDark),
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

  Widget _buildCategoryView(BuildContext context, {required bool isDark}) {
    if (_selectedCategoryIndex == 1) {
      // NUTRISI
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeaturedSpotlight(context, isDark: isDark),
          const SizedBox(height: 20),
          _buildSectionHeader(
            title: 'Modul Nutrisi Jantung',
            subtitle: 'Pedoman gizi klinis, pembatasan garam, dan pemilihan lemak baik',
            countBadge: '1 Modul',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          ..._buildFilteredTopicCards(context, isDark: isDark),
          const SizedBox(height: 20),
          _buildMedicalConsultationBanner(context, isDark: isDark),
          const SizedBox(height: 24),
        ],
      );
    } else if (_selectedCategoryIndex == 2) {
      // AKTIVITAS
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Modul Aktivitas Fisik',
            subtitle: 'Panduan latihan aerobik aman dan mobilisasi bertahap',
            countBadge: '1 Modul',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          ..._buildFilteredTopicCards(context, isDark: isDark),
          const SizedBox(height: 18),
          _buildQuickFactsSection(isDark),
          const SizedBox(height: 20),
          _buildMedicalConsultationBanner(context, isDark: isDark),
          const SizedBox(height: 24),
        ],
      );
    } else if (_selectedCategoryIndex == 3) {
      // GAYA HIDUP
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Modul Gaya Hidup Sehat',
            subtitle: 'Regenerasi tidur, manajemen stres, dan berhenti merokok',
            countBadge: '1 Modul',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          ..._buildFilteredTopicCards(context, isDark: isDark),
          const SizedBox(height: 18),
          _buildDailyTipCard(isDark),
          const SizedBox(height: 20),
          _buildMedicalConsultationBanner(context, isDark: isDark),
          const SizedBox(height: 24),
        ],
      );
    } else if (_selectedCategoryIndex == 4) {
      // MITOS & FAKTA
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Mitos vs Fakta Jantung',
            subtitle: 'Koreksi fakta medis seputar kesehatan kardiovaskular',
            countBadge: 'Klinis',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildMythVsFactCard(isDark),
          const SizedBox(height: 18),
          _buildDailyTipCard(isDark),
          const SizedBox(height: 20),
          _buildMedicalConsultationBanner(context, isDark: isDark),
          const SizedBox(height: 24),
        ],
      );
    }

    // SEMUA (DEFAULT TAB 0)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Spotlight Feature Article Card
        _buildFeaturedSpotlight(context, isDark: isDark),
        const SizedBox(height: 16),

        // Learning Tracker Bar
        _buildLearningTracker(isDark),
        const SizedBox(height: 18),

        // Interactive Myth vs Fact Card
        _buildMythVsFactCard(isDark),
        const SizedBox(height: 22),

        // Section: Main Modules
        _buildSectionHeader(
          title: 'Modul Pembelajaran Mandiri',
          subtitle: 'Kurikulum komprehensif panduan gaya hidup jantung',
          countBadge: '3 Modul',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        ..._buildFilteredTopicCards(context, isDark: isDark),
        const SizedBox(height: 18),

        // Section: Quick Facts & Targets
        _buildSectionHeader(
          title: 'Sasaran Kardiovaskular Harian',
          subtitle: 'Pedoman acuan batas aman klinis resmi',
          countBadge: 'PERKI / AHA',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildQuickFactsSection(isDark),
        const SizedBox(height: 18),

        // Daily Specialist Tip
        _buildDailyTipCard(isDark),
        const SizedBox(height: 20),

        // Doctor Consultation Banner (Avatar Stack)
        _buildMedicalConsultationBanner(context, isDark: isDark),
        const SizedBox(height: 16),

        // Medical Disclaimer
        _buildDisclaimerCard(context, isDark: isDark),
        const SizedBox(height: 26),
      ],
    );
  }


  // ==========================================================================
  // WIDGET-WIDGET KOMPONEN
  // ==========================================================================
  Widget _buildTopBar(BuildContext context, {required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 12, bottom: 8),
      child: Row(
        children: [
          EducationPage._buildBackButton(context, isDark: isDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Pusat Edukasi Jantung',
                      style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : EducationPage.darkSlate,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF86EFAC),
                          width: 0.8,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 11,
                            color: Color(0xFF16A34A),
                          ),
                          SizedBox(width: 2),
                          Text(
                            'KLINIS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16A34A),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Ditinjau oleh Tim Kardiologi HeartCare',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : EducationPage.subSlate,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildInfoButton(context, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildInfoButton(BuildContext context, {required bool isDark}) {
    return InkWell(
      onTap: () => _showMedicalSourcesDialog(context, isDark),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.info_outline_rounded,
            size: 19,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar({required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _searchQuery = val.trim().toLowerCase();
            });
          },
          style: TextStyle(
            fontSize: 12.5,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: 'Cari panduan nutrisi, garam, olahraga...',
            hintStyle: TextStyle(
              fontSize: 12,
              color: isDark
                  ? const Color(0xFF64748B)
                  : const Color(0xFF94A3B8),
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 19,
              color: Color(0xFF0284C7),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 17),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips({required bool isDark}) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          final title = _categories[index];

          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF0098B9)],
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0)),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF475569)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSpotlight(BuildContext context,
      {required bool isDark}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF16253B), Color(0xFF0B1B2B)]
              : const [Color(0xFF0284C7), Color(0xFF0369A1)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7)
                .withValues(alpha: isDark ? 0.2 : 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: Color(0xFFFDE68A),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'PANDUAN KLINIS PILIHAN',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '⏱ 5 Mnt Baca',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Diet Rendah Garam & Nutrisi Pembuluh Darah',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pedoman praktis menyusun menu makanan sehari-hari guna mengendalikan tensi darah dan mencegah penumpukan plak di arteri.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                              image: const DecorationImage(
                                image: AssetImage(
                                    'assets/images/dokter_nurlitta.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'dr. Nurlitta, Sp.JP',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Spesialis Jantung & Pembuluh',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PolaMakanSehatPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0284C7),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Pelajari',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(Icons.arrow_forward_rounded, size: 13),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningTracker(bool isDark) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: EducationPage.completedTopicsNotifier,
      builder: (context, completed, _) {
        const total = 3;
        final count = completed.length.clamp(0, total);
        final percent = count / total;
        final isAllCompleted = count == total;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
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
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 16,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Belajar Mandiri',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : EducationPage.darkSlate,
                            ),
                          ),
                          Text(
                            '$count dari $total Topik Selesai',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : EducationPage.subSlate,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isAllCompleted
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(percent * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isAllCompleted
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isAllCompleted
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF0284C7),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isAllCompleted
                    ? '🎉 Selesai! Seluruh modul utama telah Anda pelajari.'
                    : 'Buka modul di bawah ini dan tekan tombol selesai setelah membaca.',
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required String countBadge,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.5,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : EducationPage.darkSlate,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155).withValues(alpha: 0.5)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFE2E8F0),
                  width: 0.8,
                ),
              ),
              child: Text(
                countBadge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 11),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMythVsFactCard(bool isDark) {
    final myth = _myths[_currentMythIndex];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFFD97706).withValues(alpha: 0.35)
              : const Color(0xFFFDE68A),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706)
                .withValues(alpha: isDark ? 0.12 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.psychology_alt_rounded,
                        size: 15,
                        color: Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mitos vs Fakta Jantung',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? const Color(0xFFFCD34D)
                            : const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    myth.source,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // MITOS BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF3B151E)
                    : const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFFE11D48).withValues(alpha: 0.3)
                      : const Color(0xFFFECDD3),
                  width: 0.9,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'MITOS',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      myth.myth,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFFECDD3)
                            : const Color(0xFF9F1239),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // FAKTA BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0E2A1E)
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF16A34A).withValues(alpha: 0.3)
                      : const Color(0xFFBBF7D0),
                  width: 0.9,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'FAKTA MEDIS',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          myth.fact,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFBBF7D0)
                                : const Color(0xFF166534),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    myth.explanation,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFF86EFAC).withValues(alpha: 0.9)
                          : const Color(0xFF14532D),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Topik ${_currentMythIndex + 1} dari ${_myths.length}',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                InkWell(
                  onTap: _nextMyth,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    child: Row(
                      children: [
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 15,
                          color: isDark
                              ? const Color(0xFFFCD34D)
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Mitos Berikutnya',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFFCD34D)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ],
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

  Widget _buildQuickFactsSection(bool isDark) {
    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _facts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final fact = _facts[index];
          return Container(
            width: 142,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? fact.color.withValues(alpha: 0.3)
                    : fact.color.withValues(alpha: 0.2),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: fact.color.withValues(alpha: isDark ? 0.08 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? fact.color.withValues(alpha: 0.2)
                            : fact.bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(fact.icon, size: 14, color: fact.color),
                    ),
                    Text(
                      fact.label,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fact.value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: fact.color,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      fact.subtitle,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyTipCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.format_quote_rounded,
                      size: 16,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kiat Jantung Hari Ini',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : EducationPage.darkSlate,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _nextTip,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        size: 13,
                        color: Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        'Ganti Kiat',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            '"${_dailyTips[_currentTipIndex]}"',
            style: TextStyle(
              fontSize: 11.8,
              height: 1.45,
              fontStyle: FontStyle.italic,
              color: isDark
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
  List<Widget> _buildFilteredTopicCards(BuildContext context,
      {required bool isDark}) {
    final allCards = [
      _TopicCardData(
        key: 'pola_makan',
        title: 'Pola Makan & Nutrisi Jantung',
        description:
            'Panduan gizi klinis, pembatasan garam dapur (natrium), pemilahan lemak sehat omega-3, serta jadwal makan yang ramah bagi elastisitas pembuluh darah.',
        tag: 'Nutrisi & Diet',
        icon: Icons.restaurant_rounded,
        accentColor: const Color(0xFF059669),
        lightBgColor: const Color(0xFFECFDF5),
        highlights: const [
          'Serat & Omega-3',
          'Batasi Garam',
          'Pola 3 Jam',
        ],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PolaMakanSehatPage(),
            ),
          );
        },
      ),
      _TopicCardData(
        key: 'aktivitas_fisik',
        title: 'Aktivitas Fisik & Latihan Mandiri',
        description:
            'Aktivitas aerobik yang aman, terukur, dan bertahap sesuai kemampuan jantung. Lengkap dengan latihan pernapasan dalam dan mobilisasi sendi.',
        tag: 'Latihan Fisik',
        icon: Icons.directions_walk_rounded,
        accentColor: const Color(0xFF0284C7),
        lightBgColor: const Color(0xFFE0F2FE),
        highlights: const [
          'Jalan Santai',
          'Latihan Napas',
          'Mobilisasi',
        ],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AktivitasFisikPage(),
            ),
          );
        },
      ),
      _TopicCardData(
        key: 'kebiasaan_sehat',
        title: 'Kebiasaan Sehat & Gaya Hidup',
        description:
            'Menjaga pola istirahat 7-8 jam per malam, berhenti merokok dan paparan nikotin, manajemen stres, serta kepatuhan minum obat secara tepat waktu.',
        tag: 'Gaya Hidup',
        icon: Icons.spa_rounded,
        accentColor: const Color(0xFF7C3AED),
        lightBgColor: const Color(0xFFF5F3FF),
        highlights: const [
          'Bebas Rokok',
          'Tidur 7-8 Jam',
          'Kelola Stres',
        ],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const KebiasaanSehatPage(),
            ),
          );
        },
      ),
    ];

    // Filter berdasarkan kategori tab
    List<_TopicCardData> categoryFiltered = allCards;
    if (_selectedCategoryIndex == 1) {
      categoryFiltered =
          allCards.where((c) => c.key == 'pola_makan').toList();
    } else if (_selectedCategoryIndex == 2) {
      categoryFiltered =
          allCards.where((c) => c.key == 'aktivitas_fisik').toList();
    } else if (_selectedCategoryIndex == 3) {
      categoryFiltered =
          allCards.where((c) => c.key == 'kebiasaan_sehat').toList();
    } else if (_selectedCategoryIndex == 4) {
      categoryFiltered = [];
    }

    // Filter berdasarkan pencarian
    final filtered = categoryFiltered.where((card) {
      if (_searchQuery.isEmpty) return true;
      final t = card.title.toLowerCase();
      final d = card.description.toLowerCase();
      final tg = card.tag.toLowerCase();
      final h = card.highlights.join(' ').toLowerCase();
      return t.contains(_searchQuery) ||
          d.contains(_searchQuery) ||
          tg.contains(_searchQuery) ||
          h.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 32,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Topik tidak ditemukan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : EducationPage.darkSlate,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Coba gunakan kata kunci lain seperti: garam, jalan, tidur, atau rokok.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedCategoryIndex = 0;
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 15),
                label: const Text('Reset Pencarian'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0284C7),
                  side: const BorderSide(color: Color(0xFF0284C7)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return filtered.map((data) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _buildMenuCard(
          context,
          topicKey: data.key,
          title: data.title,
          description: data.description,
          tag: data.tag,
          icon: data.icon,
          accentColor: data.accentColor,
          lightBgColor: data.lightBgColor,
          highlights: data.highlights,
          isDark: isDark,
          onTap: data.onTap,
        ),
      );
    }).toList();
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String topicKey,
    required String title,
    required String description,
    required String tag,
    required IconData icon,
    required Color accentColor,
    required Color lightBgColor,
    required List<String> highlights,
    required VoidCallback onTap,
    bool isDark = false,
  }) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: EducationPage.completedTopicsNotifier,
      builder: (context, completed, _) {
        final isCompleted = completed.contains(topicKey);

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF16A34A).withValues(alpha: 0.5)
                    : (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0)),
                width: isCompleted ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isCompleted
                      ? const Color(0xFF16A34A)
                          .withValues(alpha: isDark ? 0.12 : 0.05)
                      : Colors.black
                          .withValues(alpha: isDark ? 0.15 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER: Icon, Badges, Chevron
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? accentColor.withValues(alpha: 0.18)
                              : lightBgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Icon(icon, color: accentColor, size: 22),
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
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? accentColor.withValues(alpha: 0.18)
                                        : lightBgColor,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color:
                                          accentColor.withValues(alpha: 0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: accentColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (isCompleted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: const Color(0xFF86EFAC),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          size: 10,
                                          color: Color(0xFF16A34A),
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          'Selesai',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF16A34A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : EducationPage.darkSlate,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155).withValues(alpha: 0.5)
                              : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // HIGHLIGHT PILLS
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: highlights.map((h) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 4.5,
                              height: 4.5,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              h,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Buka Modul Lengkap',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 15,
                            color: accentColor,
                          ),
                        ],
                      ),
                      Text(
                        '4 Submateri • ~8 Mnt',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedicalConsultationBanner(BuildContext context,
      {required bool isDark}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0C2438), Color(0xFF1E293B)]
              : const [Color(0xFFE0F2FE), Color(0xFFEFF6FF)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF0284C7).withValues(alpha: 0.4)
              : const Color(0xFFBAE6FD),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Overlapping avatar stack
                SizedBox(
                  width: 72,
                  height: 36,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: const DecorationImage(
                              image: AssetImage(
                                  'assets/images/dokter_nurlitta.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: const DecorationImage(
                              image:
                                  AssetImage('assets/images/dokter_andi.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 36,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: const DecorationImage(
                              image:
                                  AssetImage('assets/images/dokter_rina.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'TIM MEDIS SIAGA',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Konsultasi Spesialis Jantung',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Diskusikan pola makan khusus, batasan aktivitas fisik, atau gejala kardiovaskular bersama dokter spesialis kardiologi kami.',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF475569),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PilihDokterPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.support_agent_rounded, size: 17),
                label: const Text(
                  'Pilih Dokter & Mulai Chat',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerCard(BuildContext context, {required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? const Color(0xFF059669).withValues(alpha: 0.3)
              : const Color(0xFFA7F3D0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  size: 17,
                  color: Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Materi edukasi HeartCare disusun mengacu pada protokol klinis resmi PERKI & American Heart Association (AHA). Tidak menggantikan diagnosis medis langsung.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _showMedicalSourcesDialog(context, isDark),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  'Lihat Sumber & Akreditasi Medis →',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFF34D399)
                        : const Color(0xFF059669),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMedicalSourcesDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 20,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Referensi & Akreditasi Medis',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : EducationPage.darkSlate,
                          ),
                        ),
                        Text(
                          'Standar pedoman klinis kardiovaskular resmi',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : EducationPage.subSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSourceItem(
                icon: Icons.local_hospital_rounded,
                title: 'PERKI (Perhimpunan Dokter Spesialis Kardiovaskular Indonesia)',
                detail: 'Panduan Praktik Klinis Penyakit Jantung Koroner & Hipertensi Arteri',
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildSourceItem(
                icon: Icons.health_and_safety_rounded,
                title: 'American Heart Association (AHA)',
                detail: 'Cardiovascular Health Guidelines & Dietary Recommendations',
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildSourceItem(
                icon: Icons.public_rounded,
                title: 'European Society of Cardiology (ESC)',
                detail: 'Guidelines on Cardiovascular Disease Prevention in Clinical Practice',
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildSourceItem(
                icon: Icons.verified_rounded,
                title: 'Kementerian Kesehatan RI (Kemenkes)',
                detail: 'Panduan Pola Hidup Sehat & Gizi Seimbang Penyakit Tidak Menular',
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Peringatan Medis: Konten dalam aplikasi bertujuan memperkaya literasi kesehatan mandiri. Selalu konsultasikan perubahan diet, dosis obat, atau program latihan Anda dengan dokter spesialis jantung.',
                        style: TextStyle(
                          fontSize: 10.5,
                          height: 1.4,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Saya Mengerti',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceItem({
    required IconData icon,
    required String title,
    required String detail,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFF0284C7).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: const Color(0xFF0284C7)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : EducationPage.darkSlate,
                ),
              ),
              Text(
                detail,
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : EducationPage.subSlate,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _TopicCardData {
  final String key;
  final String title;
  final String description;
  final String tag;
  final IconData icon;
  final Color accentColor;
  final Color lightBgColor;
  final List<String> highlights;
  final VoidCallback onTap;

  const _TopicCardData({
    required this.key,
    required this.title,
    required this.description,
    required this.tag,
    required this.icon,
    required this.accentColor,
    required this.lightBgColor,
    required this.highlights,
    required this.onTap,
  });
}

// ============================================================================
// 1. DETAIL PAGE: POLA MAKAN SEHAT (NUTRISI - EMERALD GREEN THEME)
// ============================================================================
class PolaMakanSehatPage extends StatelessWidget {
  const PolaMakanSehatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: EducationPage.pageGradient(isDark),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // HEADER BAR
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 12),
                    child: Row(
                      children: [
                        EducationPage._buildBackButton(context, isDark: isDark),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pola Makan Sehat',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Panduan makanan bergizi untuk kesehatan jantung',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
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
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // BANNER RINGKASAN (EMERALD GRADIENT)
                          _buildOverviewCard(
                            icon: Icons.restaurant_menu_rounded,
                            title: 'Pola Makan Bagi Pasien Jantung',
                            description:
                                'Membahas pola makan sehat untuk orang yang sudah memiliki penyakit jantung, berfokus pada pemilihan makanan alami berkualitas dan pembiasaan waktu makan yang mendukung kerja jantung.',
                            color: const Color(0xFF059669),
                            bgColor: const Color(0xFFECFDF5),
                            isDark: isDark,
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Materi Edukasi Nutrisi',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),

                        // MATERI A: Perbanyak Makanan Sehat (Fresh Emerald Green)
                        _buildDetailCard(
                          label: 'A',
                          title: 'Perbanyak Makanan Sehat',
                          tag: 'Direkomendasikan',
                          tagColor: const Color(0xFF059669),
                          tagBgColor: const Color(0xFFECFDF5),
                          icon: Icons.eco_rounded,
                          iconColor: const Color(0xFF059669),
                          iconBgColor: const Color(0xFFECFDF5),
                          summary:
                              'Penuhi kebutuhan harian dengan makanan segar kaya serat, antioksidan, dan lemak baik yang menjaga elastisitas pembuluh darah.',
                          points: const [
                            'Memperbanyak buah dan sayuran segar aneka warna sebagai sumber serat larut dan vitamin.',
                            'Memilih ikan berlemak sehat kaya asam lemak Omega-3 (seperti salmon, kembung, tuna, tongkol).',
                            'Memilih kacang-kacangan dan biji-bijian utuh (seperti oatmeal, kedelai, kacang almond) untuk menekan kolesterol LDL.',
                            'Menjaga menu makanan tetap beragam dan seimbang agar kebutuhan nutrisi harian tercukupi.',
                          ],
                          isDark: isDark,
                        ),

                        const SizedBox(height: 14),

                        // MATERI B: Batasi Lemak, Gula, dan Garam (Warm Amber)
                        _buildDetailCard(
                          label: 'B',
                          title: 'Batasi Lemak, Gula, dan Garam',
                          tag: 'Perlu Dibatasi',
                          tagColor: const Color(0xFFD97706),
                          tagBgColor: const Color(0xFFFEF3C7),
                          icon: Icons.tune_rounded,
                          iconColor: const Color(0xFFD97706),
                          iconBgColor: const Color(0xFFFEF3C7),
                          summary:
                              'Konsumsi lemak jenuh, gula, dan natrium berlebih berpotensi menaikkan tekanan darah serta memperberat beban pompa jantung.',
                          points: const [
                            'Membatasi makanan tinggi lemak jenuh dan lemak trans yang dapat mempersempit rongga pembuluh darah.',
                            'Membatasi makanan dan minuman tinggi gula untuk mengontrol berat badan serta mencegah risiko diabetes.',
                            'Membatasi makanan tinggi garam (natrium maksimal 1 sendok teh atau 2.000 mg/hari) demi menjaga kestabilan tekanan darah.',
                            'Menghindari konsumsi camilan atau bumbu penyedap instan secara berlebihan.',
                          ],
                          isDark: isDark,
                        ),

                        const SizedBox(height: 14),

                        // MATERI C: Kurangi Makanan yang Kurang Sehat (Ruby Red)
                        _buildDetailCard(
                          label: 'C',
                          title: 'Kurangi Makanan yang Kurang Sehat',
                          tag: 'Hindari / Kurangi',
                          tagColor: const Color(0xFFDC2626),
                          tagBgColor: const Color(0xFFFEE2E2),
                          icon: Icons.no_food_outlined,
                          iconColor: const Color(0xFFDC2626),
                          iconBgColor: const Color(0xFFFEE2E2),
                          summary:
                              'Beberapa jenis olahan makanan memicu peradangan pada pembuluh darah dan menaikkan kolesterol jahat dalam darah.',
                          points: const [
                            'Makanan yang digoreng (deep fried): Minyak goreng yang dipanaskan berulang kali menghasilkan lemak trans berbahaya.',
                            'Makanan tinggi lemak hewani: Daging merah berlemak tebal dan jeroan memicu penumpukan plak koroner.',
                            'Makanan bersantan kental: Masakan santan yang dihangatkan berulang dapat meningkatkan kadar kolesterol darah.',
                            'Makanan siap saji & olahan (ultra-processed): Mengandung kadar garam, pengawet, dan lemak tersembunyi yang tinggi.',
                          ],
                          isDark: isDark,
                        ),

                        const SizedBox(height: 14),

                        // MATERI D: Atur Waktu Makan (Sky Blue)
                        _buildDetailCard(
                          label: 'D',
                          title: 'Atur Waktu Makan',
                          tag: 'Kebiasaan Rutin',
                          tagColor: const Color(0xFF0284C7),
                          tagBgColor: const Color(0xFFE0F2FE),
                          icon: Icons.access_time_rounded,
                          iconColor: const Color(0xFF0284C7),
                          iconBgColor: const Color(0xFFE0F2FE),
                          summary:
                              'Jadwal makan yang tertata baik menjaga ritme metabolisme tubuh dan stabilitas energi jantung secara teratur.',
                          points: const [
                            'Menjaga waktu makan tetap teratur setiap hari (sarapan, makan siang, dan makan malam).',
                            'Tidak membiasakan makan dengan waktu yang tidak teratur atau sering melewatkan jam makan utama.',
                            'Menjaga pola makan secara konsisten agar tubuh tidak mengalami stres metabolisme.',
                            'Memberi jeda minimal 2-3 jam antara makan malam dan waktu tidur agar lambung tidak tertekan.',
                          ],
                          isDark: isDark,
                        ),

                        const SizedBox(height: 20),

                        // TOMBOL TANDAI SELESAI DIPELAJARI
                        _buildCompletionButton(
                          context,
                          topicKey: 'pola_makan',
                          topicTitle: 'Pola Makan Sehat',
                          accentColor: const Color(0xFF059669),
                          isDark: isDark,
                        ),

                        const SizedBox(height: 10),

                        // TOMBOL KEMBALI
                        _buildBackButtonBottom(
                          context,
                          isDark: isDark,
                          accentColor: const Color(0xFF059669),
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
      },
    );
  }
}

// ============================================================================
// 2. DETAIL PAGE: AKTIVITAS FISIK (GERAK - OCEAN BLUE THEME)
// ============================================================================
class AktivitasFisikPage extends StatelessWidget {
  const AktivitasFisikPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: EducationPage.pageGradient(isDark),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // HEADER BAR
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 12),
                    child: Row(
                      children: [
                        EducationPage._buildBackButton(context, isDark: isDark),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aktivitas Fisik',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Panduan latihan fisik yang aman bagi jantung',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
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
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // BANNER RINGKASAN (AZURE BLUE)
                          _buildOverviewCard(
                            icon: Icons.directions_walk_rounded,
                            title: 'Aktivitas Fisik Aman & Terukur',
                            description:
                                'Aktivitas fisik sangat bermanfaat menjaga kekuatan pompa jantung dan kebugaran tubuh, asalkan dilakukan secara sederhana, bertahap, dan disesuaikan dengan kapasitas tubuh masing-masing.',
                            color: const Color(0xFF0284C7),
                            bgColor: const Color(0xFFE0F2FE),
                            isDark: isDark,
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pilihan Bentuk Aktivitas',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),

                        // MATERI A: Jalan Kaki (Ocean Blue)
                        _buildDetailCard(
                          label: 'A',
                          title: 'Jalan Kaki',
                          tag: 'Aktivitas Dasar',
                          tagColor: const Color(0xFF0284C7),
                          tagBgColor: const Color(0xFFE0F2FE),
                          icon: Icons.directions_walk_rounded,
                          iconColor: const Color(0xFF0284C7),
                          iconBgColor: const Color(0xFFE0F2FE),
                          summary:
                              'Salah satu aktivitas fisik terbaik, minim risiko cedera, serta sangat mudah dilakukan untuk menjaga kelancaran aliran darah.',
                          points: const [
                            'Dilakukan secara bertahap mulai dari 10-15 menit per hari dengan langkah santai di lintasan yang rata.',
                            'Dapat ditingkatkan secara perlahan hingga 20-30 menit jika tidak ada keluhan sesak napas atau lelah berlebih.',
                            'Dianjurkan berjalan santai di waktu pagi atau sore hari saat suhu lingkungan sejuk dan segar.',
                            'Gunakan alas kaki yang nyaman dan tetap terhidrasi dengan air putih secukupnya.',
                          ],
                          isDark: isDark,
                        ),

                        const SizedBox(height: 14),

                        // MATERI B: Latihan Pernapasan (Teal / Cyan Breeze)
                        _buildDetailCard(
                          label: 'B',
                          title: 'Latihan Pernapasan',
                          tag: 'Relaksasi Jantung',
                          tagColor: const Color(0xFF0D9488),
                          tagBgColor: const Color(0xFFCCFBF1),
                          icon: Icons.air_rounded,
                          iconColor: const Color(0xFF0D9488),
                          iconBgColor: const Color(0xFFCCFBF1),
                          summary:
                              'Latihan pernapasan dalam (deep breathing) yang tenang dan teratur membantu menstabilkan detak jantung serta meredakan ketegangan tubuh.',
                          points: const [
                            'Duduk dalam posisi tegak dan rileks di kursi yang nyaman, letakkan tangan di perut.',
                            'Tarik napas perlahan melalui hidung selama 3-4 detik hingga rongga dada dan perut mengembang.',
                            'Hembuskan napas perlahan melalui mulut secara tenang selama 4-6 detik.',
                            'Lakukan secara teratur 5-10 menit setiap hari atau saat merasa cemas dan tegang.',
                          ],
                          isDark: isDark,
                        ),

                        const SizedBox(height: 14),

                        // MATERI C: Mobilisasi Bertahap (Fresh Emerald Green)
                        _buildDetailCard(
                          label: 'C',
                          title: 'Mobilisasi Bertahap',
                          tag: 'Latihan Mandiri',
                          tagColor: const Color(0xFF059669),
                          tagBgColor: const Color(0xFFECFDF5),
                          icon: Icons.accessibility_new_rounded,
                          iconColor: const Color(0xFF059669),
                          iconBgColor: const Color(0xFFECFDF5),
                          summary:
                              'Latihan peregangan ringan dan mobilitas sendi menjaga otot tetap lentur tanpa membebani frekuensi detak jantung.',
                          points: const [
                            'Melakukan peregangan ringan pada area leher, bahu, lengan, dan pergelangan kaki setiap pagi.',
                            'Hindari gerakan menghentak mendadak, menahan napas saat mengangkat beban, atau membungkuk secara ekstrem.',
                            'Lakukan gerakan berdiri dan duduk perlahan untuk melatih kekuatan otot kaki.',
                            'Bagi pasien pasca perawatan, lakukan mobilisasi di dalam ruangan secara teratur di bawah pengawasan pendamping.',
                          ],
                          isDark: isDark,
                        ),

                        const SizedBox(height: 18),

                        // KOTAK PERINGATAN PENTING (WARM AMBER / GOLD)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2E1C0C)
                                : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFFFDE68A),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: isDark ? 0.1 : 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF59E0B)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.health_and_safety_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PENTING DIPERHATIKAN',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? const Color(0xFFFDE68A)
                                            : const Color(0xFF92400E),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Orang dengan penyakit jantung perlu menyesuaikan intensitas dan durasi aktivitas fisik dengan kondisi masing-masing serta selalu mengikuti anjuran dan rekomendasi dari dokter atau tenaga kesehatan yang merawat.',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        height: 1.45,
                                        color: isDark
                                            ? const Color(0xFFFCD34D)
                                            : const Color(0xFF78350F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // TOMBOL TANDAI SELESAI DIPELAJARI
                        _buildCompletionButton(
                          context,
                          topicKey: 'aktivitas_fisik',
                          topicTitle: 'Aktivitas Fisik',
                          accentColor: const Color(0xFF0284C7),
                          isDark: isDark,
                        ),

                        const SizedBox(height: 10),

                        // TOMBOL KEMBALI
                        _buildBackButtonBottom(
                          context,
                          isDark: isDark,
                          accentColor: const Color(0xFF0284C7),
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
      },
    );
  }
}

// ============================================================================
// 3. DETAIL PAGE: KEBIASAAN SEHAT (GAYA HIDUP - ROYAL VIOLET THEME)
// ============================================================================
class KebiasaanSehatPage extends StatelessWidget {
  const KebiasaanSehatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: EducationPage.pageGradient(isDark),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // HEADER BAR
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 12),
                    child: Row(
                      children: [
                        EducationPage._buildBackButton(context, isDark: isDark),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kebiasaan Sehat',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pola hidup sehari-hari untuk menjaga kondisi jantung',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
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
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // BANNER RINGKASAN (ROYAL VIOLET)
                          _buildOverviewCard(
                            icon: Icons.spa_rounded,
                            title: 'Kebiasaan Baik Setiap Hari',
                            description:
                                'Membahas kebiasaan sehari-hari yang dapat membantu menjaga kondisi jantung tetap stabil, seperti menjaga pola istirahat, menghindari rokok, mengelola stres, dan mengikuti perawatan medis yang dianjurkan.',
                            color: const Color(0xFF7C3AED),
                            bgColor: const Color(0xFFF5F3FF),
                            isDark: isDark,
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pilar Kebiasaan Sehat',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),

                        // MATERI A: Hindari Rokok (Ruby Red)
                        _buildDetailCard(
                          label: 'A',
                          title: 'Hindari Rokok',
                          tag: 'Wajib Dihindari',
                          tagColor: const Color(0xFFDC2626),
                          tagBgColor: const Color(0xFFFEE2E2),
                          icon: Icons.smoke_free_rounded,
                          iconColor: const Color(0xFFDC2626),
                          iconBgColor: const Color(0xFFFEE2E2),
                          summary:
                              'Menghindari kebiasaan merokok dan paparan asap rokok adalah langkah paling efektif untuk mencegah kerusakan pembuluh darah koroner.',
                          points: const [
                            'Zat beracun dan nikotin dalam rokok merusak dinding arteri dan mempercepat penumpukan plak aterosklerosis.',
                            'Merokok menyempitkan pembuluh darah, menaikkan denyut nadi, serta menurunkan kadar oksigen yang dibawa ke otot jantung.',
                            'Hindari pula paparan sebagai perokok pasif karena memiliki dampak bahaya yang sama tingginya.',
                            'Berhenti merokok memberikan dampak perbaikan sirkulasi darah jantung secara signifikan dalam waktu singkat.',
                          ],
                          isDark: isDark,
                        ),

                        const SizedBox(height: 14),

                        // MATERI B: Istirahat yang Cukup (Deep Indigo)
                        _buildDetailCard(
                          label: 'B',
                          title: 'Istirahat yang Cukup',
                          tag: 'Pemulihan Organ',
                          tagColor: const Color(0xFF4338CA),
                          tagBgColor: const Color(0xFFEEF2FF),
                          icon: Icons.bedtime_rounded,
                          iconColor: const Color(0xFF4338CA),
                          iconBgColor: const Color(0xFFEEF2FF),
                          summary:
                              'Waktu tidur yang berkualitas dan cukup memberi kesempatan bagi organ jantung untuk beristirahat dan menstabilkan tekanan darah.',
                          points: const [
                            'Menjaga kecukupan waktu istirahat dan tidur berkualitas selama 7-8 jam setiap malam.',
                            'Menjaga jam tidur dan bangun secara teratur setiap hari untuk keselarasan ritme sirkadian tubuh.',
                            'Kurang tidur kronis terbukti meningkatkan hormon stres dan memicu kenaikan tekanan darah tinggi.',
                            'Ciptakan suasana kamar tidur yang tenang, sejuk, dan hindari paparan layar gawai menjelang tidur.',
                          ],
                          isDark: isDark,
                        ),

                        const SizedBox(height: 14),

                        // MATERI C: Kelola Stres (Serene Violet)
                        _buildDetailCard(
                          label: 'C',
                          title: 'Kelola Stres',
                          tag: 'Kesehatan Emosional',
                          tagColor: const Color(0xFF7C3AED),
                          tagBgColor: const Color(0xFFF5F3FF),
                          icon: Icons.self_improvement_rounded,
                          iconColor: const Color(0xFF7C3AED),
                          iconBgColor: const Color(0xFFF5F3FF),
                          summary:
                              'Kondisi emosional yang terkendali melindungi jantung dari lonjakan hormon adrenalin dan kortisol yang memicu hipertensi.',
                          points: const [
                            'Mengenali pemicu stres harian dan meluangkan waktu untuk relaksasi, ibadah, meditasi, atau hobi santai.',
                            'Membiasakan berbincang dan berbagi cerita dengan keluarga atau sahabat saat menghadapi rasa cemas.',
                            'Mengatur ritme kerja dan beban pikiran agar tidak mengalami kelelahan mental yang berlebihan.',
                            'Menjaga pikiran positif dan menghindari reaksi kemarahan mendadak yang membebani kinerja pompa jantung.',
                          ],
                          isDark: isDark,
                        ),

                        const SizedBox(height: 14),

                        // MATERI D: Ikuti Perawatan (Medical Azure Blue)
                        _buildDetailCard(
                          label: 'D',
                          title: 'Ikuti Perawatan',
                          tag: 'Kepatuhan Medis',
                          tagColor: const Color(0xFF0284C7),
                          tagBgColor: const Color(0xFFE0F2FE),
                          icon: Icons.medical_services_rounded,
                          iconColor: const Color(0xFF0284C7),
                          iconBgColor: const Color(0xFFE0F2FE),
                          summary:
                              'Kepatuhan terhadap rencana terapi dokter dan pemeriksaan berkala adalah jaminan terbaik untuk kestabilan kesehatan jantung.',
                          points: const [
                            'Meminum obat-obatan yang diresepkan oleh dokter secara teratur sesuai dosis dan jadwal yang telah ditentukan.',
                            'Melakukan kontrol atau pemeriksaan kesehatan berkala sesuai anjuran untuk memantau fungsi jantung.',
                            'Memantau parameter penting seperti tekanan darah dan denyut nadi secara mandiri di rumah jika dianjurkan.',
                            'Segera berkonsultasi kembali kepada dokter jika merasakan perubahan kondisi atau gejala baru yang mengganggu.',
                          ],
                          isDark: isDark,
                        ),

                        const SizedBox(height: 20),

                        // TOMBOL TANDAI SELESAI DIPELAJARI
                        _buildCompletionButton(
                          context,
                          topicKey: 'kebiasaan_sehat',
                          topicTitle: 'Kebiasaan Sehat',
                          accentColor: const Color(0xFF7C3AED),
                          isDark: isDark,
                        ),

                        const SizedBox(height: 10),

                        // TOMBOL KEMBALI
                        _buildBackButtonBottom(
                          context,
                          isDark: isDark,
                          accentColor: const Color(0xFF7C3AED),
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
      },
    );
  }
}

// ============================================================================
// HELPER WIDGETS DETAIL PAGES & BUTTONS
// ============================================================================
Widget _buildOverviewCard({
  required IconData icon,
  required String title,
  required String description,
  required Color color,
  required Color bgColor,
  bool isDark = false,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0xFF1E293B), Color(0xFF0F172A)]
            : [bgColor, Colors.white],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isDark
            ? color.withValues(alpha: 0.4)
            : color.withValues(alpha: 0.28),
        width: 1.4,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF334155),
                  height: 1.42,
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
  required String tag,
  required Color tagColor,
  required Color tagBgColor,
  required IconData icon,
  required Color iconColor,
  required Color iconBgColor,
  required String summary,
  required List<String> points,
  bool isDark = false,
}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isDark
            ? iconColor.withValues(alpha: 0.3)
            : iconColor.withValues(alpha: 0.22),
        width: 1.3,
      ),
      boxShadow: [
        BoxShadow(
          color: iconColor.withValues(alpha: isDark ? 0.1 : 0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent color bar
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconColor, iconColor.withValues(alpha: 0.4)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER: Icon + Label + Tag + Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark
                            ? iconColor.withValues(alpha: 0.2)
                            : iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: iconColor.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 22,
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
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: iconColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'TOPIK $label',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? tagColor.withValues(alpha: 0.22)
                                      : tagBgColor,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: tagColor.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : tagColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // SUMMARY CALLOUT BOX
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                        : iconBgColor.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                    border: Border(
                      left: BorderSide(
                        color: iconColor,
                        width: 3.5,
                      ),
                    ),
                  ),
                  child: Text(
                    summary,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF334155),
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // POIN-POIN CHECKLIST
                ...points.map((point) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: iconColor,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            point,
                            style: TextStyle(
                              fontSize: 11.8,
                              color: isDark
                                  ? const Color(0xFFE2E8F0)
                                  : const Color(0xFF334155),
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
          ),
        ],
      ),
    ),
  );
}

Widget _buildCompletionButton(
  BuildContext context, {
  required String topicKey,
  required String topicTitle,
  required Color accentColor,
  bool isDark = false,
}) {
  return ValueListenableBuilder<Set<String>>(
    valueListenable: EducationPage.completedTopicsNotifier,
    builder: (context, completed, _) {
      final isCompleted = completed.contains(topicKey);

      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () {
            final newSet = Set<String>.from(completed);
            if (isCompleted) {
              newSet.remove(topicKey);
            } else {
              newSet.add(topicKey);
            }
            EducationPage.completedTopicsNotifier.value = newSet;

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor:
                    isCompleted ? const Color(0xFF475569) : accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                content: Row(
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.info_outline_rounded
                          : Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isCompleted
                            ? 'Topik ditandai belum selesai.'
                            : 'Bagus! Anda telah menyelesaikan $topicTitle.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          icon: Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : Icons.check_circle_outline_rounded,
            size: 19,
            color: Colors.white,
          ),
          label: Text(
            isCompleted
                ? 'Selesai Dipelajari (Ketuk untuk batalkan)'
                : 'Tandai Selesai Dipelajari',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isCompleted ? const Color(0xFF16A34A) : accentColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildBackButtonBottom(
  BuildContext context, {
  bool isDark = false,
  Color? accentColor,
}) {
  final color = accentColor ??
      (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7));
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: OutlinedButton.icon(
      onPressed: () => Navigator.pop(context),
      icon: Icon(
        Icons.arrow_back_rounded,
        size: 18,
        color: color,
      ),
      label: Text(
        'Kembali ke Edukasi Kesehatan',
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.6), width: 1.3),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        backgroundColor: isDark
            ? color.withValues(alpha: 0.08)
            : color.withValues(alpha: 0.05),
      ),
    ),
  );
}
