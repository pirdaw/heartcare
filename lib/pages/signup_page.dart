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

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _daftar() async {
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (nama.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom wajib diisi')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi terlalu lemah (minimal 6 karakter)'),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await AuthService.instance.signUp(
      name: nama,
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    // Keluar dari sesi otomatis Firebase agar pengguna harus login terlebih dahulu
    await AuthService.instance.signOut();

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessPage(
          title: 'Pendaftaran Berhasil',
          message: 'Akun Anda berhasil dibuat!',
          subMessage: 'Silakan masuk menggunakan email dan kata sandi Anda.',
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
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
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
                // EMAIL / NO HP
                // =====================================

                _buildLabel('Email atau No. HP'),

                const SizedBox(height: 10),

                _buildTextField(
                  controller: _emailController,
                  hintText: 'Masukkan Email atau No. HP',
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
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
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
  }) {
    return SizedBox(
      height: 58,
      child: TextField(
        controller: controller,
        obscureText: obscureText,

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