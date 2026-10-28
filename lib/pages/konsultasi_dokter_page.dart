import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:heartcare/pages/Skrining/screening_input_page.dart';
import 'package:heartcare/pages/profil_page.dart';
import 'package:heartcare/services/theme_service.dart';
import '../services/user_profile_service.dart';
import '../services/chat_service.dart';
import '../services/doctor_service.dart';

class ChatItem {
  final String message;
  final String time;
  final bool isDoctor;
  final String? attachmentType;
  final String? imagePath;

  ChatItem({
    required this.message,
    required this.time,
    required this.isDoctor,
    this.attachmentType,
    this.imagePath,
  });
}

class KonsultasiDokterPage extends StatefulWidget {
  final String doctorName;
  final String doctorPhoto;
  final String doctorSpecialty;
  final String? doctorId;
  final String? chatId;
  final bool isDoctorView;
  final String? patientName;
  final String? patientPhoto;
  final String? patientId;

  const KonsultasiDokterPage({
    super.key,
    this.doctorName = 'dr. Nurlitta Dwi',
    this.doctorPhoto = 'assets/images/dokter_nurlitta.jpg',
    this.doctorSpecialty = 'Spesialis Jantung',
    this.doctorId,
    this.chatId,
    this.isDoctorView = false,
    this.patientName,
    this.patientPhoto,
    this.patientId,
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

  String? _activeChatId;
  bool _isLoadingChat = false;
  final bool _isDoctorTyping = false;
  final List<ChatMessage> _optimisticMessages = [];
  String selectedReminder = "1 hari sebelumnya";
  StreamSubscription? _doctorStatusSub;
  bool _isDoctorOnline = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _listenDoctorOnlineStatus();
    // Pre-komputasi activeChatId secara instan pada frame pertama
    if (widget.chatId != null && widget.chatId!.isNotEmpty) {
      _activeChatId = widget.chatId;
    } else {
      final profile = UserProfileService.instance.currentProfile;
      final patientId = widget.patientId ??
          FirebaseAuth.instance.currentUser?.uid ??
          (profile.nama.isNotEmpty
              ? profile.nama
                  .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
                  .toLowerCase()
              : 'patient_user');
      final doctorId = widget.doctorId ?? widget.doctorName;
      _activeChatId = ChatService.instance.computeChatId(
        patientId: patientId,
        doctorId: doctorId,
      );
    }
    _isLoadingChat = false;
    _initChat();
  }

  Future<void> _initChat() async {
    try {
      if (widget.chatId != null && widget.chatId!.isNotEmpty) {
        _activeChatId = widget.chatId;
      } else {
        final profile = UserProfileService.instance.currentProfile;
        final resolvedId = await ChatService.instance
            .getOrCreateChatRoom(
              doctorName: widget.doctorName,
              doctorPhoto: widget.doctorPhoto,
              doctorSpecialty: widget.doctorSpecialty,
              doctorId: widget.doctorId,
              patientId: widget.patientId,
              patientName: widget.patientName ??
                  (profile.nama.isNotEmpty ? profile.nama : 'Pasien HeartCare'),
              patientPhoto: widget.patientPhoto ?? profile.fotoProfil,
            )
            .timeout(
              const Duration(seconds: 2),
              onTimeout: () => _activeChatId ?? 'chat_patient_doctor',
            );
        _activeChatId = resolvedId;
      }

      if (_activeChatId != null) {
        ChatService.instance
            .markMessagesAsRead(
              _activeChatId!,
              widget.isDoctorView ? 'doctor' : 'patient',
            )
            .catchError((_) {});
      }
    } catch (e) {
      debugPrint('[KonsultasiDokterPage] _initChat error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingChat = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _listenDoctorOnlineStatus() {
    if (widget.isDoctorView) return;

    final docId = widget.doctorId;
    if (docId != null && docId.isNotEmpty) {
      _doctorStatusSub = FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .snapshots()
          .listen((snap) {
        if (snap.exists && snap.data() != null) {
          final isOnline = snap.data()!['isOnline'] as bool? ?? true;
          if (mounted && _isDoctorOnline != isOnline) {
            setState(() {
              _isDoctorOnline = isOnline;
            });
          }
        }
      }, onError: (_) {});
    }
  }

  @override
  void dispose() {
    _doctorStatusSub?.cancel();
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==========================================================
  // WARNA SESUAI DESAIN
  // ==========================================================

  static const Color primaryBlue = Color(0xFF0284C7);
  static const Color lightBlue = Color(0xFFE0F2FE);
  static const Color onlineGreen = Color(0xFF10B981);

  // ==========================================================
  // LOGIKA NAVIGASI KEMBALI
  // ==========================================================

  void _backToHome() {
    Navigator.pop(context);
  }

  // ==========================================================
  // LOGIKA CHAT INTERAKTIF
  // ==========================================================

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

  Future<void> _sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();

    if (_activeChatId == null) {
      await _initChat();
    }
    if (_activeChatId == null) return;

    final profile = UserProfileService.instance.currentProfile;
    final senderRole = widget.isDoctorView ? 'doctor' : 'patient';
    final senderName = widget.isDoctorView
        ? widget.doctorName
        : (widget.patientName ??
            (profile.nama.isNotEmpty ? profile.nama : 'Pasien'));

    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}";

    final optMsg = ChatMessage(
      id: 'opt_${now.millisecondsSinceEpoch}',
      senderId: widget.isDoctorView ? 'doctor' : 'patient',
      senderRole: senderRole,
      senderName: senderName,
      message: text,
      timestamp: now,
      timeFormatted: timeStr,
      isRead: false,
    );

    setState(() {
      _optimisticMessages.add(optMsg);
    });
    _scrollToBottom();

    final success = await ChatService.instance.sendMessage(
      chatId: _activeChatId!,
      message: text,
      senderRole: senderRole,
      senderName: senderName,
      patientId: widget.patientId,
      patientName: widget.patientName ?? profile.nama,
      doctorId: widget.doctorId,
      doctorName: widget.doctorName,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pesan tersimpan lokal, namun gagal disinkronkan ke server Firestore. Mohon pastikan aturan keamanan (Security Rules) Firestore telah diaktifkan/dipublikasikan di Firebase Console.',
            style: TextStyle(fontSize: 12),
          ),
          backgroundColor: Color(0xFFEF4444),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    _scrollToBottom();
  }


  void _showAttachmentOptions() {
    final isDark = ThemeService.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
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
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.attach_file_rounded,
                        color: Color(0xFF0284C7),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kirim Lampiran & Foto Medis",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          "Bagikan hasil lab, resep, atau catatan dokter",
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _attachmentItem(
                  icon: Icons.photo_library_rounded,
                  iconColor: const Color(0xFF0284C7),
                  bgColor: const Color(0xFF0284C7).withValues(alpha: 0.12),
                  title: "Pilih dari Galeri (Hasil Lab / EKG)",
                  subtitle: "Kirim foto hasil lab darah, EKG, rontgen, atau resep",
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndSendImage(ImageSource.gallery);
                  },
                ),
                _attachmentItem(
                  icon: Icons.camera_alt_rounded,
                  iconColor: const Color(0xFF10B981),
                  bgColor: const Color(0xFF10B981).withValues(alpha: 0.12),
                  title: "Ambil Foto dengan Kamera",
                  subtitle: "Buka kamera untuk memotret berkas lab atau obat langsung",
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndSendImage(ImageSource.camera);
                  },
                ),
                if (!widget.isDoctorView)
                  _attachmentItem(
                    icon: Icons.monitor_heart_rounded,
                    iconColor: const Color(0xFF6366F1),
                    bgColor: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    title: "Hasil Skrining Jantung HeartCare",
                    subtitle: "Kirim ringkasan skrining risiko jantung AI terakhir",
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      _sendAttachment("Hasil Skrining Jantung HeartCare (Risiko Tinggi)");
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
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);

      if (!mounted) return;
      _showImagePreviewAndConfirm(bytes, base64String);
    } catch (e) {
      debugPrint('[KonsultasiDokterPage] Gagal mengambil gambar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showImagePreviewAndConfirm(Uint8List bytes, String base64String) {
    final isDark = ThemeService.isDarkMode;
    String selectedCategory = "Hasil Laboratorium";
    final TextEditingController captionCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.photo_library_rounded,
                            color: Color(0xFF0284C7),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Kirim Foto Berkas Medis",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                widget.isDoctorView
                                    ? "Kirim ke pasien: ${widget.patientName ?? 'Pasien'}"
                                    : "Kirim ke dokter: ${widget.doctorName}",
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Preview Gambar
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 220),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Image.memory(
                            bytes,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Kategori Dokumen
                    Text(
                      "Pilih Jenis Dokumen:",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _categoryChip(
                          label: "🔬 Hasil Lab",
                          categoryValue: "Hasil Laboratorium",
                          selected: selectedCategory == "Hasil Laboratorium",
                          isDark: isDark,
                          onTap: () => setModalState(() => selectedCategory = "Hasil Laboratorium"),
                        ),
                        _categoryChip(
                          label: "📈 EKG / Rontgen",
                          categoryValue: "Hasil EKG / Rontgen",
                          selected: selectedCategory == "Hasil EKG / Rontgen",
                          isDark: isDark,
                          onTap: () => setModalState(() => selectedCategory = "Hasil EKG / Rontgen"),
                        ),
                        _categoryChip(
                          label: "💊 Resep Obat",
                          categoryValue: "Resep Obat",
                          selected: selectedCategory == "Resep Obat",
                          isDark: isDark,
                          onTap: () => setModalState(() => selectedCategory = "Resep Obat"),
                        ),
                        _categoryChip(
                          label: "📷 Keluhan Fisik",
                          categoryValue: "Foto Keluhan Fisik",
                          selected: selectedCategory == "Foto Keluhan Fisik",
                          isDark: isDark,
                          onTap: () => setModalState(() => selectedCategory = "Foto Keluhan Fisik"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Input Catatan / Keterangan
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: TextField(
                        controller: captionCtrl,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: "Tulis catatan atau keluhan foto ini (opsional)...",
                          hintStyle: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tombol Aksi
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              side: BorderSide(
                                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Batal",
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _sendPhotoMessage(
                                base64String: base64String,
                                category: selectedCategory,
                                caption: captionCtrl.text.trim(),
                              );
                            },
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text(
                              "Kirim Foto",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
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

  Widget _categoryChip({
    required String label,
    required String categoryValue,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0284C7)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF0284C7)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected
                ? Colors.white
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
          ),
        ),
      ),
    );
  }

  Future<void> _sendPhotoMessage({
    required String base64String,
    required String category,
    String? caption,
  }) async {
    if (_activeChatId == null) {
      await _initChat();
    }
    if (_activeChatId == null) return;

    final profile = UserProfileService.instance.currentProfile;
    final senderRole = widget.isDoctorView ? 'doctor' : 'patient';
    final senderName = widget.isDoctorView
        ? widget.doctorName
        : (widget.patientName ??
            (profile.nama.isNotEmpty ? profile.nama : 'Pasien HeartCare'));

    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}";

    final displayMessage = (caption != null && caption.isNotEmpty)
        ? caption
        : "📷 $category";

    final optMsg = ChatMessage(
      id: 'opt_img_${now.millisecondsSinceEpoch}',
      senderId: widget.isDoctorView ? 'doctor' : 'patient',
      senderRole: senderRole,
      senderName: senderName,
      message: displayMessage,
      attachmentType: category,
      imagePath: base64String,
      timestamp: now,
      timeFormatted: timeStr,
      isRead: false,
    );

    setState(() {
      _optimisticMessages.add(optMsg);
    });
    _scrollToBottom();

    final success = await ChatService.instance.sendMessage(
      chatId: _activeChatId!,
      message: displayMessage,
      senderRole: senderRole,
      senderName: senderName,
      attachmentType: category,
      imagePath: base64String,
      patientId: widget.patientId,
      patientName: widget.patientName ?? profile.nama,
      doctorId: widget.doctorId,
      doctorName: widget.doctorName,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Foto $category berhasil dikirim!"
                : "Foto tersimpan lokal (menunggu sinkronisasi)",
          ),
          backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    _scrollToBottom();
  }

  Future<void> _sendAttachment(String title, {String? imagePath}) async {
    if (_activeChatId == null) {
      await _initChat();
    }
    if (_activeChatId == null) return;

    final profile = UserProfileService.instance.currentProfile;
    final senderRole = widget.isDoctorView ? 'doctor' : 'patient';
    final senderName = widget.isDoctorView
        ? widget.doctorName
        : (widget.patientName ??
            (profile.nama.isNotEmpty ? profile.nama : 'Pasien'));

    final path = imagePath ??
        (title.contains("Skrining") || title.contains("EKG")
            ? "assets/images/screening_jantung.png"
            : null);

    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}";

    final optMsg = ChatMessage(
      id: 'opt_att_${now.millisecondsSinceEpoch}',
      senderId: widget.isDoctorView ? 'doctor' : 'patient',
      senderRole: senderRole,
      senderName: senderName,
      message: "📎 Lampiran: $title",
      attachmentType: title,
      imagePath: path,
      timestamp: now,
      timeFormatted: timeStr,
      isRead: false,
    );

    setState(() {
      _optimisticMessages.add(optMsg);
    });
    _scrollToBottom();

    await ChatService.instance.sendMessage(
      chatId: _activeChatId!,
      message: "📎 Lampiran: $title",
      senderRole: senderRole,
      senderName: senderName,
      attachmentType: title,
      imagePath: path,
      patientId: widget.patientId,
      patientName: widget.patientName ?? profile.nama,
      doctorId: widget.doctorId,
      doctorName: widget.doctorName,
    );

    _scrollToBottom();
  }

