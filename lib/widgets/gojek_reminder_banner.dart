import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/reminder_notification_service.dart';
import '../pages/konsultasi_dokter_page.dart';
import '../pages/pengingat_kesehatan_page.dart';

/// Manajer overlay untuk menampilkan banner notifikasi pengingat bergaya Gojek
/// yang melayang di bagian atas layar pada halaman mana pun di dalam aplikasi.
class GojekReminderBannerManager {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void showWithNavigatorKey({
    required GlobalKey<NavigatorState> navigatorKey,
    required HeartCareReminder reminder,
    Duration duration = const Duration(seconds: 7),
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      hide();
      final overlayState = navigatorKey.currentState?.overlay;
      if (overlayState == null) return;
      _insertOverlay(overlayState, reminder, duration, navigatorKey: navigatorKey);
    });
  }

  static void show(
    BuildContext context,
    HeartCareReminder reminder, {
    Duration duration = const Duration(seconds: 7),
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    hide();
    final overlayState = navigatorKey?.currentState?.overlay ??
        Overlay.maybeOf(context, rootOverlay: true);
    if (overlayState == null) return;
    _insertOverlay(overlayState, reminder, duration, navigatorKey: navigatorKey);
  }

  static void _insertOverlay(
    OverlayState overlayState,
    HeartCareReminder reminder,
    Duration duration, {
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    try {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}

    final entry = OverlayEntry(
      builder: (context) => _GojekBannerOverlayWidget(
        reminder: reminder,
        onTapAction: () {
          hide();
          _handleNavigation(context, reminder, navigatorKey);
        },
        onDismiss: hide,
      ),
    );

    _currentEntry = entry;
    overlayState.insert(entry);

    _dismissTimer = Timer(duration, () {
      hide();
    });
  }

  static void hide() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }

  static void _handleNavigation(
    BuildContext context,
    HeartCareReminder reminder,
    GlobalKey<NavigatorState>? navigatorKey,
  ) {
    final nav = navigatorKey?.currentState ?? Navigator.of(context);

    if (reminder.type == ReminderType.medicine) {
      nav.push(
        MaterialPageRoute(
          builder: (context) => const PengingatKesehatanPage(),
        ),
      );
      return;
    }

    nav.push(
      MaterialPageRoute(
        builder: (context) => KonsultasiDokterPage(
          chatId: reminder.chatId,
          isDoctorView: reminder.isDoctorView,
          doctorName: reminder.doctorName ?? 'dr. Nurlitta Dwi',
          doctorPhoto: reminder.doctorPhoto ?? 'assets/images/dokter_nurlitta.jpg',
          doctorSpecialty: reminder.doctorSpecialty ?? 'Spesialis Jantung',
          patientName: reminder.patientName ?? 'Pasien',
          patientId: reminder.patientId,
          doctorId: reminder.doctorId,
        ),
      ),
    );
  }
}

class _GojekBannerOverlayWidget extends StatefulWidget {
  final HeartCareReminder reminder;
  final VoidCallback onTapAction;
  final VoidCallback onDismiss;

  const _GojekBannerOverlayWidget({
    required this.reminder,
    required this.onTapAction,
    required this.onDismiss,
  });

  @override
  State<_GojekBannerOverlayWidget> createState() =>
      _GojekBannerOverlayWidgetState();
}

class _GojekBannerOverlayWidgetState extends State<_GojekBannerOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismissWithAnimation() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  Widget _buildLeadingImage() {
    final photo = widget.reminder.doctorPhoto;
    if (widget.reminder.type == ReminderType.medicine) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF10B981),
            width: 1.5,
          ),
        ),
        child: const Icon(
          Icons.medication_rounded,
          color: Color(0xFF059669),
          size: 26,
        ),
      );
    }

    if (photo != null && photo.isNotEmpty) {
      if (photo.startsWith('http://') || photo.startsWith('https://')) {
        return ClipOval(
          child: Image.network(
            photo,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _defaultDoctorIcon(),
          ),
        );
      }
      if (photo.startsWith('/') || photo.contains(':\\') || photo.contains(':/')) {
        final f = File(photo);
        if (f.existsSync()) {
          return ClipOval(
            child: Image.file(
              f,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _defaultDoctorIcon(),
            ),
          );
        }
      }
      return ClipOval(
        child: Image.asset(
          photo,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultDoctorIcon(),
        ),
      );
    }

    return _defaultDoctorIcon();
  }

  Widget _defaultDoctorIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF0284C7).withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF0284C7),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.medical_services_rounded,
        color: Color(0xFF0284C7),
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topPadding = media.padding.top > 0 ? media.padding.top + 8 : 16.0;

    final isMedicine = widget.reminder.type == ReminderType.medicine;
    final primaryColor = isMedicine ? const Color(0xFF00AA13) : const Color(0xFF0284C7);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: topPadding,
      left: 14,
      right: 14,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta != null && details.primaryDelta! < -4) {
                _dismissWithAnimation();
              }
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.18),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Accent Top Bar ala Gojek
                      Container(
                        height: 3.5,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isMedicine
                                ? [const Color(0xFF00AA13), const Color(0xFF10B981)]
                                : [const Color(0xFF0EA5E9), const Color(0xFF0284C7)],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Tag Badge Gojek & Waktu & Tombol Tutup
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isMedicine
                                            ? Icons.alarm_rounded
                                            : Icons.calendar_month_rounded,
                                        size: 12,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isMedicine
                                            ? 'PENGINGAT OBAT'
                                            : 'PENGINGAT KONSULTASI',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (widget.reminder.time.isNotEmpty)
                                  Text(
                                    '•  ${widget.reminder.time}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _dismissWithAnimation,
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Main Content Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLeadingImage(),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.reminder.title,
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
                                      const SizedBox(height: 3),
                                      Text(
                                        widget.reminder.body,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          height: 1.35,
                                          color: isDark
                                              ? const Color(0xFFCBD5E1)
                                              : const Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Action Button ala Gojek
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (isMedicine &&
                                          widget.reminder.medicineName != null) {
                                        ReminderNotificationService.instance
                                            .markMedicineTaken(
                                                widget.reminder.medicineName!);
                                      }
                                      widget.onTapAction();
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isMedicine
                                              ? [
                                                  const Color(0xFF00AA13),
                                                  const Color(0xFF10B981)
                                                ]
                                              : [
                                                  const Color(0xFF0EA5E9),
                                                  const Color(0xFF0284C7)
                                                ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            widget.reminder.actionLabel ??
                                                (isMedicine
                                                    ? 'Sudah Minum'
                                                    : 'Masuk Chat'),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
        ),
      ),
    );
  }
}
