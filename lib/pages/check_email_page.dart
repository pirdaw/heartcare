import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../widgets/heartcare_auth_widgets.dart';
import 'login_page.dart';

class CheckEmailPage extends StatefulWidget {
  final String email;

  const CheckEmailPage({
    super.key,
    required this.email,
  });

  @override
  State<CheckEmailPage> createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
  int _resendCountdown = 60;
  Timer? _timer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _resendCountdown = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
    });

    final error = await AuthService.instance.sendPasswordResetEmail(widget.email);

    if (!mounted) return;

    setState(() {
      _isResending = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tautan reset telah dikirim ulang ke ${widget.email}.'),
          backgroundColor: const Color(0xFF0284C7),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _startCountdown();
    }
  }

  Future<void> _openEmailApp() async {
    final Uri emailUri = Uri(scheme: 'mailto');
    try {
      final canOpen = await canLaunchUrl(emailUri);
      if (canOpen) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buka aplikasi email Anda (seperti Gmail atau Yahoo) untuk melihat tautan.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan buka aplikasi email Anda secara manual.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HeartCareAuthBackground(
      showEkg: true,
      child: Column(
        children: [
          // ==========================================
          // TOP NAVIGATION
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
                        Icons.mark_email_read_rounded,
                        size: 14,
                        color: Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Cek Email',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 42),
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
                          color: isDark ? const Color(0xFF131D36) : Colors.white,
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
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                              ),
                            ),
                            child: const Icon(
                              Icons.mark_email_read_outlined,
                              size: 30,
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
                          icon: Icons.favorite_rounded,
                          glowColor: Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Periksa Email Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Kami telah mengirimkan tautan untuk mengatur ulang kata sandi ke:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email Pill Highlight
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF131D36).withValues(alpha: 0.85)
                          : const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.4),
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
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF0284C7),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.email,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0284C7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==========================================
                  // STEPS CARD
                  // ==========================================
                  HeartCareCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Panduan Langkah Pemulihan:',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildStepItem(isDark, '1', 'Buka kotak masuk aplikasi email Anda.'),
                        const SizedBox(height: 8),
                        _buildStepItem(isDark, '2', 'Buka pesan dari Firebase / HeartCare Support.'),
                        const SizedBox(height: 8),
                        _buildStepItem(isDark, '3', 'Klik tautan untuk membuat kata sandi baru.'),
                        const SizedBox(height: 8),
                        _buildStepItem(isDark, '4', 'Setelah tersimpan, kembali ke aplikasi dan masuk.'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==========================================
                  // ACTION BUTTONS
                  // ==========================================
                  HeartCareGradientButton(
                    onPressed: _openEmailApp,
                    text: 'Buka Aplikasi Email',
                    icon: Icons.open_in_new_rounded,
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(
                            initialEmail: widget.email,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(
                        color: Color(0xFF0284C7),
                        width: 1.4,
                      ),
                      backgroundColor: isDark
                          ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                    child: const Text(
                      'Sudah Ubah Password? Masuk Sekarang',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Resend countdown
                  Center(
                    child: _isResending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFF0284C7),
                            ),
                          )
                        : _resendCountdown > 0
                            ? Text(
                                'Kirim ulang email dalam $_resendCountdown detik',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              )
                            : GestureDetector(
                                onTap: _resendEmail,
                                child: const Text(
                                  'Belum menerima email? Kirim ulang',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF0284C7),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '💡 Tips: Periksa juga folder Spam atau Promosi jika email belum masuk.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(bool isDark, String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF0284C7),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}