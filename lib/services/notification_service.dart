import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';
import '../services/doctor_service.dart';
import '../services/profile_service.dart';
import '../pages/konsultasi_dokter_page.dart';
import '../pages/pengingat_kesehatan_page.dart';
import '../pages/education_page.dart';

/// Jenis kategori notifikasi pop-up HeartCare
enum HeartCareNotificationType {
  chatDoctor, // Pesan chat dari Dokter ke Pasien
  chatPatient, // Pesan chat dari Pasien ke Dokter
  consultation, // Pengingat Jadwal Konsultasi Dokter
  medicine, // Pengingat Minum Obat Pasien
  education, // Edukasi & Tips Kesehatan Jantung Harian
}

/// Model data notifikasi pop-up
class PopUpNotificationItem {
  final String id;
  final HeartCareNotificationType type;
  final String title;
  final String message;
  final String? avatarSource;
  final String? categoryLabel;
  final IconData icon;
  final Color primaryColor;
  final Color badgeBgColor;
  final DateTime timestamp;
  final VoidCallback? onTap;

  PopUpNotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.avatarSource,
    this.categoryLabel,
    required this.icon,
    required this.primaryColor,
    required this.badgeBgColor,
    required this.timestamp,
    this.onTap,
  });
}

/// Service pengelola notifikasi pop-up yang muncul di atas layar HP (Heads-Up Banner)
class NotificationService extends ChangeNotifier {
  NotificationService._() {
    _loadPreferences();
  }

  static final NotificationService instance = NotificationService._();

  /// Global NavigatorKey untuk menampilkan pop-up di atas screen mana saja tanpa context caller
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Global BuildContext aktif untuk cadangan overlay & dialog
  BuildContext? _globalContext;

  static void setContext(BuildContext context) {
    instance._globalContext = context;
  }

  // Toggles preferensi notifikasi
  bool _enableChat = true;
  bool _enableMedicine = true;
  bool _enableConsultation = true;
  bool _enableEducation = true;

  bool get enableChat => _enableChat;
  bool get enableMedicine => _enableMedicine;
  bool get enableConsultation => _enableConsultation;
  bool get enableEducation => _enableEducation;

  // State Overlay Entry aktif
  OverlayEntry? _currentOverlayEntry;
  Timer? _autoDismissTimer;

  // Daftar tips edukasi jantung terverifikasi
  static const List<Map<String, String>> _educationTips = [
    {
      'title': 'Kurangi Asupan Garam Harian',
      'body':
          'Batasi konsumsi garam < 5g (1 sdt) per hari untuk mengontrol tekanan darah dan elastisitas arteri jantung.',
    },
    {
      'title': 'Aktivitas Aerobik 30 Menit',
      'body':
          'Jalan cepat atau bersepeda 30 menit sehari menurunkan risiko penyakit jantung koroner hingga 35%.',
    },
    {
      'title': 'Jaga Kualitas Tidur Malam',
      'body':
          'Tidur 7-8 jam per malam memberi waktu otot jantung beristirahat dan menstabilkan hormon tekanan darah.',
    },
    {
      'title': 'Konsumsi Makanan Kaya Kalium',
      'body':
          'Pisang, bayam, dan alpukat kaya kalium yang membantu ginjal menyeimbangkan kadar natrium dalam darah.',
    },
    {
      'title': 'Waspadai Nyeri Dada Khas (Angina)',
      'body':
          'Rasa tertekan di dada menjalar ke lengan kiri atau leher adalah alarm jantung, segera istirahat dan periksa.',
    },
    {
      'title': 'Hindari Lemak Trans & Kolesterol Tinggi',
      'body':
          'Ganti gorengan dengan makanan rebus/kukus untuk mencegah penumpukan plak aterosklerosis di pembuluh darah.',
    },
  ];

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enableChat = prefs.getBool('notif_enable_chat') ?? true;
      _enableMedicine = prefs.getBool('notif_enable_medicine') ?? true;
      _enableConsultation =
          prefs.getBool('notif_enable_consultation') ?? true;
      _enableEducation = prefs.getBool('notif_enable_education') ?? true;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setNotificationPreference({
    bool? enableChat,
    bool? enableMedicine,
    bool? enableConsultation,
    bool? enableEducation,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (enableChat != null) {
        _enableChat = enableChat;
        await prefs.setBool('notif_enable_chat', enableChat);
      }
      if (enableMedicine != null) {
        _enableMedicine = enableMedicine;
        await prefs.setBool('notif_enable_medicine', enableMedicine);
      }
      if (enableConsultation != null) {
        _enableConsultation = enableConsultation;
        await prefs.setBool('notif_enable_consultation', enableConsultation);
      }
      if (enableEducation != null) {
        _enableEducation = enableEducation;
        await prefs.setBool('notif_enable_education', enableEducation);
      }
      notifyListeners();
    } catch (_) {}
  }

