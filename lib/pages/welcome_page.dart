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
                      const SizedBox(height: 12),

                      // ==========================================
                      // 1. TOP BRANDING PILL
                      // ==========================================
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                              : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.3),
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
                                color: Color(0xFFE11D48),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFE11D48),
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

                      const Spacer(),

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
                                  const Color(0xFF0284C7).withValues(alpha: isDark ? 0.25 : 0.20),
                                  const Color(0xFFE11D48).withValues(alpha: isDark ? 0.12 : 0.08),
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
                                color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.18),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: const Color(0xFFE11D48).withValues(alpha: 0.12),
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
                              glowColor: Color(0xFFE11D48),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ==========================================
                      // 3. MAIN TITLE & SUBTITLE
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

                      const SizedBox(height: 12),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Skrining risiko penyakit jantung, konsultasi kardiolog tepercaya, dan pantau ritme kardiovaskular harian Anda secara mudah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.5,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==========================================
                      // 4. VALUE PROPOSITION FEATURE CARDS (NOT EMPTY!)
                      // ==========================================
                      Row(
                        children: [
                          _buildFeaturePill(
                            isDark: isDark,
                            icon: Icons.health_and_safety_rounded,
                            iconColor: const Color(0xFF0284C7),
                            bgColor: const Color(0xFFE0F2FE),
                            title: 'Skrining Dini',
                            subtitle: 'Analisis Cerdas',
                          ),
                          const SizedBox(width: 10),
                          _buildFeaturePill(
                            isDark: isDark,
                            icon: Icons.medical_services_rounded,
                            iconColor: const Color(0xFFE11D48),
                            bgColor: const Color(0xFFFFE4E6),
                            title: 'Kardiolog',
                            subtitle: 'Dokter Siaga',
                          ),
                          const SizedBox(width: 10),
                          _buildFeaturePill(
                            isDark: isDark,
                            icon: Icons.alarm_rounded,
                            iconColor: const Color(0xFF0D9488),
                            bgColor: const Color(0xFFCCFBF1),
                            title: 'Pengingat',
                            subtitle: 'Jadwal Obat',
                          ),
                        ],
                      ),

                      const Spacer(),
                      const SizedBox(height: 24),

                      // ==========================================
                      // 5. ACTION BUTTONS
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
                      ),

                      const SizedBox(height: 14),

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
                                ? const Color(0xFF334155)
                                : const Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                          backgroundColor: isDark
                              ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.7),
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

                      const SizedBox(height: 18),

                      // ==========================================
                      // 6. MEDICAL PRIVACY BADGE
                      // ==========================================
                      const HeartCareTrustBadge(
                        text: 'Platform Pendamping Kesehatan Jantung Terpercaya',
                      ),

                      const SizedBox(height: 10),
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
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF131D36).withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : const Color(0xFF0284C7))
                  .withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark ? iconColor.withValues(alpha: 0.18) : bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}