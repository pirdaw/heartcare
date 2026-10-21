import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'detail_dokter_page.dart';
import 'konsultasi_dokter_page.dart';
import 'profil_page.dart';
import 'screening_intro_page.dart';
import 'riwayat_page.dart';
import 'signup_page.dart';
import '../services/theme_service.dart';
import '../services/doctor_service.dart';

class PilihDokterPage extends StatefulWidget {
  const PilihDokterPage({super.key});

  @override
  State<PilihDokterPage> createState() => _PilihDokterPageState();
}

class _PilihDokterPageState extends State<PilihDokterPage> {
  static const Color brandPrimary = Color(0xFF0284C7);
  static const Color brandLight = Color(0xFFE0F2FE);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  List<Map<String, dynamic>> _cachedDoctors = [];
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCachedDoctors();
  }

  Future<void> _loadCachedDoctors() async {
    final list = await DoctorService.instance.getCachedDoctors();
    if (mounted) {
      setState(() {
        _cachedDoctors = list;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildDoctorPhoto(String? photo, bool isDark) {
    if (photo != null && photo.isNotEmpty) {
      if (photo.startsWith('http://') || photo.startsWith('https://')) {
        return Image.network(
          photo,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.person,
            size: 40,
            color: isDark ? const Color(0xFF38BDF8) : brandPrimary,
          ),
        );
      }
      if (photo.startsWith('assets/')) {
        return Image.asset(
          photo,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: 40,
              color: isDark ? const Color(0xFF38BDF8) : brandPrimary,
            );
          },
        );
      }
    }
    return Icon(
      Icons.person_rounded,
      size: 40,
      color: isDark ? const Color(0xFF38BDF8) : brandPrimary,
    );
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
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
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
              'Konsultasi Dokter',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              // Tombol tambah / daftar dokter baru
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Material(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupPage(
                            initialRole: 'doctor',
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 17,
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : brandPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+ Dokter',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFF38BDF8)
                                  : brandPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData &&
                  _cachedDoctors.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                debugPrint(
                    '[PilihDokterPage] Firestore Stream Error: ${snapshot.error}');
              }

              final docs = snapshot.data?.docs ?? [];
              final List<Map<String, dynamic>> firestoreDoctors = [];

              for (final doc in docs) {
                final data = doc.data();
                if (DoctorService.isDoctorDocument(data)) {
                  final normalized = DoctorService.normalizeDoctorData(
                    id: doc.id,
                    data: data,
                  );
                  firestoreDoctors.add(normalized);
                  // Simpan ke cache lokal agar selalu tersedia offline
                  DoctorService.instance.cacheDoctor(normalized);
                }
              }

              // Gabungkan dokter dari Firestore dan Cache Lokal (Deduplikasi)
              final Map<String, Map<String, dynamic>> mergedMap = {};
              for (final d in _cachedDoctors) {
                final key =
                    (d['id'] ?? d['uid'] ?? d['email'] ?? d['nama']).toString();
                mergedMap[key] = d;
              }
              for (final d in firestoreDoctors) {
                final key =
                    (d['id'] ?? d['uid'] ?? d['email'] ?? d['nama']).toString();
                mergedMap[key] = d;
              }

              final List<Map<String, dynamic>> allDoctors =
                  mergedMap.values.toList();

              // Kategori spesialisasi dinamis dari dokter yang terdaftar
              final Set<String> categorySet = {'Semua'};
              for (final doc in allDoctors) {
                final sp = doc['spesialis'] as String;
                if (sp.isNotEmpty) {
                  categorySet.add(sp);
                }
              }
              final List<String> categories = categorySet.toList();

              // Filter pencarian dan kategori
              final query = _searchQuery.trim().toLowerCase();
              final filteredDoctors = allDoctors.where((dokter) {
                final nama = (dokter['nama'] as String).toLowerCase();
                final spesialis = (dokter['spesialis'] as String).toLowerCase();
                final lokasi = (dokter['lokasi'] as String).toLowerCase();

                final matchesQuery = query.isEmpty ||
                    nama.contains(query) ||
                    spesialis.contains(query) ||
                    lokasi.contains(query);

                if (!matchesQuery) return false;

                if (_selectedCategory != 'Semua') {
                  return (dokter['spesialis'] as String) == _selectedCategory;
                }

                return true;
              }).toList();

              return SafeArea(
                child: Column(
                  children: [
                    // =========================================================
                    // SEARCH BAR
                    // =========================================================
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
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
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cari dokter spesialis terdaftar...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: isDark
                                  ? const Color(0xFF38BDF8)
                                  : brandPrimary,
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
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),

                    // =========================================================
                    // KATEGORI DOKTER
                    // =========================================================
                    if (categories.length > 1) ...[
                      SizedBox(
                        height: 38,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final String category = categories[index];
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
                    ],

                    // =========================================================
                    // SUBHEADER: RINGKASAN JUMLAH DOKTER
                    // =========================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Dokter Terdaftar (Real-Time)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
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
                                  : brandLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF1E3A5F)
                                    : const Color(0xFFBAE6FD),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${filteredDoctors.length} Dokter',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFF38BDF8)
                                    : brandPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // =========================================================
                    // DAFTAR DOKTER REAL-TIME
                    // =========================================================
                    Expanded(
                      child: allDoctors.isEmpty
                          ? _buildNoDoctorsYetState(isDark: isDark)
                          : (filteredDoctors.isEmpty
                              ? _emptyDoctorState(isDark: isDark)
                              : ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 6, 20, 20),
                                  itemCount: filteredDoctors.length,
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(height: 12);
                                  },
                                  itemBuilder: (context, index) {
                                    final dokter = filteredDoctors[index];

                                    return Material(
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(18),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailDokterPage(
                                                doctorId:
                                                    dokter['id'] as String?,
                                                nama:
                                                    dokter['nama'] as String,
                                                spesialis: dokter['spesialis']
                                                    as String,
                                                imagePath:
                                                    dokter['foto'] as String,
                                                pengalaman: dokter['pengalaman']
                                                    as String,
                                                sip: dokter['sip'] as String,
                                                lokasi:
                                                    dokter['lokasi'] as String,
                                                tentang:
                                                    dokter['tentang'] as String,
                                                isOnline: dokter['isOnline']
                                                        as bool? ??
                                                    true,
                                              ),
                                            ),
                                          );
                                        },
                                        child: _doctorCard(
                                          dokter: dokter,
                                          isDark: isDark,
                                          onDirectChat: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    KonsultasiDokterPage(
                                                  doctorId: dokter['id']
                                                      as String?,
                                                  doctorName:
                                                      dokter['nama'] as String,
                                                  doctorPhoto:
                                                      dokter['foto'] as String,
                                                  doctorSpecialty:
                                                      dokter['spesialis']
                                                          as String,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                )),
                    ),
                  ],
                ),
              );
            },
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
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
              )
            : null,
        color: selected
            ? null
            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F3F6)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? const Color(0xFF0284C7)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected
              ? Colors.white
              : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563)),
        ),
      ),
    );
  }

  // =========================================================
  // DOCTOR CARD
  // =========================================================
  Widget _doctorCard({
    required Map<String, dynamic> dokter,
    required bool isDark,
    required VoidCallback onDirectChat,
  }) {
    final isOnline = dokter['isOnline'] == true;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0284C7))
                .withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // FOTO DOKTER
          Stack(
            children: [
              Container(
                width: 72,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isDark
                      ? const Color(0xFF0F2B3E)
                      : const Color(0xFFEFF6FF),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E3A5F)
                        : const Color(0xFFBAE6FD),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.5),
                  child: _buildDoctorPhoto(
                    dokter['foto'] as String?,
                    isDark,
                  ),
                ),
              ),
              // INDIKATOR STATUS ONLINE
              if (isOnline)
                Positioned(
                  right: 3,
                  top: 3,
                  child: Container(
                    width: 12,
                    height: 12,
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

          const SizedBox(width: 13),

          // INFORMASI DOKTER
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dokter['nama'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dokter['spesialis'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF38BDF8) : brandPrimary,
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
                        fontSize: 11,
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

          const SizedBox(width: 8),

          // TOMBOL CHAT CEPAT
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onDirectChat,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATE JIKA BELUM ADA DOKTER TERDAFTAR DI FIRESTORE
  // =========================================================
  Widget _buildNoDoctorsYetState({bool isDark = false}) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                size: 44,
                color: Color(0xFF0284C7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Dokter Terdeteksi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Akun dokter yang dibuat akan langsung tampil di sini secara real-time. Jika Anda sudah membuat akun dokter, Anda dapat menyinkronkannya atau membuat dokter uji coba di bawah ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Tombol 1: Daftar Akun Dokter Baru
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupPage(
                        initialRole: 'doctor',
                      ),
                    ),
                  ).then((_) => _loadCachedDoctors());
                },
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text(
                  'Daftar Akun Dokter Baru',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Tombol 2: Jadikan Akun Saya Sebagai Dokter (Jika sedang login)
            if (currentUser != null) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isActionLoading
                      ? null
                      : () async {
                          setState(() => _isActionLoading = true);
                          final ok = await DoctorService.instance.promoteCurrentUserToDoctor();
                          await _loadCachedDoctors();
                          if (mounted) {
                            setState(() => _isActionLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok
                                    ? 'Akun Anda (${currentUser.displayName ?? currentUser.email}) berhasil diaktifkan sebagai Dokter!'
                                    : 'Gagal mengaktifkan akun dokter.'),
                                backgroundColor: ok
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.verified_user_rounded, size: 18),
                  label: Text(
                    'Jadikan Akun Saya (${currentUser.email ?? "Aktif"}) Sebagai Dokter',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF0284C7) : const Color(0xFF38BDF8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Tombol 3: Tambah Dokter Uji Coba Cepat (dr. Valent, Sp.JP)
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _isActionLoading
                    ? null
                    : () async {
                        setState(() => _isActionLoading = true);
                        final doc = await DoctorService.instance.seedQuickTestDoctor();
                        await _loadCachedDoctors();
                        if (mounted) {
                          setState(() => _isActionLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Dokter uji coba (${doc["nama"]}) berhasil ditambahkan dan siap dites chat real-time!'),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.bolt_rounded, size: 18),
                label: const Text(
                  'Tambah Dokter Uji Coba (dr. Valent, Sp.JP)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
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
              color: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F5F9),
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
            'Tidak ada dokter terdaftar yang cocok dengan pencarian.',
            style: TextStyle(
              fontSize: 12.5,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
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
    final Color activeColor =
        isDark ? const Color(0xFF38BDF8) : const Color(0xFF1479F5);
    final Color inactiveColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

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