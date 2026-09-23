import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'forgot_password_page.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk input email/no HP
  final TextEditingController emailController =
      TextEditingController();

  // Controller untuk input password
  final TextEditingController passwordController =
      TextEditingController();

  // Menampilkan / menyembunyikan password
  bool _obscurePassword = true;

  // Status loading saat proses login berlangsung
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // PROSES LOGIN DENGAN FIREBASE AUTHENTICATION
  // ==========================================
  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan kata sandi wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await AuthService.instance.signIn(
      email: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SizedBox.expand(
        child: Stack(
          children: [
            // ==========================================
            // DEKORASI BIRU MUDA DI KIRI BAWAH
            // ==========================================

            Positioned(
              left: -135,
              bottom: -105,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),

                      // ==========================================
                      // JUDUL
                      // ==========================================

                      const Center(
                        child: Text(
                          'Selamat Kembali!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ==========================================
                      // SUBJUDUL
                      // ==========================================

                      const Center(
                        child: Text(
                          'Silahkan masuk untuk melanjutkan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 70),

                      // ==========================================
                      // EMAIL / NO HP
                      // ==========================================

                      const Text(
                        'Email atau No. HP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        height: 58,
                        child: TextField(
                          controller: emailController,
                          keyboardType:
                              TextInputType.emailAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Masukkan email atau no. HP',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            enabledBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(7),
                              borderSide:
                                  const BorderSide(
                                color: Color(0xFF76AFC7),
                                width: 1.2,
                              ),
                            ),
                            focusedBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(7),
                              borderSide:
                                  const BorderSide(
                                color: Color(0xFF147C9C),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ==========================================
                      // PASSWORD
                      // ==========================================

                      const Text(
                        'Kata Sandi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        height: 58,
                        child: TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Masukkan kata sandi',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),

                            // ICON MATA
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 23,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword;
                                });
                              },
                            ),

                            enabledBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(7),
                              borderSide:
                                  const BorderSide(
                                color: Color(0xFF76AFC7),
                                width: 1.2,
                              ),
                            ),

                            focusedBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(7),
                              borderSide:
                                  const BorderSide(
                                color: Color(0xFF147C9C),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ==========================================
                      // LUPA PASSWORD
                      // ==========================================

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Lupa kata sandi?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0086B3),
                          ),
                        ),
                      ),

                      // ==========================================
                      // JARAK SEBELUM TOMBOL
                      // ==========================================

                      SizedBox(
                        height:
                            screenHeight < 750 ? 55 : 85,
                      ),

                      // ==========================================
                      // TOMBOL MASUK
                      // ==========================================

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF0B9AC1),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
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
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 45),

                      // ==========================================
                      // DAFTAR
                      // ==========================================

                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Belum punya akun? ',
                              ),

                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignupPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Daftar di sini',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color:
                                          Color(0xFF0077CC),
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
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
}