import 'package:flutter/material.dart';
import 'data_pribadi_page.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

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
                  children: [
                    const Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // FOTO PROFIL
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFB9E9FA),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/profile_woman.png',
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 65,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                        ),

                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 29,
                            height: 29,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Nadea Fieldzah Putri',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    const Text(
                      '+62 123 456 789',
                      style: TextStyle(
                        fontSize: 6,
                        color: Colors.grey,
                      ),
                    ),

                    const Text(
                      'nadea123@gmail.com',
                      style: TextStyle(
                        fontSize: 6,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 17),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Informasi',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    // DATA PRIBADI
                    _profileMenu(
                      icon: Icons.person_outline,
                      title: 'Data Pribadi',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DataPribadiPage(),
                          ),
                        );
                      },
                    ),

                    _profileMenu(
                      icon: Icons.medical_information_outlined,
                      title: 'Data Kesehatan',
                      onTap: () {},
                    ),

                    _profileMenu(
                      icon: Icons.settings_outlined,
                      title: 'Pengaturan',
                      onTap: () {},
                    ),

                    _profileMenu(
                      icon: Icons.info_outline,
                      title: 'Tentang Aplikasi',
                      onTap: () {},
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                      child: const Text(
                        'Keluar',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
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

  Widget _profileMenu({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 27,
        child: Row(
          children: [
            Icon(
              icon,
              size: 13,
              color: Colors.black87,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 7,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 13,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE0E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 27,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Konfirmasi Log Out',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Apakah Anda yakin ingin keluar\n'
                  'dari akun?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 7,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 24,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: SizedBox(
                        height: 24,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                          child: const Text(
                            'Keluar',
                            style: TextStyle(
                              fontSize: 8,
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
          _navItem(
            Icons.medical_services_outlined,
            'Dokter',
            false,
          ),
          _navItem(
            Icons.description_outlined,
            'Riwayat',
            false,
          ),
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
          ),
        ),
      ],
    );
  }
}