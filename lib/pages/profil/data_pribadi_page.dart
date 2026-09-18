import 'package:flutter/material.dart';
import '../Skrining/custom_bottom_nav_bar.dart';
import '../screening_intro_page.dart';
import '../home_page.dart';
import '../riwayat_page.dart';
import 'profil_page.dart';

class _DataPribadiField {
  final String label;
  final String value;

  const _DataPribadiField({required this.label, required this.value});
}

class DataPribadiPage extends StatelessWidget {
  const DataPribadiPage({super.key});

  static const Color primaryTeal = Color(0xFF0098B9);

  // Data statis untuk contoh — ganti dengan data pengguna sesungguhnya.
  static const List<_DataPribadiField> _fields = [
    _DataPribadiField(label: 'Nama Lengkap', value: 'Nadea Fieldzah Putri'),
    _DataPribadiField(label: 'Jenis Kelamin', value: 'Perempuan'),
    _DataPribadiField(
      label: 'Tempat, Tanggal Lahir',
      value: 'Jember, 29 Februari 2004',
    ),
    _DataPribadiField(
      label: 'Alamat',
      value: 'Jl. Gandaria Tengah No. 24 Jakarta Selatan',
    ),
    _DataPribadiField(label: 'No. Telepon', value: '+62 123 456 799'),
    _DataPribadiField(label: 'Email', value: 'nadea123@gmail.com'),
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RiwayatPage()),
        );
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
            // Top bar: tombol back + judul "Data Pribadi"
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
                        'Data Pribadi',
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Pribadi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: List.generate(_fields.length, (index) {
                          final field = _fields[index];
                          final bool isLast = index == _fields.length - 1;
                          return Column(
                            children: [
                              _DataPribadiRow(
                                label: field.label,
                                value: field.value,
                                onTap: () {
                                  // TODO: navigasi ke form edit field ini
                                },
                              ),
                              if (!isLast)
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF1F3F6),
                                  indent: 16,
                                  endIndent: 16,
                                ),
                            ],
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur ubah data segera hadir'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Ubah Data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            HeartCareBottomNavBar(
              currentIndex: 4,
              onTap: (index) => _onNavTap(context, index),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataPribadiRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DataPribadiRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
