import 'package:flutter/material.dart';

/// Ilustrasi Lencana Hati dengan Garis EKG dan Lingkaran Aksen
/// Digunakan pada halaman Hasil Skrining sesuai dengan desain Figma (Layar 4)
class HeartRiskBadgeIllustration extends StatelessWidget {
  final double size;
  final Color heartColor;
  final Color pulseColor;
  final Color accentColor;

  const HeartRiskBadgeIllustration({
    super.key,
    this.size = 130,
    this.heartColor = const Color(0xFFEF4444),
    this.pulseColor = Colors.white,
    this.accentColor = const Color(0xFF7CD3DF),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HeartRiskBadgePainter(
          heartColor: heartColor,
          pulseColor: pulseColor,
          accentColor: accentColor,
        ),
      ),
    );
  }
}

class _HeartRiskBadgePainter extends CustomPainter {
  final Color heartColor;
  final Color pulseColor;
  final Color accentColor;

  _HeartRiskBadgePainter({
    required this.heartColor,
    required this.pulseColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w * 0.5, h * 0.5);

    // 1. Lingkaran aksen belakang (cyan lembut di sisi kiri dan kanan bawah)
    final Paint accentPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    // Lingkaran aksen kiri
    canvas.drawCircle(
      Offset(w * 0.30, h * 0.58),
      w * 0.22,
      accentPaint,
    );

    // Lingkaran aksen kanan
    canvas.drawCircle(
      Offset(w * 0.70, h * 0.58),
      w * 0.22,
      accentPaint,
    );

    // 2. Bentuk Jantung Utama (Merah)
    final Paint heartPaint = Paint()
      ..color = heartColor
      ..style = PaintingStyle.fill;

    final Path heartPath = Path();
    // Titik bawah ujung jantung
    heartPath.moveTo(center.dx, h * 0.82);

    // Lengkungan kiri
    heartPath.cubicTo(
      w * 0.18,
      h * 0.62,
      w * 0.10,
      h * 0.32,
      w * 0.28,
      h * 0.22,
    );
    heartPath.cubicTo(
      w * 0.40,
      h * 0.15,
      w * 0.48,
      h * 0.28,
      center.dx,
      h * 0.38,
    );

    // Lengkungan kanan
    heartPath.cubicTo(
      w * 0.52,
      h * 0.28,
      w * 0.60,
      h * 0.15,
      w * 0.72,
      h * 0.22,
    );
    heartPath.cubicTo(
      w * 0.90,
      h * 0.32,
      w * 0.82,
      h * 0.62,
      center.dx,
      h * 0.82,
    );
    heartPath.close();

    // Bayangan halus di bawah jantung
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(heartPath.shift(const Offset(0, 3)), shadowPaint);

    // Gambar jantung merah
    canvas.drawPath(heartPath, heartPaint);

    // 3. Garis EKG Putih di tengah jantung
    final Paint pulsePaint = Paint()
      ..color = pulseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path pulsePath = Path();
    final double midY = h * 0.48;

    pulsePath.moveTo(w * 0.28, midY);
    pulsePath.lineTo(w * 0.40, midY);
    pulsePath.lineTo(w * 0.44, midY - 6);
    pulsePath.lineTo(w * 0.48, midY + 12);
    pulsePath.lineTo(w * 0.54, midY - 24); // Puncak gelombang R
    pulsePath.lineTo(w * 0.60, midY + 14); // Palung gelombang S
    pulsePath.lineTo(w * 0.64, midY);
    pulsePath.lineTo(w * 0.72, midY);

    canvas.drawPath(pulsePath, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant _HeartRiskBadgePainter oldDelegate) {
    return oldDelegate.heartColor != heartColor ||
        oldDelegate.pulseColor != pulseColor ||
        oldDelegate.accentColor != accentColor;
  }
}
