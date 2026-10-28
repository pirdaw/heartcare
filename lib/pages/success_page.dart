import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';

class SuccessPage extends StatefulWidget {
  final String title;
  final String message;
  final String? subMessage;
  final String? subtitle;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? destinationPage;
  final Duration? duration;

  const SuccessPage({
    super.key,
    this.title = 'Successful',
    this.message = 'Password Anda telah berhasil diubah',
    this.subMessage,
    this.subtitle,
    this.buttonText = 'Selesai',
    this.onButtonPressed,
    this.destinationPage,
    this.duration,
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

    // Jika ada duration atau destinationPage tanpa button listener khusus, auto navigasi
    if (widget.duration != null) {
      Future.delayed(widget.duration!, () {
        if (!mounted) return;
        if (widget.onButtonPressed != null) {
          widget.onButtonPressed!();
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => widget.destinationPage ?? const HomePage(),
            ),
            (route) => false,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayDesc = widget.subtitle ?? widget.message;

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
                  displayDesc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),

                if (widget.subMessage != null && widget.subMessage!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.subMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],

                const SizedBox(height: 36),

                // Tombol atau Loading Indicator
                if (widget.duration != null && widget.onButtonPressed == null)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0B9AC1)),
                    ),
                  )
                else
                  SizedBox(
                    width: 140,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: widget.onButtonPressed ??
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
                        widget.buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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