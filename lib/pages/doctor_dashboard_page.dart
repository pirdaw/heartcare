import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/theme_service.dart';
import '../services/doctor_service.dart';
import 'home_page.dart';
import 'konsultasi_dokter_page.dart';
import 'welcome_page.dart';
import '../services/chat_notification_service.dart';
import '../widgets/chat_notification_sheet.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  Map<String, dynamic>? _doctorProfile;
  bool _isLoading = false;
  bool _isOnline = true;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _doctorProfile = AuthService.instance.getFastDoctorProfile();
    _isOnline = _doctorProfile?['isOnline'] ?? true;
    _loadDoctorProfile();
  }

  Future<void> _loadDoctorProfile() async {
    try {
      final profile = await AuthService.instance
          .getCurrentDoctorProfile()
          .timeout(const Duration(seconds: 2));
      if (profile != null) {
        DoctorService.instance
            .registerOrUpdateDoctorInFirestore(profile)
            .catchError((_) {});
      }
      if (mounted && profile != null) {
        setState(() {
          _doctorProfile = profile;
          _isOnline = profile['isOnline'] ?? true;
        });
      }
    } catch (e) {
      debugPrint('[DoctorDashboardPage] _loadDoctorProfile error: $e');
    } finally {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleOnlineStatus() async {
    final newStatus = !_isOnline;
    setState(() {
      _isOnline = newStatus;
    });

    final uid = _doctorProfile?['uid'] ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await DoctorService.instance.updateDoctorOnlineStatus(
        uid: uid,
        isOnline: newStatus,
      );
    }
    await AuthService.instance.updateDoctorOnlineStatus(newStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? 'Status: Online (Siap menerima konsultasi pasien)'
                : 'Status: Offline (Pasien tetap dapat meninggalkan pesan chat)',
          ),
          backgroundColor:
              newStatus ? const Color(0xFF10B981) : const Color(0xFF64748B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Keluar dari Akun Dokter'),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun portal dokter?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomePage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  /// Dialog pemilihan foto profil dokter (Galeri, Kamera, Default)
  void _showPhotoPickerOptions() {
    final isDark = ThemeService.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Ubah Foto Profil Dokter",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFF0284C7),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    "Pilih dari Galeri",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    "Pilih foto formal dokter dari galeri",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 6),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFE8F6FA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF0098B9),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    "Ambil Foto (Kamera)",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    "Gunakan kamera langsung untuk mengambil foto baru",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 6),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFF64748B),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    "Kembalikan ke Foto Bawaan",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    const defaultPhoto = 'assets/images/dokter_nurlitta.jpg';
                    final uid = _doctorProfile?['uid'] ?? FirebaseAuth.instance.currentUser?.uid;
                    if (uid != null) {
                      await DoctorService.instance.updateDoctorPhoto(uid: uid, photoData: defaultPhoto);
                    }
                    if (mounted) {
                      setState(() {
                        if (_doctorProfile != null) {
                          _doctorProfile!['foto'] = defaultPhoto;
                        }
                      });
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("Foto profil dikembalikan ke default"),
                          backgroundColor: Color(0xFF0284C7),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      final uid = _doctorProfile?['uid'] ?? FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        await DoctorService.instance.updateDoctorPhoto(
          uid: uid,
          photoData: base64String,
        );
      }

      setState(() {
        if (_doctorProfile != null) {
          _doctorProfile!['foto'] = base64String;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Foto profil dokter berhasil diperbarui!"),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('[DoctorDashboardPage] Gagal memilih foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memperbarui foto profil: $e"),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Sheet Modal Lengkap untuk Edit Profil Dokter (Nama, SIP, Spesialis, Lokasi, Telepon, Bio)
  void _showEditDoctorProfileSheet() {
    final isDark = ThemeService.isDarkMode;

    final namaCtrl = TextEditingController(
      text: _doctorProfile?['nama'] ?? 'dr. Dokter HeartCare',
    );
    final sipCtrl = TextEditingController(
      text: _doctorProfile?['sip'] ?? 'SIP-2026/01/9921',
    );
    final spesialisCtrl = TextEditingController(
      text: _doctorProfile?['spesialis'] ?? 'Spesialis Jantung & Pembuluh Darah',
    );
    final lokasiCtrl = TextEditingController(
      text: _doctorProfile?['lokasi'] ?? 'Klinik Jantung HeartCare',
    );
    final pengalamanCtrl = TextEditingController(
      text: _doctorProfile?['pengalaman'] ?? '10 tahun',
    );
    final teleponCtrl = TextEditingController(
      text: (_doctorProfile?['telepon'] ??
              _doctorProfile?['noWa'] ??
              _doctorProfile?['whatsapp'] ??
              '')
          .toString()
          .trim(),
    );
    final tentangCtrl = TextEditingController(
      text: _doctorProfile?['tentang'] ??
          'Dokter spesialis jantung dan kardiovaskular bersertifikasi yang berdedikasi melayani konsultasi kesehatan jantung pasien secara komprehensif.',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 22,
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
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medical_information_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Edit Profil & SIP Dokter",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Perbarui nama, nomor SIP, dan data praktik",
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                _inputField(
                  "Nama Lengkap Dokter",
                  namaCtrl,
                  hint: "Contoh: dr. Valent Pratama, Sp.JP",
                  helper: "Gelar dr. akan otomatis disesuaikan",
                  isDark: isDark,
                ),
                _inputField(
                  "Nomor SIP yang Berlaku",
                  sipCtrl,
                  hint: "Contoh: SIP-9921/2026 atau 1823/SIP/2021",
                  helper: "Pastikan nomor SIP resmi dan masih aktif",
                  isDark: isDark,
                ),
                _inputField(
                  "Spesialisasi",
                  spesialisCtrl,
                  hint: "Contoh: Spesialis Jantung & Pembuluh Darah",
                  isDark: isDark,
                ),
                _inputField(
                  "Lokasi / Rumah Sakit Praktik",
                  lokasiCtrl,
                  hint: "Contoh: Klinik Jantung HeartCare / RS Jantung",
                  isDark: isDark,
                ),
                _inputField(
                  "Pengalaman Kerja",
                  pengalamanCtrl,
                  hint: "Contoh: 10 tahun",
                  isDark: isDark,
                ),
                _inputField(
                  "No. Telepon / WhatsApp",
                  teleponCtrl,
                  hint: "Contoh: +62 812-3456-7890",
                  keyboardType: TextInputType.phone,
                  isDark: isDark,
                ),
                _inputField(
                  "Tentang Dokter (Bio & Deskripsi)",
                  tentangCtrl,
                  hint: "Deskripsi singkat profil dan keahlian Anda...",
                  maxLines: 3,
                  isDark: isDark,
                ),

                const SizedBox(height: 16),

                // TOMBOL SIMPAN
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      final uid = _doctorProfile?['uid'] ??
                          FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null || uid.isEmpty) {
                        Navigator.pop(context);
                        return;
                      }

                      final messenger = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(context);

                      final success =
                          await DoctorService.instance.updateDoctorProfile(
                        uid: uid,
                        nama: namaCtrl.text,
                        sip: sipCtrl.text,
                        spesialis: spesialisCtrl.text,
                        lokasi: lokasiCtrl.text,
                        pengalaman: pengalamanCtrl.text,
                        telepon: teleponCtrl.text,
                        tentang: tentangCtrl.text,
                      );

                      nav.pop();
                      if (mounted) {
                        if (success) {
                          setState(() {
                            if (_doctorProfile != null) {
                              _doctorProfile!['nama'] = namaCtrl.text.trim();
                              _doctorProfile!['sip'] = sipCtrl.text.trim();
                              _doctorProfile!['spesialis'] = spesialisCtrl.text.trim();
                              _doctorProfile!['lokasi'] = lokasiCtrl.text.trim();
                              _doctorProfile!['pengalaman'] = pengalamanCtrl.text.trim();
                              _doctorProfile!['telepon'] = teleponCtrl.text.trim();
                              _doctorProfile!['noWa'] = teleponCtrl.text.trim();
                              _doctorProfile!['whatsapp'] = teleponCtrl.text.trim();
                              _doctorProfile!['tentang'] = tentangCtrl.text.trim();
                            }
                          });
                          await _loadDoctorProfile();
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Profil dan nomor WhatsApp dokter berhasil diperbarui!",
                              ),
                              backgroundColor: Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text("Gagal memperbarui profil dokter."),
                              backgroundColor: Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Simpan Perubahan Profil",
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
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

  Widget _inputField(
    String label,
    TextEditingController controller, {
    String? hint,
    String? helper,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isDark = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: hint,
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
          if (helper != null) ...[
            const SizedBox(height: 3),
            Text(
              helper,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final doctorName = _doctorProfile?['nama'] ?? 'dr. Dokter HeartCare';
    final doctorSpecialty =
        _doctorProfile?['spesialis'] ?? 'Spesialis Jantung & Pembuluh Darah';
    final doctorPhoto =
        _doctorProfile?['foto'] ?? 'assets/images/dokter_nurlitta.jpg';
    final doctorSip = _doctorProfile?['sip'] ?? 'SIP-2026/01/9921';
    final doctorLokasi = _doctorProfile?['lokasi'] ?? 'Klinik Jantung HeartCare';
    final doctorPengalaman = _doctorProfile?['pengalaman'] ?? '10 tahun';
    final doctorTelepon = (_doctorProfile?['telepon'] ??
            _doctorProfile?['noWa'] ??
            _doctorProfile?['whatsapp'] ??
            '')
        .toString()
        .trim();
    final doctorUid = _doctorProfile?['uid'];

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF1E293B) : const Color(0xFF0284C7),
        elevation: 0,
        titleSpacing: 16,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Portal Dokter',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: ChatNotificationService.instance,
            builder: (context, _) {
              final unread = ChatNotificationService.instance.totalUnreadNotificationCount;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => ChatNotificationSheet.show(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.notifications_outlined,
                              size: 20,
                              color: Colors.white,
                            ),
                            if (unread > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    unread > 9 ? '9+' : '$unread',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
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
              );
            },
          ),
          IconButton(
            tooltip: 'Mode Pasien',
            icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDoctorProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================================================
                    // KARTU PROFIL UTAMA DOKTER
                    // =========================================================
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [Color(0xFF1E293B), Color(0xFF0F172A)]
                              : const [Color(0xFF0284C7), Color(0xFF0369A1)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Avatar Dokter dengan Badge Ubah Foto
                              GestureDetector(
                                onTap: _showPhotoPickerOptions,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF0369A1),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.2,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: DoctorService.buildDoctorImage(
                                        doctorPhoto,
                                        width: 64,
                                        height: 64,
                                        isDark: isDark,
                                      ),
                                    ),
                                    // BADGE KAMERA
                                    Positioned(
                                      left: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(3.5),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.65),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded,
                                          size: 11,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    // INDIKATOR STATUS ONLINE / OFFLINE
                                    Positioned(
                                      right: 1,
                                      bottom: 1,
                                      child: Container(
                                        width: 15,
                                        height: 15,
                                        decoration: BoxDecoration(
                                          color: _isOnline
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF94A3B8),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctorName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      doctorSpecialty,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFE0F2FE),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "SIP: $doctorSip",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFBAE6FD),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.white24, height: 1),
                          const SizedBox(height: 10),

                          // STATUS KONSULTASI & TOMBOL EDIT PROFIL
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Status online/offline text
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isOnline
                                        ? Icons.check_circle_rounded
                                        : Icons.pause_circle_filled_rounded,
                                    color: _isOnline
                                        ? const Color(0xFF4ADE80)
                                        : const Color(0xFFCBD5E1),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isOnline
                                        ? "Siap Konsultasi"
                                        : "Sedang Offline",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                              // Tombol Edit Profil & Switch Status
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Tombol Edit Profil
                                  InkWell(
                                    onTap: _showEditDoctorProfileSheet,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white30,
                                          width: 1,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit_rounded,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            "Edit Profil",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  // Tombol Toggle Online/Offline
                                  InkWell(
                                    onTap: _toggleOnlineStatus,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _isOnline
                                            ? Colors.black.withValues(alpha: 0.22)
                                            : const Color(0xFF10B981),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white30,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        _isOnline ? "Ubah Offline" : "Online-kan",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =========================================================
                    // DETAIL DATA DOKTER & SIP AKTIF
                    // =========================================================
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.badge_rounded,
                                    size: 18,
                                    color: isDark
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF0284C7),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Informasi Praktik & SIP',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: _showEditDoctorProfileSheet,
                                child: Text(
                                  'Perbarui',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF0284C7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          _infoItem(
                            icon: Icons.verified_rounded,
                            label: 'Nomor SIP',
                            value: doctorSip,
                            isDark: isDark,
                          ),
                          _infoItem(
                            icon: Icons.local_hospital_rounded,
                            label: 'Lokasi Praktik',
                            value: doctorLokasi,
                            isDark: isDark,
                          ),
                          _infoItem(
                            icon: Icons.work_outline_rounded,
                            label: 'Pengalaman',
                            value: doctorPengalaman,
                            isDark: isDark,
                          ),
                          _infoItem(
                            icon: Icons.phone_rounded,
                            label: 'Telepon / WhatsApp',
                            value: doctorTelepon.isNotEmpty ? doctorTelepon : 'Belum diisi',
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // STATISTIK KILAT
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            isDark: isDark,
                            icon: Icons.forum_rounded,
                            color: const Color(0xFF0284C7),
                            label: 'Pesan Masuk',
                            value: 'Real-Time',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            isDark: isDark,
                            icon: Icons.verified_user_rounded,
                            color: const Color(0xFF10B981),
                            label: 'Keamanan',
                            value: 'Firebase Auth',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // JUDUL DAFTAR CHAT PASIEN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  "Konsultasi Pasien",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 7,
                                color: Color(0xFF10B981),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Live",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // STREAM DAFTAR CHAT PASIEN REAL-TIME
                    StreamBuilder<List<ChatRoom>>(
                      stream: ChatService.instance.getDoctorChatsStream(
                        doctorName,
                        doctorId: doctorUid,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final chatRooms = snapshot.data ?? [];

                        if (chatRooms.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 36,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 44,
                                  color: isDark
                                      ? const Color(0xFF475569)
                                      : const Color(0xFF94A3B8),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Belum Ada Percakapan Pasien",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isOnline
                                      ? "Pesan konsultasi dari pasien akan langsung muncul di sini secara real-time."
                                      : "Anda sedang offline. Pasien tetap dapat meninggalkan pesan chat, dan akan muncul di sini.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: chatRooms.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final room = chatRooms[index];
                            final hasUnread = room.unreadCountDoctor > 0;

                            return Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: hasUnread
                                      ? const Color(0xFF0284C7)
                                      : (isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0)),
                                  width: hasUnread ? 1.5 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.2 : 0.03,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                leading: Stack(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF0F2B3E)
                                            : const Color(0xFFE0F2FE),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person_rounded,
                                        color: Color(0xFF0284C7),
                                        size: 26,
                                      ),
                                    ),
                                    if (hasUnread)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 11,
                                          height: 11,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0284C7),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isDark
                                                  ? const Color(0xFF1E293B)
                                                  : Colors.white,
                                              width: 1.8,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        room.patientName.isNotEmpty
                                            ? room.patientName
                                            : "Pasien HeartCare",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: hasUnread
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      room.lastMessageTimeFormatted,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: hasUnread
                                            ? const Color(0xFF0284C7)
                                            : (isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B)),
                                        fontWeight: hasUnread
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          room.lastMessage.isNotEmpty
                                              ? room.lastMessage
                                              : "Klik untuk membuka percakapan",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: hasUnread
                                                ? (isDark
                                                    ? Colors.white
                                                    : const Color(0xFF0F172A))
                                                : (isDark
                                                    ? const Color(0xFF94A3B8)
                                                    : const Color(0xFF64748B)),
                                            fontWeight: hasUnread
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      if (hasUnread) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0284C7),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${room.unreadCountDoctor} baru',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          KonsultasiDokterPage(
                                        chatId: room.id,
                                        isDoctorView: true,
                                        doctorName: room.doctorName,
                                        doctorPhoto: room.doctorPhoto,
                                        doctorSpecialty: room.doctorSpecialty,
                                        patientName: room.patientName,
                                        patientId: room.patientId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 15,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required bool isDark,
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
