import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/theme_service.dart';
import '../services/doctor_service.dart';
import 'konsultasi_dokter_page.dart';
import 'welcome_page.dart';
import 'home_page.dart';
import '../services/chat_notification_service.dart';
import '../widgets/chat_notification_sheet.dart';
import 'doctor_edit_profile_page.dart';

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

  /// Navigasi ke Halaman / Menu Khusus Edit Profil Dokter
  Future<void> _openEditProfilePage() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorEditProfilePage(
          doctorProfile: _doctorProfile,
        ),
      ),
    );
    if (updated == true || mounted) {
      await _loadDoctorProfile();
    }
  }

  /// Sheet Modal Lengkap untuk Edit Profil Dokter (Nama, Jenis Kelamin, SIP, Spesialis, Lokasi, Telepon, Bio)
  void _showEditDoctorProfileSheet() {
    _openEditProfilePage();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final doctorName = _doctorProfile?['nama'] ??
        _doctorProfile?['name'] ??
        FirebaseAuth.instance.currentUser?.displayName ??
        'dr. Dokter HeartCare';
    final doctorSpecialty =
        _doctorProfile?['spesialis'] ?? 'Spesialis Jantung & Pembuluh Darah';
    final doctorPhoto =
        _doctorProfile?['foto'] ?? '';
    final doctorSip = _doctorProfile?['sip'] ?? 'SIP-2026/01/9921';
    final doctorLokasi = _doctorProfile?['lokasi'] ?? 'Klinik Jantung HeartCare';
    final doctorPengalaman = _doctorProfile?['pengalaman'] ?? '10 tahun';
    final doctorJenisKelamin = (_doctorProfile?['jenisKelamin'] ??
            _doctorProfile?['gender'] ??
            'Laki-laki')
        .toString();
    final doctorTelepon = (_doctorProfile?['telepon'] ??
            _doctorProfile?['noWa'] ??
            _doctorProfile?['whatsapp'] ??
            '')
        .toString()
        .trim();
    final doctorUid = _doctorProfile?['uid'] ??
        _doctorProfile?['id'] ??
        FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: Navigator.canPop(context) ? 0 : 16,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                tooltip: 'Kembali',
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Portal Dokter',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          // NOTIFIKASI CHAT DOKTER
          ListenableBuilder(
            listenable: ChatNotificationService.instance,
            builder: (context, _) {
              final unread = ChatNotificationService.instance
                  .totalUnreadNotificationCount;
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

          // TOMBOL MODE PASIEN
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFBAE6FD),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swap_horiz_rounded,
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0284C7),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Mode Pasien',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // TOMBOL KELUAR
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF3B1219).withValues(alpha: 0.6)
                  : const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF881337) : const Color(0xFFFECDD3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE11D48).withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _showLogoutDialog,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFE11D48),
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF1E293B),
                    Color(0xFF162032),
                    Color(0xFF111927),
                    Color(0xFF0F172A),
                  ]
                : const [
                    Color(0xFFE0F2FE),
                    Color(0xFFEDF6FD),
                    Color(0xFFF3F8FD),
                    Color(0xFFF8FAFC),
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Ornamen ambient glow lembut persis seperti Home Page
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF38BDF8)
                        .withValues(alpha: isDark ? 0.04 : 0.16),
                  ),
                ),
              ),
              Positioned(
                top: 260,
                left: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0EA5E9)
                        .withValues(alpha: isDark ? 0.03 : 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: 120,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0284C7)
                        .withValues(alpha: isDark ? 0.03 : 0.06),
                  ),
                ),
              ),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadDoctorProfile,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.fromLTRB(16, 6, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // =========================================================
                            // KARTU PROFIL UTAMA DOKTER (KONSISTEN DENGAN HERO HOME)
                            // =========================================================
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? const [Color(0xFF1E293B), Color(0xFF0F172A)]
                                      : const [
                                          Color(0xFF38BDF8),
                                          Color(0xFF0EA5E9),
                                          Color(0xFF0284C7),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.28),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Background decorative circles
                                  Positioned(
                                    right: -25,
                                    top: -25,
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.10),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 35,
                                    bottom: -35,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.08),
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(16),
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
                                                    width: 66,
                                                    height: 66,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white.withValues(alpha: 0.2),
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 2.2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withValues(alpha: 0.15),
                                                          blurRadius: 8,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    clipBehavior: Clip.antiAlias,
                                                    child: DoctorService.buildDoctorImage(
                                                      doctorPhoto,
                                                      width: 66,
                                                      height: 66,
                                                      isDark: isDark,
                                                    ),
                                                  ),
                                                  // BADGE KAMERA
                                                  Positioned(
                                                    left: 0,
                                                    bottom: 0,
                                                    child: Container(
                                                      padding: const EdgeInsets.all(4),
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

                                            const SizedBox(width: 14),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    doctorName,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 16.5,
                                                      fontWeight: FontWeight.w800,
                                                      color: Colors.white,
                                                      letterSpacing: -0.2,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    doctorSpecialty,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12.5,
                                                      color: Color(0xFFE0F2FE),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          "SIP: $doctorSip",
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            fontSize: 11,
                                                            color: Color(0xFFBAE6FD),
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 7,
                                                          vertical: 2,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withValues(alpha: 0.22),
                                                          borderRadius: BorderRadius.circular(10),
                                                          border: Border.all(
                                                            color: Colors.white.withValues(alpha: 0.4),
                                                            width: 0.8,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              doctorJenisKelamin == 'Perempuan'
                                                                  ? Icons.female_rounded
                                                                  : Icons.male_rounded,
                                                              size: 12,
                                                              color: Colors.white,
                                                            ),
                                                            const SizedBox(width: 3),
                                                            Text(
                                                              doctorJenisKelamin,
                                                              style: const TextStyle(
                                                                fontSize: 10,
                                                                fontWeight: FontWeight.w700,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        const Divider(color: Colors.white24, height: 1),
                                        const SizedBox(height: 12),

                                        // STATUS KONSULTASI & TOMBOL EDIT PROFIL
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Status online/offline text
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 9,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: Colors.white.withValues(alpha: 0.35),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    _isOnline
                                                        ? Icons.check_circle_rounded
                                                        : Icons.pause_circle_filled_rounded,
                                                    color: _isOnline
                                                        ? const Color(0xFF4ADE80)
                                                        : Colors.white70,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    _isOnline
                                                        ? "Siap Konsultasi"
                                                        : "Sedang Offline",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                                      horizontal: 10,
                                                      vertical: 5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(20),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withValues(alpha: 0.08),
                                                          blurRadius: 6,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.edit_rounded,
                                                          color: Color(0xFF0284C7),
                                                          size: 13,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          "Edit Profil",
                                                          style: TextStyle(
                                                            color: Color(0xFF0284C7),
                                                            fontSize: 11.5,
                                                            fontWeight: FontWeight.w800,
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
                                                      horizontal: 10,
                                                      vertical: 5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _isOnline
                                                          ? Colors.black.withValues(alpha: 0.22)
                                                          : const Color(0xFF10B981),
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: Border.all(
                                                        color: Colors.white.withValues(alpha: 0.4),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      _isOnline ? "Ubah Offline" : "Online-kan",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11.5,
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
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // =========================================================
                            // DETAIL DATA DOKTER & SIP AKTIF
                            // =========================================================
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFBAE6FD).withValues(alpha: 0.6),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.badge_rounded,
                                              size: 16,
                                              color: Color(0xFF0284C7),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Informasi Praktik & SIP',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: _openEditProfilePage,
                                        child: Text(
                                          'Perbarui',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? const Color(0xFF38BDF8)
                                                : const Color(0xFF0284C7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Divider(
                                    height: 1,
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                  ),
                                  const SizedBox(height: 12),
                                  _infoItem(
                                    icon: Icons.verified_rounded,
                                    label: 'Nomor SIP',
                                    value: doctorSip,
                                    isDark: isDark,
                                  ),
                                  _infoItem(
                                    icon: doctorJenisKelamin == 'Perempuan'
                                        ? Icons.female_rounded
                                        : Icons.male_rounded,
                                    label: 'Jenis Kelamin',
                                    value: doctorJenisKelamin,
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
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
          ),
          const SizedBox(width: 9),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155)
              : const Color(0xFFBAE6FD).withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7.5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 19),
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