  /// Menampilkan notifikasi pop-up melayang di atas layar HP (Heads-Up Banner)
  void showNotification({
    BuildContext? context,
    required HeartCareNotificationType type,
    required String title,
    required String message,
    String? avatarSource,
    String? categoryLabel,
    IconData? icon,
    Color? primaryColor,
    Color? badgeBgColor,
    VoidCallback? onTap,
    Duration duration = const Duration(milliseconds: 4500),
  }) {
    // Periksa apakah kategori notifikasi diaktifkan oleh pengguna
    if (type == HeartCareNotificationType.chatDoctor ||
        type == HeartCareNotificationType.chatPatient) {
      if (!_enableChat) return;
    } else if (type == HeartCareNotificationType.medicine) {
      if (!_enableMedicine) return;
    } else if (type == HeartCareNotificationType.consultation) {
      if (!_enableConsultation) return;
    } else if (type == HeartCareNotificationType.education) {
      if (!_enableEducation) return;
    }

    // Cari OverlayState yang aktif secara bertingkat (multi-fallback)
    OverlayState? overlayState;
    if (context != null) {
      try {
        overlayState = Overlay.maybeOf(context);
      } catch (_) {}
    }
    if (overlayState == null) {
      try {
        overlayState = navigatorKey.currentState?.overlay;
      } catch (_) {}
    }
    if (overlayState == null && _globalContext != null) {
      try {
        overlayState = Overlay.maybeOf(_globalContext!);
      } catch (_) {}
    }
    if (overlayState == null && navigatorKey.currentContext != null) {
      try {
        overlayState = Overlay.maybeOf(navigatorKey.currentContext!);
      } catch (_) {}
    }

    // Tentukan tema dan warna default per jenis notifikasi
    final IconData defaultIcon;
    final Color defaultPrimary;
    final Color defaultBadgeBg;
    final String defaultLabel;

    switch (type) {
      case HeartCareNotificationType.chatDoctor:
        defaultIcon = Icons.medical_services_rounded;
        defaultPrimary = const Color(0xFF0284C7);
        defaultBadgeBg = const Color(0xFFE0F2FE);
        defaultLabel = "CHAT DOKTER";
        break;
      case HeartCareNotificationType.chatPatient:
        defaultIcon = Icons.person_pin_rounded;
        defaultPrimary = const Color(0xFF0284C7);
        defaultBadgeBg = const Color(0xFFE0F2FE);
        defaultLabel = "PESAN PASIEN";
        break;
      case HeartCareNotificationType.medicine:
        defaultIcon = Icons.medication_rounded;
        defaultPrimary = const Color(0xFFD97706);
        defaultBadgeBg = const Color(0xFFFEF3C7);
        defaultLabel = "PENGINGAT OBAT";
        break;
      case HeartCareNotificationType.consultation:
        defaultIcon = Icons.event_available_rounded;
        defaultPrimary = const Color(0xFF0D9488);
        defaultBadgeBg = const Color(0xFFCCFBF1);
        defaultLabel = "JADWAL KONSULTASI";
        break;
      case HeartCareNotificationType.education:
        defaultIcon = Icons.health_and_safety_rounded;
        defaultPrimary = const Color(0xFF7C3AED);
        defaultBadgeBg = const Color(0xFFEDE9FE);
        defaultLabel = "EDUKASI JANTUNG";
        break;
    }

    final item = PopUpNotificationItem(
      id: "notif_${DateTime.now().millisecondsSinceEpoch}",
      type: type,
      title: title,
      message: message,
      avatarSource: avatarSource,
      categoryLabel: categoryLabel ?? defaultLabel,
      icon: icon ?? defaultIcon,
      primaryColor: primaryColor ?? defaultPrimary,
      badgeBgColor: badgeBgColor ?? defaultBadgeBg,
      timestamp: DateTime.now(),
      onTap: onTap,
    );

    // Haptic feedback getaran notifikasi di HP
    try {
      HapticFeedback.mediumImpact().catchError((_) {});
    } catch (_) {}

    // JIKA OVERLAY TERSEDIA: TAMPILKAN HEADS-UP POP-UP BANNER DI ATAS LAYAR
    if (overlayState != null) {
      // Bersihkan notifikasi sebelumnya jika sedang aktif
      _dismissCurrent();

      debugPrint('🔔 [HeartCare Pop-up Notification] Overlay Active -> $title: $message');

      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (context) => Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _TopPopUpNotificationBanner(
            item: item,
            onDismiss: () {
              if (_currentOverlayEntry == entry) {
                _dismissCurrent();
              }
            },
          ),
        ),
      );

