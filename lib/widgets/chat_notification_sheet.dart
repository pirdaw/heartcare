import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_notification_service.dart';
import '../services/user_profile_service.dart';
import '../pages/konsultasi_dokter_page.dart';

/// Modal Bottom Sheet untuk menampilkan Pusat Notifikasi Chat Dokter & Pasien
/// Mengadopsi estetika desain Home Page dengan aksen gradasi modern,
/// filter tab efisien (Semua & Belum Dibaca), dan menu hapus (Delete).
class ChatNotificationSheet extends StatefulWidget {
  final ChatSenderRole? viewerRole;
  final String? patientId;
  final String? patientName;
  final String? doctorId;
  final String? doctorName;

  const ChatNotificationSheet({
    super.key,
    this.viewerRole,
    this.patientId,
    this.patientName,
    this.doctorId,
    this.doctorName,
  });

  static Future<void> show(
    BuildContext context, {
    ChatSenderRole? viewerRole,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatNotificationSheet(
        viewerRole: viewerRole,
        patientId: patientId,
        patientName: patientName,
        doctorId: doctorId,
        doctorName: doctorName,
      ),
    );
  }

  @override
  State<ChatNotificationSheet> createState() => _ChatNotificationSheetState();
}

class _ChatNotificationSheetState extends State<ChatNotificationSheet> {
  // 0: Semua, 1: Belum Dibaca
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: ChatNotificationService.instance,
      builder: (context, _) {
        final service = ChatNotificationService.instance;

        final authUser = FirebaseAuth.instance.currentUser;
        final profile = UserProfileService.instance.currentProfile;

        // Auto-detect peran dan identitas akun jika tidak dioper secara eksplisit
        ChatSenderRole effectiveRole =
            widget.viewerRole ?? ChatSenderRole.patient;
        String? effectivePatientId = widget.patientId;
        String? effectivePatientName = widget.patientName;
        String? effectiveDoctorId = widget.doctorId;
        String? effectiveDoctorName = widget.doctorName;

        if (widget.viewerRole == null) {
          final isDoctor =
              (authUser?.email?.toLowerCase().contains('dokter') ?? false) ||
                  (authUser?.displayName?.toLowerCase().startsWith('dr.') ??
                      false) ||
                  (profile.nama.toLowerCase().startsWith('dr.'));
          if (isDoctor) {
            effectiveRole = ChatSenderRole.doctor;
            effectiveDoctorId = authUser?.uid;
            effectiveDoctorName = (authUser?.displayName?.isNotEmpty ?? false)
                ? authUser!.displayName
                : (profile.nama.isNotEmpty ? profile.nama : 'Dokter');
          } else {
            effectiveRole = ChatSenderRole.patient;
            effectivePatientId =
                authUser?.uid ?? authUser?.email ?? profile.nama;
            effectivePatientName = profile.nama.isNotEmpty
                ? profile.nama
                : (authUser?.displayName ?? 'Pasien');
          }
        } else if (effectiveRole == ChatSenderRole.patient) {
          effectivePatientId ??=
              authUser?.uid ?? authUser?.email ?? profile.nama;
          effectivePatientName ??= profile.nama.isNotEmpty
              ? profile.nama
              : (authUser?.displayName ?? 'Pasien');
        } else {
          effectiveDoctorId ??= authUser?.uid;
          effectiveDoctorName ??= (authUser?.displayName?.isNotEmpty ?? false)
              ? authUser!.displayName
              : (profile.nama.isNotEmpty ? profile.nama : 'Dokter');
        }

        final isPatient = effectiveRole == ChatSenderRole.patient;
        final accountDisplayName = isPatient
            ? (effectivePatientName?.isNotEmpty == true
                ? effectivePatientName!
                : 'Pasien')
            : (effectiveDoctorName?.isNotEmpty == true
                ? effectiveDoctorName!
                : 'Dokter');

        // Ambil notifikasi yang HANYA diperuntukkan bagi akun ini
        final allForAccount = service.getNotificationsForUser(
          viewerRole: effectiveRole,
          patientId: effectivePatientId,
          patientName: effectivePatientName,
          doctorId: effectiveDoctorId,
          doctorName: effectiveDoctorName,
        );

        final unreadCount = allForAccount.where((n) => !n.isRead).length;

        // Hanya 2 tab: 0 = Semua, 1 = Belum Dibaca (menu "Sudah Dibaca" dihapus sesuai permintaan)
        List<ChatNotificationItem> displayNotifications;
        if (_selectedFilterIndex == 1) {
          displayNotifications =
              allForAccount.where((n) => !n.isRead).toList();
        } else {
          displayNotifications = allForAccount;
        }

        return Container(
          height: size.height * 0.82,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.18),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // DRAG HANDLE
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ==========================================================
                // GRADIENT HERO HEADER (Mengadopsi Banner Gradasi Home Page)
                // ==========================================================
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
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
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.30),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Lingkaran dekoratif ambient lembut (serasi dengan kartu AI Home)
                      Positioned(
                        right: -15,
                        top: -15,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 45,
                        bottom: -20,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Icon(
                                    isPatient
                                        ? Icons.notifications_active_rounded
                                        : Icons.medical_services_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Pusat Notifikasi',
                                            style: TextStyle(
                                              fontSize: 16.5,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          if (unreadCount > 0) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEF4444),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.2),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                '$unreadCount baru',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isPatient
                                            ? 'Pesan masuk dari dokter untuk Anda'
                                            : 'Pesan masuk dari pasien untuk Anda',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Tombol Tutup Sheet
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.20),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // BADGE PERAN & IDENTITAS AKUN AKTIF
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.32),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPatient
                                        ? Icons.person_rounded
                                        : Icons.medical_services_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      isPatient
                                          ? 'Akun Pasien: $accountDisplayName'
                                          : 'Akun Dokter: $accountDisplayName',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // MENU AKSI HEADER: TANDAI BACA & HAPUS SEMUA
                            if (allForAccount.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  if (unreadCount > 0)
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () {
                                          service.markAllNotificationsAsReadForUser(
                                            viewerRole: effectiveRole,
                                            patientId: effectivePatientId,
                                            patientName: effectivePatientName,
                                            doctorId: effectiveDoctorId,
                                            doctorName: effectiveDoctorName,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.12),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.done_all_rounded,
                                                size: 14,
                                                color: Color(0xFF0284C7),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Tandai Baca',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0284C7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                  // TOMBOL MENU HAPUS SEMUA
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        _confirmDeleteAll(
                                          context,
                                          service: service,
                                          role: effectiveRole,
                                          patientId: effectivePatientId,
                                          patientName: effectivePatientName,
                                          doctorId: effectiveDoctorId,
                                          doctorName: effectiveDoctorName,
                                          isDark: isDark,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.18),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.32),
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.delete_sweep_rounded,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Hapus Semua',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ==========================================================
                // FILTER TABS: HANYA "SEMUA" & "BELUM DIBACA"
                // ==========================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      _filterChip(
                        title: 'Semua',
                        count: allForAccount.length,
                        index: 0,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _filterChip(
                        title: 'Belum Dibaca',
                        count: unreadCount,
                        index: 1,
                        isDark: isDark,
                      ),
                      const Spacer(),
                      // MENU DELETE / OPSI POPUP
                      if (allForAccount.isNotEmpty)
                        PopupMenuButton<String>(
                          tooltip: 'Menu Opsi Notifikasi',
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            size: 22,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          onSelected: (val) {
                            if (val == 'mark_all_read') {
                              service.markAllNotificationsAsReadForUser(
                                viewerRole: effectiveRole,
                                patientId: effectivePatientId,
                                patientName: effectivePatientName,
                                doctorId: effectiveDoctorId,
                                doctorName: effectiveDoctorName,
                              );
                            } else if (val == 'delete_all') {
                              _confirmDeleteAll(
                                context,
                                service: service,
                                role: effectiveRole,
                                patientId: effectivePatientId,
                                patientName: effectivePatientName,
                                doctorId: effectiveDoctorId,
                                doctorName: effectiveDoctorName,
                                isDark: isDark,
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'mark_all_read',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.done_all_rounded,
                                    size: 18,
                                    color: Color(0xFF0284C7),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Tandai Semua Dibaca',
                                    style: TextStyle(fontSize: 12.5),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete_all',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_sweep_rounded,
                                    size: 18,
                                    color: Color(0xFFEF4444),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hapus Semua Notifikasi',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ==========================================================
                // DAFTAR NOTIFIKASI DENGAN TILE GRADASI & MENU DELETE
                // ==========================================================
                Expanded(
                  child: displayNotifications.isEmpty
                      ? _emptyState(
                          isDark,
                          isPatient: isPatient,
                          accountName: accountDisplayName,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                          itemCount: displayNotifications.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final notif = displayNotifications[index];
                            return _notificationTile(
                              context: context,
                              notif: notif,
                              service: service,
                              isDark: isDark,
                              isPatientView: isPatient,
                              onTap: () async {
                                await service.markAsRead(
                                  notif.conversationDoctorName,
                                  viewerRole: effectiveRole,
                                  patientId: notif.patientId ?? effectivePatientId,
                                  doctorId: notif.doctorId ?? effectiveDoctorId,
                                );
                                if (!context.mounted) return;
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => KonsultasiDokterPage(
                                      chatId: notif.chatId,
                                      isDoctorView: !isPatient,
                                      doctorName: notif.conversationDoctorName,
                                      doctorPhoto: notif.doctorPhoto,
                                      doctorSpecialty: notif.doctorSpecialty,
                                      patientName: notif.patientName,
                                      patientId: notif.patientId ?? effectivePatientId,
                                      doctorId: notif.doctorId ?? effectiveDoctorId,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filterChip({
    required String title,
    required int count,
    required int index,
    required bool isDark,
  }) {
    final isSelected = _selectedFilterIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFF0284C7),
                    Color(0xFF0EA5E9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0284C7)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF475569)),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.28)
                    : (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationTile({
    required BuildContext context,
    required ChatNotificationItem notif,
    required ChatNotificationService service,
    required bool isDark,
    required bool isPatientView,
    required VoidCallback onTap,
  }) {
    final isDoctorSender = notif.senderRole == ChatSenderRole.doctor;

    // Geser ke kiri untuk menghapus (Swipe-to-delete)
    return Dismissible(
      key: ValueKey('notif_${notif.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
            SizedBox(width: 6),
            Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        _deleteSingleNotification(context, service, notif.id);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              gradient: !notif.isRead
                  ? LinearGradient(
                      colors: isDark
                          ? const [Color(0xFF0F2B3E), Color(0xFF132F4C)]
                          : const [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: notif.isRead
                  ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                  : null,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: notif.isRead
                    ? (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0))
                    : (isDark
                        ? const Color(0xFF0284C7)
                        : const Color(0xFFBAE6FD)),
                width: notif.isRead ? 1 : 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: (notif.isRead
                          ? Colors.black.withValues(alpha: isDark ? 0.2 : 0.03)
                          : const Color(0xFF0284C7).withValues(alpha: 0.10)),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AVATAR DOKTER / PASIEN
                Stack(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFF0F2B3E)
                            : const Color(0xFFEFF6FF),
                        border: Border.all(
                          color: isDoctorSender
                              ? const Color(0xFF0284C7)
                              : const Color(0xFF10B981),
                          width: 1.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isDoctorSender
                                    ? const Color(0xFF0284C7)
                                    : const Color(0xFF10B981))
                                .withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: isDoctorSender
                            ? Image.asset(
                                notif.doctorPhoto,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.medical_services,
                                    color: Color(0xFF0284C7),
                                    size: 22,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.person,
                                color: Color(0xFF10B981),
                                size: 28,
                              ),
                      ),
                    ),
                    if (!notif.isRead)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                // INFO NOTIFIKASI
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              notif.senderName,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: notif.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: isDoctorSender
                                  ? (isDark
                                      ? const Color(0xFF0F2B3E)
                                      : const Color(0xFFE0F2FE))
                                  : (isDark
                                      ? const Color(0xFF063A24)
                                      : const Color(0xFFD1FAE5)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isDoctorSender ? 'Dokter' : 'Pasien',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isDoctorSender
                                    ? const Color(0xFF0284C7)
                                    : const Color(0xFF059669),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            notif.time,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDoctorSender
                            ? notif.doctorSpecialty
                            : 'Konsultasi: ${notif.conversationDoctorName}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : const Color(0xFF0284C7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.messageSnippet,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: notif.isRead
                              ? (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B))
                              : (isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A)),
                          fontWeight: notif.isRead
                              ? FontWeight.normal
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),

                // TOMBOL MENU DELETE INDIVIDUAL
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 19,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                  tooltip: 'Hapus notifikasi ini',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () {
                    _deleteSingleNotification(context, service, notif.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSingleNotification(
    BuildContext context,
    ChatNotificationService service,
    String notifId,
  ) async {
    await service.deleteNotification(notifId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Notifikasi berhasil dihapus'),
            ],
          ),
          backgroundColor: const Color(0xFF0284C7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmDeleteAll(
    BuildContext context, {
    required ChatNotificationService service,
    required ChatSenderRole role,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    required bool isDark,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_sweep_rounded,
                color: Color(0xFFEF4444),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Hapus Notifikasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus semua notifikasi untuk akun ini? Notifikasi yang sudah dihapus tidak dapat dipulihkan.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await service.clearAllNotificationsForUser(
                viewerRole: role,
                patientId: patientId,
                patientName: patientName,
                doctorId: doctorId,
                doctorName: doctorName,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.delete_sweep_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Semua notifikasi akun telah dibersihkan'),
                      ],
                    ),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(
    bool isDark, {
    required bool isPatient,
    required String accountName,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0xFF1E293B), Color(0xFF0F2B3E)]
                    : const [Color(0xFFE0F2FE), Color(0xFFF0F9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFBAE6FD),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 44,
              color: isDark
                  ? const Color(0xFF38BDF8)
                  : const Color(0xFF0284C7),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Text(
              isPatient
                  ? 'Pesan konsultasi masuk dari dokter untuk $accountName akan muncul di sini'
                  : 'Pesan konsultasi masuk dari pasien untuk $accountName akan muncul di sini',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
