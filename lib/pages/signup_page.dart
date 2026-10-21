import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'success_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final TextEditingController _namaController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _teleponController =
      TextEditingController();

  final TextEditingController _tanggalLahirController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _tanggalLahirController.dispose();
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
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
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
        const SnackBar(content: Text('Mohon lengkapi semua data wajib (Nama, Email, Kata Sandi).')),
      );
      return;
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

    final error = await AuthService.instance.signUp(
      name: nama,
      email: email,
      password: password,
      telepon: telepon,
      tanggalLahir: tanggalLahir,
    );

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

    // Keluar dari sesi otomatis Firebase agar pengguna harus login terlebih dahulu
    await AuthService.instance.signOut();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessPage(
          title: 'Pendaftaran Berhasil',
          message: 'Akun Anda berhasil dibuat!',
          subMessage: 'Profil Anda telah tersimpan. Silakan masuk menggunakan email dan kata sandi Anda.',
          buttonText: 'Masuk',
          onButtonPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                  ),
                  child: Column(
                    children: [
                // =====================================
                // LOGO
                // =====================================

                const SizedBox(height: 35),

                Image.asset(
                  'assets/images/heartcare_logo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 8),

                // =====================================
                // JUDUL
                // =====================================

                const Text(
                  'Buat Akun Baru',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 12),

                // =====================================
                // SUBJUDUL
                // =====================================

                const Text(
                  'Daftar Untuk Mulai Menggunakan\n'
                  'HeartCare',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 30),

                // =====================================
                // NAMA LENGKAP
                // =====================================

                _buildLabel('Nama Lengkap'),

                const SizedBox(height: 10),

                _buildTextField(
                  controller: _namaController,
                  hintText: 'Masukkan Nama Lengkap',
                ),

                const SizedBox(height: 20),

                // =====================================
                // EMAIL
                // =====================================

                _buildLabel('Email'),

                const SizedBox(height: 10),

                _buildTextField(
                  controller: _emailController,
                  hintText: 'Masukkan Alamat Email',
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                // =====================================
                // NO. TELEPON
                // =====================================

                _buildLabel('No. Telepon'),

                const SizedBox(height: 10),

                _buildTextField(
                  controller: _teleponController,
                  hintText: 'Contoh: 081234567890',
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 20),

                // =====================================
                // TANGGAL LAHIR
                // =====================================

                _buildLabel('Tanggal Lahir'),

                const SizedBox(height: 10),

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

                const SizedBox(height: 20),

                // =====================================
                // KATA SANDI
                // =====================================

                _buildLabel('Kata Sandi'),

                const SizedBox(height: 10),

                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Masukkan Kata Sandi',
                  obscureText: !_passwordVisible,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordVisible =
                            !_passwordVisible;
                      });
                    },
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 23,
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =====================================
                // KONFIRMASI KATA SANDI
                // =====================================

                _buildLabel('Konfirmasi Kata Sandi'),

                const SizedBox(height: 10),

                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Masukkan Ulang Kata Sandi',
                  obscureText:
                      !_confirmPasswordVisible,
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
                      size: 23,
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // =====================================
                // TOMBOL DAFTAR
                // =====================================

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _daftar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF0B9AC1),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFF0B9AC1).withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
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
                        : const Text(
                            'Daftar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                // =====================================
                // LOGIN
                // =====================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
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

  // ===========================================
  // LABEL
  // ===========================================

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  // ===========================================
  // TEXT FIELD
  // ===========================================

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
      height: 58,
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
            fontSize: 14,
            color: Colors.grey,
          ),

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 18,
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