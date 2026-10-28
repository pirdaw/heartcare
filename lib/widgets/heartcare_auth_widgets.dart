import 'package:flutter/material.dart';
import '../services/theme_service.dart';

/// Reusable background with cardiac theme:
/// - Soft medical cyan & cardiac rose ambient orbs
/// - Subtle EKG heartbeat waveform in the background
/// - Full light / dark mode support
class HeartCareAuthBackground extends StatelessWidget {
  final Widget child;
  final bool showEkg;

  const HeartCareAuthBackground({
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
          backgroundColor: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
          body: Stack(
            children: [
              // 1. Base Gradient Background
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? const [
                            Color(0xFF0B132B),
                            Color(0xFF111D3E),
                            Color(0xFF1E1B38),
                          ]
                        : const [
                            Color(0xFFF0F9FF), // Pale sky cyan
                            Color(0xFFF8FAFC), // Pure clean slate
                            Color(0xFFFFF1F2), // Soft heart rose tint
                          ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),

              // 2. Ambient Glowing Orb - Top Right (Medical Cyan)
              Positioned(
                top: -80,
                right: -80,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (isDark ? const Color(0xFF0284C7) : const Color(0xFF38BDF8))
                            .withValues(alpha: isDark ? 0.28 : 0.25),
                        (isDark ? const Color(0xFF0284C7) : const Color(0xFF38BDF8))
                            .withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Ambient Glowing Orb - Bottom Left (Heart Rose / Coral)
              Positioned(
                bottom: -100,
                left: -80,
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (isDark ? const Color(0xFFE11D48) : const Color(0xFFFB7185))
                            .withValues(alpha: isDark ? 0.22 : 0.18),
                        (isDark ? const Color(0xFFE11D48) : const Color(0xFFFB7185))
                            .withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Ambient Glowing Orb - Center Right (Subtle Warm Glow)
              Positioned(
                top: size.height * 0.42,
                right: -70,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF0EA5E9).withValues(alpha: isDark ? 0.15 : 0.12),
                        const Color(0xFF0EA5E9).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // 5. Cardiac EKG Waveform Painter in Background
              if (showEkg)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _EkgHeartbeatPainter(
                        waveColor: (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                            .withValues(alpha: isDark ? 0.15 : 0.10),
                        pulseColor: const Color(0xFFE11D48).withValues(alpha: isDark ? 0.25 : 0.18),
                      ),
                    ),
                  ),
                ),

              // 6. Main Interactive Content
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

/// Custom Painter drawing a sleek cardiac rhythm / EKG line across the screen
class _EkgHeartbeatPainter extends CustomPainter {
  final Color waveColor;
  final Color pulseColor;

  _EkgHeartbeatPainter({
    required this.waveColor,
    required this.pulseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final y = size.height * 0.28;

    final paintLine = Paint()
      ..color = waveColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, y);

    // Flat lead-in
    path.lineTo(w * 0.12, y);

    // First slight P-wave bump
    path.quadraticBezierTo(w * 0.16, y - 10, w * 0.20, y);
    path.lineTo(w * 0.25, y);

    // Q dip
    path.lineTo(w * 0.27, y + 8);

    // R spike (tall heartbeat peak)
    path.lineTo(w * 0.31, y - 55);

    // S dip (deep)
    path.lineTo(w * 0.35, y + 25);

    // Return to baseline
    path.lineTo(w * 0.38, y);

    // T wave (moderate rounded peak)
    path.quadraticBezierTo(w * 0.44, y - 18, w * 0.50, y);

    // Small flat baseline
    path.lineTo(w * 0.62, y);

    // Second smaller rhythm
    path.quadraticBezierTo(w * 0.65, y - 8, w * 0.68, y);
    path.lineTo(w * 0.72, y + 6);
    path.lineTo(w * 0.75, y - 40);
    path.lineTo(w * 0.78, y + 18);
    path.lineTo(w * 0.81, y);
    path.quadraticBezierTo(w * 0.86, y - 14, w * 0.91, y);
    path.lineTo(w, y);

    canvas.drawPath(path, paintLine);

    // Second subtle lower wave for depth
    final y2 = size.height * 0.78;
    final path2 = Path();
    path2.moveTo(0, y2);
    path2.lineTo(w * 0.35, y2);
    path2.quadraticBezierTo(w * 0.39, y2 - 7, w * 0.42, y2);
    path2.lineTo(w * 0.45, y2 + 5);
    path2.lineTo(w * 0.48, y2 - 35);
    path2.lineTo(w * 0.51, y2 + 15);
    path2.lineTo(w * 0.54, y2);
    path2.quadraticBezierTo(w * 0.58, y2 - 12, w * 0.62, y2);
    path2.lineTo(w, y2);

    final paintLine2 = Paint()
      ..color = pulseColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path2, paintLine2);
  }

  @override
  bool shouldRepaint(covariant _EkgHeartbeatPainter oldDelegate) =>
      oldDelegate.waveColor != waveColor || oldDelegate.pulseColor != pulseColor;
}

/// Animated Heartbeat / Pulse Badge
class HeartPulseBadge extends StatefulWidget {
  final Widget? child;
  final double size;
  final IconData icon;
  final Color? glowColor;

  const HeartPulseBadge({
    super.key,
    this.child,
    this.size = 72,
    this.icon = Icons.favorite_rounded,
    this.glowColor,
  });

  @override
  State<HeartPulseBadge> createState() => _HeartPulseBadgeState();
}

class _HeartPulseBadgeState extends State<HeartPulseBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.06).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGlow = widget.glowColor ?? const Color(0xFF0284C7);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  effectiveGlow,
                  effectiveGlow.withValues(alpha: 0.85),
                  const Color(0xFFE11D48),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: effectiveGlow.withValues(alpha: 0.35),
                  blurRadius: 18 * _scaleAnimation.value,
                  spreadRadius: 2 * (_scaleAnimation.value - 0.96) * 10,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: const Color(0xFFE11D48).withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: widget.child ??
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: widget.size * 0.48,
                  ),
            ),
          ),
        );
      },
    );
  }
}

