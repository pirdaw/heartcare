import 'package:flutter/material.dart';
import 'pilih_jadwal_page.dart';

class DetailDokterPage extends StatelessWidget {
  const DetailDokterPage({super.key});

  static const Color primaryBlue = Color(0xFF079BC0);
  static const Color activeBlue = Color(0xFF087EFF);
  static const Color onlineGreen = Color(0xFF55C900);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // HEADER
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                12,
                18,
                0,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

                  // TOMBOL KEMBALI
                  Container(
                    width: 38,
                    height: 38,
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
                        Icons.chevron_left,
                        size: 28,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // BOOKMARK
                  Row(
                    children: [

                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(),
                        onPressed: () {},
                        icon: const Icon(
                          Icons.bookmark_border,
                          size: 24,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(width: 10),

                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(),
                        onPressed: () {},
                        icon: const Icon(
                          Icons.share_outlined,
                          size: 23,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==================================================
            // ISI HALAMAN
            // ==================================================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [

                    const SizedBox(height: 5),

                    // ==================================================
                    // FOTO DOKTER
                    // ==================================================

                    Container(
                      width: 138,
                      height: 138,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE9E9E9),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/dokter_nurlitta.png',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 75,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 13),

                    // ==================================================
                    // NAMA
                    // ==================================================

                    const Text(
                      'dr. Nurlitta Dwi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 3),

                    const Text(
                      'Spesialis Jantung',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888888),
                      ),
                    ),

                    const SizedBox(height: 7),

                    // STATUS ONLINE
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: const [

                        Icon(
                          Icons.circle,
                          size: 9,
                          color: onlineGreen,
                        ),

                        SizedBox(width: 5),

                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 9,
                            color: onlineGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // INFORMASI
                    // ==================================================

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Informasi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // PENGALAMAN
                    _informationRow(
                      icon: Icons.business_center_outlined,
                      title: 'Pengalaman',
                      value: '8 tahun',
                    ),

                    const SizedBox(height: 11),

                    // SIP
                    _informationRow(
                      icon: Icons.description_outlined,
                      title: 'SIP',
                      value: '2406/SIP/2023',
                    ),

                    const SizedBox(height: 11),

                    // LOKASI
                    _informationRow(
                      icon: Icons.location_on_outlined,
                      title: 'Lokasi Praktek',
                      value: 'Jember',
                    ),

                    const SizedBox(height: 27),

                    // ==================================================
                    // TENTANG DOKTER
                    // ==================================================

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tentang Dokter',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Berpengalaman dalam memberikan pemeriksaan '
                        'dan penanganan komprehensif terhadap berbagai '
                        'kondisi jantung dan kardiovaskular.',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.45,
                          color: Color(0xFF444444),
                        ),
                      ),
                    ),

                    const SizedBox(height: 17),

                    // ==================================================
                    // TOMBOL PILIH JADWAL
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 43,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PilihJadwalPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(7),
                          ),
                        ),
                        child: const Text(
                          'Pilih Jadwal',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================

      bottomNavigationBar:
          _buildBottomNavigation(),
    );
  }

  // ==========================================================
  // BARIS INFORMASI
  // ==========================================================

  static Widget _informationRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [

        SizedBox(
          width: 25,
          child: Icon(
            icon,
            size: 17,
            color: const Color(0xFF555555),
          ),
        ),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF555555),
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  static Widget _buildBottomNavigation() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [

          _bottomItem(
            Icons.home_outlined,
            'Home',
            false,
          ),

          _bottomItem(
            Icons.favorite_border,
            'Skrining',
            false,
          ),

          _bottomItem(
            Icons.person_outline,
            'Dokter',
            true,
          ),

          _bottomItem(
            Icons.description_outlined,
            'Riwayat',
            false,
          ),

          _bottomItem(
            Icons.person_outline,
            'Profil',
            false,
          ),
        ],
      ),
    );
  }

  static Widget _bottomItem(
    IconData icon,
    String label,
    bool active,
  ) {
    return SizedBox(
      width: 55,
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            size: 25,
            color: active
                ? const Color(0xFF087EFF)
                : Colors.black87,
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: active
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: active
                  ? const Color(0xFF087EFF)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}