      _currentOverlayEntry = entry;
      try {
        overlayState.insert(entry);

        // Auto-dismiss setelah durasi
        _autoDismissTimer = Timer(duration, () {
          if (_currentOverlayEntry == entry) {
            _dismissCurrent();
          }
        });
        return;
      } catch (e) {
        debugPrint('[NotificationService] Overlay insert failed, using fallback: $e');
      }
    }

    // JIKA OVERLAY BELUM TERSEDIA (FALLBACK): TAMPILKAN FLOATING BANNER DI ATAS
    final fallbackContext = context ?? _globalContext ?? navigatorKey.currentContext;
    if (fallbackContext != null) {
      try {
        ScaffoldMessenger.maybeOf(fallbackContext)?.hideCurrentSnackBar();
        ScaffoldMessenger.maybeOf(fallbackContext)?.showSnackBar(
          SnackBar(
            content: InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: item.badgeBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          item.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: item.primaryColor,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            duration: duration,
          ),
        );
      } catch (e) {
        debugPrint('[NotificationService] SnackBar fallback error: $e');
      }
    }
  }

  void _dismissCurrent() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    try {
      _currentOverlayEntry?.remove();
    } catch (_) {}
    _currentOverlayEntry = null;
  }

  /// Menampilkan dialog pop-up konfirmasi / peringatan di tengah layar
  Future<void> showPopUpAlert({
    BuildContext? context,
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    String? actionLabel,
    VoidCallback? onAction,
  }) async {
    final targetContext =
        context ?? _globalContext ?? navigatorKey.currentContext;
    if (targetContext == null) return;

    final isDark = ThemeService.isDarkMode;
    showDialog(
      context: targetContext,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.4,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Tutup',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                onAction();
              },
              child: Text(
                actionLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // METODE KHUSUS PER KATEGORI NOTIFIKASI
  // ==========================================================================

  /// 1. Notifikasi Pop-up Chat Dokter ke Pasien
  void showDoctorChatNotification({
    BuildContext? context,
    required String doctorName,
    required String message,
    String? doctorPhoto,
    String? doctorSpecialty,
    String? chatId,
    String? doctorId,
  }) {
    showNotification(
      context: context,
      type: HeartCareNotificationType.chatDoctor,
      title: doctorName,
      message: message,
      avatarSource: doctorPhoto,
      categoryLabel: "CHAT DOKTER • ${doctorSpecialty ?? 'Spesialis Jantung'}",
      onTap: () {
        final route = MaterialPageRoute(
          builder: (ctx) => KonsultasiDokterPage(
            chatId: chatId,
            isDoctorView: false,
            doctorId: doctorId,
            doctorName: doctorName,
            doctorPhoto: doctorPhoto ?? 'assets/images/dokter_nurlitta.jpg',
            doctorSpecialty: doctorSpecialty ?? 'Spesialis Jantung',
          ),
        );
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(route);
        } else {
          final target = context ?? _globalContext ?? navigatorKey.currentContext;
          if (target != null) Navigator.push(target, route);
        }
      },
    );
  }

  /// 2. Notifikasi Pop-up Chat Pasien ke Dokter
  void showPatientChatNotification({
    BuildContext? context,
    required String patientName,
    required String message,
    String? patientPhoto,
    String? patientId,
    String? chatId,
    String? doctorName,
    String? doctorPhoto,
    String? doctorSpecialty,
  }) {
    showNotification(
      context: context,
      type: HeartCareNotificationType.chatPatient,
      title: patientName.isNotEmpty ? patientName : "Pasien HeartCare",
      message: message,
      avatarSource: patientPhoto,
      categoryLabel: "PESAN PASIEN KONSULTASI",
      onTap: () {
        final route = MaterialPageRoute(
          builder: (ctx) => KonsultasiDokterPage(
            chatId: chatId,
            isDoctorView: true,
            patientId: patientId,
            patientName: patientName,
            patientPhoto: patientPhoto,
            doctorName: doctorName ?? 'dr. Dokter HeartCare',
            doctorPhoto: doctorPhoto ?? 'assets/images/dokter_nurlitta.jpg',
            doctorSpecialty: doctorSpecialty ?? 'Spesialis Jantung',
          ),
        );
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(route);
        } else {
          final target = context ?? _globalContext ?? navigatorKey.currentContext;
          if (target != null) Navigator.push(target, route);
        }
      },
    );
  }

  /// 3. Notifikasi Pop-up Pengingat Jadwal Konsultasi
  void showConsultationReminderNotification({
    BuildContext? context,
    required String doctorName,
    required String scheduledTime,
    String? doctorPhoto,
    String? doctorSpecialty,
    String? chatId,
  }) {
    showNotification(
      context: context,
      type: HeartCareNotificationType.consultation,
      title: "Jadwal Konsultasi: $doctorName",
      message:
          "Sesi konsultasi Anda dijadwalkan pada $scheduledTime. Ketuk untuk membuka ruang chat.",
      avatarSource: doctorPhoto,
      categoryLabel: "PENGINGAT JADWAL KONSULTASI",
      onTap: () {
        final route = MaterialPageRoute(
          builder: (ctx) => KonsultasiDokterPage(
            chatId: chatId,
            doctorName: doctorName,
            doctorPhoto: doctorPhoto ?? 'assets/images/dokter_nurlitta.jpg',
            doctorSpecialty: doctorSpecialty ?? 'Spesialis Jantung',
          ),
        );
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(route);
        } else {
          final target = context ?? _globalContext ?? navigatorKey.currentContext;
          if (target != null) Navigator.push(target, route);
        }
      },
    );
  }

  /// 4. Notifikasi Pop-up Pengingat Minum Obat
  void showMedicineReminderNotification({
    BuildContext? context,
    required String medicineName,
    required String dosage,
    required String instruction,
    String? time,
  }) {
    final timeStr = time != null ? "Pukul $time WIB • " : "";
    showNotification(
      context: context,
      type: HeartCareNotificationType.medicine,
      title: "Waktunya Minum: $medicineName",
      message: "$timeStr$dosage ($instruction). Ketuk untuk melihat daftar obat.",
      categoryLabel: "PENGINGAT MINUM OBAT",
      onTap: () {
        final route = MaterialPageRoute(
          builder: (ctx) => const PengingatKesehatanPage(),
        );
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(route);
        } else {
          final target = context ?? _globalContext ?? navigatorKey.currentContext;
          if (target != null) Navigator.push(target, route);
        }
      },
    );
  }

  /// 5. Notifikasi Pop-up Edukasi Kesehatan Jantung
  void showHealthEducationNotification({
    BuildContext? context,
    String? title,
    String? message,
  }) {
    final tip = _educationTips[Random().nextInt(_educationTips.length)];
    final resolvedTitle = title ?? tip['title']!;
    final resolvedMessage = message ?? tip['body']!;

    showNotification(
      context: context,
      type: HeartCareNotificationType.education,
      title: resolvedTitle,
      message: resolvedMessage,
      categoryLabel: "TIPS KESEHATAN JANTUNG",
      onTap: () {
        final route = MaterialPageRoute(
          builder: (ctx) => const EducationPage(),
        );
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(route);
        } else {
          final target = context ?? _globalContext ?? navigatorKey.currentContext;
          if (target != null) Navigator.push(target, route);
        }
      },
    );
  }
}

