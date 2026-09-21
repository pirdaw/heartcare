import 'package:flutter/material.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({super.key});

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
                          'Tentang Aplikasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // INFO APLIKASI
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        border: Border.all(
                          color: const Color(0xFFD0D0D0),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3BB7E8),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'MedTriage',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Aplikasi yang membantu pengguna melakukan '
                            'skrining dini kesehatan jantung, berkonsultasi '
                            'dengan tenaga kesehatan, serta memantau kondisi '
                            'jantung secara mudah dan praktis untuk mendukung '
                            'pencegahan penyakit jantung.',
                            style: TextStyle(
                              fontSize: 7,
                              height: 1.35,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // VISI MISI
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFD0D0D0),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visi',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 7),

                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.visibility_outlined,
                                size: 30,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Menjadi platform layanan kesehatan '
                                  'jantung yang terpercaya dalam membantu '
                                  'masyarakat melakukan skrining dini, '
                                  'konsultasi kesehatan, dan pemantauan '
                                  'kondisi secara mudah, cepat, dan berkelanjutan.',
                                  style: const TextStyle(
                                    fontSize: 7,
                                    height: 1.35,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            'Misi',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 7),

                          _mission(
                            Icons.track_changes,
                            'Menyediakan layanan skrining kesehatan '
                            'jantung secara mudah dan cepat untuk membantu '
                            'deteksi dini faktor risiko penyakit jantung.',
                          ),

                          const SizedBox(height: 8),

                          _mission(
                            Icons.medical_services_outlined,
                            'Memberikan akses konsultasi dengan tenaga '
                            'kesehatan secara praktis melalui platform digital.',
                          ),

                          const SizedBox(height: 8),

                          _mission(
                            Icons.menu_book_outlined,
                            'Menyajikan informasi dan edukasi kesehatan '
                            'jantung yang akurat, mudah dipahami, dan berbasis '
                            'praktik kesehatan.',
                          ),
                        ],
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

  Widget _mission(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 25,
          color: Colors.grey,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 7,
              height: 1.35,
              color: Colors.grey,
            ),
          ),
        ),
      ],
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