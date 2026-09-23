import 'package:flutter/material.dart';
import 'home_page.dart';
import 'konsultasi_dokter_page.dart';

class KonfirmasiJadwalPage extends StatelessWidget {
  final String doctorName;
  final String doctorSpecialty;
  final String doctorPhoto;
  final String selectedDate;
  final String selectedTime;

  const KonfirmasiJadwalPage({
    super.key,
    this.doctorName = 'dr. Nurlitta Dwi',
    this.doctorSpecialty = 'Spesialis Jantung',
    this.doctorPhoto = 'assets/images/dokter_nurlitta.jpg',
    this.selectedDate = '2 September 2026',
    this.selectedTime = '09.00',
  });

  static const Color brandTeal = Color(0xFF0098B9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0F172A),
                size: 18,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Konfirmasi Jadwal',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ==========================================
              // ICON SUKSES TERKONFIRMASI
              // ==========================================
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7FB),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFB4E3EE),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: brandTeal.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: brandTeal,
                  size: 46,
                ),
              ),

              const SizedBox(height: 18),

              // ==========================================
              // TITLE & SUBTITLE
              // ==========================================
              const Text(
                'Jadwal Berhasil Dipilih!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Jadwal konsultasi Anda telah tersimpan di sistem. Silakan lanjutkan konsultasi atau kembali ke beranda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // KARTU DETAIL JADWAL KONSULTASI
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ROW DOKTER
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: brandTeal.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              doctorPhoto,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.person,
                                color: brandTeal,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctorName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                doctorSpecialty,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: brandTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),

                    // RINCIAN WAKTU & LAYANAN
                    _detailRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Tanggal Konsultasi',
                      value: selectedDate,
                    ),
                    const SizedBox(height: 12),
                    _detailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Waktu Konsultasi',
                      value: 'Pukul $selectedTime WIB',
                    ),
                    const SizedBox(height: 12),
                    _detailRow(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Layanan',
                      value: 'Konsultasi Online via Chat',
                    ),
                    const SizedBox(height: 12),
                    _detailRow(
                      icon: Icons.verified_rounded,
                      label: 'Status',
                      value: 'Terkonfirmasi',
                      valueColor: const Color(0xFF10B981),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==========================================
              // TOMBOL 1: KONSULTASI DOKTER LEWAT CHAT
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KonsultasiDokterPage(
                          doctorName: doctorName,
                          doctorPhoto: doctorPhoto,
                          doctorSpecialty: doctorSpecialty,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_rounded,
                        size: 19,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Konsultasi Dokter Lewat Chat',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ==========================================
              // TOMBOL 2: KEMBALI KE BERANDA
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_rounded,
                        size: 20,
                        color: Color(0xFF64748B),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
