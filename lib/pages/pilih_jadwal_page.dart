import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heartcare/services/theme_service.dart';
import '../services/user_profile_service.dart';
import '../services/profile_service.dart';
import 'home_page.dart';
import 'konfirmasi_jadwal_page.dart';
import 'profil_page.dart';

class PilihJadwalPage extends StatefulWidget {
  final String? doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorPhoto;

  const PilihJadwalPage({
    super.key,
    this.doctorId,
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
  String selectedConsultationType = 'video'; // 'video' atau 'chat'


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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
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
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F3F6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.chevron_left,
                            size: 28,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),

                      // JUDUL
                      Expanded(
                        child: Center(
                          child: Text(
                            "Pilih Jadwal",
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                        Text(
                          "September 2026",
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155),
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
                                        gradient: isSelected
                                            ? const LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color(0xFF0EA5E9),
                                                  Color(0xFF0284C7),
                                                ],
                                              )
                                            : null,
                                        color: isSelected
                                            ? null
                                            : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF0284C7)
                                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                          width: 1.2,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF0284C7).withValues(alpha: 0.30),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            item["day"]!,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.white
                                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
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
                                                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
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

                        const SizedBox(height: 24),

                        // ==========================================
                        // METODE KONSULTASI: VIDEO CALL VS CHAT
                        // ==========================================
                        _buildConsultationTypeSelector(isDark),

                        const SizedBox(height: 26),

                        // PAGI
                        _timeSection(
                          isDark: isDark,
                          title: "Pagi",
                          times: morningTimes,
                        ),

                        const SizedBox(height: 24),

                        // SIANG
                        _timeSection(
                          isDark: isDark,
                          title: "Siang",
                          times: afternoonTimes,
                        ),

                        const SizedBox(height: 24),

                        // SORE
                        _timeSection(
                          isDark: isDark,
                          title: "Sore",
                          times: eveningTimes,
                        ),

                        const SizedBox(height: 36),

                        // TOMBOL KONFIRMASI JADWAL
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: selectedTime == null
                                  ? null
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFF0EA5E9),
                                        Color(0xFF0284C7),
                                      ],
                                    ),
                              color: selectedTime == null
                                  ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1))
                                  : null,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: selectedTime == null
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: const Color(0xFF0284C7).withValues(alpha: 0.28),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                            ),
                            child: ElevatedButton(
                              onPressed: selectedTime == null
                                  ? null
                                  : _onConfirmSchedule,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                disabledBackgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
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
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BOTTOM NAVIGATION
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _bottomNavItem(
                    isDark: isDark,
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
                    isDark: isDark,
                    icon: Icons.favorite_border,
                    label: "Skrining",
                    active: false,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _bottomNavItem(
                    isDark: isDark,
                    icon: Icons.medical_services_outlined,
                    label: "Dokter",
                    active: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _bottomNavItem(
                    isDark: isDark,
                    icon: Icons.description_outlined,
                    label: "Riwayat",
                    active: false,
                  ),
                  _bottomNavItem(
                    isDark: isDark,
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
      },
    );
  }

  Widget _timeSection({
    required bool isDark,
    required String title,
    required List<String> times,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const int crossAxisCount = 5;
            const double spacing = 8;
            final double itemWidth =
                (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                    crossAxisCount;

            return Wrap(
              spacing: spacing,
              runSpacing: 10,
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
                      width: itemWidth,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF0EA5E9),
                                  Color(0xFF0284C7),
                                ],
                              )
                            : null,
                        color: isSelected
                            ? null
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF4F6F8)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0284C7)
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          width: 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.22),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConsultationTypeSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.video_camera_front_rounded,
              size: 18,
              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
            ),
            const SizedBox(width: 8),
            Text(
              "Pilih Metode Konsultasi:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Opsi 1: Video Call Langsung
            Expanded(
              child: _consultationTypeCard(
                isDark: isDark,
                type: 'video',
                title: 'Video Call',
                subtitle: 'Tatap muka & bicara langsung keluhan',
                icon: Icons.videocam_rounded,
                badge: 'Rekomendasi',
                badgeColor: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 10),
            // Opsi 2: Chat Online
            Expanded(
              child: _consultationTypeCard(
                isDark: isDark,
                type: 'chat',
                title: 'Chat Online',
                subtitle: 'Konsultasi via chat teks & kirim foto',
                icon: Icons.chat_bubble_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _consultationTypeCard({
    required bool isDark,
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    String? badge,
    Color? badgeColor,
  }) {
    final bool isSelected = selectedConsultationType == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedConsultationType = type;
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? const Color(0xFF0284C7).withValues(alpha: 0.18)
                    : const Color(0xFFE0F2FE))
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0284C7)
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0284C7)
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 17,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                  ),
                  const Spacer(),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (badgeColor ?? const Color(0xFF10B981)).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: badgeColor ?? const Color(0xFF10B981),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? const Color(0xFF0284C7)
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.25,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onConfirmSchedule() {
    if (selectedTime == null) return;

    final formattedDate = '$selectedDayName, $selectedDay September 2026';
    UserProfileData? profile;
    try {
      profile = UserProfileService.instance.currentProfile;
    } catch (_) {}
    final resolvedPatientName = profile != null && profile.nama.isNotEmpty
        ? profile.nama
        : 'Pasien HeartCare';
    final resolvedPatientPhoto = profile != null && profile.fotoProfil.isNotEmpty
        ? profile.fotoProfil
        : ProfileService.instance.currentImagePath;
    String? currentUid;
    try {
      currentUid = FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {}

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KonfirmasiJadwalPage(
          doctorId: widget.doctorId,
          doctorName: widget.doctorName,
          doctorSpecialty: widget.doctorSpecialty,
          doctorPhoto: widget.doctorPhoto,
          selectedDate: formattedDate,
          selectedTime: selectedTime!,
          consultationType: selectedConsultationType,
          patientName: resolvedPatientName,
          patientPhoto: resolvedPatientPhoto,
          patientId: currentUid,
        ),
      ),
    );
  }

  Widget _bottomNavItem({
    required bool isDark,
    required IconData icon,
    required String label,
    required bool active,
    VoidCallback? onTap,
  }) {
    final activeColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF1479F5);
    final inactiveColor = isDark ? const Color(0xFF64748B) : const Color(0xFF64748B);

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
              color: active ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}