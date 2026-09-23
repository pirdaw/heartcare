import 'package:flutter/material.dart';
import 'package:heartcare/pages/home_page.dart';
import 'package:heartcare/pages/dokter_page.dart';
import 'package:heartcare/pages/riwayat_page.dart';
import 'package:heartcare/pages/Skrining/screening_input_page.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF0F172A),
                size: 28,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Tentang Aplikasi",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CARD 1: OVERVIEW & BRANDING
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.monitor_heart_rounded,
                            color: Color(0xFF0098B9),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "MediTriage HeartCare",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Aplikasi yang membantu pengguna melakukan skrining dini kesehatan jantung, berkonsultasi dengan tenaga kesehatan, serta memantau kondisi jantung secara mudah dan praktis untuk mendukung pencegahan penyakit jantung.",
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // CARD 2: VISI & MISI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // VISI
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.visibility_outlined,
                            size: 20,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Visi",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Menjadi platform layanan kesehatan jantung yang terpercaya dalam membantu masyarakat melakukan skrining dini, konsultasi kesehatan, dan pemantauan kondisi jantung secara mudah, cepat, dan berkelanjutan.",
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.45,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),

                    // MISI
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.track_changes_rounded,
                            size: 20,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Misi",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _bulletItem(
                                "Menyediakan layanan skrining kesehatan jantung secara mudah dan cepat untuk membantu deteksi dini faktor risiko penyakit jantung.",
                              ),
                              const SizedBox(height: 6),
                              _bulletItem(
                                "Memberikan akses konsultasi kesehatan dengan tenaga kesehatan secara praktis melalui platform digital.",
                              ),
                              const SizedBox(height: 6),
                              _bulletItem(
                                "Menyajikan informasi dan edukasi kesehatan jantung yang akurat, mudah dipahami, dan berbasis praktik kesehatan.",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _bulletItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "• ",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0098B9),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              height: 1.45,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ],
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
