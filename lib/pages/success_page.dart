import 'package:flutter/material.dart';
import 'home_page.dart';

<<<<<<< HEAD
class SuccessPage extends StatelessWidget {
  final String title;
  final String message;
  final String subMessage;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const SuccessPage({
    super.key,
    this.title = 'Successful',
    this.message = 'Password Anda telah berhasil diubah',
    this.subMessage = 'Silakan klik Selesai untuk masuk ke akun Anda.',
    this.buttonText = 'Selesai',
    this.onButtonPressed,
  });
=======
class SuccessPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget? destinationPage;
  final Duration duration;

  const SuccessPage({
    super.key,
    this.title = 'Pendaftaran Berhasil!',
    this.subtitle = 'Menyiapkan akun Anda, mohon tunggu sebentar...',
    this.destinationPage,
    this.duration = const Duration(milliseconds: 1800),
  });

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();

    // Otomatis navigasi ke halaman utama/tujuan tanpa perlu klik tombol
    Future.delayed(widget.duration, () {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => widget.destinationPage ?? const HomePage(),
        ),
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
>>>>>>> a00283c708b1bbb7d146aabf5e55656be1c38c85

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
<<<<<<< HEAD
                // ==========================================
                // ICON CENTANG
                // ==========================================
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF009FE3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF4D91D8),
                    size: 36,
                  ),
                ),

                const SizedBox(height: 24),

                // ==========================================
                // SUCCESSFUL / JUDUL
                // ==========================================
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 40),

                // ==========================================
                // TOMBOL SELESAI / AKSI
                // ==========================================
                SizedBox(
                  width: 130,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onButtonPressed ??
                        () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B9AC1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
=======
                // Icon Animasi Centang
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F5FA),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0B9AC1).withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B9AC1).withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF0B9AC1),
                      size: 46,
>>>>>>> a00283c708b1bbb7d146aabf5e55656be1c38c85
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Judul
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 10),

                // Keterangan
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 36),

                // Loading Indicator
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0B9AC1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}