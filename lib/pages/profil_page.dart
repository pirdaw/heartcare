import 'package:flutter/material.dart';
import 'package:heartcare/pages/data_pribadi_page.dart';
import 'package:heartcare/pages/data_kesehatan_page.dart';
import 'package:heartcare/pages/pengaturan_page.dart';
import 'package:heartcare/pages/tentang_aplikasi_page.dart';
import 'package:heartcare/pages/home_page.dart';
import 'package:heartcare/pages/dokter_page.dart';
import 'package:heartcare/pages/riwayat_page.dart';
import 'package:heartcare/pages/login_page.dart';
import 'package:heartcare/pages/Skrining/screening_input_page.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 36),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ICON LOGOUT MERAH BULAT
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 30,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 18),

                // JUDUL
                const Text(
                  "Konfirmasi Log Out",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),

                // SUBTITLE
                const Text(
                  "Apakah Anda yakin ingin keluar\ndari akun?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 22),

                // DUA TOMBOL: BATAL & KELUAR
                Row(
                  children: [
                    // TOMBOL BATAL
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // TOMBOL KELUAR MERAH
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Keluar",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Profil",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // ==========================================================
              // AVATAR PROFIL DENGAN BADGE KAMERA
              // ==========================================================
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 116,
                      height: 116,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD6EFF6),
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/profile_woman.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 64,
                            color: Color(0xFF0098B9),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0F172A),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 19,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // NAMA LENGKAP
              const Text(
                "Nadea Fieldzah Putri",
                style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),

              // TELEPON
              const Text(
                "+62 123 456 799",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),

              // EMAIL
              const Text(
                "nadea123@gmail.com",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 28),

              // ==========================================================
              // SECTION: INFORMASI
              // ==========================================================
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Informasi",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // CARD MENU ITEM
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _menuTile(
                      context,
                      icon: Icons.person_outline_rounded,
                      title: "Data Pribadi",
                      isFirst: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DataPribadiPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _menuTile(
                      context,
                      icon: Icons.add_box_outlined,
                      title: "Data Kesehatan",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DataKesehatanPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _menuTile(
                      context,
                      icon: Icons.settings_outlined,
                      title: "Pengaturan",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PengaturanPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _menuTile(
                      context,
                      icon: Icons.info_outline_rounded,
                      title: "Tentang Aplikasi",
                      isLast: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TentangAplikasiPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ==========================================================
              // TOMBOL KELUAR
              // ==========================================================
              Center(
                child: InkWell(
                  onTap: () => _showLogoutDialog(context),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      "Keluar",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: const Color(0xFF0F172A),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.home_outlined, "Home", 0),
          _navItem(context, Icons.favorite_border, "Skrining", 1),
          _navItem(context, Icons.person_outline, "Dokter", 2),
          _navItem(context, Icons.description_outlined, "Riwayat", 3),
          _navItem(context, Icons.person_rounded, "Profil", 4, active: true),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, int index, {bool active = false}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (active) return;
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreeningInputPage()));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PilihDokterPage()));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatPage()));
        }
      },
      child: SizedBox(
        width: 55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: active ? const Color(0xFF1479F5) : Colors.black87,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? const Color(0xFF1479F5) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
