import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

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
                          'Riwayat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // RIWAYAT 1
                    _historyCard(
                      date: '12 November 2025 • 10:59',
                      status: 'TINGGI',
                      statusColor: Colors.red,
                      backgroundColor: const Color(0xFFFFE6E6),
                      title: 'Jantung berdebar sekali, pusing',
                      onTap: () {},
                    ),

                    const SizedBox(height: 16),

                    // RIWAYAT 2
                    _historyCard(
                      date: '06 Agustus 2025 • 17:23',
                      status: 'SELESAI',
                      statusColor: const Color(0xFF159BC2),
                      backgroundColor: const Color(0xFFE9E9E9),
                      title: 'Konsultasi online',
                      doctor: 'dr. Nurlita Dwi',
                      image: 'assets/images/profile_woman.png',
                      onTap: () {},
                    ),

                    const SizedBox(height: 16),

                    // RIWAYAT 3
                    _historyCard(
                      date: '12 April 2025 • 10:59',
                      status: 'RENDAH',
                      statusColor: const Color(0xFF42C957),
                      backgroundColor: const Color(0xFFE5FFE8),
                      title: 'Mudah lelah setelah beraktivitas',
                      onTap: () {},
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

  Widget _historyCard({
    required String date,
    required String status,
    required Color statusColor,
    required Color backgroundColor,
    required String title,
    required VoidCallback onTap,
    String? doctor,
    String? image,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (image != null)
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: ClipOval(
                    child: Image.asset(
                      image,
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 6,
                        color: Colors.grey,
                      ),
                    ),

                    if (doctor != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        doctor,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 6,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            height: 20,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: const BorderSide(
                  color: Color(0xFFB5B5B5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(
                'Lihat Detail',
                style: TextStyle(
                  fontSize: 7,
                  color: Color(0xFF159BC2),
                ),
              ),
            ),
          ),
        ],
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
          _navItem(
            Icons.medical_services_outlined,
            'Dokter',
            false,
          ),
          _navItem(
            Icons.description_outlined,
            'Riwayat',
            true,
          ),
          _navItem(Icons.person_outline, 'Profil', false),
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