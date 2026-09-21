import 'package:flutter/material.dart';
import 'login_page.dart';
import 'data_kesehatan_page.dart';
import 'pengaturan_page.dart';
import 'tentang_aplikasi_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Keluar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            TextButton(
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
              child: const Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon(String namaHalaman) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$namaHalaman belum dibuat'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 28),

                    const Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 135,
                          height: 135,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFA9DDF1),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/profile.png',
                              width: 135,
                              height: 135,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 90,
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                        ),

                        Positioned(
                          right: -3,
                          bottom: -2,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF37474F),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 27,
                              color: Color(0xFF37474F),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 17),

                    const Text(
                      'Nadea Fieldzah Putri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      '+62 123 456 799',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'nadea123@gmail.com',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 29),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 21),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 15),

                          _buildMenu(
                            icon: Icons.person_outline,
                            title: 'Data Pribadi',
                            onTap: () {
                              _showComingSoon('Data Pribadi');
                            },
                          ),

                          _buildMenu(
                            icon: Icons.medical_services_outlined,
                            title: 'Data Kesehatan',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DataKesehatanPage(),
                                ),
                              );
                            },
                          ),

                          _buildMenu(
                            icon: Icons.settings_outlined,
                            title: 'Pengaturan',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PengaturanPage(),
                                ),
                              );
                            },
                          ),

                          _buildMenu(
                            icon: Icons.info_outline,
                            title: 'Tentang Aplikasi',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TentangAplikasiPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE5E5E5),
                    ),

                    const SizedBox(height: 38),

                    GestureDetector(
                      onTap: _showLogoutDialog,
                      child: const Text(
                        'Keluar',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 68),
                  ],
                ),
              ),
            ),

            Container(
              height: 69,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFDADADA),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    selected: false,
                    onTap: () {
                      _showComingSoon('Home');
                    },
                  ),

                  _buildBottomItem(
                    icon: Icons.favorite_border,
                    label: 'Skrining',
                    selected: false,
                    onTap: () {
                      _showComingSoon('Skrining');
                    },
                  ),

                  _buildBottomItem(
                    icon: Icons.medical_services_outlined,
                    label: 'Dokter',
                    selected: false,
                    onTap: () {
                      _showComingSoon('Dokter');
                    },
                  ),

                  _buildBottomItem(
                    icon: Icons.description_outlined,
                    label: 'Riwayat',
                    selected: false,
                    onTap: () {
                      _showComingSoon('Riwayat');
                    },
                  ),

                  _buildBottomItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
                    selected: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF37474F),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF444444),
                ),
              ),
            ),

            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Color(0xFF44474F),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 27,
              color: selected
                  ? const Color(0xFF005CFF)
                  : Colors.black,
            ),

            const SizedBox(height: 2),

            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: selected
                    ? const Color(0xFF005CFF)
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}