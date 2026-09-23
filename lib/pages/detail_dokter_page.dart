import 'package:flutter/material.dart';
import 'home_page.dart';
import 'pilih_jadwal_page.dart';
import 'profil_page.dart';

class DetailDokterPage extends StatelessWidget {
  final String nama;
  final String spesialis;
  final String imagePath;
  final String pengalaman;
  final String sip;
  final String lokasi;
  final String tentang;
  final bool isOnline;

  const DetailDokterPage({
    super.key,
    this.nama = 'dr. Nurlitta Dwi',
    this.spesialis = 'Spesialis Jantung',
    this.imagePath = 'assets/images/dokter_nurlitta.jpg',
    this.pengalaman = '12 tahun',
    this.sip = '2406/SIP/2023',
    this.lokasi = 'RS Mitra Sehat, Jember',
    this.tentang =
        'Berpengalaman dalam memberikan pemeriksaan dan penanganan komprehensif terhadap berbagai kondisi jantung dan kardiovaskular.',
    this.isOnline = true,
  });

  static const Color brandTeal = Color(0xFF0098B9);
  static const Color onlineGreen = Color(0xFF10B981);

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
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0F172A),
                size: 18,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Detail Dokter',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dokter disimpan ke favorit'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(
              Icons.bookmark_border_rounded,
              color: Color(0xFF475569),
              size: 24,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    // ==================================================
                    // KARTU PROFIL UTAMA
                    // ==================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // FOTO DOKTER BESAR DENGAN BORDER
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: brandTeal.withValues(alpha: 0.25),
                                    width: 3.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: brandTeal.withValues(alpha: 0.15),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: const Color(0xFFE0F2FE),
                                        child: const Icon(
                                          Icons.person,
                                          size: 65,
                                          color: brandTeal,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // STATUS ONLINE DOT
                              Positioned(
                                right: 6,
                                bottom: 4,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: isOnline
                                        ? onlineGreen
                                        : const Color(0xFF94A3B8),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // NAMA DOKTER
                          Text(
                            nama,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // SPESIALIS
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F7FB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              spesialis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: brandTeal,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // STATUS LABEL
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: isOnline
                                    ? onlineGreen
                                    : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isOnline
                                    ? 'Tersedia untuk Konsultasi'
                                    : 'Sedang Tidak Praktik',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isOnline
                                      ? onlineGreen
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // KARTU INFORMASI DOKTER
                    // ==================================================
                    Container(
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
                                Icons.badge_outlined,
                                color: brandTeal,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Informasi Dokter',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _infoTile(
                            icon: Icons.work_outline_rounded,
                            title: 'Pengalaman Praktik',
                            value: pengalaman,
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          _infoTile(
                            icon: Icons.verified_user_outlined,
                            title: 'Nomor SIP',
                            value: sip,
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          _infoTile(
                            icon: Icons.location_on_outlined,
                            title: 'Lokasi Praktik',
                            value: lokasi,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // TENTANG DOKTER
                    // ==================================================
                    Container(
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
                                Icons.info_outline_rounded,
                                color: brandTeal,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Tentang Dokter',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            tentang,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.55,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // TOMBOL PILIH JADWAL
                    // ==================================================
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PilihJadwalPage(
                                doctorName: nama,
                                doctorSpecialty: spesialis,
                                doctorPhoto: imagePath,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Pilih Jadwal Konsultasi',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
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
          ],
        ),
      ),

      // ==================================================
      // BOTTOM NAVIGATION BAR
      // ==================================================
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 62,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bottomNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                active: false,
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
              ),
              _bottomNavItem(
                icon: Icons.favorite_border,
                label: 'Skrining',
                active: false,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _bottomNavItem(
                icon: Icons.medical_services,
                label: 'Dokter',
                active: true,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _bottomNavItem(
                icon: Icons.description_outlined,
                label: 'Riwayat',
                active: false,
              ),
              _bottomNavItem(
                icon: Icons.person_outline,
                label: 'Profil',
                active: false,
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
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF475569)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomNavItem({
    required IconData icon,
    required String label,
    required bool active,
    VoidCallback? onTap,
  }) {
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
              color: active ? brandTeal : const Color(0xFF64748B),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? brandTeal : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}