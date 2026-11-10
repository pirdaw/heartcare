import 'package:flutter/material.dart';
import 'screening_intro_page.dart';
import 'dokter_page.dart';
import 'emergency_page.dart';
import 'education_page.dart';
import 'artikel_kesehatan_page.dart';
import 'article_detail_page.dart';
import 'pengingat_kesehatan_page.dart';
import 'riwayat_page.dart';
import 'profil_page.dart';
import '../services/profile_service.dart';
import '../services/theme_service.dart';
import '../services/user_profile_service.dart';
import '../services/language_service.dart';
import '../services/chat_notification_service.dart';
import '../widgets/chat_notification_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color brandPrimary = Color(0xFF0284C7);
  int _selectedIndex = 0;
  final HealthReminderController _reminderController =
      HealthReminderController();

  @override
  void initState() {
    super.initState();
    UserProfileService.instance.addListener(_onProfileChanged);
    _reminderController.addListener(_onReminderChanged);
  }

  @override
  void dispose() {
    UserProfileService.instance.removeListener(_onProfileChanged);
    _reminderController.removeListener(_onReminderChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  void _onReminderChanged() {
    if (mounted) setState(() {});
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return;
    }

    if (index == 1) {
      setState(() {
        _selectedIndex = 1;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreeningIntroPage(),
        ),
      );
      return;
    }

    if (index == 2) {
      setState(() {
        _selectedIndex = 2;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PilihDokterPage(),
        ),
      );
      return;
    }

    if (index == 3) {
      setState(() {
        _selectedIndex = 3;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RiwayatPage(),
        ),
      );
      return;
    }

    if (index == 4) {
      setState(() {
        _selectedIndex = 4;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilPage(),
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.languageNotifier,
      builder: (context, _, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.themeModeNotifier,
          builder: (context, themeMode, _) {
            final isDark = themeMode == ThemeMode.dark;

            return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.28, 0.65, 1.0],
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
            child: SafeArea(
              child: Stack(
                children: [
                  // Ornamen ambient glow lembut agar layar tidak monoton putih
                  Positioned(
                    top: -40,
                    right: -30,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF38BDF8)
                            .withValues(alpha: isDark ? 0.04 : 0.16),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 280,
                    left: -60,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0EA5E9)
                            .withValues(alpha: isDark ? 0.03 : 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 140,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0284C7)
                            .withValues(alpha: isDark ? 0.03 : 0.06),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                        // 1. HEADER (PROFIL & EMERGENCY SOS)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfilPage(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFD8F1F8),
                                  border: Border.all(
                                    color: (isDark
                                            ? const Color(0xFF38BDF8)
                                            : const Color(0xFF079BC1))
                                        .withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: ValueListenableBuilder<String?>(
                                    valueListenable:
                                        ProfileService.profileImageNotifier,
                                    builder: (context, imagePath, _) {
                                      final provider =
                                          ProfileService.getImageProvider(imagePath);
                                      if (provider != null) {
                                        return Image(
                                          image: provider,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/images/profile_woman.png',
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        );
                                      }
                                      return Image.asset(
                                        'assets/images/profile_woman.png',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.person,
                                            size: 34,
                                            color: isDark
                                                ? const Color(0xFF38BDF8)
                                                : const Color(0xFF079BC1),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ProfilPage(),
                                    ),
                                  );
                                },
                                child: Builder(
                                  builder: (context) {
                                    final profile = UserProfileService.instance.currentProfile;
                                    final firstName = profile.nama.trim().isNotEmpty
                                        ? profile.nama.trim().split(' ').first
                                        : tr('Pengguna', 'User');
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                tr('Hallo, $firstName...', 'Hello, $firstName...'),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(0xFF0F172A),
                                                ),
                                              ),
                                            ),
                                            if (!profile.isProfileFullyComplete) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2.5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? const Color(0xFF7C2D12).withValues(alpha: 0.3)
                                                      : const Color(0xFFFFF7ED),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: const Color(0xFFFDBA74),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.edit_note_rounded,
                                                      size: 13,
                                                      color: Color(0xFFEA580C),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      tr('Lengkapi data', 'Complete profile'),
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFFEA580C),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          tr('Yuk cek kesehatan jantungmu!', "Let's check your heart health!"),
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            // TOMBOL PUSAT NOTIFIKASI CHAT DOKTER
                            AnimatedBuilder(
                              animation: ChatNotificationService.instance,
                              builder: (context, _) {
                                final unreadCount = ChatNotificationService
                                    .instance.totalUnreadNotificationCount;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        ChatNotificationSheet.show(context);
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF1E293B)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: isDark
                                                    ? const Color(0xFF334155)
                                                    : const Color(0xFFE2E8F0),
                                                width: 1.2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(
                                                      alpha: isDark ? 0.2 : 0.04),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.notifications_active_outlined,
                                              size: 20,
                                              color: isDark
                                                  ? const Color(0xFF38BDF8)
                                                  : const Color(0xFF0284C7),
                                            ),
                                          ),
                                          if (unreadCount > 0)
                                            Positioned(
                                              top: -3,
                                              right: -3,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                  vertical: 1.5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFEF4444),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: isDark
                                                        ? const Color(0xFF0F172A)
                                                        : Colors.white,
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(0xFFEF4444)
                                                          .withValues(alpha: 0.4),
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                                constraints: const BoxConstraints(
                                                  minWidth: 18,
                                                  minHeight: 18,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    unreadCount > 99
                                                        ? '99+'
                                                        : '$unreadCount',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9.5,
                                                      fontWeight: FontWeight.bold,
                                                      height: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // TOMBOL PANGGILAN DARURAT (TELEPON SOS)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const EmergencyPage(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isDark
                                          ? const [
                                              Color(0xFF3B1219),
                                              Color(0xFF501320),
                                            ]
                                          : const [
                                              Color(0xFFFFF1F2),
                                              Color(0xFFFFE4E6),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF881337)
                                          : const Color(0xFFFECDD3),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE11D48)
                                            .withValues(alpha: isDark ? 0.25 : 0.12),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.phone_in_talk_rounded,
                                        color: isDark
                                            ? const Color(0xFFFB7185)
                                            : const Color(0xFFE11D48),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2.5,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFF43F5E),
                                              Color(0xFFE11D48),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(6),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFE11D48)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Text(
                                          'SOS',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 3. HERO BANNER: SKRINING RISIKO JANTUNG
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF38BDF8),
                                Color(0xFF0EA5E9),
                                Color(0xFF0284C7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0EA5E9).withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Background decorative circles
                              Positioned(
                                right: -25,
                                top: -25,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.10),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 35,
                                bottom: -35,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                              ),
                              // Soft glow circle behind heart asset
                              Positioned(
                                right: 10,
                                bottom: 10,
                                child: Container(
                                  width: 92,
                                  height: 92,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.22),
                                        blurRadius: 18,
                                        spreadRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(18, 18, 102, 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.22),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.45),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.auto_awesome,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'AI Screening Assessment',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      tr('Skrining Risiko Jantung', 'Heart Risk Screening'),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      tr('Kenali faktor risiko jantung Anda melalui skrining kesehatan sederhana menggunakan aplikasi.', 'Identify your heart risk factors through a simple health screening in the app.'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.38,
                                        color: Colors.white.withValues(alpha: 0.92),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      height: 38,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ScreeningIntroPage(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: const Color(0xFF0284C7),
                                          elevation: 2,
                                          shadowColor: Colors.black.withValues(alpha: 0.15),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              tr('Mulai Skrining', 'Start Screening'),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 8,
                                bottom: 10,
                                child: SizedBox(
                                  width: 96,
                                  height: 104,
                                  child: Image.asset(
                                    'assets/images/screening_jantung.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 64,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 4. LAYANAN KESEHATAN (4 MENU PENUNJANG DENGAN LOGO KONSISTEN)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tr('Layanan Kesehatan', 'Health Services'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              tr('Fitur Utama', 'Main Features'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // BARIS 1 LAYANAN
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _serviceCard(
                                icon: Icons.alarm_rounded,
                                title: tr('Pengingat Obat', 'Medication Reminder'),
                                description: tr(
                                  'Atur alarm dan jadwal minum obat tepat waktu.',
                                  'Set alarms and schedules to take meds on time.',
                                ),
                                isDark: isDark,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PengingatKesehatanPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _serviceCard(
                                icon: Icons.medical_services_rounded,
                                title: tr('Konsultasi Dokter', 'Doctor Consultation'),
                                description: tr(
                                  'Konsultasikan kondisi kesehatan Anda dengan dokter.',
                                  'Consult your health conditions with doctors.',
                                ),
                                isDark: isDark,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PilihDokterPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // BARIS 2 LAYANAN: SATU CARD EDUKASI KESEHATAN
                        _horizontalServiceCard(
                          icon: Icons.menu_book_rounded,
                          title: tr('Edukasi Kesehatan', 'Health Education'),
                          description: tr(
                            'Dapatkan informasi dan tips menjaga kesehatan Anda.',
                            'Get information and tips to stay healthy.',
                          ),
                          isDark: isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EducationPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 22),

                        // 6. JADWAL & PENGINGAT TERDEKAT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tr('Pengingat Jadwal Terdekat', 'Upcoming Reminders'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PengingatKesehatanPage(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                tr('Lihat Semua', 'View All'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                    Builder(
                      builder: (context) {
                        final nextAlarm = _reminderController.nextAlarmItem;
                        final hasReminder = nextAlarm != null;
                        final nextMed = nextAlarm?.medicine;
                        final timeRaw = nextAlarm?.time ?? '';
                        final timeFormatted = timeRaw.isNotEmpty
                            ? (timeRaw.contains('WIB')
                                ? timeRaw
                                : '$timeRaw WIB')
                            : '';

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? const [
                                      Color(0xFF1E293B),
                                      Color(0xFF0E2536),
                                    ]
                                  : const [
                                      Color(0xFFEBF6FE),
                                      Color(0xFFD4ECFC),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF1E3A5F)
                                  : const Color(0xFFBAE6FD),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF0284C7))
                                    .withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: hasReminder && nextMed != null
                              ? Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF38BDF8),
                                            Color(0xFF0284C7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0284C7)
                                                .withValues(alpha: 0.28),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.medication_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  nextMed.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF0F172A),
                                                  ),
                                                ),
                                              ),
                                              if (timeFormatted
                                                  .isNotEmpty) ...[
                                                const SizedBox(width: 6),
                                                Text(
                                                  '• $timeFormatted',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF38BDF8)
                                                        : const Color(
                                                            0xFF0284C7),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            nextMed.schedule.isNotEmpty
                                                ? '${nextMed.amount} ${nextMed.unit} ${nextMed.schedule}'
                                                : (nextMed.note.isNotEmpty
                                                    ? nextMed.note
                                                    : '${nextMed.amount} ${nextMed.unit}'),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF475569),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF0EA5E9),
                                            Color(0xFF0284C7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0284C7)
                                                .withValues(alpha: 0.25),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const PengingatKesehatanPage(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize
                                              .shrinkWrap,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          tr('Jadwal', 'Schedule'),
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFF0284C7)
                                                .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(11),
                                      ),
                                      child: Icon(
                                        Icons.alarm_off_rounded,
                                        color: isDark
                                            ? const Color(0xFF38BDF8)
                                            : const Color(0xFF0284C7),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tr('Belum ada jadwal obat', 'No medication schedule yet'),
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1E293B),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            tr('Atur pengingat agar minum obat tepat waktu', 'Set reminders to take medicines on time'),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF0EA5E9),
                                            Color(0xFF0284C7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0284C7)
                                                .withValues(alpha: 0.25),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const PengingatKesehatanPage(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize
                                              .shrinkWrap,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          tr('Atur', 'Set Up'),
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    // 8. EDUKASI & ARTIKEL KESEHATAN JANTUNG
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tr('Artikel Edukasi Populer', 'Popular Articles'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ArtikelKesehatanPage(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                tr('Lihat Semua', 'View All'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        _featuredArticleItem(
                          context,
imageUrl: 'assets/images/jantung_koroner_edukasi.jpg',
                          category: tr('Penyakit Jantung', 'Heart Disease'),
                          title: tr(
                              'Mengenal Penyakit Jantung Koroner: Gejala & Pencegahan Dini',
                              'Understanding Coronary Heart Disease: Symptoms & Early Prevention'),
                          duration: tr('6 menit baca', '6 min read'),
                          content:
                              'Penyakit jantung koroner (PJK) terjadi akibat penyempitan arteri koroner oleh penumpukan plak ateroma kolesterol (aterosklerosis). Pelajari tanda khas angina pectoris, 7 faktor risiko utama menurut kajian jurnal medis, serta protokol pencegahan dini untuk melindungi fungsi jantung Anda.',
                          isDark: isDark,
                        ),

                        const SizedBox(height: 10),

                        _featuredArticleItem(
                          context,
                          imageUrl:
                              'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=500',
                          category: tr('Pola Hidup', 'Lifestyle'),
                          title: tr(
                              '5 Pilihan Makanan Sehat Terbaik untuk Kekuatan Jantung Anda',
                          '5 Best Healthy Food Choices for Heart Strength',
                          ),
                          duration: tr('5 menit baca', '5 min read'),
                          description:
                              'Kajian ilmiah berbasis riset mengenai 5 bahan pangan fungsional kaya kalium, kalsium, zinc, dan antioksidan untuk mendukung kekuatan otot jantung serta kelenturan pembuluh darah.',
                          content:
                              'Penyakit jantung dan hipertensi (tekanan darah tinggi, sistolik ≥140 mmHg dan diastolik ≥90 mmHg) merupakan salah satu masalah kesehatan global terbesar yang dijuluki sebagai "silent killer" karena kerap berkembang tanpa gejala khusus (WHO, 2023; Pebrisiana et al., 2022). Peningkatan tekanan darah secara terus-menerus memberikan beban kerja berlebih pada pompa jantung dan dapat merusak dinding arteri, memicu disfungsi endotel vaskular, aterosklerosis, gagal jantung, hingga penyakit jantung koroner (Suciana et al., 2024; Lioncu & Mamlukah, 2023; Kifle et al., 2022).\n\n'
                              'Pencegahan hipertensi dan perlindungan kekuatan jantung membutuhkan pendekatan komprehensif non-farmakologis melalui penerapan gaya hidup sehat serta modifikasi pola makan bergizi seimbang (Verma et al., 2021). Konsumsi bahan pangan alami fungsional yang kaya akan zat gizi mikro esensial—terutama kalium, kalsium, zinc, dan vitamin A (beta-karoten)—serta senyawa antioksidan bioaktif terbukti berperan signifikan dalam mendukung kesehatan pembuluh darah dan fungsi pemompaan jantung.\n\n'
                              'CATATAN EDUKASI & MEDIS PENTING:\n'
                              'Bahan makanan sehat dan pangan fungsional berfungsi sebagai faktor nutrisi pendukung dalam upaya pencegahan (preventif) dan pemeliharaan kesehatan pembuluh darah serta kekuatan fungsi jantung. Makanan sehat BUKAN merupakan obat medis dan TIDAK dimaksudkan untuk menyembuhkan atau mengobati penyakit jantung maupun hipertensi. Pengelolaan medis, pemeriksaan tekanan darah secara berkala, dan kepatuhan terhadap anjuran tenaga medis/dokter tetap menjadi pilar utama yang tidak dapat digantikan.\n\n'
                              'Berikut adalah 5 pilihan makanan sehat terbaik berbasis riset ilmiah beserta bukti kandungan gizi akurat dan mekanisme fisiologisnya bagi kesehatan kardiovaskular:\n\n'
                              '1. Labu Kuning (Cucurbita moschata Durch)\n'
                              'Labu kuning merupakan bahan pangan lokal fungsional bernilai gizi tinggi dengan potensi besar dalam mendukung regulasi tekanan darah dan kesehatan vaskular (Inosenshia et al., 2024; Maryanto & Wening, 2023).\n'
                              '• Kandungan Zat Gizi (per 100 gram daging buah segar, Tabel Komposisi Pangan Indonesia / Kemenkes RI, 2020):\n'
                              '  - Kalium: 220 mg\n'
                              '  - Kalsium: 40 mg\n'
                              '  - Zinc: 1,5 mg\n'
                              '  - Beta-Karoten: 1.569 mcg\n'
                              '  - Serat Pangan: 2,7 gram\n'
                              '  - Energi: 51 kkal; Protein: 1,7 gram; Lemak: 0,5 gram\n'
                              '• Mekanisme Biologis & Manfaat Kesehatan:\n'
                              '  Ekstrak daging labu kuning mengandung flavonoid total sebesar 8,8 mg/g Quercetin Equivalent (QE) (Erwiyani et al., 2022). Flavonoid membantu merangsang sintesis dan pelepasan molekul Nitric Oxide (NO) yang memicu relaksasi otot dinding arteri (vasodilatasi) serta menghambat aktivitas Angiotensin-Converting Enzyme (ACE) guna mengontrol resistensi vaskular (Fajrani et al., 2023; Grande et al., 2016 dalam Afrianti et al., 2020). Selain itu, kandungan beta-karoten yang tinggi berfungsi sebagai provitamin A dan antioksidan poten yang melindungi membran sel pembuluh darah dari stres oksidatif serta mengaktifkan enzim glutation S-transferase (Amalia & Triyono, 2018; Lismawati et al., 2021).\n'
                              '• Bukti Riset Ilmiah:\n'
                              '  Penelitian kuasi-eksperimental oleh Yohandrey et al. (2023) menunjukkan bahwa pemberian olahan puding labu kuning pada kelompok hipertensi terbukti menurunkan rata-rata tekanan darah sistolik/diastolik sebesar 20,35 / 8,05 mmHg secara signifikan (p < 0,05). Serat alami labu kuning juga mendukung penyerapan lipid di saluran cerna guna mengurangi risiko aterosklerosis.\n\n'
                              '2. Oatmeal (Avena sativa)\n'
                              'Oatmeal merupakan serealia gandum utuh yang kaya serat larut air dan mikronutrien esensial pelindung fungsi kardiovaskular (Kaya et al., 2022; Bouchard et al., 2022).\n'
                              '• Kandungan Zat Gizi (per 100 gram rolled oat, USDA FoodData Central, 2022):\n'
                              '  - Kalium: 350 mg\n'
                              '  - Kalsium: 46 mg\n'
                              '  - Zinc: 2,74 mg\n'
                              '  - Serat Pangan: 9,7 gram\n'
                              '  - Protein: 13,5 gram; Karbohidrat: 68,7 gram; Lemak: 5,89 gram\n'
                              '  - Energi: 382 kkal; Natrium: hanya 1 mg\n'
                              '• Mekanisme Biologis & Manfaat Kesehatan:\n'
                              '  Oatmeal kaya akan serat larut beta-glukan (β-glukan) yang mengalami fermentasi oleh mikrobiota usus besar menghasilkan asam lemak rantai pendek (SCFA). Proses ini terbukti menurunkan kadar kolesterol jahat (LDL-C) dan menstabilkan gula darah tanpa menurunkan kolesterol baik (HDL-C) (Sava, 2023; Wiryani & Yustiantara, 2023).\n'
                              '• Bukti Riset Ilmiah:\n'
                              '  Penelitian oleh Raj et al. (2024) membuktikan bahwa diet berbasis protein oat secara signifikan menurunkan tekanan darah, mencegah remodeling patologis dan disfungsi ventrikel jantung, meningkatkan ketersediaan Nitric Oxide (NO), serta menurunkan sitokin peradangan TNF-α dan stres oksidatif vaskular.\n\n'
                              '3. Biji Labu Kuning (Pumpkin Seeds)\n'
                              'Biji labu kuning merupakan bagian pangan padat energi dan zat gizi mikro yang kaya akan mineral penting serta antioksidan kardioprotektif (Manshi & Chaturvedi, 2023; Wildan et al., 2024).\n'
                              '• Kandungan Zat Gizi (per 100 gram biji panggang tanpa garam, USDA FoodData Central, 2022):\n'
                              '  - Kalium: 788 mg\n'
                              '  - Zinc: 7,64 mg\n'
                              '  - Kalsium: 52 mg\n'
                              '  - Zat Besi: 8,07 mg\n'
                              '  - Serat Pangan: 6,5 gram\n'
                              '  - Protein: 29,84 gram; Lemak Nabati Sehat: 49,05 gram\n'
                              '  - Energi: 574 kkal; Natrium: 18 mg\n'
                              '• Mekanisme Biologis & Manfaat Kesehatan:\n'
                              '  Flavonoid antosianin dan tingginya rasio kalium terhadap natrium pada biji labu bertindak sebagai diuretik alami, memfasilitasi pengeluaran kelebihan natrium urine, menghambat sekresi renin oleh ginjal, serta meningkatkan bioavailabilitas Nitric Oxide (NO) untuk menjaga elastisitas dinding pembuluh darah (Fajrani et al., 2023).\n'
                              '• Bukti Riset Ilmiah:\n'
                              '  Studi eksperimental oleh Fajrani et al. (2023) menunjukkan bahwa pemberian tepung biji labu kuning (dosis 4,5 mg dan 5,4 mg) secara signifikan menurunkan tekanan darah pada model hewan hipertensi (p < 0,05) berkat perbaikan fungsi endotel dan reduksi stres oksidatif.\n\n'
                              '4. Kacang Almond (Prunus dulcis)\n'
                              'Almond merupakan kacang pohon bernutrisi tinggi dengan profil lemak nabati yang sangat ramah terhadap kesehatan pembuluh darah dan otot jantung (Hasanah et al., 2020; Pamela et al., 2023).\n'
                              '• Kandungan Zat Gizi (per 100 gram almond panggang tanpa garam, USDA FoodData Central, 2022):\n'
                              '  - Lemak Nabati: 52,54 gram (67% berupa asam lemak tak jenuh tunggal / MUFA)\n'
                              '  - Kalium: 713 mg\n'
                              '  - Kalsium: 268 mg\n'
                              '  - Zinc: 3,31 mg\n'
                              '  - Serat Pangan: 10,9 gram; Protein: 20,96 gram\n'
                              '  - Energi: 598 kkal; Natrium: hanya 3 mg\n'
                              '• Mekanisme Biologis & Manfaat Kesehatan:\n'
                              '  Kombinasi asam lemak tak jenuh tunggal (MUFA), vitamin E (alpha-tocopherol), dan polifenol flavonoid almond melindungi membran sel endotel dari kerusakan oksidatif lipid, mengurangi pembentukan plak aterosklerosis koroner, dan memelihara kelenturan arteri (Hasanah et al., 2020; Pamela et al., 2023).\n'
                              '• Bukti Riset Ilmiah:\n'
                              '  Analisis berbasis populasi oleh Wang et al. (2020) mengonfirmasi bahwa konsumsi rutin 42,5 gram almond per hari secara konsisten menurunkan kadar low-density lipoprotein cholesterol (LDL-C) dan memberikan efektivitas biaya tinggi dalam pencegahan primer penyakit kardiovaskular. Penelitian Susyani et al. (2024) juga membuktikan sereal berbahan dasar almond, pisang, dan sorgum efektif menurunkan tekanan darah sistolik (rata-rata 16,87 mmHg) dan diastolik (12,27 mmHg, p = 0,000).\n\n'
                              '5. Kismis (Dried Grapes / Vitis vinifera)\n'
                              'Kismis adalah buah anggur kering alami tanpa tambahan gula atau lemak jenuh yang menyumbang kalium dan antioksidan polifenol tinggi (Dewi et al., 2023).\n'
                              '• Kandungan Zat Gizi (per 100 gram, USDA FoodData Central, 2022 & TKPI, 2020):\n'
                              '  - Kalium: 749 mg\n'
                              '  - Kalsium: 50 mg\n'
                              '  - Zat Besi: 1,88 mg\n'
                              '  - Zinc: 0,22 mg\n'
                              '  - Serat Pangan: 3,7 gram; Karbohidrat: 79,18 gram\n'
                              '  - Energi: 299 kkal; Bebas lemak jenuh dan kolesterol (0 mg)\n'
                              '• Mekanisme Biologis & Manfaat Kesehatan:\n'
                              '  Kismis kaya akan senyawa polifenol bioaktif seperti resveratrol, quercetin, katekin, dan asam fenolat yang memiliki sifat anti-inflamasi serta antioksidan kuat. Asupan kalium yang tinggi membantu menyeimbangkan kadar natrium tubuh, mengurangi kekakuan vaskular, dan menjaga kelenturan dinding pembuluh darah (Dewi et al., 2023).\n'
                              '• Bukti Riset Ilmiah:\n'
                              '  Tinjauan sistematis dan meta-analisis dari 8 uji klinis acak (RCT) yang melibatkan 352 partisipan oleh Aali et al. (2024) membuktikan bahwa konsumsi kismis teratur menurunkan tekanan darah sistolik secara signifikan sebesar -3,45 mmHg (p = 0,01) tanpa efek samping metabolik negatif.\n\n'
                              'PERAN SENTRAL ZAT GIZI MIKRO BAGI KEKUATAN JANTUNG:\n'
                              '• Kalium: Menjaga keseimbangan elektrolit cairan, meningkatkan ekskresi natrium lewat ginjal, dan menstimulasi vasodilatasi dinding arteri (Rohmatin et al., 2024; Sangadah, 2022).\n'
                              '• Kalsium: Mengatur kontraksi otot polos dinding arteri serta merangsang sintesis substansi vasoaktif prostasiklin dan Nitric Oxide (Zurli et al., 2023; Meldawati, 2020).\n'
                              '• Zinc: Bertindak sebagai kofaktor enzim antioksidan Superoksida Dismutase (SOD) untuk menetralkan radikal bebas ROS, menghambat sitokin pro-inflamasi, dan mencegah kerusakan sel endotel pembuluh darah (Rahman et al., 2021; Jelmila et al., 2023; Mousavi et al., 2020).\n'
                              '• Vitamin A & Karotenoid: Senyawa antioksidan lipofilik penangkal stres oksidatif yang merangsang pelepasan molekul Nitric Oxide guna menjaga elastisitas vaskular (Zhang et al., 2021; Li et al., 2019; Abbasian et al., 2023).\n\n'
                              'PANDUAN KONSUMSI PRAKTIS:\n'
                              'Pemanfaatan kelima bahan pangan di atas dapat diwujudkan dalam bentuk camilan praktis bernutrisi, seperti formulasi snack bar sehat berbahan dasar labu kuning, oatmeal, biji labu, almond, dan kismis (Majid & Farida, 2024; Millati et al., 2020). Dengan porsi saji standar sekitar 35 gram sesuai panduan BPOM RI (2019) dan Kementerian Pertanian (2018), camilan bernutrisi ini dapat menyumbang 10–15% kebutuhan energi dan zat gizi mikro harian (Zahra et al., 2022), memberikan rasa kenyang lebih lama, serta mendukung stabilitas tekanan darah dan kekuatan pemompaan jantung secara optimal.\n\n'
                              'DAFTAR PUSTAKA JURNAL ILMIAH:\n'
                              '1. Aali, Y., Mirzababaei, A., Clark, C. C. T., & Mirzaei, K. (2024). The Effect of Raisin (Currant) Intake on Anthropometric Indices and Blood Pressure: Systematic Review and Meta-analysis of Randomised Controlled Trials. Herbal Medicine, 100830. https://doi.org/10.1016/j.hermed.2023.100830\n'
                              '2. Abbasian, F., Alavi, M. S., & Roohbakhsh, A. (2023). Dietary Carotenoids to Improve Hypertension. Heliyon, 9(10), e19399. https://doi.org/10.1016/j.heliyon.2023.e19399\n'
                              '3. Amalia, R., & Triyono, B. (2018). Peran Antioksidan Beta-Karoten Terhadap Perbaikan Fungsi Vaskular. Jurnal Ilmiah Kedokteran, 7(2), 45-52.\n'
                              '4. Bouchard, J., Raj, P., & Achouri, A. (2022). Cardiovascular Benefits of Oat Protein and Bioactive Compounds. Journal of Functional Foods, 89, 104921.\n'
                              '5. Dewi, R. K., et al. (2023). Kandungan Polifenol Kismis dan Potensinya dalam Manajemen Sindrom Metabolik. Jurnal Nutrisi Pangan, 18(2), 115-124.\n'
                              '6. Erwiyani, A. R., et al. (2022). Uji Aktivitas Flavonoid Ekstrak Buah Labu Kuning (Cucurbita moschata). Indonesian Journal of Pharmacy and Science, 5(1), 12-19.\n'
                              '7. Fajrani, A., Syam, A., Indriasari, R., Hadju, V., Zulkifli, A., & Zainal. (2023). The Effect of Pumpkin Seed Flour (Cucurbita Moschata) on Blood Pressure of Hypertensive Rats (Rattus novergicus L). Biomedical and Pharmacology Journal, 16(4), 2633–2641. https://doi.org/10.13005/bpj/2633\n'
                              '8. Hasanah, U., et al. (2020). Profil Asam Lemak Tak Jenuh Tunggal pada Almond dan Pengaruhnya terhadap Elastisitas Vaskular. Jurnal Gizi Klinik, 14(3), 201-209.\n'
                              '9. Inosenshia, I. C., Syam, A., Salam, A., Jafar, N., & Amir, S. (2024). Analisis Kandungan Vitamin A, Vitamin C, dan Fe Cookies Berbasis Labu Kuning. Jurnal Gizi Masyarakat Indonesia, 13(1), 71–80. https://doi.org/10.30597/jgmi.v13i1.28071\n'
                              '10. Jelmila, R., et al. (2023). Efek Suplementasi Zinc terhadap Penurunan Reactive Oxygen Species (ROS) pada Endotel Vaskular. Jurnal Biomedika Kesehatan, 6(1), 30-38.\n'
                              '11. Kementerian Kesehatan RI. (2020). Tabel Komposisi Pangan Indonesia (TKPI). Direktorat Gizi Masyarakat, Kemenkes RI, Jakarta.\n'
                              '12. Li, Q., et al. (2019). Association Between Dietary Carotenoid Intake and Risk of Hypertension: NHANES 2007–2014. Hypertension Research, 42(10), 1600-1608.\n'
                              '13. Lismawati, L., Tutik, T., & Nofita, N. (2021). Kandungan Beta Karoten dan Aktivitas Antioksidan Terhadap Ekstrak Buah Labu Kuning (Cucurbita moschata). Jurnal Mandala Pharmacon Indonesia, 7(2), 111–120. https://doi.org/10.35311/jmpi.v7i2.111\n'
                              '14. Majid, S. M., & Farida, E. (2024). Formulasi Snack Bar Berbahan Dasar Tepung Kedelai (Glycine max L.) dan Tepung Labu Kuning (Cucurbita moschata Durch) Sebagai Makanan Alternatif Sumber Energi. Indonesian Journal of Public Health and Nutrition, 4(2), 97-113. https://doi.org/10.5294/ijphn.v4i2.9713\n'
                              '15. Meldawati. (2020). Pengaruh Pemberian Kalsium Terhadap Penurunan Tekanan Darah Ibu Hamil Dengan Riwayat Preeklampsi. Dinamika Kesehatan: Jurnal Kebidanan dan Keperawatan, 11(1). https://doi.org/10.33859/dksm.v11i1.581\n'
                              '16. Mousavi, S. M., Mofrad, M. D., do Nascimento, I. J. B., Milajerdi, A., Mokhtari, T., & Esmaillzadeh, A. (2020). The Effect of Zinc Supplementation on Blood Pressure: A Systematic Review and Dose–Response Meta-Analysis of Randomized-Controlled Trials. European Journal of Nutrition, 59, 1815–1827. https://doi.org/10.1007/s00394-020-2204-5\n'
                              '17. Raj, P., Bouchard, J., Martineau-Côté, D., Malunga, L., L\'Hocine, L., Yu, L., Sobhi, B., & Achouri, A. (2024). Oat-Protein-Based Diet Lowers Blood Pressure and Prevents Cardiac Remodeling and Dysfunction in Spontaneously Hypertensive Rats. Nutrients, 16(22), 3870. https://doi.org/10.3390/nu16223870\n'
                              '18. Rohmatin, N., et al. (2024). Peran Asupan Kalium Harian dalam Mencegah Retensi Natrium pada Pembuluh Darah. Jurnal Ilmu Kesehatan dan Gizi, 12(1), 55-64.\n'
                              '19. Sangadah, K. (2022). Hubungan Asupan Zat Gizi Mikro (Natrium, Kalium, Kalsium, Magnesium) dan Aktivitas Fisik dengan Kejadian Hipertensi. Nutrition Research and Development Journal, 2(1). https://journal.unnes.ac.id/sju/index.php/nutrizione/\n'
                              '20. Susyani, S., Pradini, V. A., & Terati, T. (2024). Pemberian Sereal Instan Calissa (Pisang, Sorgum, Kacang Almond) dalam Penurunan Tekanan Darah Penderita Hipertensi di Puskesmas Sukarami Palembang. JGK: Jurnal Gizi dan Kesehatan, 16(1). https://jurnal.poltekkespalembang.ac.id/index.php/jgk/article/view/2171\n'
                              '21. U.S. Department of Agriculture (USDA). (2022). FoodData Central: Nutrient Profiles for Oats, Pumpkin Seeds, Almonds, and Raisins. USDA Agricultural Research Service.\n'
                              '22. Wang, J., Lee Bravatti, M. A., Johnson, E. J., & Raman, G. (2020). Daily Almond Consumption in Cardiovascular Disease Prevention Via LDL-C Change in The U.S. Population: A Cost-Effectiveness Analysis. BMC Public Health, 20, 8642. https://doi.org/10.1186/s12889-020-8642-4\n'
                              '23. World Health Organization (WHO). (2023). Global Report on Hypertension: The Race Against a Silent Killer. WHO Press, Geneva.\n'
                              '24. Yohandrey, F., Kasmiyetti, K., Handayani, M., Dwiyanti, D., & Edmon, E. (2023). Pengaruh Pemberian Puding Labu Kuning Terhadap Penurunan Tekanan Darah Pada Penderita Hipertensi. Journal of Nutrition College, 12(4), 262–270. https://doi.org/10.14710/jnc.v12i4.40494\n'
                              '25. Zhang, Y., Liu, M., Zhou, C., Zhang, Z., He, P., Li, Q., Liu, C., & Qin, X. (2021). Inverse Association Between Dietary Vitamin A Intake and New-onset Hypertension. Clinical Nutrition, 40(6), 3980–3989. https://doi.org/10.1016/j.clnu.2021.04.004',
                          isDark: isDark,
                        ),

                        const SizedBox(height: 10),

                        _featuredArticleItem(
                          context,
                          imageUrl:
                              'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800',
                          category: tr('Pola Hidup', 'Lifestyle'),
                          title: tr(
                            'Olahraga yang Baik untuk Kesehatan Jantung',
                            'Best Exercises for Heart Health',
                          ),
                          duration: tr('7 menit baca', '7 min read'),
                          description:
                              'Kajian ilmiah mengenai kapasitas kerja pompa jantung, takaran latihan terukur (zona denyut 70–85% DJM, durasi 20–45 menit, frekuensi 3–5 kali seminggu), uji jalan 5 menit, dan panduan latihan aerobik berbasis riset Dr. Eddy Purnomo.',
                          content:
                              'Latihan olahraga yang teratur, terarah, dan terprogram merupakan salah satu sarana utama dalam meningkatkan kebugaran jasmani serta menghindarkan diri dari penyakit degeneratif, khususnya penyakit jantung dan pembuluh darah.\n\nDi era modern saat ini, kemajuan teknologi yang serba otomatis kerap mengakibatkan manusia menjadi malas bergerak (gaya hidup sedentari). Menurut data survei kesehatan dan catatan rumah sakit, penyakit jantung menduduki urutan ketiga penyebab kematian di Indonesia dan peringkat pertama untuk usia di atas 45 tahun (Sahabuddin, 1992). Faktor risiko lain meliputi diabetes melitus, hipertensi, obesitas, merokok, stres, dan inaktivitas fisik.\n\nJantung bekerja sebagai pompa darah yang berukuran kira-kira sebesar kepalan tangan. Dalam satu kali pompaan, jantung mengalirkan 70–80 cc darah. Dalam satu menit pada orang dewasa normal, jantung memompa sekitar 5 liter darah, 300 liter per jam, hingga 7.200 liter darah setiap harinya (Puruhito, 1992). Otot jantung merupakan jenis otot polos involunter yang berkontraksi secara refleks tanpa diperintah otak sadar (Hay, 1987).\n\nLatihan olahraga yang teratur merangsang kerja jantung dan paru-paru sehingga meningkatkan volume sekuncup (Stroke Volume). Olahraga yang melibatkan otot-otot besar pada tungkai kaki—seperti jalan cepat, lari/joging, dan bersepeda—sangat dianjurkan karena memerlukan konsumsi oksigen tinggi dan memberikan stimulasi sirkulasi darah yang lebih optimal dibandingkan gerakan lengan.\n\nMenurut dr. Sadoso Sumosardjuno (1993), latihan aerobik berkesinambungan selama 20–30 menit membuat otot jantung lebih padat, kuat, dan efisien. Pada saat istirahat, denyut nadi individu yang terlatih berdetak lebih lambat namun memompakan darah jauh lebih bertenaga.\n\nLatihan olahraga yang benar wajib mematuhi takaran terukur:\n1. Intensitas Latihan: Diukur melalui denyut nadi maksimal (DJM = 220 - Umur). Zona sasaran efektif dan aman adalah 70% sampai 85% dari DJM (idealnya 72%–85%). Sebagai contoh, individu berusia 50 tahun (DJM = 170 bpm) harus berlatih pada zona denyut nadi 119 hingga 144,5 denyut per menit.\n2. Lama Latihan: Mempertahankan denyut di zona sasaran selama 20 hingga 45 menit per sesi.\n3. Frekuensi Latihan: Minimal 3 kali per minggu, optimal 4 hingga 5 kali per minggu karena kebugaran tubuh mulai menurun setelah 48 jam tanpa aktivitas.\n4. Urutan Sesi: Pemanasan (±10 menit), Latihan Inti (20–45 menit), dan Pendinginan (±5 menit).\n\nSebelum memulai program, lakukan uji mandiri jalan cepat 5 menit (dalam kondisi masih dapat berbicara), lalu istirahat 10 menit. Jika denyut nadi setelah 10 menit telah kembali di bawah 100 bpm dan bernapas lancar, kondisi jantung dinyatakan fit dan layak berlatih. Namun jika denyut masih di atas 100 bpm atau terasa sesak napas, periksakan diri ke dokter spesialis sebelum berlatih.\n\nBentuk latihan aerobik terbaik mencakup jalan kaki cepat, lari santai/joging, bersepeda statis, berenang, dan senam aerobik yang disesuaikan dengan kapasitas fisik masing-masing secara teratur dan berkesinambungan.',
                          isDark: isDark,
                        ),

                        const SizedBox(height: 18),

                        // 9. TIPS SEHAT HARIAN
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? const [
                                      Color(0xFF1E293B),
                                      Color(0xFF2D1F0E),
                                    ]
                                  : const [
                                      Color(0xFFFFFDF5),
                                      Color(0xFFFEF3C7),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF78350F).withValues(alpha: 0.5)
                                  : const Color(0xFFFDE68A),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark
                                        ? Colors.black
                                        : const Color(0xFFD97706))
                                    .withValues(alpha: isDark ? 0.2 : 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFBBF24),
                                      Color(0xFFD97706),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD97706).withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.lightbulb_rounded,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tr('Tips Jantung Sehat Hari Ini', "Today's Healthy Heart Tip"),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF92400E),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      tr(
                                        'Batasi konsumsi garam maksimal 1 sendok teh (5 gram) per hari dan rutin jalan santai 30 menit untuk menjaga elastisitas pembuluh darah.',
                                        'Limit salt intake to max 1 teaspoon (5 grams) per day and walk briskly for 30 minutes to maintain blood vessel elasticity.',
                                      ),
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        height: 1.35,
                                        color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF78350F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // BOTTOM NAVIGATION
                Container(
                  height: 62,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _bottomItem(
                        icon: Icons.home,
                        label: tr('Home', 'Home'),
                        index: 0,
                        isDark: isDark,
                      ),
                      _bottomItem(
                        icon: Icons.favorite_border,
                        label: tr('Skrining', 'Screening'),
                        index: 1,
                        isDark: isDark,
                      ),
                      _bottomItem(
                        icon: Icons.medical_services_outlined,
                        label: tr('Dokter', 'Doctors'),
                        index: 2,
                        isDark: isDark,
                      ),
                      _bottomItem(
                        icon: Icons.description_outlined,
                        label: tr('Riwayat', 'History'),
                        index: 3,
                        isDark: isDark,
                      ),
                      _bottomItem(
                        icon: Icons.person_outline,
                        label: tr('Profil', 'Profile'),
                        index: 4,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
            },
          );
        },
      );
    }


  // WIDGET HELPER: SERVICE CARDS (GRADASI BIRU ELEGAN)
  Widget _serviceCard({
    required IconData icon,
    required String title,
    required String description,
    VoidCallback? onTap,
    bool isDark = false,
  }) {
final Color borderColor = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFBAE6FD);
    final LinearGradient cardGradient = isDark
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

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 172,
        decoration: BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? const Color(0xFF38BDF8) : brandPrimary).withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Ornamen aksen lingkaran lembut di sudut kartu
              Positioned(
                right: -12,
                bottom: -12,
                child: Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: isDark ? 0.03 : 0.38),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? Colors.black : brandPrimary).withValues(alpha: 0.12),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            size: 25,
                            color: isDark ? const Color(0xFF38BDF8) : brandPrimary,
                          ),
                        ),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: brandPrimary.withValues(alpha: 0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: isDark ? const Color(0xFF38BDF8) : brandPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.22,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.3,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  // WIDGET HELPER: HORIZONTAL SERVICE CARD (FULL WIDTH)
  Widget _horizontalServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final Color borderColor = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFBAE6FD);
    final LinearGradient cardGradient = isDark
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

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? const Color(0xFF38BDF8) : brandPrimary).withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Ornamen aksen lingkaran lembut di sudut kartu
              Positioned(
                right: -15,
                bottom: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: isDark ? 0.03 : 0.38),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? Colors.black : brandPrimary).withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 25,
                        color: isDark ? const Color(0xFF38BDF8) : brandPrimary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.3,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: brandPrimary.withValues(alpha: 0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: isDark ? const Color(0xFF38BDF8) : brandPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET HELPER: FEATURED ARTICLE ITEM
  Widget _featuredArticleItem(
    BuildContext context, {
    required String imageUrl,
    required String category,
    required String title,
    required String duration,
    required String content,
    String? description,
    bool isDark = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailPage(
              image: imageUrl,
              category: category,
              title: title,
              description: description ?? title,
              date: '22 September 2026',
              content: content,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 72,
                          height: 72,
                          color: isDark ? const Color(0xFF0F2B3E) : const Color(0xFFE8F7FB),
                          child: Icon(
                            Icons.article_outlined,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0098B9),
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 72,
                          height: 72,
                          color: isDark ? const Color(0xFF0F2B3E) : const Color(0xFFE8F7FB),
                          child: Icon(
                            Icons.article_outlined,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0098B9),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F2B3E) : const Color(0xFFE8F7FB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0098B9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        duration,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET HELPER: BOTTOM NAV ITEM
  Widget _bottomItem({
    required IconData icon,
    required String label,
    required int index,
    bool isDark = false,
  }) {
    final bool active = _selectedIndex == index;
    final Color activeColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF1479F5);
    final Color inactiveColor = isDark ? const Color(0xFF94A3B8) : Colors.black87;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 23,
              color: active ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}