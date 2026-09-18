import 'package:flutter/material.dart';
import 'Skrining/custom_bottom_nav_bar.dart';
import 'screening_intro_page.dart';
import 'home_page.dart';
import 'Profil/profil_page.dart';

/// Model sederhana untuk satu entri riwayat.
/// Nantinya bisa diganti/diisi dari API atau database.
class RiwayatItem {
  final String tanggal;
  final String judul;
  final RiwayatStatus status;

  // Khusus entri hasil konsultasi dokter (opsional)
  final String? namaDokter;
  final String? subJudul; // contoh: "Konsultasi online"
  final String? avatarAsset;

  const RiwayatItem({
    required this.tanggal,
    required this.judul,
    required this.status,
    this.namaDokter,
    this.subJudul,
    this.avatarAsset,
  });
}

enum RiwayatStatus { tinggi, selesai, rendah }

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  static const List<RiwayatItem> _dummyData = [
    RiwayatItem(
      tanggal: '12 November 2025 • 10.59',
      judul: 'Jantung berdebar sekali, pusing',
      status: RiwayatStatus.tinggi,
    ),
    RiwayatItem(
      tanggal: '06 Agustus 2025 • 17.23',
      judul: 'Konsultasi online',
      subJudul: 'Konsultasi online',
      namaDokter: 'dr. Nurlitta Dwi',
      avatarAsset: 'assets/images/dr_nurlitta.png',
      status: RiwayatStatus.selesai,
    ),
    RiwayatItem(
      tanggal: '12 April 2025 • 10.59',
      judul: 'Mudah lelah setelah beraktivitas',
      status: RiwayatStatus.rendah,
    ),
  ];

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScreeningIntroPage()),
        );
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Halaman Dokter segera hadir')),
        );
        break;
      case 3:
        // Sudah berada di halaman Riwayat
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: tombol back + judul "Riwayat"
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F3F6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF1E293B),
                        size: 26,
                      ),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Riwayat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
            ),

            // Daftar riwayat
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: _dummyData.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return _RiwayatCard(item: _dummyData[index]);
                },
              ),
            ),

            // Bottom Navigation
            HeartCareBottomNavBar(
              currentIndex: 3,
              onTap: (index) => _onNavTap(context, index),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  final RiwayatItem item;

  const _RiwayatCard({required this.item});

  _StatusStyle get _style {
    switch (item.status) {
      case RiwayatStatus.tinggi:
        return const _StatusStyle(
          cardColor: Color(0xFFFCE7E9),
          badgeColor: Color(0xFFEF4444),
          badgeTextColor: Colors.white,
          label: 'TINGGI',
        );
      case RiwayatStatus.selesai:
        return const _StatusStyle(
          cardColor: Color(0xFFF3F4F6),
          badgeColor: Color(0xFFDBEAFE),
          badgeTextColor: Color(0xFF2563EB),
          label: 'SELESAI',
        );
      case RiwayatStatus.rendah:
        return const _StatusStyle(
          cardColor: Color(0xFFE7F8ED),
          badgeColor: Color(0xFF22C55E),
          badgeTextColor: Colors.white,
          label: 'RENDAH',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final bool isKonsultasi = item.namaDokter != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: style.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isKonsultasi)
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFD8F1F8),
                  child: ClipOval(
                    child: Image.asset(
                      item.avatarAsset ?? '',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 20,
                          color: Color(0xFF079BC1),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.namaDokter!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                _StatusBadge(style: style),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.tanggal,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                _StatusBadge(style: style),
              ],
            ),

          if (isKonsultasi) ...[
            const SizedBox(height: 6),
            Text(
              item.tanggal,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],

          const SizedBox(height: 8),
          Text(
            isKonsultasi ? (item.subJudul ?? item.judul) : item.judul,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: () {
                // TODO: navigasi ke halaman detail riwayat
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Lihat Detail',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  final Color cardColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final String label;

  const _StatusStyle({
    required this.cardColor,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.label,
  });
}

class _StatusBadge extends StatelessWidget {
  final _StatusStyle style;

  const _StatusBadge({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: style.badgeTextColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
