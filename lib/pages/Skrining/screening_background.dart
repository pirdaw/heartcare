import 'package:flutter/material.dart';
import '../../services/theme_service.dart';

/// Latar belakang seragam untuk seluruh alur Skrining:
/// - Gradasi dasar halus selaras dengan Menu Welcome & Home
/// - Ambient glow lembut dengan RadialGradient transparan (tanpa polkadot / lingkaran tegas)
/// - Garis ritme EKG halus pada latar belakang
/// - Dukungan penuh Light & Dark mode
class ScreeningBackground extends StatelessWidget {
  final Widget child;
  final bool showEkg;

  const ScreeningBackground({
    super.key,
    required this.child,
    this.showEkg = true,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;
        final size = MediaQuery.of(context).size;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          body: Stack(
            children: [
              // 1. Gradasi Utama (Menyesuaikan desain Welcome & Home)
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.32, 0.68, 1.0],
                    colors: isDark
                        ? const [
                            Color(0xFF1E293B),
                            Color(0xFF162032),
                            Color(0xFF111927),
                            Color(0xFF0E2536),
                          ]
                        : const [
                            Color(0xFFE0F2FE),
                            Color(0xFFF4F9FD),
                            Color(0xFFE0F2FE),
                            Color(0xFFBAE6FD),
                          ],
                  ),
                ),
              ),

              // 2. Ambient Glowing Orb - Atas Kanan (Gradasi radial halus, tanpa batas polkadot)
              Positioned(
                top: -60,
                right: -50,
                child: IgnorePointer(
                  child: Container(
                    width: 270,
                    height: 270,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF38BDF8)
                              .withValues(alpha: isDark ? 0.12 : 0.22),
                          const Color(0xFF38BDF8).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Ambient Glowing Orb - Tengah Kiri (Cyan lembut)
              Positioned(
                top: size.height * 0.35,
                left: -70,
                child: IgnorePointer(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF0EA5E9)
                              .withValues(alpha: isDark ? 0.10 : 0.16),
                          const Color(0xFF0EA5E9).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Ambient Glowing Orb - Bawah Kanan (Sky Blue)
              Positioned(
                bottom: -70,
                right: -50,
                child: IgnorePointer(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF0284C7)
                              .withValues(alpha: isDark ? 0.12 : 0.20),
                          const Color(0xFF0284C7).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 5. Garis EKG Halus di Latar Belakang
              if (showEkg)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ScreeningEkgWavePainter(
                        waveColor: (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                            .withValues(alpha: isDark ? 0.14 : 0.09),
                      ),
                    ),
                  ),
                ),

              // 6. Konten Utama
              SafeArea(
                child: child,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Painter garis ritme EKG halus di background
class _ScreeningEkgWavePainter extends CustomPainter {
  final Color waveColor;

  _ScreeningEkgWavePainter({required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final y = size.height * 0.26;

    final paintLine = Paint()
      ..color = waveColor
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, y);
    path.lineTo(w * 0.12, y);

    // Gelombang P
    path.quadraticBezierTo(w * 0.16, y - 8, w * 0.20, y);
    path.lineTo(w * 0.25, y);

    // Gelombang Q
    path.lineTo(w * 0.27, y + 6);

    // Gelombang R (Spike detak jantung)
    path.lineTo(w * 0.31, y - 48);

    // Gelombang S
    path.lineTo(w * 0.35, y + 22);

    // Kembali baseline
    path.lineTo(w * 0.38, y);

    // Gelombang T
    path.quadraticBezierTo(w * 0.44, y - 15, w * 0.50, y);
    path.lineTo(w * 0.62, y);

    // Siklus kedua
    path.quadraticBezierTo(w * 0.66, y - 8, w * 0.70, y);
    path.lineTo(w * 0.74, y);
    path.lineTo(w * 0.76, y + 6);
    path.lineTo(w * 0.80, y - 44);
    path.lineTo(w * 0.84, y + 20);
    path.lineTo(w * 0.87, y);
    path.quadraticBezierTo(w * 0.92, y - 14, w * 0.96, y);
    path.lineTo(w, y);

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _ScreeningEkgWavePainter oldDelegate) =>
      oldDelegate.waveColor != waveColor;
}

