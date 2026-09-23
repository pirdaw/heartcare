import 'package:flutter/material.dart';
import 'home_page.dart';
import 'konfirmasi_jadwal_page.dart';
import 'profil_page.dart';

class PilihJadwalPage extends StatefulWidget {
  final String doctorName;
  final String doctorSpecialty;
  final String doctorPhoto;

  const PilihJadwalPage({
    super.key,
    this.doctorName = 'dr. Nurlitta Dwi',
    this.doctorSpecialty = 'Spesialis Jantung',
    this.doctorPhoto = 'assets/images/dokter_nurlitta.jpg',
  });

  @override
  State<PilihJadwalPage> createState() => _PilihJadwalPageState();
}

class _PilihJadwalPageState extends State<PilihJadwalPage> {
  int selectedDay = 2;
  String selectedDayName = 'Sel';
  String? selectedTime = '09.00';

  static const Color brandTeal = Color(0xFF0098B9);

  final List<Map<String, String>> dates = [
    {"day": "Sen", "date": "1"},
    {"day": "Sel", "date": "2"},
    {"day": "Rab", "date": "3"},
    {"day": "Kam", "date": "4"},
    {"day": "Jum", "date": "5"},
    {"day": "Sab", "date": "6"},
    {"day": "Min", "date": "7"},
  ];

  final List<String> morningTimes = [
    "08.00",
    "08.30",
    "09.00",
    "09.30",
    "10.00",
  ];

  final List<String> afternoonTimes = [
    "13.00",
    "13.30",
    "14.00",
    "14.30",
    "15.00",
  ];

  final List<String> eveningTimes = [
    "16.00",
    "17.00",
    "17.30",
  ];

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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  // TOMBOL KEMBALI BUNDAR
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F3F6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.chevron_left,
                        size: 28,
                        color: Color(0xFF1E293B),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  // JUDUL
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Pilih Jadwal",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),

                  // PENYEIMBANG KANAN
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // ==================================================
            // CONTENT PEMILIHAN JADWAL
            // ==================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BULAN & TAHUN
                    const Text(
                      "September 2026",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // BARIS 7 KAPSUL HARI (Sen 1 - Min 7)
                    Row(
                      children: dates.map((item) {
                        final int day = int.parse(item["date"]!);
                        final bool isSelected = selectedDay == day;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.5),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedDay = day;
                                    selectedDayName = item["day"]!;
                                  });
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? brandTeal
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? brandTeal
                                          : const Color(0xFFE2E8F0),
                                      width: 1.2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: brandTeal
                                                  .withValues(alpha: 0.25),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item["day"]!,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF475569),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        item["date"]!,
                                        style: TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // PAGI
                    // ==================================================
                    _timeSection(
                      title: "Pagi",
                      times: morningTimes,
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // SIANG
                    // ==================================================
                    _timeSection(
                      title: "Siang",
                      times: afternoonTimes,
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // SORE
                    // ==================================================
                    _timeSection(
                      title: "Sore",
                      times: eveningTimes,
                    ),

                    const SizedBox(height: 36),

                    // ==================================================
                    // TOMBOL KONFIRMASI JADWAL (TEAL)
                    // ==================================================
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: selectedTime == null
                            ? null
                            : _onConfirmSchedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandTeal,
                          disabledBackgroundColor: const Color(0xFFB4E3EE),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Konfirmasi Jadwal",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ==================================================
      // BOTTOM NAVIGATION (SESUAI GAMBAR)
      // ==================================================
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 62,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bottomNavItem(
                icon: Icons.home_outlined,
                label: "Home",
                active: false,
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
              ),
              _bottomNavItem(
                icon: Icons.favorite_border,
                label: "Skrining",
                active: false,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _bottomNavItem(
                icon: Icons.medical_services_outlined,
                label: "Dokter",
                active: true,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _bottomNavItem(
                icon: Icons.description_outlined,
                label: "Riwayat",
                active: false,
              ),
              _bottomNavItem(
                icon: Icons.person_outline,
                label: "Profil",
                active: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // WIDGET KELOMPOK WAKTU (PAGI / SIANG / SORE)
  // ==========================================================
  Widget _timeSection({
    required String title,
    required List<String> times,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: times.map((time) {
            final bool isSelected = selectedTime == time;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedTime = time;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? brandTeal : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? brandTeal
                          : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: brandTeal.withValues(alpha: 0.20),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ==========================================================
  // AKSI KONFIRMASI: MEMBUKA HALAMAN BARU (BUKAN POP-UP)
  // ==========================================================
  void _onConfirmSchedule() {
    if (selectedTime == null) return;

    final formattedDate = '$selectedDayName, $selectedDay September 2026';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KonfirmasiJadwalPage(
          doctorName: widget.doctorName,
          doctorSpecialty: widget.doctorSpecialty,
          doctorPhoto: widget.doctorPhoto,
          selectedDate: formattedDate,
          selectedTime: selectedTime!,
        ),
      ),
    );
  }

  // ==========================================================
  // BOTTOM NAVIGATION ITEM
  // ==========================================================
  Widget _bottomNavItem({
    required IconData icon,
    required String label,
    required bool active,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 23,
              color: active ? brandTeal : const Color(0xFF64748B),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? brandTeal : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}