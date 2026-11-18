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
  final String? badgeLabel;
  final IconData? icon;

  const SuccessPage({
    super.key,
    this.title = 'Berhasil',
    this.message = 'Operasi berhasil dilakukan',
    this.subMessage,
    this.subtitle,
    this.buttonText = 'Masuk Sekarang',
    this.onButtonPressed,
    this.destinationPage,
    this.duration,
    this.badgeLabel,
    this.icon,
  });

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Auto navigasi jika ditentukan duration
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayDesc = widget.subtitle ?? widget.subMessage ?? '';
    final isDoctor = widget.title.toLowerCase().contains('dokter') ||
        widget.message.toLowerCase().contains('dokter');

    final effectiveBadge = widget.badgeLabel ??
        (isDoctor ? 'Akun Dokter Terverifikasi' : 'Pendaftaran Berhasil');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 1. Base Multi-stop Gradient Background (Sama persis dengan Menu Home)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.32, 0.70, 1.0],
                  colors: isDark
                      ? const [
                          Color(0xFF1E293B),
                          Color(0xFF162032),
                          Color(0xFF111927),
                          Color(0xFF0F172A),
                        ]
                      : const [
                          Color(0xFFE0F2FE),
                          Color(0xFFEDF6FD),
                          Color(0xFFF3F8FD),
                          Color(0xFFF8FAFC),
                        ],
                ),
              ),
            ),
          ),

          // 2. Ornamen Ambient Glow Lembut (Konsisten dengan Menu Home)
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8)
                    .withValues(alpha: isDark ? 0.05 : 0.20),
              ),
            ),
          ),
          Positioned(
            top: 260,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0EA5E9)
                    .withValues(alpha: isDark ? 0.04 : 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0284C7)
                    .withValues(alpha: isDark ? 0.05 : 0.10),
              ),
            ),
          ),

          // 3. Konten Utama
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Card Modern bergaya Home Page
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 34,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B).withValues(alpha: 0.95)
                              : Colors.white.withValues(alpha: 0.97),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7)
                                  .withValues(alpha: isDark ? 0.25 : 0.08),
                              blurRadius: 30,
                              spreadRadius: 2,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: const Color(0xFF38BDF8)
                                  .withValues(alpha: isDark ? 0.12 : 0.05),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Badge Chip di bagian atas (gaya + AI Screening Assessment di Home)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6.5,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0284C7)
                                        .withValues(alpha: 0.22)
                                    : const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: (isDark
                                          ? const Color(0xFF38BDF8)
                                          : const Color(0xFF0284C7))
                                      .withValues(alpha: 0.35),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isDoctor
                                        ? Icons.verified_rounded
                                        : Icons.stars_rounded,
                                    size: 15,
                                    color: isDoctor
                                        ? const Color(0xFF0284C7)
                                        : const Color(0xFF0284C7),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    effectiveBadge,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? const Color(0xFF38BDF8)
                                          : const Color(0xFF0284C7),
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Lingkaran Ikon Centang Animasi dengan Glow
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFFE0F2FE),
                                  border: Border.all(
                                    color: const Color(0xFF38BDF8)
                                        .withValues(alpha: 0.45),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0284C7)
                                          .withValues(alpha: 0.22),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 66,
                                    height: 66,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF38BDF8),
                                          Color(0xFF0284C7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF0284C7),
                                          blurRadius: 10,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      widget.icon ?? Icons.check_rounded,
                                      color: Colors.white,
                                      size: 38,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Judul Utama
                            Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                letterSpacing: -0.4,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Pesan Subtitle (Highlight)
                            Text(
                              widget.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF38BDF8)
                                    : const Color(0xFF0284C7),
                              ),
                            ),

                            if (displayDesc.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              // Keterangan Panduan (Bebas dari istilah teknis Firestore)
                              Text(
                                displayDesc,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                  height: 1.5,
                                ),
                              ),
                            ],

                            const SizedBox(height: 22),

                            // Mini Card Fitur Layanan (Gaya persis Layanan Kesehatan di Home)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A).withValues(alpha: 0.6)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFE0F2FE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isDoctor
                                          ? Icons.medical_services_rounded
                                          : Icons.favorite_rounded,
                                      color: const Color(0xFF0284C7),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isDoctor
                                              ? 'Portal Dokter HeartCare'
                                              : 'Layanan Terpadu HeartCare',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isDoctor
                                              ? 'Kelola jadwal, konsultasi chat pasien, dan resep medis'
                                              : 'Skrining risiko jantung, konsultasi dokter, & pengingat obat',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B),
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 26),

                            // Tombol CTA Gradient Penuh (Konsisten dengan Tombol Home)
                            if (widget.duration != null &&
                                widget.onButtonPressed == null)
                              const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.8,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF0284C7),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0284C7),
                                      Color(0xFF0369A1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0284C7)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: widget.onButtonPressed ??
                                        () {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  widget.destinationPage ??
                                                  const LoginPage(),
                                            ),
                                            (route) => false,
                                          );
                                        },
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.buttonText,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Footer HeartCare Branding
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              size: 13,
                              color: const Color(0xFF0284C7)
                                  .withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'HeartCare • Sahabat Jantung Anda',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
