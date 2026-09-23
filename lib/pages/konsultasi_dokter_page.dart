import 'package:flutter/material.dart';
import 'package:heartcare/pages/Skrining/screening_input_page.dart';
import 'package:heartcare/pages/home_page.dart';
import 'package:heartcare/pages/profil_page.dart';

class ChatItem {
  final String message;
  final String time;
  final bool isDoctor;
  final String? attachmentType;

  ChatItem({
    required this.message,
    required this.time,
    required this.isDoctor,
    this.attachmentType,
  });
}

class KonsultasiDokterPage extends StatefulWidget {
  final String doctorName;
  final String doctorPhoto;
  final String doctorSpecialty;

  const KonsultasiDokterPage({
    super.key,
    this.doctorName = 'dr. Nurlitta Dwi',
    this.doctorPhoto = 'assets/images/dokter_nurlitta.jpg',
    this.doctorSpecialty = 'Spesialis Jantung',
  });

  @override
  State<KonsultasiDokterPage> createState() =>
      _KonsultasiDokterPageState();
}

class _KonsultasiDokterPageState
    extends State<KonsultasiDokterPage> {
  final TextEditingController messageController =
      TextEditingController();
  final ScrollController _scrollController =
      ScrollController();

  late List<ChatItem> _messages;
  bool _isDoctorTyping = false;
  String selectedReminder = "1 hari sebelumnya";

  @override
  void initState() {
    super.initState();
    _messages = [
      ChatItem(
        message: "Halo Nadea, Selamat datang!\nAda yang bisa saya bantu?",
        time: "14.00",
        isDoctor: true,
      ),
      ChatItem(
        message:
            "Dok, saya tadi melakukan skrining,\nhasilnya risiko tinggi.\nApa yang harus saya lakukan?",
        time: "14.01",
        isDoctor: false,
      ),
      ChatItem(
        message:
            "Baik, saya akan bantu.\nApakah ada gejala lain\nseperti nyeri dada atau sesak\nnafas?",
        time: "14.02",
        isDoctor: true,
      ),
      ChatItem(
        message:
            "Iya dok, saya sering sesak nafas saat\naktivitas berat",
        time: "14.03",
        isDoctor: false,
      ),
    ];
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
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
  // LOGIKA NAVIGASI KEMBALI KE BERANDA
  // ==========================================================

  void _backToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }

  // ==========================================================
  // LOGIKA CHAT INTERAKTIF
  // ==========================================================

  String _currentTimeString() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return "$hour.$minute";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final time = _currentTimeString();

    setState(() {
      _messages.add(
        ChatItem(
          message: text,
          time: time,
          isDoctor: false,
        ),
      );
      _isDoctorTyping = true;
    });

    messageController.clear();
    _scrollToBottom();

    // Simulasi jawaban dokter secara realistis dan interaktif
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      final reply = _getDoctorReply(text);
      final replyTime = _currentTimeString();

      setState(() {
        _isDoctorTyping = false;
        _messages.add(
          ChatItem(
            message: reply,
            time: replyTime,
            isDoctor: true,
          ),
        );
      });

      _scrollToBottom();
    });
  }

  String _getDoctorReply(String userText) {
    final lower = userText.toLowerCase();

    if (lower.contains("sesak") ||
        lower.contains("nafas") ||
        lower.contains("dada") ||
        lower.contains("nyeri") ||
        lower.contains("sakit")) {
      return "Baik, keluhan sesak nafas atau nyeri dada adalah gejala penting yang memerlukan perhatian. Sebaiknya batasi aktivitas berat terlebih dahulu dan usahakan duduk tegak rileks. Apakah ada riwayat hipertensi sebelumnya?";
    } else if (lower.contains("obat") ||
        lower.contains("resep") ||
        lower.contains("minum")) {
      return "Untuk konsumsi obat jantung, sangat disarankan disesuaikan dengan hasil pemeriksaan fisik dan rekam medis terbaru. Tolong hindari konsumsi obat tanpa resep ya.";
    } else if (lower.contains("tensi") ||
        lower.contains("tekanan darah") ||
        lower.contains("darah tinggi") ||
        lower.contains("hipertensi")) {
      return "Catatan tensi sangat berharga. Disarankan mengukur tekanan darah 2x sehari (pagi dan malam). Jika angka sistolik di atas 140 mmHg, segera istirahat.";
    } else if (lower.contains("terima kasih") ||
        lower.contains("makasih") ||
        lower.contains("baik dok") ||
        lower.contains("oke dok") ||
        lower.contains("siap")) {
      return "Sama-sama. Tetap jaga pola makan rendah garam, cukup istirahat, dan kurangi stres. Jika ada keluhan darurat mendadak, segera gunakan tombol darurat 119 ya!";
    } else {
      return "Saya telah menerima informasi yang Anda sampaikan. Tetap tenang dan istirahat yang cukup. Kita akan diskusikan penanganan mendalam pada sesi konsultasi terjadwal.";
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D1D1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Kirim Lampiran Medis",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                _attachmentItem(
                  icon: Icons.monitor_heart_outlined,
                  title: "Hasil Skrining Jantung",
                  subtitle:
                      "Kirim ringkasan skrining HeartCare terakhir",
                  onTap: () {
                    Navigator.pop(context);
                    _sendAttachment(
                      "Hasil Skrining Jantung HeartCare (Risiko Tinggi)",
                    );
                  },
                ),
                _attachmentItem(
                  icon: Icons.camera_alt_outlined,
                  title: "Ambil Foto Keluhan / Resep",
                  subtitle:
                      "Buka kamera untuk memotret dokumen atau obat",
                  onTap: () {
                    Navigator.pop(context);
                    _sendAttachment(
                      "Foto Rekam Medis / EKG",
                    );
                  },
                ),
                _attachmentItem(
                  icon: Icons.image_outlined,
                  title: "Pilih dari Galeri",
                  subtitle:
                      "Pilih foto hasil laboratorium dari galeri",
                  onTap: () {
                    Navigator.pop(context);
                    _sendAttachment(
                      "Berkas Hasil Laboratorium",
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _attachmentItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: lightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendAttachment(String title) {
    final time = _currentTimeString();

    setState(() {
      _messages.add(
        ChatItem(
          message: "📎 Lampiran: $title",
          time: time,
          isDoctor: false,
          attachmentType: title,
        ),
      );
      _isDoctorTyping = true;
    });

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final replyTime = _currentTimeString();

      setState(() {
        _isDoctorTyping = false;
        _messages.add(
          ChatItem(
            message:
                "Terima kasih atas lampirannya ($title). Dokumen ini sudah saya periksa dan simpan di rekam medis konsultasi Anda.",
            time: replyTime,
            isDoctor: true,
          ),
        );
      });

      _scrollToBottom();
    });
  }

  // ==========================================================
  // HALAMAN UTAMA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _backToHome();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        body: SafeArea(
          child: Column(
            children: [

              // ==================================================
              // HEADER DOKTER
              // ==================================================

              Container(
                height: 74,
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

                    // TOMBOL KEMBALI KE BERANDA
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F1F1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: _backToHome,
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 28,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // FOTO DOKTER
                    _doctorImage(
                      width: 44,
                      height: 44,
                    ),

                    const SizedBox(width: 10),

                    // NAMA DOKTER
                    Expanded(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "Konsultasi dengan",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),

                          const SizedBox(height: 1),

                          Text(
                            widget.doctorName,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 2),

                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: _isDoctorTyping
                                    ? primaryBlue
                                    : onlineGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isDoctorTyping
                                    ? "Sedang mengetik..."
                                    : "Online",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: _isDoctorTyping
                                      ? primaryBlue
                                      : onlineGreen,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // TOMBOL ATUR PENGINGAT (HEADER)
                    IconButton(
                      onPressed: showReminderSheet,
                      tooltip: "Atur Pengingat",
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        size: 24,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // AREA CHAT INTERAKTIF
              // ==================================================

              Expanded(
                child: Column(
                  children: [

                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior
                                .onDrag,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        itemCount: _messages.length +
                            1 +
                            (_isDoctorTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          // TANGGAL HARI INI
                          if (index == 0) {
                            return Column(
                              children: [
                                Center(
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
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
                                const SizedBox(height: 18),
                              ],
                            );
                          }

                          final messageIndex = index - 1;

                          if (messageIndex < _messages.length) {
                            final item = _messages[messageIndex];
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 16),
                              child: item.isDoctor
                                  ? _doctorMessage(
                                      item.message,
                                      item.time,
                                    )
                                  : _userMessage(
                                      item.message,
                                      item.time,
                                    ),
                            );
                          }

                          // INDIKATOR DOKTER SEDANG MENGETIK
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                _doctorImage(
                                  width: 28,
                                  height: 28,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(
                                    12,
                                    9,
                                    12,
                                    9,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFFE2E8F0),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${widget.doctorName} sedang mengetik...",
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontStyle:
                                          FontStyle.italic,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // ==================================================
                    // INPUT PESAN
                    // ==================================================

                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        14,
                        10,
                        10,
                        10,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [

                          Expanded(
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      const Color(0xFFCBD5E1),
                                ),
                                borderRadius:
                                    BorderRadius.circular(22),
                              ),
                              child: TextField(
                                controller:
                                    messageController,
                                textInputAction:
                                    TextInputAction.send,
                                onSubmitted: (_) =>
                                    _sendMessage(),
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF0F172A),
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      "Ketik pesan....",
                                  hintStyle: const TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap:
                                        _showAttachmentOptions,
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 22,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // TOMBOL KIRIM
                          Container(
                            width: 40,
                            height: 40,
                            decoration:
                                const BoxDecoration(
                              color: primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: _sendMessage,
                              icon: const Icon(
                                Icons.send,
                                size: 20,
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
      ),
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
          width: 28,
          height: 28,
        ),

        const SizedBox(width: 8),

        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.fromLTRB(
              12,
              9,
              10,
              6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
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
                      fontSize: 13.5,
                      height: 1.35,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.fromLTRB(
          12,
          9,
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
                  fontSize: 13.5,
                  height: 1.35,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),

            const SizedBox(height: 3),

            Text(
              time,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF164E63),
                fontWeight: FontWeight.w600,
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
        widget.doctorPhoto,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.person,
            color: Colors.grey,
            size: 25,
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
            onTap: _backToHome,
          ),

          _navItem(
            Icons.favorite_border,
            "Skrining",
            false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScreeningInputPage(),
                ),
              );
            },
          ),

          _navItem(
            Icons.person_outline,
            "Dokter",
            true,
            onTap: () {
              Navigator.pop(context);
            },
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
    );
  }

  Widget _navItem(
    IconData icon,
    String text,
    bool active, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
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
                fontSize: 10.5,
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
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                        width: 34,
                        height: 34,
                        decoration:
                            const BoxDecoration(
                          color: Color(0xFFD7F0F7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.access_time_rounded,
                          color: primaryBlue,
                          size: 20,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Text(
                        "Pilih waktu pengingat sesuai dengan kebutuhan Anda. Kami akan mengirimkan notifikasi sebelum jadwal konsultasi dimulai.",
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // CARD DOKTER
                    // ==================================================

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Container(
                        padding:
                            const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [

                            _doctorImage(
                              width: 48,
                              height: 48,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    widget.doctorName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),

                                  Text(
                                    widget.doctorSpecialty,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF475569),
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 11,
                                        color:
                                            Color(0xFF458B9A),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Jumat, 18 September 2026",
                                        style: TextStyle(
                                          fontSize: 9.5,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 2),

                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.access_time,
                                        size: 11,
                                        color:
                                            Color(0xFF458B9A),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "10:00 WIB",
                                        style: TextStyle(
                                          fontSize: 9.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Text(
                        "Pilih Waktu Pengingat",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

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

                    const SizedBox(height: 10),

                    // SIMPAN
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 38,
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
                                  BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Simpan Pengingat",
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // BATAL
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style:
                              OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF475569),
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
        height: 28,
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 3,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? lightBlue
              : Colors.white,
          borderRadius:
              BorderRadius.circular(8),
        ),
        child: Row(
          children: [

            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF087EFF)
                      : const Color(0xFF9DAEB4),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration:
                            const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF087EFF),
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 8),

            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(18),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
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

                const SizedBox(height: 25),

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

                const SizedBox(height: 20),

                const Text(
                  "Pengingat Berhasil Diatur!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Anda akan menerima notifikasi 1 hari sebelum\njadwal konsultasi dimulai",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: Color(0xFF475569),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // CARD JADWAL
                // ==================================================

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [

                        _doctorImage(
                          width: 48,
                          height: 48,
                        ),

                        const SizedBox(width: 10),

                        Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              widget.doctorName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),

                            Text(
                              widget.doctorSpecialty,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF475569),
                              ),
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: const [
                                Icon(
                                  Icons.calendar_today,
                                  size: 11,
                                  color:
                                      Color(0xFF458B9A),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Jumat, 18 September 2026",
                                  style: TextStyle(
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 2),

                            Row(
                              children: const [
                                Icon(
                                  Icons.access_time,
                                  size: 11,
                                  color:
                                      Color(0xFF458B9A),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "10:00 WIB",
                                  style: TextStyle(
                                    fontSize: 9.5,
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

                const SizedBox(height: 20),

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
                    height: 40,
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
                              BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Mengerti",
                        style: TextStyle(
                          fontSize: 13,
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
          ),
        );
      },
    );
  }
}