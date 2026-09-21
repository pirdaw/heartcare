import 'package:flutter/material.dart';
import 'home_page.dart';
import 'detail_dokter_page.dart';

class PilihDokterPage extends StatefulWidget {
  const PilihDokterPage({super.key});

  @override
  State<PilihDokterPage> createState() => _PilihDokterPageState();
}

class _PilihDokterPageState extends State<PilihDokterPage> {
  // =========================================================
  // DATA
  // =========================================================

  final List<Map<String, String>> _dokter = [
    {
      'nama': 'dr. Andi Pratama',
      'spesialis': 'Spesialis Jantung',
    },
    {
      'nama': 'dr. Sinta Maharani',
      'spesialis': 'Spesialis Jantung',
    },
    {
  'nama': 'dr. Nurlitta Dwi',
  'spesialis': 'Spesialis Jantung',
},
    {
      'nama': 'dr. Rina Amelia',
      'spesialis': 'Spesialis Jantung',
    },
  ];

  final TextEditingController _searchController =
      TextEditingController();

  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  // =========================================================
  // CATEGORY
  // =========================================================

  final List<String> _categories = [
    'Semua',
    'Jantung',
    'Umum',
    'Spesialis',
  ];

  // =========================================================
  // FILTER DOKTER
  // =========================================================

  List<Map<String, String>> get _filteredDoctors {
    return _dokter.where((dokter) {
      final String nama =
          dokter['nama']!.toLowerCase();

      final String spesialis =
          dokter['spesialis']!.toLowerCase();

      // Filter pencarian
      final bool cocokSearch =
          nama.contains(_searchQuery.toLowerCase()) ||
          spesialis.contains(_searchQuery.toLowerCase());

      if (!cocokSearch) {
        return false;
      }

      // Filter kategori
      if (_selectedCategory == 'Semua') {
        return true;
      }

      if (_selectedCategory == 'Jantung') {
        return spesialis.contains('jantung');
      }

      if (_selectedCategory == 'Umum') {
        return spesialis.contains('umum');
      }

      if (_selectedCategory == 'Spesialis') {
        return spesialis.contains('spesialis');
      }

      return true;
    }).toList();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // =========================================================
            // HEADER
            // =========================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                10,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F3F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF1E293B),
                        size: 26,
                      ),
                    ),
                  ),

                  const Expanded(
                    child: Text(
                      'Pilih Dokter',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),

                  const SizedBox(width: 40),
                ],
              ),
            ),

            // =========================================================
            // SEARCH
            // =========================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                12,
              ),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari dokter...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF6B7280),
                      size: 22,
                    ),

                    // Tombol X ketika mengetik
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF6B7280),
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
                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                  ),
                ),
              ),
            ),

            // =========================================================
            // CATEGORY
            // =========================================================

            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final String category =
                      _categories[index];

                  final bool selected =
                      _selectedCategory == category;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: _categoryItem(
                      category,
                      selected,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // =========================================================
            // DAFTAR DOKTER
            // =========================================================

            Expanded(
              child: _filteredDoctors.isEmpty
                  ? _emptyDoctorState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        20,
                      ),
                      itemCount: _filteredDoctors.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 14);
                      },
                      itemBuilder: (context, index) {
                        final dokter =
                            _filteredDoctors[index];

                        return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DetailDokterPage(),
      ),
    );
  },
  child: _doctorCard(
    name: dokter['nama']!,
    specialist: dokter['spesialis']!,
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
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color(0xFFE5E5E5),
                width: 0.7,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              // HOME
              _bottomItem(
                context,
                Icons.home_outlined,
                'Home',
                false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const HomePage(),
                    ),
                  );
                },
              ),

              // SKRINING
              _bottomItem(
                context,
                Icons.favorite_border,
                'Skrining',
                false,
              ),

              // DOKTER
              _bottomItem(
                context,
                Icons.medical_services_outlined,
                'Dokter',
                true,
              ),

              // RIWAYAT
              _bottomItem(
                context,
                Icons.description_outlined,
                'Riwayat',
                false,
              ),

              // PROFIL
              _bottomItem(
                context,
                Icons.person_outline,
                'Profil',
                false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // CATEGORY ITEM
  // =========================================================

  Widget _categoryItem(
    String text,
    bool selected,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF087EFF)
            : const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: selected
              ? FontWeight.w600
              : FontWeight.w400,
          color: selected
              ? Colors.white
              : const Color(0xFF4B5563),
        ),
      ),
    );
  }

  // =========================================================
  // DOCTOR CARD
  // =========================================================

  Widget _doctorCard({
    required String name,
    required String specialist,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // =======================================================
          // PLACEHOLDER FOTO DOKTER
          // =======================================================

          Container(
            width: 72,
            height: 82,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Color(0xFF9CA3AF),
            ),
          ),

          const SizedBox(width: 14),

          // =======================================================
          // INFORMASI DOKTER
          // =======================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  specialist,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),

          // =======================================================
          // PANAH
          // =======================================================

          const Icon(
            Icons.chevron_right,
            size: 25,
            color: Color(0xFF444444),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================

  Widget _emptyDoctorState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 50,
            color: Color(0xFFB0B7C3),
          ),

          const SizedBox(height: 12),

          const Text(
            'Dokter tidak ditemukan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Coba gunakan kata kunci lain.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOTTOM NAV ITEM
  // =========================================================

  static Widget _bottomItem(
    BuildContext context,
    IconData icon,
    String label,
    bool selected, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 58,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 27,
              color: selected
                  ? const Color(0xFF087EFF)
                  : Colors.black87,
            ),

            const SizedBox(height: 3),

            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: selected
                    ? const Color(0xFF087EFF)
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}