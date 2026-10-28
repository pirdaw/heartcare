import 'dart:async';
import 'package:flutter/material.dart';
import '../services/chat_notification_service.dart';
import '../pages/konsultasi_dokter_page.dart';

/// Overlay manager untuk menampilkan banner notifikasi chat floating
/// yang dapat melayang di atas layar aktif mana pun.
class ChatNotificationBannerManager {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show(
    BuildContext context,
    ChatNotificationItem notification, {
    Duration duration = const Duration(seconds: 4),
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    // Tutup banner sebelumnya jika masih ada
    hide();

    final overlayState = navigatorKey?.currentState?.overlay ??
        Overlay.maybeOf(context, rootOverlay: true);

    if (overlayState == null) return;
    _insertOverlay(overlayState, notification, duration, navigatorKey: navigatorKey);
  }

  static void showWithNavigatorKey({
    required GlobalKey<NavigatorState> navigatorKey,
    required ChatNotificationItem notification,
    Duration duration = const Duration(seconds: 4),
  }) {
    hide();
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;
    _insertOverlay(overlayState, notification, duration, navigatorKey: navigatorKey);
  }

  static void _insertOverlay(
    OverlayState overlayState,
    ChatNotificationItem notification,
    Duration duration, {
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    final entry = OverlayEntry(
      builder: (context) => _InAppNotificationBannerWidget(
        notification: notification,
        onTap: () {
          hide();
          final nav = navigatorKey?.currentState ?? Navigator.of(context);
          nav.push(
            MaterialPageRoute(
              builder: (context) => KonsultasiDokterPage(
                doctorName: notification.conversationDoctorName,
                doctorPhoto: notification.doctorPhoto,
                doctorSpecialty: notification.doctorSpecialty,
              ),
            ),
          );
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
}

class _InAppNotificationBannerWidget extends StatefulWidget {
  final ChatNotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _InAppNotificationBannerWidget({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationBannerWidget> createState() =>
      _InAppNotificationBannerWidgetState();
}

class _InAppNotificationBannerWidgetState
    extends State<_InAppNotificationBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _animController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    final isDoctorSender =
        widget.notification.senderRole == ChatSenderRole.doctor;

    return Positioned(
      top: topPadding + 8,
      left: 14,
      right: 14,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap,
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) < -100) {
                  _handleDismiss();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                        : const Color(0xFF0284C7).withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark
                              ? Colors.black
                              : const Color(0xFF0284C7))
                          .withValues(alpha: isDark ? 0.45 : 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // AVATAR PENGIRIM
                    Stack(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? const Color(0xFF0F2B3E)
                                : const Color(0xFFE0F2FE),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF38BDF8)
                                  : const Color(0xFF0284C7),
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: isDoctorSender
                                ? Image.asset(
                                    widget.notification.doctorPhoto,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.medical_services_rounded,
                                        color: Color(0xFF0284C7),
                                        size: 24,
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    color: Color(0xFF0284C7),
                                    size: 26,
                                  ),
                          ),
                        ),
                        // Badge Ikon Kecil
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              color: isDoctorSender
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              isDoctorSender
                                  ? Icons.medical_services
                                  : Icons.chat_bubble,
                              size: 9,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // KONTEN NOTIFIKASI
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.notification.senderName,
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
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0F2B3E)
                                      : const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isDoctorSender ? 'Dokter' : 'Pasien',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF0284C7),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                widget.notification.time,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.notification.messageSnippet,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // TOMBOL AKSI CEPAT: BUKA / DISMISS
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Buka',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: _handleDismiss,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFF1F5F9),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
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
    );
  }
}
