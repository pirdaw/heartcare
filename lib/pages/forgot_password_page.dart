import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/heartcare_auth_widgets.dart';
import 'check_email_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13.5, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE11D48),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorSnackBar('Masukkan alamat email terlebih dahulu.');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showErrorSnackBar('Format email tidak valid. Masukkan format yang benar.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final error = await AuthService.instance.sendPasswordResetEmail(email);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (error != null) {
      _showErrorSnackBar(error);
      return;
    }

    // Berhasil kirim email -> pindah ke CheckEmailPage dengan email tujuan
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckEmailPage(email: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HeartCareAuthBackground(
      showEkg: true,
      child: Column(
        children: [
          // ==========================================
          // TOP NAVIGATION BAR
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const HeartCareBackButton(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_reset_rounded,
                        size: 14,
                        color: Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pemulihan Sandi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 42), // Balance for back button
              ],
            ),
          ),

          // ==========================================
          // SCROLLABLE CONTENT
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // Hero Icon / Badge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF131D36)
                              : Colors.white,
                          border: Border.all(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.20),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFE0F2FE),
                                  const Color(0xFFBAE6FD).withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.lock_open_rounded,
                              size: 28,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: HeartPulseBadge(
                          size: 28,
                          icon: Icons.shield_rounded,
                          glowColor: Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Lupa Kata Sandi?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Jangan khawatir! Masukkan email akun HeartCare Anda untuk menerima tautan instruksi pemulihan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // FORM CARD
                  // ==========================================
                  HeartCareCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeartCareTextField(
                          controller: _emailController,
                          label: 'Email Terdaftar',
                          hintText: 'nama@email.com',
                          prefixIcon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleResetPassword(),
                        ),

                        const SizedBox(height: 18),

                        // Info hint
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A).withValues(alpha: 0.6)
                                : const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.mark_email_unread_outlined,
                                size: 18,
                                color: Color(0xFF0284C7),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Tautan pemulihan akan berlaku selama 60 menit untuk menjamin keamanan akun medis Anda.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        HeartCareGradientButton(
                          onPressed: _handleResetPassword,
                          text: 'Kirim Tautan Pemulihan',
                          icon: Icons.send_rounded,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // KEMBALI KE LOGIN
                  // ==========================================
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF131D36).withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ingat kata sandi Anda? ',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Kembali ke Masuk',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const HeartCareTrustBadge(),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}