/// Widget visual notifikasi pop-up melayang di atas layar HP (Heads-Up Banner)
class _TopPopUpNotificationBanner extends StatefulWidget {
  final PopUpNotificationItem item;
  final VoidCallback onDismiss;

  const _TopPopUpNotificationBanner({
    required this.item,
    required this.onDismiss,
  });

  @override
  State<_TopPopUpNotificationBanner> createState() =>
      _TopPopUpNotificationBannerState();
}

class _TopPopUpNotificationBannerState
    extends State<_TopPopUpNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _dismissWithAnimation() {
    _animController
        .reverse()
        .then((_) => widget.onDismiss())
        .catchError((_) => widget.onDismiss());
  }

  Widget _buildAvatar(bool isDark) {
    final item = widget.item;

    if (item.type == HeartCareNotificationType.chatDoctor) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? const Color(0xFF0F2B3E) : const Color(0xFFE0F2FE),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFBAE6FD),
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: DoctorService.buildDoctorImage(
          item.avatarSource,
          width: 44,
          height: 44,
        ),
      );
    }

    if (item.type == HeartCareNotificationType.chatPatient) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? const Color(0xFF0F2B3E) : const Color(0xFFE0F2FE),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFBAE6FD),
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ProfileService.buildPatientImage(
          item.avatarSource,
          width: 44,
          height: 44,
          isDark: isDark,
        ),
      );
    }

    // Avatar khusus icon berwarna untuk Pengingat Obat, Jadwal, dan Edukasi
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: item.badgeBgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: item.primaryColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Icon(
        item.icon,
        size: 24,
        color: item.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final item = widget.item;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          bottom: false,
          child: SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  // Geser ke atas untuk menutup notifikasi pop-up
                  if (details.primaryDelta != null &&
                      details.primaryDelta! < -4) {
                    _dismissWithAnimation();
                  }
                },
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      _dismissWithAnimation();
                      item.onTap?.call();
                    },
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 480),
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.45 : 0.12,
                            ),
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // BARIS ATAS: KATEGORI, APP BRAND, DAN WAKTU
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: item.badgeBgColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      item.icon,
                                      size: 11,
                                      color: item.primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.categoryLabel ?? "HEARTCARE",
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: item.primaryColor,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "Baru saja",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: _dismissWithAnimation,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 13,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // BARIS KONTEN: AVATAR, JUDUL, PESAN
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildAvatar(isDark),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.message,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        height: 1.3,
                                        color: isDark
                                            ? const Color(0xFFCBD5E1)
                                            : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0F2B3E)
                                      : const Color(0xFFF0F9FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}

