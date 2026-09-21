import 'package:flutter/material.dart';

class DataKesehatanPage extends StatelessWidget {
  const DataKesehatanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      children: [
                        _backButton(context),
                        const SizedBox(width: 18),
                        const Text(
                          'Data Kesehatan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 38),

                    const Text(
                      'Informasi Kesehatan',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // DATA KESEHATAN
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF999999),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _healthItem(
                            'Golongan Darah',
                            'O',
                          ),
                          _divider(),
                          _healthItem(
                            'Tinggi Badan',
                            '167 cm',
                          ),
                          _divider(),
                          _healthItem(
                            'Berat Badan',
                            '51 kg',
                          ),
                          _divider(),
                          _healthItem(
                            'Alergi',
                            'Tidak ada',
                          ),
                          _divider(),
                          _healthItem(
                            'Penyakit yang diderita',
                            'Tidak ada',
                          ),
                          _divider(),
                          _healthItem(
                            'Riwayat Operasi',
                            'Tidak ada',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // TOMBOL UBAH DATA
                    SizedBox(
                      width: double.infinity,
                      height: 31,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF119FC2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Ubah Data',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _bottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F1F1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 16,
        ),
      ),
    );
  }

  Widget _healthItem(String title, String value) {
    return SizedBox(
      height: 49,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 0.7,
      color: Color(0xFFD5D5D5),
    );
  }

  Widget _bottomNavigation() {
    return Container(
      height: 55,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, 'Home', false),
          _navItem(Icons.favorite_border, 'Skrining', false),
          _navItem(Icons.medical_services_outlined, 'Dokter', false),
          _navItem(Icons.description_outlined, 'Riwayat', false),
          _navItem(Icons.person_outline, 'Profil', true),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String title,
    bool active,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 21,
          color: active
              ? const Color(0xFF006EFF)
              : Colors.black87,
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 7,
            color: active
                ? const Color(0xFF006EFF)
                : Colors.black87,
            fontWeight:
                active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}