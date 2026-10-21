import 'package:flutter/material.dart';

/// Ilustrasi clipboard medis dengan grafik EKG dan jantung merah berdetak
/// Dibuat murni dengan CustomPainter agar tajam dan presisi di semua resolusi layar.
class MedicalClipboardIllustration extends StatelessWidget {
  final double width;
  final double height;

  const MedicalClipboardIllustration({
    super.key,
    this.width = 230,
    this.height = 290,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _ClipboardPainter(),
      ),
    );
  }
}

class _ClipboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Dimensi Clipboard Utama
    final double boardLeft = w * 0.12;
    final double boardTop = h * 0.10;
    final double boardWidth = w * 0.76;
    final double boardHeight = h * 0.82;
    const double boardRadius = 18.0;

    final RRect boardRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boardLeft, boardTop, boardWidth, boardHeight),
      const Radius.circular(boardRadius),
    );

    // 1. Bayangan halus clipboard
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.04)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRRect(boardRRect.shift(const Offset(0, 5)), shadowPaint);

    // 2. Isi clipboard (Putih)
    final Paint whiteFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(boardRRect, whiteFill);

    // 3. Border Clipboard (Cyan/Teal)
    final Paint boardBorder = Paint()
      ..color = const Color(0xFF079BC1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5;
    canvas.drawRRect(boardRRect, boardBorder);

    // 4. Klip Penjepit di bagian atas (Navy / Dark Slate)
    final Paint clipPaint = Paint()
      ..color = const Color(0xFF1E3A5F)
      ..style = PaintingStyle.fill;

    final double clipWidth = boardWidth * 0.44;
    final double clipHeight = h * 0.08;
    final double clipLeft = boardLeft + (boardWidth - clipWidth) / 2;
    final double clipTop = boardTop - (clipHeight * 0.35);

    // Kotak klip utama
    final RRect clipMainRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(clipLeft, clipTop + clipHeight * 0.25, clipWidth, clipHeight * 0.75),
      const Radius.circular(8.0),
    );
    canvas.drawRRect(clipMainRRect, clipPaint);

    // Tonjolan bulat klip di paling atas dengan lubang gantung
    final double tabWidth = clipWidth * 0.42;
    final double tabHeight = clipHeight * 0.6;
    final double tabLeft = clipLeft + (clipWidth - tabWidth) / 2;
    final double tabTop = clipTop;

    final RRect clipTabRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tabLeft, tabTop, tabWidth, tabHeight),
      const Radius.circular(6.0),
    );
    canvas.drawRRect(clipTabRRect, clipPaint);

    // Lubang gantung di tab klip
    final Paint holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(tabLeft + tabWidth / 2, tabTop + tabHeight * 0.4),
      tabWidth * 0.16,
      holePaint,
    );

    // 5. Elemen Kertas di dalam Clipboard
    // A. Avatar Profil Medis (Biru Muda Pastel)
    final Paint avatarPaint = Paint()
      ..color = const Color(0xFFABC8E2)
      ..style = PaintingStyle.fill;

    final double avatarCenterX = boardLeft + boardWidth * 0.22;
    final double avatarCenterY = boardTop + boardHeight * 0.18;
    final double avatarHeadRadius = boardWidth * 0.07;

    // Kepala avatar
    canvas.drawCircle(
      Offset(avatarCenterX, avatarCenterY),
      avatarHeadRadius,
      avatarPaint,
    );

    // Bahu avatar
    final Path shoulderPath = Path();
    shoulderPath.moveTo(avatarCenterX - avatarHeadRadius * 1.5, avatarCenterY + avatarHeadRadius * 2.1);
    shoulderPath.quadraticBezierTo(
      avatarCenterX,
      avatarCenterY + avatarHeadRadius * 0.8,
      avatarCenterX + avatarHeadRadius * 1.5,
      avatarCenterY + avatarHeadRadius * 2.1,
    );
    shoulderPath.close();
    canvas.drawPath(shoulderPath, avatarPaint);

    // B. Garis-garis Rekam Medis di samping Avatar (Biru Lembut)
    final Paint linePaint = Paint()
      ..color = const Color(0xFFCCE1F2)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    final double linesStartX = boardLeft + boardWidth * 0.42;
    final double lineY1 = boardTop + boardHeight * 0.14;
    final double lineY2 = boardTop + boardHeight * 0.20;
    final double lineY3 = boardTop + boardHeight * 0.26;

    canvas.drawLine(
      Offset(linesStartX, lineY1),
      Offset(linesStartX + boardWidth * 0.42, lineY1),
      linePaint,
    );
    canvas.drawLine(
      Offset(linesStartX, lineY2),
      Offset(linesStartX + boardWidth * 0.32, lineY2),
      linePaint,
    );
    canvas.drawLine(
      Offset(linesStartX, lineY3),
      Offset(linesStartX + boardWidth * 0.38, lineY3),
      linePaint,
    );

    // C. Garis EKG Navy di Bagian Tengah Kertas
    final Paint ecgNavyPaint = Paint()
      ..color = const Color(0xFF1E3A5F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter;

    final double ecgY = boardTop + boardHeight * 0.44;
    final double ecgStartX = boardLeft + boardWidth * 0.08;
    final double ecgEndX = boardLeft + boardWidth * 0.90;
    final double ecgSpan = ecgEndX - ecgStartX;

    final Path ecgNavyPath = Path();
    ecgNavyPath.moveTo(ecgStartX, ecgY);
    ecgNavyPath.lineTo(ecgStartX + ecgSpan * 0.16, ecgY);
    // Gelombang P kecil
    ecgNavyPath.lineTo(ecgStartX + ecgSpan * 0.22, ecgY - 6);
    ecgNavyPath.lineTo(ecgStartX + ecgSpan * 0.28, ecgY);
    // Datar sesaat
    ecgNavyPath.lineTo(ecgStartX + ecgSpan * 0.34, ecgY);
    // QRS Complex yang tajam & khas
    ecgNavyPath.lineTo(ecgStartX + ecgSpan * 0.38, ecgY + 8); // Q dip
    ecgNavyPath.lineTo(ecgStartX + ecgSpan * 0.46, ecgY - 44); // R peak tinggi
    ecgNavyPath.lineTo(ecgStartX + ecgSpan * 0.54, ecgY + 22); // S drop
    ecgNavyPath.lineTo(ecgStartX + ecgSpan * 0.60, ecgY); // kembali
    // Gelombang T
    ecgNavyPath.lineTo(ecgStartX + ecgSpan * 0.68, ecgY - 10);
    ecgNavyPath.lineTo(ecgStartX + ecgSpan * 0.76, ecgY);
    // Datar ke kanan
    ecgNavyPath.lineTo(ecgEndX, ecgY);

    canvas.drawPath(ecgNavyPath, ecgNavyPaint);

    // Garis checklist tambahan di bawah EKG
    final Paint faintLinePaint = Paint()
      ..color = const Color(0xFFD6E7F5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    final double bottomLineY1 = boardTop + boardHeight * 0.58;
    final double bottomLineY2 = boardTop + boardHeight * 0.65;
    canvas.drawLine(
      Offset(boardLeft + boardWidth * 0.10, bottomLineY1),
      Offset(boardLeft + boardWidth * 0.45, bottomLineY1),
      faintLinePaint,
    );
    canvas.drawLine(
      Offset(boardLeft + boardWidth * 0.10, bottomLineY2),
      Offset(boardLeft + boardWidth * 0.38, bottomLineY2),
      faintLinePaint,
    );

    // 6. Ikon Jantung Merah di Sudut Kanan Bawah
    final double heartCenterX = boardLeft + boardWidth * 0.72;
    final double heartCenterY = boardTop + boardHeight * 0.75;
    final double heartScale = w * 0.46;

    // Bayangan halus jantung
    final Path heartPath = _getHeartPath(heartCenterX, heartCenterY, heartScale);
    final Paint heartShadowPaint = Paint()
      ..color = const Color(0xFFE53935).withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(heartPath.shift(const Offset(0, 6)), heartShadowPaint);

    // Badan jantung merah cerah
    final Paint heartPaint = Paint()
      ..color = const Color(0xFFEA3748)
      ..style = PaintingStyle.fill;
    canvas.drawPath(heartPath, heartPaint);

    // 7. Garis EKG Putih di Atas Jantung Merah
    final Paint whiteEcgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path whiteEcgPath = Path();
    final double hEcgY = heartCenterY - heartScale * 0.05;
    final double hLeft = heartCenterX - heartScale * 0.36;
    final double hRight = heartCenterX + heartScale * 0.36;
    final double hSpan = hRight - hLeft;

    whiteEcgPath.moveTo(hLeft, hEcgY);
    whiteEcgPath.lineTo(hLeft + hSpan * 0.28, hEcgY);
    whiteEcgPath.lineTo(hLeft + hSpan * 0.38, hEcgY + 12); // Q
    whiteEcgPath.lineTo(hLeft + hSpan * 0.50, hEcgY - 26); // R
    whiteEcgPath.lineTo(hLeft + hSpan * 0.62, hEcgY + 16); // S
    whiteEcgPath.lineTo(hLeft + hSpan * 0.72, hEcgY);
    whiteEcgPath.lineTo(hRight, hEcgY);

    canvas.drawPath(whiteEcgPath, whiteEcgPaint);
  }

  Path _getHeartPath(double cx, double cy, double size) {
    final Path path = Path();
    final double halfW = size * 0.5;
    final double h = size * 0.88;

    // Mulai dari ujung bawah jantung
    path.moveTo(cx, cy + h * 0.46);

    // Sisi kiri
    path.cubicTo(
      cx - halfW * 1.1,
      cy + h * 0.12,
      cx - halfW * 0.95,
      cy - h * 0.40,
      cx - halfW * 0.42,
      cy - h * 0.40,
    );
    path.cubicTo(
      cx - halfW * 0.14,
      cy - h * 0.40,
      cx,
      cy - h * 0.18,
      cx,
      cy - h * 0.08,
    );

    // Sisi kanan
    path.cubicTo(
      cx,
      cy - h * 0.18,
      cx + halfW * 0.14,
      cy - h * 0.40,
      cx + halfW * 0.42,
      cy - h * 0.40,
    );
    path.cubicTo(
      cx + halfW * 0.95,
      cy - h * 0.40,
      cx + halfW * 1.1,
      cy + h * 0.12,
      cx,
      cy + h * 0.46,
    );

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}