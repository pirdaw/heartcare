import 'package:flutter/material.dart';
import '../widgets/heartcare_auth_widgets.dart';
import 'login_page.dart';
import 'signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return HeartCareAuthBackground(
      showEkg: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // ==========================================
                      // 1. TOP BRANDING PILL
                      // ==========================================
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                              : Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF1E3A5F)
                                : const Color(0xFFBAE6FD),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.10),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF0284C7),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF38BDF8),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'HEARTCARE • PEDULI JANTUNG SEHAT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: isDark
                                    ? const Color(0xFF38BDF8)
                                    : const Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 1),

                      // ==========================================
                      // 2. HERO LOGO CARD WITH GLOW & HEARTBEAT
                      // ==========================================
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ambient glow ring
                          Container(
                            width: 190,
                            height: 190,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFF0284C7).withValues(alpha: isDark ? 0.25 : 0.18),
                                  const Color(0xFF38BDF8).withValues(alpha: isDark ? 0.12 : 0.08),
                                  Colors.transparent,
                                ],
                                stops: const [0.3, 0.7, 1.0],
                              ),
                            ),
                          ),

                          // Card container for HeartCare Logo
                          Container(
                            width: 150,
                            height: 150,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF131D36)
                                  : Colors.white,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF1E3A5F)
                                    : const Color(0xFFBAE6FD),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.16),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/heartcare_logo.png',
                                width: 110,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          // Floating animated heart pulse badge
                          Positioned(
                            bottom: 4,
                            right: size.width * 0.16,
                            child: const HeartPulseBadge(
                              size: 38,
                              icon: Icons.monitor_heart_rounded,
                              glowColor: Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ==========================================
                      // 3. MAIN TITLE
                      // ==========================================
                      Text(
                        'Jaga Detak Sehat\nJantung Anda',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          letterSpacing: -0.4,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==========================================
                      // 4. VALUE PROPOSITION FEATURE CARDS (HOME PALETTE)
                      // ==========================================
                      Row(
                        children: [
                          _buildFeaturePill(
                            isDark: isDark,
                            icon: Icons.health_and_safety_rounded,
                            title: 'Skrining Dini',
                            subtitle: 'Analisis Cerdas',
                          ),
                          const SizedBox(width: 10),
                          _buildFeaturePill(
                            isDark: isDark,
                            icon: Icons.medical_services_rounded,
                            title: 'Kardiolog',
                            subtitle: 'Dokter Siaga',
                          ),
                          const SizedBox(width: 10),
                          _buildFeaturePill(
                            isDark: isDark,
                            icon: Icons.alarm_rounded,
                            title: 'Pengingat',
                            subtitle: 'Jadwal Obat',
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      // ==========================================
                      // 5. ACTION BUTTONS (Shifted upwards to fill space)
                      // ==========================================
                      HeartCareGradientButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        text: 'Mulai Sekarang',
                        icon: Icons.arrow_forward_rounded,
                        gradientColors: const [
                          Color(0xFF0EA5E9),
                          Color(0xFF0284C7),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Shortcut Daftar Akun Baru Langsung
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF1E3A5F)
                                : const Color(0xFFBAE6FD),
                            width: 1.4,
                          ),
                          backgroundColor: isDark
                              ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.85),
                          elevation: 0,
                        ),
                        child: Text(
                          'Daftar Akun Baru',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                          ),
                        ),
                      ),

                      // Balanced spacer below buttons
                      const Spacer(flex: 1),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturePill({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final borderColor = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFBAE6FD);
    final cardGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E293B),
              Color(0xFF0E2536),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEBF6FE),
              Color(0xFFD4ECFC),
            ],
          );

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                  .withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}