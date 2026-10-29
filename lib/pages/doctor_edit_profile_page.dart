import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/doctor_service.dart';

class DoctorEditProfilePage extends StatefulWidget {
  final Map<String, dynamic>? doctorProfile;

  const DoctorEditProfilePage({
    super.key,
    this.doctorProfile,
  });

  @override
  State<DoctorEditProfilePage> createState() => _DoctorEditProfilePageState();
}

class _DoctorEditProfilePageState extends State<DoctorEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _namaCtrl;
  late TextEditingController _sipCtrl;
  late TextEditingController _spesialisCtrl;
  late TextEditingController _lokasiCtrl;
  late TextEditingController _pengalamanCtrl;
  late TextEditingController _teleponCtrl;
  late TextEditingController _tentangCtrl;

  String? _currentPhoto;
  bool _photoChanged = false;
  bool _isOnline = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.doctorProfile;

    _namaCtrl = TextEditingController(
      text: profile?['nama'] ?? 'dr. Dokter HeartCare',
    );
    _sipCtrl = TextEditingController(
      text: profile?['sip'] ?? 'SIP-2026/01/9921',
    );
    _spesialisCtrl = TextEditingController(
      text: profile?['spesialis'] ?? 'Spesialis Jantung & Pembuluh Darah',
    );
    _lokasiCtrl = TextEditingController(
      text: profile?['lokasi'] ?? 'Klinik Jantung HeartCare',
    );
    _pengalamanCtrl = TextEditingController(
      text: profile?['pengalaman'] ?? '10 tahun',
    );
    _teleponCtrl = TextEditingController(
      text: (profile?['telepon'] ??
              profile?['noWa'] ??
              profile?['whatsapp'] ??
              '')
          .toString()
          .trim(),
    );
    _tentangCtrl = TextEditingController(
      text: profile?['tentang'] ??
          'Dokter spesialis jantung dan kardiovaskular bersertifikasi yang berdedikasi melayani konsultasi kesehatan jantung pasien secara komprehensif.',
    );

    _currentPhoto = profile?['foto'] ?? 'assets/images/dokter_nurlitta.jpg';
    _isOnline = profile?['isOnline'] ?? true;
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _sipCtrl.dispose();
    _spesialisCtrl.dispose();
    _lokasiCtrl.dispose();
    _pengalamanCtrl.dispose();
    _teleponCtrl.dispose();
    _tentangCtrl.dispose();
    super.dispose();
  }

  /// Sheet pemilihan sumber foto profil (Kamera, Galeri, atau Foto Bawaan)
  void _showPhotoPickerSheet() {
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
                    "Pilih foto formal dokter dari galeri ponsel",
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
                    "Gunakan kamera untuk mengambil foto baru",
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
                  subtitle: Text(
                    "Gunakan kembali avatar resmi bawaan aplikasi",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentPhoto = 'assets/images/dokter_nurlitta.jpg';
                      _photoChanged = true;
                    });
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

      setState(() {
        _currentPhoto = base64String;
        _photoChanged = true;
      });
    } catch (e) {
      debugPrint('[DoctorEditProfilePage] Gagal memilih foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memilih foto: $e"),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final nama = _namaCtrl.text.trim();
    final sip = _sipCtrl.text.trim();

    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama lengkap dokter tidak boleh kosong"),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (sip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nomor SIP dokter tidak boleh kosong"),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final uid = widget.doctorProfile?['uid'] ??
          FirebaseAuth.instance.currentUser?.uid;

      if (uid == null || uid.isEmpty) {
        throw Exception("Akun dokter tidak ditemukan.");
      }

      // Update data profil dokter di Firestore dan cache
      final success = await DoctorService.instance.updateDoctorProfile(
        uid: uid,
        nama: nama,
        sip: sip,
        spesialis: _spesialisCtrl.text.trim(),
        lokasi: _lokasiCtrl.text.trim(),
        pengalaman: _pengalamanCtrl.text.trim(),
        telepon: _teleponCtrl.text.trim(),
        tentang: _tentangCtrl.text.trim(),
        foto: _photoChanged ? _currentPhoto : null,
      );

      // Perbarui foto secara eksplisit bila ada perubahan
      if (_photoChanged && _currentPhoto != null) {
        await DoctorService.instance.updateDoctorPhoto(
          uid: uid,
          photoData: _currentPhoto!,
        );
      }

      // Perbarui status konsultasi (online/offline)
      await DoctorService.instance.updateDoctorOnlineStatus(
        uid: uid,
        isOnline: _isOnline,
      );
      await AuthService.instance.updateDoctorOnlineStatus(_isOnline);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil dokter berhasil diperbarui!"),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memperbarui profil dokter. Silakan coba lagi."),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('[DoctorEditProfilePage] Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi kesalahan: $e"),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    size: 28,
                  ),
                  tooltip: 'Kembali',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            centerTitle: true,
            title: Text(
              "Edit Profil Dokter",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // =========================================================
                  // HEADER FOTO PROFIL DOKTER
                  // =========================================================
                  _buildPhotoSection(isDark),

                  const SizedBox(height: 20),

                  // =========================================================
                  // SECTION 1: DATA IDENTITAS DOKTER & SIP
                  // =========================================================
                  _buildSectionCard(
                    isDark: isDark,
                    title: "Identitas & Legalitas Dokter",
                    subtitle: "Nama lengkap resmi dan nomor Surat Izin Praktik",
                    icon: Icons.badge_rounded,
                    iconGradient: const [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                    children: [
                      _buildTextField(
                        label: "Nama Lengkap Dokter",
                        controller: _namaCtrl,
                        hint: "Contoh: dr. Valent Pratama, Sp.JP",
                        helper: "Format gelar dokter akan otomatis disesuaikan",
                        icon: Icons.person_outline_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        label: "Nomor SIP yang Berlaku",
                        controller: _sipCtrl,
                        hint: "Contoh: 2406/SIP/2025 atau SIP-9921/2026",
                        helper: "Pastikan nomor SIP resmi dan masih aktif",
                        icon: Icons.verified_outlined,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        label: "Spesialisasi",
                        controller: _spesialisCtrl,
                        hint: "Contoh: Spesialis Jantung & Pembuluh Darah",
                        helper: "Bidang spesialisasi medis yang dijalani",
                        icon: Icons.medical_services_outlined,
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // =========================================================
                  // SECTION 2: DATA PRAKTIK & KONTAK
                  // =========================================================
                  _buildSectionCard(
                    isDark: isDark,
                    title: "Informasi Praktik & Kontak",
                    subtitle: "Fasilitas kesehatan dan nomor kontak aktif",
                    icon: Icons.local_hospital_rounded,
                    iconGradient: const [Color(0xFF14B8A6), Color(0xFF0D9488)],
                    children: [
                      _buildTextField(
                        label: "Lokasi Praktik / Rumah Sakit",
                        controller: _lokasiCtrl,
                        hint: "Contoh: Klinik Jantung HeartCare / RS. Unair",
                        icon: Icons.apartment_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        label: "Pengalaman Praktik",
                        controller: _pengalamanCtrl,
                        hint: "Contoh: 10 tahun",
                        icon: Icons.work_history_outlined,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        label: "Nomor Telepon / WhatsApp",
                        controller: _teleponCtrl,
                        hint: "Contoh: 085324532144",
                        helper: "Digunakan untuk koordinasi layanan konsultasi",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // =========================================================
                  // SECTION 3: TENTANG & BIO DOKTER
                  // =========================================================
                  _buildSectionCard(
                    isDark: isDark,
                    title: "Tentang Dokter (Bio & Ringkasan)",
                    subtitle: "Deskripsi singkat profil dokter untuk pasien",
                    icon: Icons.description_rounded,
                    iconGradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    children: [
                      _buildTextField(
                        label: "Deskripsi Singkat Profil",
                        controller: _tentangCtrl,
                        hint:
                            "Tuliskan keahlian klinis, riwayat pendidikan, atau dedikasi Anda...",
                        maxLines: 4,
                        icon: Icons.edit_note_rounded,
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // =========================================================
                  // SECTION 4: STATUS KESIAPAN KONSULTASI
                  // =========================================================
                  _buildStatusCard(isDark),

                  const SizedBox(height: 24),

                  // =========================================================
                  // TOMBOL SIMPAN PERUBAHAN
                  // =========================================================
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF0284C7).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Simpan Perubahan Profil",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Widget kartu foto profil dokter
  Widget _buildPhotoSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showPhotoPickerSheet,
            child: Stack(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFE0F2FE),
                    border: Border.all(
                      color: const Color(0xFF0284C7),
                      width: 2.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: DoctorService.buildDoctorImage(
                    _currentPhoto,
                    width: 96,
                    height: 96,
                    isDark: isDark,
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _showPhotoPickerSheet,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 14,
                    color: Color(0xFF0284C7),
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Ubah Foto Profil",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget section card pembungkus form
  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> iconGradient,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: iconGradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  /// Widget status kesiapan online/offline
  Widget _buildStatusCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _isOnline
                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                  : const Color(0xFF64748B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isOnline
                  ? Icons.check_circle_rounded
                  : Icons.pause_circle_filled_rounded,
              color: _isOnline
                  ? const Color(0xFF10B981)
                  : const Color(0xFF64748B),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? "Siap Konsultasi (Online)" : "Sedang Offline",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isOnline
                      ? "Pasien dapat melihat status Anda aktif dan mengirim pesan konsultasi"
                      : "Status offline, pesan konsultasi tetap tersimpan",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isOnline,
            activeColor: const Color(0xFF10B981),
            onChanged: (val) {
              setState(() {
                _isOnline = val;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Helper input field yang rapi dan konsisten
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    String? helper,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF334155),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 12.5,
                color:
                    isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper,
            style: TextStyle(
              fontSize: 11,
              color:
                  isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ],
    );
  }
}

