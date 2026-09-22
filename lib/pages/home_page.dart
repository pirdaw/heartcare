import 'package:flutter/material.dart';
import 'screening_intro_page.dart';
import 'dokter_page.dart';
import 'emergency_page.dart';
import 'education_page.dart';
import 'pengingat_kesehatan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Menu Skrining
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreeningIntroPage(),
        ),
      );
    }

    // Menu Dokter
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PilihDokterPage(),
        ),
      );
    }
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
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ==================================================
                    // HEADER
                    // ==================================================

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFD8F1F8),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/profile_woman.png',
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 38,
                                  color: Color(0xFF079BC1),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hallo, Nadea...',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                'Apa yang bisa kami bantu\n'
                                'hari ini?',
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.25,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ==================================================
                        // EMERGENCY
                        // ==================================================

                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EmergencyPage(),
                              ),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 42,
                            minHeight: 42,
                          ),
                          icon: const Icon(
                            Icons.notifications_active,
                            color: Color(0xFFFF1F35),
                            size: 32,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // CARD SKRINING
                    // ==================================================

                    Container(
                      width: double.infinity,
                      height: 205,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9F0F9),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.10),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(
                              14,
                              16,
                              90,
                              12,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Skrining Risiko Jantung',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF263238),
                                  ),
                                ),

                                const SizedBox(height: 7),

                                const Text(
                                  'Kenali faktor risiko jantung Anda\n'
                                  'melalui skrining kesehatan\n'
                                  'sederhana menggunakan aplikasi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.3,
                                    color: Color(0xFF263238),
                                  ),
                                ),

                                const Spacer(),

                                SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ScreeningIntroPage(),
                                        ),
                                      );
                                    },
                                    style:
                                        ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF079BC1),
                                      foregroundColor:
                                          Colors.white,
                                      elevation: 0,
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Mulai Skrining',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Positioned(
                            right: 4,
                            bottom: 10,
                            child: SizedBox(
                              width: 90,
                              height: 90,
                              child: Image.asset(
                                'assets/images/screening_jantung.png',
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 62,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // JUDUL LAYANAN
                    // ==================================================

                    const Text(
                      'Layanan Kesehatan',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ==================================================
                    // BARIS 1
                    // ==================================================

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
  child: _serviceCard(
    icon: Icons.notifications_none,
    title: 'Pengingat Kesehatan',
    description:
        'Pengingat agar tidak melewati kegiatan penting.',
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const PengingatKesehatanPage(),
        ),
      );
    },
  ),
),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _serviceCard(
                            icon: Icons.person_outline,
                            title: 'Konsultasi Dokter',
                            description:
                                'Konsultasikan kondisi kesehatan Anda dengan dokter.',
                            iconColor:
                                const Color(0xFF2680EB),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PilihDokterPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ==================================================
                    // BARIS 2
                    // ==================================================

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _serviceCard(
                            icon: Icons.favorite,
                            title:
                                'Program Kesehatan Jantung',
                            description:
                                'Ikuti program untuk menjaga kesehatan jantung Anda.',
                            iconColor:
                                const Color(0xFFFF6675),
                            circleColor:
                                const Color(0xFFEAF7FA),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // ==================================================
                        // EDUKASI KESEHATAN
                        // ==================================================

                        Expanded(
                          child: _serviceCard(
                            icon:
                                Icons.menu_book_outlined,
                            title: 'Edukasi Kesehatan',
                            description:
                                'Dapatkan informasi dan tips menjaga kesehatan Anda.',
                            iconColor:
                                const Color(0xFF237BEA),

                            // HOME → EDUCATION PAGE
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EducationPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ==================================================
            // BOTTOM NAVIGATION
            // ==================================================

            Container(
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
                  _bottomItem(
                    icon: Icons.home,
                    label: 'Home',
                    index: 0,
                  ),

                  _bottomItem(
                    icon: Icons.favorite_border,
                    label: 'Skrining',
                    index: 1,
                  ),

                  _bottomItem(
                    icon:
                        Icons.medical_services_outlined,
                    label: 'Dokter',
                    index: 2,
                  ),

                  _bottomItem(
                    icon: Icons.description_outlined,
                    label: 'Riwayat',
                    index: 3,
                  ),

                  _bottomItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
                    index: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // SERVICE CARD
  // ==============================================================

  Widget _serviceCard({
    required IconData icon,
    required String title,
    required String description,
    Color iconColor = Colors.black,
    Color circleColor =
        const Color(0xFFF1F1F1),
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 170,
        padding: const EdgeInsets.fromLTRB(
          12,
          11,
          10,
          10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(7),
          border: Border.all(
            color: const Color(0xFFDCDCDC),
            width: 0.9,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: circleColor,
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 35,
                color: iconColor,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.bold,
                height: 1.15,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 5),

            Expanded(
              child: Text(
                description,
                maxLines: 4,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.25,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // BOTTOM NAV ITEM
  // ==============================================================

  Widget _bottomItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool active =
        _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 55,
        height: 58,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 25,
              color: active
                  ? const Color(0xFF1479F5)
                  : Colors.black87,
            ),

            const SizedBox(height: 2),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: active
                    ? const Color(0xFF1479F5)
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}