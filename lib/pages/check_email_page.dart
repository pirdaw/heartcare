import 'dart:async';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../services/auth_service.dart';
=======
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
>>>>>>> a00283c708b1bbb7d146aabf5e55656be1c38c85

class CheckEmailPage extends StatefulWidget {
  final String email;

<<<<<<< HEAD
  const CheckEmailPage({super.key, required this.email});
=======
  const CheckEmailPage({
    super.key,
    required this.email,
  });
>>>>>>> a00283c708b1bbb7d146aabf5e55656be1c38c85

  @override
  State<CheckEmailPage> createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
<<<<<<< HEAD
  bool _isResending = false;

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);

    final error = await AuthService.instance.sendPasswordResetEmail(
      widget.email,
    );

    if (!mounted) return;
    setState(() => _isResending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Email reset password dikirim ulang'),
      ),
    );
=======
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
>>>>>>> a00283c708b1bbb7d146aabf5e55656be1c38c85
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
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tautan reset telah dikirim ulang ke ${widget.email}.'),
          backgroundColor: const Color(0xFF0B9AC1),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),

              // ==========================================
              // TOMBOL KEMBALI
              // ==========================================
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F0F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    size: 23,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ==========================================
              // ILUSTRASI / ICON EMAIL
              // ==========================================
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F5FA),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF76AFC7).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 42,
                    color: Color(0xFF0B9AC1),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // ICON EMAIL
              // ==========================================
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEAF6FB),
                  border: Border.all(
                    color: const Color(0xFF009FE3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  color: Color(0xFF0B9AC1),
                  size: 32,
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // JUDUL
              // ==========================================
<<<<<<< HEAD
              const Text(
                'Periksa email kamu',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
=======
              const Center(
                child: Text(
                  'Periksa Email Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
>>>>>>> a00283c708b1bbb7d146aabf5e55656be1c38c85
                ),
              ),

              const SizedBox(height: 12),

              // ==========================================
              // KETERANGAN
              // ==========================================
<<<<<<< HEAD
              Text(
                'Kami sudah mengirimkan link reset password ke:\n'
                '${widget.email}\n\n'
                'Buka email tersebut dan klik link di dalamnya untuk '
                'membuat kata sandi baru.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 35),

              // ==========================================
              // TOMBOL KEMBALI KE MASUK
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    );
                  },
=======
              const Center(
                child: Text(
                  'Kami telah mengirimkan tautan untuk mengatur ulang kata sandi ke:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ==========================================
              // KOTAK BADGE EMAIL PENGGUNA
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8FB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF76AFC7),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF147C9C),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.email,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF147C9C),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // PANDUAN LANGKAH-LANGKAH
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: Color(0xFF0B9AC1),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Langkah Selanjutnya:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildStepItem('1', 'Buka kotak masuk email Anda.'),
                    const SizedBox(height: 6),
                    _buildStepItem('2', 'Buka pesan dari Firebase / HeartCare.'),
                    const SizedBox(height: 6),
                    _buildStepItem('3', 'Klik tautan untuk membuat kata sandi baru.'),
                    const SizedBox(height: 6),
                    _buildStepItem('4', 'Setelah tersimpan, kembali ke aplikasi dan masuk.'),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ==========================================
              // TOMBOL BUKA APLIKASI EMAIL
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _openEmailApp,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text(
                    'Buka Aplikasi Email',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
>>>>>>> a00283c708b1bbb7d146aabf5e55656be1c38c85
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B9AC1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ==========================================
              // TOMBOL SUDAH RESET / KEMBALI KE LOGIN
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
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
                    foregroundColor: const Color(0xFF0B9AC1),
                    side: const BorderSide(
                      color: Color(0xFF0B9AC1),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
<<<<<<< HEAD
                    'Kembali ke Masuk',
=======
                    'Sudah Ubah Password? Masuk Sekarang',
>>>>>>> a00283c708b1bbb7d146aabf5e55656be1c38c85
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // KIRIM ULANG EMAIL DENGAN COUNTDOWN
              // ==========================================
              Center(
<<<<<<< HEAD
                child: GestureDetector(
                  onTap: _isResending ? null : _resendEmail,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Belum menerima email? ',
                        ),
                        TextSpan(
                          text: _isResending
                              ? 'Mengirim...'
                              : 'Kirim ulang email',
                          style: const TextStyle(
                            color: Color(0xFF0077CC),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
=======
                child: _isResending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0B9AC1),
                        ),
                      )
                    : _resendCountdown > 0
                        ? Text(
                            'Kirim ulang email dalam $_resendCountdown detik',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          )
                        : GestureDetector(
                            onTap: _resendEmail,
                            child: const Text(
                              'Belum menerima email? Kirim ulang',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF0077CC),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
              ),

              const SizedBox(height: 12),

              // ==========================================
              // TIPS SPAM FOLDER
              // ==========================================
              Center(
                child: Text(
                  'Tips: Jika email belum muncul, periksa folder Spam atau Promosi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
>>>>>>> a00283c708b1bbb7d146aabf5e55656be1c38c85
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======

  Widget _buildStepItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF0B9AC1),
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
            style: const TextStyle(
              fontSize: 12.5,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
>>>>>>> a00283c708b1bbb7d146aabf5e55656be1c38c85
