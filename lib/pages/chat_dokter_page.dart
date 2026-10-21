import 'package:flutter/material.dart';

class KonsultasiDokterPage extends StatefulWidget {
  const KonsultasiDokterPage({super.key});

  @override
  State<KonsultasiDokterPage> createState() =>
      _KonsultasiDokterPageState();
}

class _KonsultasiDokterPageState
    extends State<KonsultasiDokterPage> {
  final TextEditingController messageController =
      TextEditingController();

  String selectedReminder = "1 hari sebelumnya";

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  // ==========================================================
  // WARNA SESUAI DESAIN
  // ==========================================================

  static const Color primaryBlue = Color(0xFF079BC0);
  static const Color lightBlue = Color(0xFFD0ECF4);
  static const Color doctorBlue = Color(0xFF5BBBD4);
  static const Color onlineGreen = Color(0xFF55C900);

  // ==========================================================
  // HALAMAN UTAMA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // HEADER DOKTER
            // ==================================================

            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE1E1E1),
                    width: 1,
                  ),
                ),
              ),

              child: Row(
                children: [

                  // TOMBOL KEMBALI
                  Container(
                    width: 36,
                    height: 36,
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
                        size: 27,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // FOTO DOKTER
                  _doctorImage(
                    width: 44,
                    height: 44,
                  ),

                  const SizedBox(width: 10),

                  // NAMA DOKTER
                  const Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Konsultasi dengan",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),

                      Text(
                        "dr. Nurlitta Dwi",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),

                      SizedBox(height: 2),

                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: onlineGreen,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Online",
                            style: TextStyle(
                              fontSize: 9.5,
                              color: onlineGreen,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==================================================
            // CHAT
            // ==================================================

            Expanded(
              child: Column(
                children: [

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      children: [

                        // HARI INI
                        Center(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: lightBlue,
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "Hari ini",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF397A8A),
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // PESAN DOKTER
                        _doctorMessage(
                          "Halo Nadea, Selamat datang!\n"
                          "Ada yang bisa saya bantu?",
                          "14.00",
                        ),

                        const SizedBox(height: 18),

                        // PESAN USER
                        _userMessage(
                          "Dok, saya tadi melakukan skrining,\n"
                          "hasilnya risiko tinggi.\n"
                          "Apa yang harus saya lakukan?",
                          "14.01",
                        ),

                        const SizedBox(height: 10),

                        // FOTO HASIL SKRINING USER
                        _userImageMessage(
                          "assets/images/screening_jantung.png",
                          "14.01",
                        ),

                        const SizedBox(height: 18),

                        // PESAN DOKTER
                        _doctorMessage(
                          "Baik, saya akan bantu.\n"
                          "Apakah ada gejala lain\n"
                          "seperti nyeri dada atau sesak\n"
                          "nafas?",
                          "14.02",
                        ),

                        const SizedBox(height: 18),

                        // PESAN USER
                        _userMessage(
                          "Iya dok, saya sering sesak nafas saat\n"
                          "aktivitas berat",
                          "14.03",
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // INPUT PESAN
                  // ==================================================

                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      14,
                      8,
                      8,
                      8,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFFE1E1E1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [

                        Expanded(
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    const Color(0xFFAAAAAA),
                              ),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: TextField(
                              controller:
                                  messageController,
                              style: const TextStyle(
                                fontSize: 13.5,
                              ),
                              decoration:
                                  const InputDecoration(
                                hintText:
                                    "Ketik pesan....",
                                hintStyle: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 9,
                                ),
                                suffixIcon: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 21,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 7),

                        // TOMBOL KIRIM
                        Container(
                          width: 34,
                          height: 34,
                          decoration:
                              const BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              if (messageController
                                  .text
                                  .trim()
                                  .isNotEmpty) {
                                messageController.clear();
                              }
                            },
                            icon: const Icon(
                              Icons.send,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar: _bottomNavigation(),
    );
  }

  // ==========================================================
  // PESAN DOKTER
  // ==========================================================

  Widget _doctorMessage(
    String message,
    String time,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _doctorImage(
          width: 30,
          height: 30,
        ),

        const SizedBox(width: 8),

        Flexible(
          child: Container(
            constraints:
                const BoxConstraints(maxWidth: 245),
            padding: const EdgeInsets.fromLTRB(
              12,
              10,
              10,
              6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // PESAN USER
  // ==========================================================

  Widget _userMessage(
    String message,
    String time,
  ) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints:
            const BoxConstraints(maxWidth: 255),
        padding: const EdgeInsets.fromLTRB(
          12,
          10,
          10,
          6,
        ),
        decoration: BoxDecoration(
          color: doctorBlue,
          borderRadius:
              BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 3),

            Text(
              time,
              style: const TextStyle(
                fontSize: 9.5,
                color: Color(0xFF397080),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PESAN GAMBAR USER
  // ==========================================================

  Widget _userImageMessage(
    String imagePath,
    String time,
  ) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 210),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: doctorBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.white24,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_outlined,
                      color: Colors.white,
                      size: 36,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 2),
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: Color(0xFF397080),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // FOTO DOKTER
  // ==========================================================

  Widget _doctorImage({
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE6E6E6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        "assets/images/dokter_nurlitta.png",
        fit: BoxFit.cover,

        // Kalau gambar belum ada, coba profile_woman atau icon
        errorBuilder:
            (context, error, stackTrace) {
          return Image.asset(
            "assets/images/profile_woman.png",
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.person,
                color: Colors.grey,
                size: width * 0.6,
              );
            },
          );
        },
      ),
    );
  }

  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  Widget _bottomNavigation() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [

          _navItem(
            Icons.home_outlined,
            "Home",
            false,
          ),

          _navItem(
            Icons.favorite_border,
            "Skrining",
            false,
          ),

          _navItem(
            Icons.person_outline,
            "Dokter",
            true,
          ),

          _navItem(
            Icons.description_outlined,
            "Riwayat",
            false,
          ),

          _navItem(
            Icons.person_outline,
            "Profil",
            false,
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String text,
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
            size: 24,
            color: active
                ? const Color(0xFF087EFF)
                : Colors.black87,
          ),

          const SizedBox(height: 2),

          Text(
            text,
            style: TextStyle(
              fontSize: 9.5,
              color: active
                  ? const Color(0xFF087EFF)
                  : Colors.black87,
              fontWeight: active
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BOTTOM SHEET PENGINGAT
  // ==========================================================

  void showReminderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: 335,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // HANDLE
                  Center(
                    child: Container(
                      margin:
                          const EdgeInsets.only(top: 8),
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D1D1),
                        borderRadius:
                            BorderRadius.circular(5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ICON BULAT
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration:
                          const BoxDecoration(
                        color: Color(0xFFD7F0F7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Text(
                      "Atur Pengingat Konsultasi",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Text(
                      "Pilih waktu pengingat sesuai dengan kebutuhan\n"
                      "anda. Kami akan mengirimkan notifikasi sebelum\n"
                      "jadwal konsultasi.",
                      style: TextStyle(
                        fontSize: 9,
                        height: 1.3,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // CARD DOKTER
                  // ==================================================

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Container(
                      height: 68,
                      padding:
                          const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius:
                            BorderRadius.circular(7),
                      ),
                      child: Row(
                        children: [

                          _doctorImage(
                            width: 45,
                            height: 45,
                          ),

                          const SizedBox(width: 8),

                          Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              const Text(
                                "dr. Nurlitta Dwi, Sp.JP",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),

                              const Text(
                                "Spesialis Jantung",
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Row(
                                children: const [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 10,
                                    color:
                                        Color(0xFF458B9A),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Jumat, 18 September 2026",
                                    style: TextStyle(
                                      fontSize: 7,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: const [
                                  Icon(
                                    Icons.access_time,
                                    size: 10,
                                    color:
                                        Color(0xFF458B9A),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "10:00 WIB",
                                    style: TextStyle(
                                      fontSize: 7,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Text(
                      "Pilih Waktu Pengingat",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // ==================================================
                  // PILIHAN WAKTU
                  // ==================================================

                  _reminderOption(
                    "1 hari sebelumnya",
                    setSheetState,
                  ),

                  _reminderOption(
                    "3 jam sebelumnya",
                    setSheetState,
                  ),

                  _reminderOption(
                    "1 jam sebelumnya",
                    setSheetState,
                  ),

                  _reminderOption(
                    "30 menit sebelumnya",
                    setSheetState,
                  ),

                  const SizedBox(height: 6),

                  // SIMPAN
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 27,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);

                          Future.delayed(
                            const Duration(
                              milliseconds: 150,
                            ),
                            () {
                              if (mounted) {
                                showReminderSuccess();
                              }
                            },
                          );
                        },
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              primaryBlue,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Simpan Pengingat",
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // BATAL
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 27,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              primaryBlue,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // PILIHAN REMINDER
  // ==========================================================

  Widget _reminderOption(
    String text,
    StateSetter setSheetState,
  ) {
    final bool selected =
        selectedReminder == text;

    return GestureDetector(
      onTap: () {
        setSheetState(() {
          selectedReminder = text;
        });
      },
      child: Container(
        height: 18,
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: selected
              ? lightBlue
              : Colors.white,
          borderRadius:
              BorderRadius.circular(7),
        ),
        child: Row(
          children: [

            const SizedBox(width: 5),

            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF087EFF)
                      : const Color(0xFF9DAEB4),
                  width: 1,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration:
                            const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF087EFF),
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 6),

            Text(
              text,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SUCCESS REMINDER
  // ==========================================================

  void showReminderSuccess() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) {
        return Container(
          height: 335,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(18),
            ),
          ),
          child: Column(
            children: [

              // HANDLE
              Container(
                margin:
                    const EdgeInsets.only(top: 8),
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D1D1),
                  borderRadius:
                      BorderRadius.circular(5),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // CHECK HIJAU
              // ==================================================

              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE3F6EC),
                  border: Border.all(
                    color: const Color(0xFFD0F0DF),
                    width: 6,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration:
                      const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF18B86A),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Pengingat Berhasil Diatur!",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Anda akan menerima notifikasi 1 hari sebelum\n"
                "jadwal konsultasi",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // CARD JADWAL
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Container(
                  height: 72,
                  padding:
                      const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius:
                        BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [

                      _doctorImage(
                        width: 48,
                        height: 48,
                      ),

                      const SizedBox(width: 9),

                      Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "dr. Nurlitta Dwi, Sp.JP",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          const Text(
                            "Spesialis Jantung",
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Row(
                            children: const [
                              Icon(
                                Icons.calendar_today,
                                size: 10,
                                color:
                                    Color(0xFF458B9A),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Jumat, 18 September 2026",
                                style: TextStyle(
                                  fontSize: 7,
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: const [
                              Icon(
                                Icons.access_time,
                                size: 10,
                                color:
                                    Color(0xFF458B9A),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "10:00 WIB",
                                style: TextStyle(
                                  fontSize: 7,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // MENGERTI
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 29,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          primaryBlue,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Mengerti",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}