/// Elevated Card Container with fine border and smooth shadow
class HeartCareCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  const HeartCareCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF131D36).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? const Color(0xFF1E293B)
              : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0284C7))
                .withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFFE11D48).withValues(alpha: isDark ? 0.08 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Modern HeartCare Input Field with leading icon in soft tinted box
class HeartCareTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  const HeartCareTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Label
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Text Field Box
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            enabled: enabled,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF0F172A).withValues(alpha: 0.7)
                  : const Color(0xFFF8FAFC),
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 13.5,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 10),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    prefixIcon,
                    size: 20,
                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 54,
                minHeight: 38,
              ),
              suffixIcon: suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF0284C7),
                  width: 1.8,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Gradient CTA Button with glow shadow and loading state
class HeartCareGradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final List<Color>? gradientColors;

  const HeartCareGradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.height = 54,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        const [
          Color(0xFF0284C7),
          Color(0xFF0369A1),
        ];

    final isDisabled = onPressed == null || isLoading;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDisabled
              ? [
                  colors.first.withValues(alpha: 0.5),
                  colors.last.withValues(alpha: 0.5),
                ]
              : colors,
        ),
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.38),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isDisabled ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          icon,
                          color: Colors.white,
                          size: 19,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Back button with modern circular glassmorphic design
class HeartCareBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const HeartCareBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 17,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
        onPressed: onPressed ?? () => Navigator.pop(context),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

/// Security / trust badge shown at bottom of medical auth pages
class HeartCareTrustBadge extends StatelessWidget {
  final String text;

  const HeartCareTrustBadge({
    super.key,
    this.text = 'Data rekam medis jantung Anda terenkripsi aman',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 14,
              color: Color(0xFF0284C7),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
