import 'package:flutter/material.dart';
import '../services/auth_service.dart';
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectTanggalLahir() async {
    final now = DateTime.now();
    final initialDate = DateTime(2000, 1, 1);
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0098B9),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Mohon lengkapi semua data wajib (Nama, Email, Kata Sandi).'),
        ),
      );
      return;
    }

    if (_isDoctorRole) {
      final sip = _sipController.text.trim();
      if (sip.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon isi Nomor SIP (Surat Izin Praktik) dokter.'),
          ),
        );
        return;
      }
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak sama.')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi terlalu lemah (minimal 6 karakter).'),
        ),
      );
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
        telepon: telepon,
        spesialis: _spesialisController.text.trim(),
        sip: _sipController.text.trim(),
        lokasi: _lokasiController.text.trim(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
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
          subMessage:
              'Profil Anda telah tersimpan di sistem Firestore. Silakan masuk menggunakan email dan kata sandi Anda.',
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ==========================================
            // DEKORASI BIRU MUDA DI KIRI BAWAH
            // ==========================================
            Positioned(
              left: -135,
              top: screenHeight - 285,
              child: Container(
                width: 390,
                height: 390,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8DCEE),
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
            ),

            // ==========================================
            // ISI HALAMAN
            // ==========================================
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      // LOGO
                      Image.asset(
                        'assets/images/heartcare_logo.png',
                        width: 75,
                        height: 75,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 8),

                      // JUDUL
                      Text(
                        _isDoctorRole ? 'Daftar Akun Dokter' : 'Buat Akun Baru',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // SUBJUDUL
                      Text(
                        _isDoctorRole
                            ? 'Daftar sebagai Dokter untuk melayani\nkonsultasi pasien di HeartCare'
                            : 'Daftar Untuk Mulai Menggunakan\nHeartCare',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==========================================
                      // TAB PILIH ROLE (PASIEN / DOKTER)
                      // ==========================================
                      Container(
                        height: 46,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1,
                          ),
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
                                borderRadius: BorderRadius.circular(9),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: !_isDoctorRole
                                        ? const Color(0xFF0098B9)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(9),
                                    boxShadow: !_isDoctorRole
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF0098B9)
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 6,
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
                                          : const Color(0xFF64748B),
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
                                borderRadius: BorderRadius.circular(9),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _isDoctorRole
                                        ? const Color(0xFF0098B9)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(9),
                                    boxShadow: _isDoctorRole
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF0098B9)
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 6,
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
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // =====================================
                      // NAMA LENGKAP
                      // =====================================
                      _buildLabel(_isDoctorRole
                          ? 'Nama Lengkap & Gelar Dokter'
                          : 'Nama Lengkap'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _namaController,
                        hintText: _isDoctorRole
                            ? 'Contoh: dr. Budi Santoso, Sp.JP'
                            : 'Masukkan Nama Lengkap Anda',
                      ),
                      const SizedBox(height: 18),

                      // =====================================
                      // EMAIL
                      // =====================================
                      _buildLabel(_isDoctorRole ? 'Email Dokter' : 'Email'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hintText: _isDoctorRole
                            ? 'Contoh: dokter.budi@heartcare.com'
                            : 'Masukkan Alamat Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),

                      // =====================================
                      // NO. TELEPON
                      // =====================================
                      _buildLabel('No. Telepon / WhatsApp'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _teleponController,
                        hintText: 'Contoh: 081234567890',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 18),

                      // FIELD KHUSUS DOKTER vs PASIEN
                      if (_isDoctorRole) ...[
                        // SPESIALISASI
                        _buildLabel('Spesialisasi'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _spesialisController,
                          hintText:
                              'Contoh: Spesialis Jantung & Pembuluh Darah',
                        ),
                        const SizedBox(height: 18),

                        // NO SIP
                        _buildLabel('Nomor SIP (Surat Izin Praktik)'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _sipController,
                          hintText: 'Contoh: 2406/SIP/2023',
                        ),
                        const SizedBox(height: 18),

                        // LOKASI PRAKTIK
                        _buildLabel('Rumah Sakit / Klinik Praktik'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _lokasiController,
                          hintText: 'Contoh: RS Mitra Sehat, Jember',
                        ),
                        const SizedBox(height: 18),
                      ] else ...[
                        // TANGGAL LAHIR PASIEN
                        _buildLabel('Tanggal Lahir'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _tanggalLahirController,
                          hintText: 'Pilih Tanggal Lahir',
                          readOnly: true,
                          onTap: _selectTanggalLahir,
                          suffixIcon: IconButton(
                            onPressed: _selectTanggalLahir,
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                              size: 22,
                              color: Color(0xFF0098B9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // =====================================
                      // KATA SANDI
                      // =====================================
                      _buildLabel('Kata Sandi'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Masukkan Kata Sandi (min. 6 karakter)',
                        obscureText: !_passwordVisible,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 22,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // =====================================
                      // KONFIRMASI KATA SANDI
                      // =====================================
                      _buildLabel('Konfirmasi Kata Sandi'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Masukkan Ulang Kata Sandi',
                        obscureText: !_confirmPasswordVisible,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _confirmPasswordVisible =
                                  !_confirmPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _confirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 22,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // =====================================
                      // TOMBOL DAFTAR
                      // =====================================
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _daftar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0098B9),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  _isDoctorRole
                                      ? 'Daftar sebagai Dokter'
                                      : 'Daftar Sekarang',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // =====================================
                      // LINK SUDAH PUNYA AKUN
                      // =====================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah memiliki akun? ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Masuk di sini',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1689D0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 56,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: Colors.grey,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(
              color: Color(0xFF76AFC7),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(
              color: Color(0xFF147C9C),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}