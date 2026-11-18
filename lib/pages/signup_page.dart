import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../widgets/heartcare_auth_widgets.dart';
import 'login_page.dart';
import 'success_page.dart';

class SignupPage extends StatefulWidget {
  final String initialRole;

  const SignupPage({
    super.key,
    this.initialRole = 'patient',
  });

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late bool _isDoctorRole;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();

  // Dokter specific controllers
  final TextEditingController _spesialisController =
      TextEditingController(text: 'Spesialis Jantung & Pembuluh Darah');
  final TextEditingController _sipController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _pengalamanController =
      TextEditingController(text: '10 tahun');
  final TextEditingController _tentangController = TextEditingController();

  // Foto dan Jenis Kelamin Dokter
  Uint8List? _doctorPhotoBytes;
  String? _doctorPhotoBase64;
  String _selectedJenisKelamin = '';
  final ImagePicker _signupPicker = ImagePicker();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isDoctorRole = widget.initialRole == 'doctor';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _tanggalLahirController.dispose();
    _spesialisController.dispose();
    _sipController.dispose();
    _lokasiController.dispose();
    _pengalamanController.dispose();
    _tentangController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Uint8List? _getDoctorPhotoBytes() {
    if (_doctorPhotoBytes != null) return _doctorPhotoBytes;
    if (_doctorPhotoBase64 != null && _doctorPhotoBase64!.trim().isNotEmpty) {
      try {
        String clean = _doctorPhotoBase64!.trim();
        if (clean.contains(',')) {
          clean = clean.split(',').last;
        }
        return base64Decode(clean);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _pickDoctorPhoto(ImageSource source) async {
    try {
      final XFile? file = await _signupPicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _doctorPhotoBytes = bytes;
          _doctorPhotoBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      _showSnackBar('Gagal memilih foto: $e');
    }
  }

  void _showPhotoOptionsDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Unggah Foto Profil Dokter (Wajib)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Foto resmi dokter wajib diisi untuk verifikasi akun',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0284C7)),
                ),
                title: const Text('Ambil Foto dari Kamera', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  _pickDoctorPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF0284C7)),
                ),
                title: const Text('Pilih dari Galeri', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  _pickDoctorPhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTanggalLahir() async {
    final now = DateTime.now();
    final initialDate = DateTime(2000, 1, 1);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'PILIH TANGGAL LAHIR',
      confirmText: 'PILIH',
      cancelText: 'BATAL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF0284C7),
              onPrimary: Colors.white,
              onSurface: isDark ? Colors.white : const Color(0xFF0F172A),
              surface: isDark ? const Color(0xFF1E293B) : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      const months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      setState(() {
        _tanggalLahirController.text =
            '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      });
    }
  }

  Future<void> _daftar() async {
    if (_isLoading) return;

    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final telepon = _teleponController.text.trim();
    final tanggalLahir = _tanggalLahirController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (nama.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Mohon lengkapi semua data wajib (Nama, Email, Kata Sandi).');
      return;
    }

    final photoBase64 = _doctorPhotoBase64 ??
        (_doctorPhotoBytes != null ? base64Encode(_doctorPhotoBytes!) : null);

    if (_isDoctorRole) {
      if (photoBase64 == null || photoBase64.trim().isEmpty) {
        _showSnackBar('Foto profil dokter wajib diunggah.');
        return;
      }
      if (_selectedJenisKelamin.isEmpty) {
        _showSnackBar('Mohon pilih jenis kelamin dokter.');
        return;
      }
      final sip = _sipController.text.trim();
      if (sip.isEmpty) {
        _showSnackBar('Mohon isi Nomor SIP (Surat Izin Praktik) dokter.');
        return;
      }
      final lokasi = _lokasiController.text.trim();
      if (lokasi.isEmpty) {
        _showSnackBar('Mohon isi Rumah Sakit / Klinik Praktik.');
        return;
      }
    }

    if (password != confirmPassword) {
      _showSnackBar('Konfirmasi kata sandi tidak sama.');
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Kata sandi terlalu lemah (minimal 6 karakter).');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String? error;
    if (_isDoctorRole) {
      error = await AuthService.instance.signUpDoctor(
        name: nama,
        email: email,
        password: password,
        foto: photoBase64!,
        jenisKelamin: _selectedJenisKelamin,
        telepon: telepon,
        spesialis: _spesialisController.text.trim(),
        sip: _sipController.text.trim(),
        lokasi: _lokasiController.text.trim(),
        pengalaman: _pengalamanController.text.trim(),
        tentang: _tentangController.text.trim(),
      );
    } else {
      error = await AuthService.instance.signUp(
        name: nama,
        email: email,
        password: password,
        telepon: telepon,
        tanggalLahir: tanggalLahir,
        role: 'patient',
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (error != null) {
      _showSnackBar(error);
      return;
    }

    // Keluar dari sesi otomatis Firebase agar pengguna login terlebih dahulu
    await AuthService.instance.signOut();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessPage(
          title: _isDoctorRole
              ? 'Pendaftaran Dokter Berhasil'
              : 'Pendaftaran Berhasil',
          message: _isDoctorRole
              ? 'Akun Dokter Anda berhasil dibuat!'
              : 'Akun Anda berhasil dibuat!',
          subMessage: _isDoctorRole
              ? 'Silakan masuk menggunakan email dan kata sandi Anda untuk mulai mengelola jadwal dan konsultasi pasien.'
              : 'Silakan masuk menggunakan email dan kata sandi Anda untuk mulai memantau kesehatan jantung Anda.',
          badgeLabel: _isDoctorRole
              ? 'Akun Dokter Terverifikasi'
              : 'Registrasi Berhasil',
          buttonText: 'Masuk Sekarang',
          onButtonPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(initialEmail: email),
              ),
              (route) => false,
            );
          },
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13.5, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HeartCareAuthBackground(
      showEkg: true,
      child: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // TOP BAR (BACK BUTTON & BRANDING PILL)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HeartCareBackButton(
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                          : Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF1E3A5F)
                            : const Color(0xFFBAE6FD),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF0284C7),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF38BDF8),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'HEARTCARE • DAFTAR',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // MAIN SIGNUP FORM
            // ==========================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 6),

                    // Center Logo with ambient glow ring
                    Container(
                      width: 82,
                      height: 82,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF131D36) : Colors.white,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E3A5F)
                              : const Color(0xFFBAE6FD),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.16),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.10),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/heartcare_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Judul
                    Text(
                      _isDoctorRole ? 'Daftar Akun Dokter' : 'Buat Akun Baru',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Subjudul
                    Text(
                      _isDoctorRole
                          ? 'Daftar sebagai Dokter untuk melayani\nkonsultasi pasien di HeartCare'
                          : 'Daftar Untuk Mulai Menggunakan\nHeartCare',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==========================================
                    // TAB PILIH ROLE (PASIEN / DOKTER)
                    // ==========================================
                    Container(
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E3A5F)
                              : const Color(0xFFBAE6FD),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isDoctorRole = false;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: !_isDoctorRole
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF0EA5E9),
                                            Color(0xFF0284C7),
                                          ],
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: !_isDoctorRole
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF0284C7)
                                                .withValues(alpha: 0.28),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  'Daftar Pasien',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: !_isDoctorRole
                                        ? Colors.white
                                        : (isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isDoctorRole = true;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: _isDoctorRole
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF0EA5E9),
                                            Color(0xFF0284C7),
                                          ],
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: _isDoctorRole
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF0284C7)
                                                .withValues(alpha: 0.28),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  'Daftar Dokter',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: _isDoctorRole
                                        ? Colors.white
                                        : (isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // FOTO PROFIL DOKTER (WAJIB JIKA DOKTER)
                    if (_isDoctorRole) ...[
                      _buildDoctorPhotoPicker(isDark),
                      const SizedBox(height: 20),
                    ],

                    // =====================================
                    // NAMA LENGKAP
                    // =====================================
                    _buildFieldGroup(
                      isDark: isDark,
                      label: _isDoctorRole
                          ? 'Nama Lengkap & Gelar Dokter'
                          : 'Nama Lengkap',
                      controller: _namaController,
                      hintText: _isDoctorRole
                          ? 'Contoh: dr. Budi Santoso, Sp.JP'
                          : 'Masukkan Nama Lengkap Anda',
                      prefixIcon: Icons.person_outline_rounded,
                    ),

                    const SizedBox(height: 18),

                    // PILIHAN JENIS KELAMIN (WAJIB JIKA DOKTER)
                    if (_isDoctorRole) ...[
                      _buildDoctorGenderSelector(isDark),
                      const SizedBox(height: 18),
                    ],

                    // =====================================
                    // EMAIL
                    // =====================================
                    _buildFieldGroup(
                      isDark: isDark,
                      label: _isDoctorRole ? 'Email Dokter' : 'Email',
                      controller: _emailController,
                      hintText: _isDoctorRole
                          ? 'Contoh: dokter.budi@heartcare.com'
                          : 'Masukkan Alamat Email',
                      prefixIcon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 18),

                    // =====================================
                    // NO. TELEPON
                    // =====================================
                    _buildFieldGroup(
                      isDark: isDark,
                      label: 'No. Telepon / WhatsApp',
                      controller: _teleponController,
                      hintText: 'Contoh: 081234567890',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 18),

                    // FIELD KHUSUS DOKTER vs PASIEN
                    if (_isDoctorRole) ...[
                      // SPESIALISASI
                      _buildFieldGroup(
                        isDark: isDark,
                        label: 'Spesialisasi',
                        controller: _spesialisController,
                        hintText: 'Contoh: Spesialis Jantung & Pembuluh Darah',
                        prefixIcon: Icons.medical_services_outlined,
                      ),
                      const SizedBox(height: 18),

                      // NO SIP
                      _buildFieldGroup(
                        isDark: isDark,
                        label: 'Nomor SIP (Surat Izin Praktik)',
                        controller: _sipController,
                        hintText: 'Contoh: 2406/SIP/2023',
                        prefixIcon: Icons.verified_user_outlined,
                      ),
                      const SizedBox(height: 18),

                      // LOKASI PRAKTIK
                      _buildFieldGroup(
                        isDark: isDark,
                        label: 'Rumah Sakit / Klinik Praktik',
                        controller: _lokasiController,
                        hintText: 'Contoh: RS Mitra Sehat, Jember',
                        prefixIcon: Icons.local_hospital_outlined,
                      ),
                      const SizedBox(height: 18),

                      // PENGALAMAN PRAKTIK
                      _buildFieldGroup(
                        isDark: isDark,
                        label: 'Pengalaman Praktik',
                        controller: _pengalamanController,
                        hintText: 'Contoh: 10 tahun',
                        prefixIcon: Icons.work_history_outlined,
                      ),
                      const SizedBox(height: 18),

                      // BIO / TENTANG DOKTER
                      _buildFieldGroup(
                        isDark: isDark,
                        label: 'Bio / Tentang Dokter (Singkat)',
                        controller: _tentangController,
                        hintText: 'Contoh: Dokter spesialis jantung fokus prevensi kardiovaskular',
                        prefixIcon: Icons.info_outline_rounded,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 18),
                    ] else ...[
                      // TANGGAL LAHIR PASIEN
                      _buildFieldGroup(
                        isDark: isDark,
                        label: 'Tanggal Lahir',
                        controller: _tanggalLahirController,
                        hintText: 'Pilih Tanggal Lahir',
                        prefixIcon: Icons.calendar_today_rounded,
                        readOnly: true,
                        onTap: _selectTanggalLahir,
                        suffixIcon: IconButton(
                          onPressed: _selectTanggalLahir,
                          icon: Icon(
                            Icons.calendar_month_rounded,
                            size: 21,
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFF0284C7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // =====================================
                    // KATA SANDI
                    // =====================================
                    _buildFieldGroup(
                      isDark: isDark,
                      label: 'Kata Sandi',
                      controller: _passwordController,
                      hintText: 'Masukkan Kata Sandi (min. 6 karakter)',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: !_passwordVisible,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 21,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =====================================
                    // KONFIRMASI KATA SANDI
                    // =====================================
                    _buildFieldGroup(
                      isDark: isDark,
                      label: 'Konfirmasi Kata Sandi',
                      controller: _confirmPasswordController,
                      hintText: 'Masukkan Ulang Kata Sandi',
                      prefixIcon: Icons.lock_clock_outlined,
                      obscureText: !_confirmPasswordVisible,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                        icon: Icon(
                          _confirmPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 21,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // =====================================
                    // TOMBOL DAFTAR
                    // =====================================
                    HeartCareGradientButton(
                      onPressed: _isLoading ? null : _daftar,
                      isLoading: _isLoading,
                      text: _isDoctorRole
                          ? 'Daftar sebagai Dokter'
                          : 'Daftar Sekarang',
                      icon: Icons.arrow_forward_rounded,
                      gradientColors: const [
                        Color(0xFF0EA5E9),
                        Color(0xFF0284C7),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // =====================================
                    // LINK SUDAH PUNYA AKUN
                    // =====================================
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF475569),
                          ),
                          children: [
                            const TextSpan(text: 'Sudah memiliki akun? '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Masuk di sini',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: isDark
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF0284C7),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorPhotoPicker(bool isDark) {
    final photoBytes = _getDoctorPhotoBytes();
    final hasPhoto = photoBytes != null ||
        (_doctorPhotoBase64 != null && _doctorPhotoBase64!.trim().isNotEmpty);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 106,
              height: 106,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3.5),
              child: ClipOval(
                child: photoBytes != null
                    ? Image.memory(
                        photoBytes,
                        fit: BoxFit.cover,
                        width: 99,
                        height: 99,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDoctorPhotoPlaceholder(isDark),
                      )
                    : _buildDoctorPhotoPlaceholder(isDark),
              ),
            ),
            InkWell(
              onTap: _showPhotoOptionsDialog,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _showPhotoOptionsDialog,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasPhoto
                      ? Icons.check_circle_rounded
                      : Icons.add_a_photo_outlined,
                  size: 16,
                  color: hasPhoto
                      ? const Color(0xFF10B981)
                      : const Color(0xFF0284C7),
                ),
                const SizedBox(width: 6),
                Text(
                  hasPhoto
                      ? 'Ganti Foto Profil Dokter'
                      : 'Unggah Foto Profil Dokter (Wajib)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: hasPhoto
                        ? const Color(0xFF10B981)
                        : (isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0284C7)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorPhotoPlaceholder(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_alt_1_rounded,
            size: 40,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
          const SizedBox(height: 2),
          Text(
            'Wajib Foto',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorGenderSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Jenis Kelamin Dokter',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedJenisKelamin = 'Laki-laki';
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: _selectedJenisKelamin == 'Laki-laki'
                        ? const Color(0xFF0284C7).withValues(alpha: 0.14)
                        : (isDark
                            ? const Color(0xFF131D36).withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.95)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedJenisKelamin == 'Laki-laki'
                          ? const Color(0xFF0284C7)
                          : (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFBAE6FD)),
                      width: _selectedJenisKelamin == 'Laki-laki' ? 2 : 1.2,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.male_rounded,
                        size: 20,
                        color: _selectedJenisKelamin == 'Laki-laki'
                            ? const Color(0xFF0284C7)
                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Laki-laki',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: _selectedJenisKelamin == 'Laki-laki'
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: _selectedJenisKelamin == 'Laki-laki'
                              ? const Color(0xFF0284C7)
                              : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedJenisKelamin = 'Perempuan';
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: _selectedJenisKelamin == 'Perempuan'
                        ? const Color(0xFFEC4899).withValues(alpha: 0.14)
                        : (isDark
                            ? const Color(0xFF131D36).withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.95)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedJenisKelamin == 'Perempuan'
                          ? const Color(0xFFEC4899)
                          : (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFBAE6FD)),
                      width: _selectedJenisKelamin == 'Perempuan' ? 2 : 1.2,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female_rounded,
                        size: 20,
                        color: _selectedJenisKelamin == 'Perempuan'
                            ? const Color(0xFFEC4899)
                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Perempuan',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: _selectedJenisKelamin == 'Perempuan'
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: _selectedJenisKelamin == 'Perempuan'
                              ? const Color(0xFFEC4899)
                              : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldGroup({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF131D36).withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.95),
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 13.5,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 10),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    prefixIcon,
                    size: 18,
                    color: isDark
                        ? const Color(0xFF38BDF8)
                        : const Color(0xFF0284C7),
                  ),
                ),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 54, minHeight: 36),
              suffixIcon: suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF1E3A5F)
                      : const Color(0xFFBAE6FD),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF0284C7),
                  width: 1.8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}