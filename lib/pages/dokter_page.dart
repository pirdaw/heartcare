import 'package:flutter/material.dart';
import 'home_page.dart';
import 'detail_dokter_page.dart';
import 'profil_page.dart';
import 'screening_intro_page.dart';
import 'riwayat_page.dart';
import '../services/theme_service.dart';

class PilihDokterPage extends StatefulWidget {
  const PilihDokterPage({super.key});

  @override
  State<PilihDokterPage> createState() => _PilihDokterPageState();
}

class _PilihDokterPageState extends State<PilihDokterPage> {
  static const Color brandTeal = Color(0xFF0098B9);

  // =========================================================
  // DATA DOKTER LENGKAP DENGAN FOTO ASLI & DETAIL DINAMIS
  // =========================================================
  final List<Map<String, dynamic>> _dokter = [
    {
      'nama': 'dr. Andi Pratama',
      'spesialis': 'Spesialis Jantung & Pembuluh Darah',
      'foto': 'assets/images/dokter_andi.jpg',
      'gambar': 'assets/images/dokter_andi.jpg',
      'pengalaman': '10 tahun',
      'sip': '1823/SIP/2021',
      'lokasi': 'Klinik Jantung Sejahtera, Jember',
      'tentang':
          'Fokus pada prevensi dan penanganan penyakit jantung koroner serta aritmia dengan pendekatan preventif dan rehabilitasi kardiovaskular.',
      'isOnline': true,
    },
    {
      'nama': 'dr. Sinta Maharani',
      'spesialis': 'Spesialis Jantung & Kardiovaskular',
      'foto': 'assets/images/dokter_sinta.jpg',
      'gambar': 'assets/images/dokter_sinta.jpg',
      'pengalaman': '8 tahun',
      'sip': '2105/SIP/2022',
      'lokasi': 'RS Graha Medika, Jember',
      'tentang':
          'Berpengalaman dalam ekokardiografi, diagnosis gagal jantung dini, dan konsultasi gaya hidup sehat untuk penderita hipertensi.',
      'isOnline': true,
    },
    {
      'nama': 'dr. Nurlitta Dwi',
      'spesialis': 'Spesialis Jantung & Konsultan Aritmia',
      'foto': 'assets/images/dokter_nurlitta.jpg',
      'gambar': 'assets/images/dokter_nurlitta.jpg',
      'pengalaman': '12 tahun',
      'sip': '2406/SIP/2023',
      'lokasi': 'RS Mitra Sehat, Jember',
      'tentang':
          'Berpengalaman dalam memberikan pemeriksaan dan penanganan komprehensif terhadap berbagai kondisi jantung dan kardiovaskular.',
      'isOnline': true,
    },
    {
      'nama': 'dr. Rina Amelia',
      'spesialis': 'Spesialis Jantung & Prevensi Kardio',
      'foto': 'assets/images/dokter_rina.jpg',
      'gambar': 'assets/images/dokter_rina.jpg',
      'pengalaman': '7 tahun',
      'sip': '1944/SIP/2023',
      'lokasi': 'Pusat Jantung Terpadu, Jember',
      'tentang':
          'Spesialis dalam evaluasi risiko serangan jantung, skrining kardiovaskular berkala, dan manajemen kolesterol tinggi.',
      'isOnline': true,
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Spesialis',
  ];

  // =========================================================
  // FILTER PENCARIAN & KATEGORI DOKTER
  // =========================================================
  List<Map<String, dynamic>> get _filteredDoctors {
    return _dokter.where((dokter) {
      final String nama = (dokter['nama'] as String? ?? '').toLowerCase();
      final String spesialis = (dokter['spesialis'] as String? ?? '').toLowerCase();
      final String lokasi = (dokter['lokasi'] as String? ?? '').toLowerCase();

      final query = _searchQuery.trim().toLowerCase();
      final bool cocokSearch = query.isEmpty ||
          nama.contains(query) ||
          spesialis.contains(query) ||
          lokasi.contains(query);

      if (!cocokSearch) {
        return false;
      }

      // Filter kategori
      if (_selectedCategory == 'Semua') {
        return true;
      }

      if (_selectedCategory == 'Spesialis') {
        return spesialis.contains('spesialis');
      }

      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandTeal = Color(0xFF0098B9);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor:
                isDark ? const Color(0xFF0F172A) : Colors.white,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: Colors.black12,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    size: 18,
                  ),
                ),
              ),
            ),
            centerTitle: true,
            title: Text(
              'Pilih Dokter',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // =========================================================
                // SEARCH BAR
                // =========================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari dokter spesialis...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark ? const Color(0xFF38BDF8) : brandTeal,
                          size: 22,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF64748B),
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),

                // =========================================================
                // KATEGORI DOKTER
                // =========================================================
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final String category = _categories[index];
                      final bool selected = _selectedCategory == category;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: _categoryItem(
                          category,
                          selected,
                          isDark: isDark,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 6),

                // =========================================================
                // SUBHEADER: RINGKASAN JUMLAH DOKTER
                // =========================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Dokter Spesialis',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F2B3E)
                              : const Color(0xFFE8F7FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_filteredDoctors.length} Dokter',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF38BDF8) : brandTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // =========================================================
                // DAFTAR DOKTER
                // =========================================================
                Expanded(
                  child: _filteredDoctors.isEmpty
                      ? _emptyDoctorState(isDark: isDark)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                          itemCount: _filteredDoctors.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 12);
                          },
                          itemBuilder: (context, index) {
                            final dokter = _filteredDoctors[index];

                            return Material(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailDokterPage(
                                        nama: dokter['nama'] as String,
                                        spesialis: dokter['spesialis'] as String,
                                        imagePath: dokter['foto'] as String,
                                        pengalaman: dokter['pengalaman'] as String,
                                        sip: dokter['sip'] as String,
                                        lokasi: dokter['lokasi'] as String,
                                        tentang: dokter['tentang'] as String,
                                        isOnline: dokter['isOnline'] as bool? ?? true,
                                      ),
                                    ),
                                  );
                                },
                                child: _doctorCard(
                                  dokter: dokter,
                                  isDark: isDark,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // =========================================================
          // BOTTOM NAVIGATION
          // =========================================================
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _bottomItem(
                    context,
                    Icons.home_outlined,
                    'Home',
                    false,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                  ),
                  _bottomItem(
                    context,
                    Icons.favorite_border,
                    'Skrining',
                    false,
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScreeningIntroPage(),
                        ),
                      );
                    },
                  ),
                  _bottomItem(
                    context,
                    Icons.medical_services,
                    'Dokter',
                    true,
                    isDark: isDark,
                  ),
                  _bottomItem(
                    context,
                    Icons.description_outlined,
                    'Riwayat',
                    false,
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RiwayatPage(),
                        ),
                      );
                    },
                  ),
                  _bottomItem(
                    context,
                    Icons.person_outline,
                    'Profil',
                    false,
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // CATEGORY ITEM
  // =========================================================
  Widget _categoryItem(
    String text,
    bool selected, {
    bool isDark = false,
  }) {
    const Color brandTeal = Color(0xFF0098B9);
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: selected
            ? brandTeal
            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F3F6)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? brandTeal
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected
              ? Colors.white
              : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563)),
        ),
      ),
    );
  }

  // =========================================================
  // DOCTOR CARD (NADEA'S WIDGET)
  // =========================================================
  Widget _doctorCard({
    required Map<String, dynamic> dokter,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // FOTO DOKTER NYATA
          Stack(
            children: [
              Container(
                width: 76,
                height: 86,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isDark
                      ? const Color(0xFF0F2B3E)
                      : const Color(0xFFEFF6FF),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E3A5F)
                        : const Color(0xFFE0F2FE),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.5),
                  child: Image.asset(
                    dokter['foto'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 40,
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : brandTeal,
                      );
                    },
                  ),
                ),
              ),
              // INDIKATOR STATUS ONLINE
              if (dokter['isOnline'] == true)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          // INFORMASI DOKTER
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dokter['nama'] as String,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dokter['spesialis'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF38BDF8)
                        : brandTeal,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.work_outline_rounded,
                      size: 13,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dokter['pengalaman']} pengalaman',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dokter['lokasi'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // TOMBOL CHEVRON / DETAIL
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EMPTY STATE JIKA PENCARIAN KOSONG
  // =========================================================
  Widget _emptyDoctorState({bool isDark = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_search_rounded,
              size: 42,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Dokter tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Coba gunakan kata kunci nama atau klinik lain.',
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOTTOM NAV ITEM HELPER
  // =========================================================
  static Widget _bottomItem(
    BuildContext context,
    IconData icon,
    String label,
    bool selected, {
    VoidCallback? onTap,
    bool isDark = false,
  }) {
    const Color brandTeal = Color(0xFF0098B9);
    final Color activeColor = isDark ? const Color(0xFF38BDF8) : brandTeal;
    final Color inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 23,
              color: selected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}