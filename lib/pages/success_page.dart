import 'package:flutter/material.dart';
import 'home_page.dart';

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