import 'package:flutter/material.dart';

/// Bottom Navigation Bar kustom yang identik dengan desain referensi
class HeartCareBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const HeartCareBottomNavBar({
    super.key,
    this.currentIndex = 1,
    this.onTap,
  });

  static const Color primaryTeal = Color(0xFF0098B9);
  static const Color inactiveColor = Color(0xFF4B5563);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home_outlined,
            label: 'Home',
          ),
          _buildNavItem(
            index: 1,
            customIcon: _buildHeartPlusIcon(currentIndex == 1),
            label: 'Skrining',
          ),
          _buildNavItem(
            index: 2,
            customIcon: _buildDoctorIcon(currentIndex == 2),
            label: 'Dokter',
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.description_outlined,
            label: 'Riwayat',
          ),
          _buildNavItem(
            index: 4,
            icon: Icons.person_outline_rounded,
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    IconData? icon,
    Widget? customIcon,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;
    final Color itemColor = isSelected ? primaryTeal : inactiveColor;

    return InkWell(
      onTap: () => onTap?.call(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 28,
            child: Center(
              child: customIcon ??
                  Icon(
                    icon,
                    size: 24,
                    color: itemColor,
                  ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: itemColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartPlusIcon(bool isSelected) {
    final Color color = isSelected ? primaryTeal : inactiveColor;
    return SizedBox(
      width: 30,
      height: 26,
      child: CustomPaint(
        painter: _HeartPlusPainter(color: color),
      ),
    );
  }

  Widget _buildDoctorIcon(bool isSelected) {
    final Color color = isSelected ? primaryTeal : inactiveColor;
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(
        painter: _DoctorIconPainter(color: color),
      ),
    );
  }
}

/// Painter untuk ikon hati dengan tanda plus (+) di tengahnya persis seperti desain
class _HeartPlusPainter extends CustomPainter {
  final Color color;

  _HeartPlusPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    // Gambar kontur hati
    final Path heartPath = Path();
    heartPath.moveTo(w * 0.5, h * 0.85);

    // Kurva kiri
    heartPath.cubicTo(
      w * 0.15,
      h * 0.65,
      w * 0.05,
      h * 0.35,
      w * 0.22,
      h * 0.18,
    );
    heartPath.cubicTo(
      w * 0.35,
      h * 0.05,
      w * 0.48,
      h * 0.15,
      w * 0.5,
      h * 0.30,
    );

    // Kurva kanan
    heartPath.cubicTo(
      w * 0.52,
      h * 0.15,
      w * 0.65,
      h * 0.05,
      w * 0.78,
      h * 0.18,
    );
    heartPath.cubicTo(
      w * 0.95,
      h * 0.35,
      w * 0.85,
      h * 0.65,
      w * 0.5,
      h * 0.85,
    );

    canvas.drawPath(heartPath, strokePaint);

    // Tanda Plus di tengah
    final double centerX = w * 0.5;
    final double centerY = h * 0.46;
    const double plusRadius = 4.5;

    // Horizontal
    canvas.drawLine(
      Offset(centerX - plusRadius, centerY),
      Offset(centerX + plusRadius, centerY),
      strokePaint,
    );
    // Vertikal
    canvas.drawLine(
      Offset(centerX, centerY - plusRadius),
      Offset(centerX, centerY + plusRadius),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HeartPlusPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Painter untuk ikon dokter (kepala + stetoskop/bahu)
class _DoctorIconPainter extends CustomPainter {
  final Color color;

  _DoctorIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    // Lingkaran kepala
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.28),
      w * 0.22,
      strokePaint,
    );

    // Bahu melengkung
    final Path bodyPath = Path();
    bodyPath.moveTo(w * 0.12, h * 0.88);
    bodyPath.cubicTo(
      w * 0.15,
      h * 0.60,
      w * 0.85,
      h * 0.60,
      w * 0.88,
      h * 0.88,
    );
    canvas.drawPath(bodyPath, strokePaint);

    // Stetoskop U melengkung di leher
    final Path stethoPath = Path();
    stethoPath.moveTo(w * 0.38, h * 0.55);
    stethoPath.quadraticBezierTo(w * 0.5, h * 0.76, w * 0.62, h * 0.55);
    canvas.drawPath(stethoPath, strokePaint);

    // Bulatan stetoskop kecil
    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.77), 1.8, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _DoctorIconPainter oldDelegate) =>
      oldDelegate.color != color;
}