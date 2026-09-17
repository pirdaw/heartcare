import 'package:flutter/material.dart';

class PilihDokterPage extends StatelessWidget {
  const PilihDokterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // HEADER
            // =========================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.chevron_left,
                        size: 28,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const Expanded(
                    child: Center(
                      child: Text(
                        "Pilih Dokter",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 38),
                ],
              ),
            ),

            // =========================
            // CONTENT
            // =========================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 5),

                    // =========================
                    // SEARCH BAR
                    // =========================
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFB8CDD4),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 28,
                            color: Color(0xFF555555),
                          ),
                          hintText: "Cari dokter atau spesialis",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // =========================
                    // CATEGORY
                    // =========================
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _categoryButton(
                            "Semua",
                            selected: true,
                          ),
                          _categoryButton("Umum"),
                          _categoryButton("Anak"),
                          _categoryButton("Penyakit Dalam"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // =========================
                    // DOCTOR LIST
                    // =========================
                    _doctorCard(
                      image: "assets/images/dokter1.png",
                      name: "dr. Nurlitta Dwi",
                      specialist: "Dokter Umum",
                    ),

                    _doctorCard(
                      image: "assets/images/dokter2.png",
                      name: "dr. Alvian Pratama, Sp.PD",
                      specialist: "Dokter Spesialis Penyakit Dalam",
                    ),

                    _doctorCard(
                      image: "assets/images/dokter3.png",
                      name: "dr. Aisyah Putri, Sp.A",
                      specialist: "Dokter Spesialis Anak",
                    ),

                    _doctorCard(
                      image: "assets/images/dokter4.png",
                      name: "dr. Adrian Mahendra, Sp.B",
                      specialist: "Dokter Spesialis Bedah",
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar: Container(
        height: 82,
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomItem(
              Icons.home_outlined,
              "Home",
              false,
            ),
            _bottomItem(
              Icons.favorite_border,
              "Skrining",
              false,
            ),
            _bottomItem(
              Icons.person_outline,
              "Dokter",
              true,
            ),
            _bottomItem(
              Icons.description_outlined,
              "Riwayat",
              false,
            ),
            _bottomItem(
              Icons.person_outline,
              "Profil",
              false,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // CATEGORY BUTTON
  // =========================================================

  static Widget _categoryButton(
    String text, {
    bool selected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 7),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF079BC0)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? const Color(0xFF079BC0)
              : const Color(0xFFD0D0D0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: selected
              ? Colors.white
              : const Color(0xFF555555),
        ),
      ),
    );
  }

  // =========================================================
  // DOCTOR CARD
  // =========================================================

  static Widget _doctorCard({
    required String image,
    required String name,
    required String specialist,
  }) {
    return Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [

          // FOTO DOKTER
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE7E7E7),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  size: 35,
                  color: Colors.grey,
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // NAMA + SPESIALIS
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  specialist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                // STATUS ONLINE
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF55C900),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "Online",
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF55C900),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // PANAH
          const Icon(
            Icons.chevron_right,
            size: 25,
            color: Color(0xFF444444),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOTTOM NAV ITEM
  // =========================================================

  static Widget _bottomItem(
    IconData icon,
    String label,
    bool selected,
  ) {
    return SizedBox(
      width: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 27,
            color: selected
                ? const Color(0xFF087EFF)
                : Colors.black87,
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: selected
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: selected
                  ? const Color(0xFF087EFF)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}