  // ==========================================================
  // HALAMAN UTAMA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _backToHome();
            }
          },
          child: Scaffold(
            backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),

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
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE1E1E1),
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
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: _backToHome,
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // FOTO DOKTER
                        // FOTO / AVATAR HEADER
                        widget.isDoctorView
                            ? Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0F2FE),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Color(0xFF0284C7),
                                  size: 26,
                                ),
                              )
                            : _doctorImage(
                                width: 44,
                                height: 44,
                              ),

                        const SizedBox(width: 10),

                        // NAMA
                        Expanded(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              Text(
                                widget.isDoctorView
                                    ? "Konsultasi Pasien"
                                    : "Konsultasi dengan",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),

                              const SizedBox(height: 1),

                              Text(
                                widget.isDoctorView
                                    ? (widget.patientName ?? "Pasien HeartCare")
                                    : widget.doctorName,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                                        : (widget.isDoctorView
                                            ? onlineGreen
                                            : (_isDoctorOnline
                                                ? onlineGreen
                                                : const Color(0xFFF59E0B))),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isDoctorTyping
                                        ? "Sedang mengetik..."
                                        : (widget.isDoctorView
                                            ? "Pasien Aktif"
                                            : (_isDoctorOnline
                                                ? "Online"
                                                : "Offline")),
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: _isDoctorTyping
                                          ? primaryBlue
                                          : (widget.isDoctorView
                                              ? onlineGreen
                                              : (_isDoctorOnline
                                                  ? onlineGreen
                                                  : const Color(0xFFF59E0B))),
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
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            size: 24,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // PENGINGAT JIKA DOKTER SEDANG OFFLINE (UNTUK PASIEN)
                  // ==================================================
                  if (!widget.isDoctorView && !_isDoctorOnline)
                    Container(
                      margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A2415)
                            : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF78350F)
                              : const Color(0xFFFDE68A),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.pause_circle_filled_rounded,
                              color: Color(0xFFD97706),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dokter Sedang Offline',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFFFDE68A)
                                        : const Color(0xFF92400E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Dokter saat ini sedang tidak menerima konsultasi langsung. Anda tetap dapat meninggalkan pesan atau pertanyaan di bawah ini, dokter akan merespons saat kembali online.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    height: 1.35,
                                    color: isDark
                                        ? const Color(0xFFE2E8F0)
                                        : const Color(0xFF78350F),
                                  ),
                                ),
                              ],
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
                          child: StreamBuilder<List<ChatMessage>>(
                            initialData: _activeChatId != null
                                ? ChatService.instance
                                    .getCachedMessages(_activeChatId!)
                                : [],
                            stream: _activeChatId != null
                                ? ChatService.instance
                                    .getMessagesStream(_activeChatId!)
                                : const Stream.empty(),
                            builder: (context, snapshot) {
                              if (_isLoadingChat &&
                                  _optimisticMessages.isEmpty &&
                                  (!snapshot.hasData ||
                                      snapshot.data!.isEmpty)) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              final streamMessages = snapshot.data ?? [];
                              final Map<String, ChatMessage> map = {};

                              for (final m in _optimisticMessages) {
                                map[m.id] = m;
                              }

                              for (final m in streamMessages) {
                                _optimisticMessages.removeWhere((opt) =>
                                    opt.message == m.message &&
                                    opt.senderRole == m.senderRole);
                                map[m.id] = m;
                              }

                              final messages = map.values.toList();
                              messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                              if (messages.isNotEmpty) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _scrollToBottom();
                                });
                              }

                              return ListView.builder(
                                controller: _scrollController,
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                itemCount: messages.length + 1,
                                itemBuilder: (context, index) {
                                  // TANGGAL HARI INI
                                  if (index == 0) {
                                    return Column(
                                      children: [
                                        Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF1E293B)
                                                  : const Color(0xFFE0F2FE),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isDark
                                                    ? const Color(0xFF334155)
                                                    : const Color(0xFFBAE6FD),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.lock_outline_rounded,
                                                  size: 12,
                                                  color: isDark
                                                      ? const Color(0xFF38BDF8)
                                                      : const Color(0xFF0284C7),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  "Terkoneksi Real-Time (Aman dengan Firebase)",
                                                  style: TextStyle(
                                                    fontSize: 10.5,
                                                    color: isDark
                                                        ? const Color(0xFF38BDF8)
                                                        : const Color(0xFF0284C7),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                      ],
                                    );
                                  }

                                  final msg = messages[index - 1];
                                  final bool isMyMessage = widget.isDoctorView
                                      ? msg.senderRole == 'doctor'
                                      : msg.senderRole == 'patient';

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: msg.imagePath != null &&
                                            msg.imagePath!.isNotEmpty
                                        ? _buildImageMessageBubble(
                                            msg: msg,
                                            isMyMessage: isMyMessage,
                                            isDark: isDark,
                                          )
                                        : (isMyMessage
                                            ? _userMessage(
                                                msg.message,
                                                msg.timeFormatted,
                                                isDark,
                                              )
                                            : _doctorMessage(
                                                msg.message,
                                                msg.timeFormatted,
                                                isDark,
                                                senderName: msg.senderName,
                                              )),
                                  );
                                },
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
                            12,
                            10,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            border: Border(
                              top: BorderSide(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, -3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: TextField(
                                    controller: messageController,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _sendMessage(),
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: (!widget.isDoctorView && !_isDoctorOnline)
                                          ? "Tinggalkan pesan untuk dokter..."
                                          : "Ketik pesan....",
                                      hintStyle: TextStyle(
                                        fontSize: 13.5,
                                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      prefixIcon: GestureDetector(
                                        onTap: _showAttachmentOptions,
                                        child: Tooltip(
                                          message: "Menu Lampiran Medis",
                                          child: Icon(
                                            Icons.add_circle_outline_rounded,
                                            size: 22,
                                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                                          ),
                                        ),
                                      ),
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _pickAndSendImage(ImageSource.gallery),
                                            child: Tooltip(
                                              message: "Kirim Foto dari Galeri (Hasil Lab / EKG)",
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: Icon(
                                                  Icons.photo_library_outlined,
                                                  size: 21,
                                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF0284C7),
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => _pickAndSendImage(ImageSource.camera),
                                            child: Tooltip(
                                              message: "Ambil Foto dengan Kamera",
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 3, right: 12),
                                                child: Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: 21,
                                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF0284C7),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // TOMBOL KIRIM
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: _sendMessage,
                                  icon: const Icon(
                                    Icons.send_rounded,
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

            bottomNavigationBar: _bottomNavigation(isDark),
          ),
        );
      },
    );
  }

  // ==========================================================
  // PESAN DOKTER
  // ==========================================================

  Widget _doctorMessage(
    String message,
    String time,
    bool isDark, {
    String? senderName,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        widget.isDoctorView
            ? Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF0284C7),
                  size: 20,
                ),
              )
            : _doctorImage(
                width: 32,
                height: 32,
              ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.74,
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
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
    bool isDark,
  ) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0284C7).withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.done_all_rounded,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PESAN GAMBAR USER
  // ==========================================================

  // ==========================================================
  // PESAN GAMBAR / LAMPIRAN MEDIS (HASIL LAB, EKG, RESEP, DLL)
  // ==========================================================

  Widget _buildImageMessageBubble({
    required ChatMessage msg,
    required bool isMyMessage,
    required bool isDark,
  }) {
    final category = msg.attachmentType ?? "Hasil Laboratorium";
    final isLab = category.toLowerCase().contains("lab");
    final isEkg = category.toLowerCase().contains("ekg") ||
        category.toLowerCase().contains("skrining") ||
        category.toLowerCase().contains("rontgen");
    final isResep = category.toLowerCase().contains("resep") ||
        category.toLowerCase().contains("obat");

    final IconData badgeIcon = isLab
        ? Icons.science_rounded
        : (isEkg
            ? Icons.monitor_heart_rounded
            : (isResep ? Icons.medication_rounded : Icons.photo_library_rounded));

    final Color badgeColor = isLab
        ? const Color(0xFF0284C7)
        : (isEkg
            ? const Color(0xFF6366F1)
            : (isResep ? const Color(0xFF10B981) : const Color(0xFF0EA5E9)));

    final senderDisplay = msg.senderRole == 'doctor'
        ? (msg.senderName.isNotEmpty ? msg.senderName : 'Dokter')
        : (msg.senderName.isNotEmpty ? msg.senderName : 'Pasien');

    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMyMessage ? 18 : 4),
            bottomRight: Radius.circular(isMyMessage ? 4 : 18),
          ),
          border: Border.all(
            color: isMyMessage
                ? const Color(0xFF0284C7)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isMyMessage ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Header: Pengirim dan Jenis Lampiran
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badgeIcon, size: 15, color: badgeColor),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isMyMessage ? category : "$senderDisplay • $category",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Gambar (Bisa Diklik untuk Fullscreen Zoom)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: GestureDetector(
                onTap: () => _openFullScreenImageViewer(
                  msg.imagePath!,
                  category,
                  msg.message,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Container(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF1F5F9),
                        child: _buildChatImage(
                          msg.imagePath!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.zoom_in_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Perbesar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
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
            ),

            // Keterangan / Pesan Tambahan jika ada
            if (msg.message.isNotEmpty &&
                !msg.message.startsWith('📷') &&
                !msg.message.startsWith('📎'))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  msg.message,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),

            // Waktu dan Indikator Centang
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.timeFormatted,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  if (isMyMessage) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.done_all_rounded,
                      size: 14,
                      color: Color(0xFF0284C7),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatImage(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _errorImagePlaceholder(),
      );
    }
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _errorImagePlaceholder(),
      );
    }
    try {
      final clean = path.contains(',') ? path.split(',').last : path;
      final bytes = base64Decode(clean);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _errorImagePlaceholder(),
      );
    } catch (_) {
      return _errorImagePlaceholder();
    }
  }

  Widget _errorImagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_rounded, color: Colors.grey, size: 36),
          SizedBox(height: 6),
          Text(
            "Gambar tidak dapat dimuat",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _openFullScreenImageViewer(
    String imagePath,
    String title,
    String caption,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.94),
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black45,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Gunakan 2 jari untuk memperbesar (zoom in)",
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(24),
                  minScale: 0.8,
                  maxScale: 4.5,
                  child: _buildChatImage(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              if (caption.isNotEmpty &&
                  !caption.startsWith('📎') &&
                  !caption.startsWith('📷'))
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      caption,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
      child: DoctorService.buildDoctorImage(
        widget.doctorPhoto,
        width: width,
        height: height,
      ),
    );
  }

  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  Widget _bottomNavigation(bool isDark) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade300,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [

          _navItem(
            isDark,
            Icons.home_outlined,
            "Home",
            false,
            onTap: _backToHome,
          ),

          _navItem(
            isDark,
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
            isDark,
            Icons.person_outline,
            "Dokter",
            true,
            onTap: () {
              Navigator.pop(context);
            },
          ),

          _navItem(
            isDark,
            Icons.description_outlined,
            "Riwayat",
            false,
          ),

          _navItem(
            isDark,
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
    bool isDark,
    IconData icon,
    String text,
    bool active, {
    VoidCallback? onTap,
  }) {
    final activeColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF1479F5);
    final inactiveColor = isDark ? const Color(0xFF64748B) : Colors.black87;

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
              color: active ? activeColor : inactiveColor,
            ),

            const SizedBox(height: 2),

            Text(
              text,
              style: TextStyle(
                fontSize: 9.5,
                color: active ? activeColor : inactiveColor,
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
                                            Color(0xFF0284C7),
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
                                            Color(0xFF0284C7),
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
                                      Color(0xFF0284C7),
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
                                      Color(0xFF0284C7),
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