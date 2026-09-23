import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CheckEmailPage extends StatefulWidget {
  final String email;

  const CheckEmailPage({super.key, required this.email});

  @override
  State<CheckEmailPage> createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
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

              const SizedBox(height: 32),

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
              const Text(
                'Periksa email kamu',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),

              // ==========================================
              // KETERANGAN
              // ==========================================
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B9AC1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Masuk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==========================================
              // KIRIM ULANG EMAIL
              // ==========================================
              Center(
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
