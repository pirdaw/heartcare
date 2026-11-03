import 'package:flutter/material.dart';
import '../services/chat_notification_service.dart';
import '../pages/konsultasi_dokter_page.dart';

/// Modal Bottom Sheet untuk menampilkan Pusat Notifikasi Chat Dokter & Pasien
class ChatNotificationSheet extends StatefulWidget {
  const ChatNotificationSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChatNotificationSheet(),
    );
  }

  @override
  State<ChatNotificationSheet> createState() => _ChatNotificationSheetState();
}

class _ChatNotificationSheetState extends State<ChatNotificationSheet> {
  // 0: Semua, 1: Dari Dokter, 2: Dari Pasien
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

        ChatSenderRole? roleFilter;
        if (_selectedFilterIndex == 1) {
          roleFilter = ChatSenderRole.patient; // Ditujukan untuk pasien (dari dokter)
        } else if (_selectedFilterIndex == 2) {
          roleFilter = ChatSenderRole.doctor; // Ditujukan untuk dokter (dari pasien)
        }

        final notifications = service.getNotifications(filterRecipientRole: roleFilter);
        final unreadCount = service.totalUnreadNotificationCount;

        return Container(
          height: size.height * 0.78,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
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
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F2B3E)
                              : const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF1E3A5F)
                                : const Color(0xFFBAE6FD),
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFF0284C7),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Notifikasi Chat',
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$unreadCount baru',
                                      style: const TextStyle(
                                        fontSize: 10.5,
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
                              'Pesan masuk dari dokter dan konsultasi pasien',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (unreadCount > 0)
                        TextButton(
                          onPressed: () {
                            service.markAllNotificationsAsRead();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Tandai Baca',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // FILTER TABS (Semua / Dari Dokter / Dari Pasien)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _filterChip(
                        title: 'Semua',
                        count: service.getNotifications().length,
                        index: 0,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _filterChip(
                        title: 'Dari Dokter',
                        count: service
                            .getNotifications(
                                filterRecipientRole: ChatSenderRole.patient)
                            .length,
                        index: 1,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _filterChip(
                        title: 'Dari Pasien',
                        count: service
                            .getNotifications(
                                filterRecipientRole: ChatSenderRole.doctor)
                            .length,
                        index: 2,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(height: 16),

                // DAFTAR NOTIFIKASI
                Expanded(
                  child: notifications.isEmpty
                      ? _emptyState(isDark)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          itemCount: notifications.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final notif = notifications[index];
                            return _notificationTile(
                              notif: notif,
                              isDark: isDark,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => KonsultasiDokterPage(
                                      doctorName: notif.conversationDoctorName,
                                      doctorPhoto: notif.doctorPhoto,
                                      doctorSpecialty: notif.doctorSpecialty,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),

                // SECTION UJI SIMULASI NOTIFIKASI (UNTUK PENGUJIAN FITUR)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.science_outlined,
                            size: 14,
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Simulasi Pengujian Notifikasi Chat:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                service.simulateDoctorInitiatedMessage(
                                  doctorName: 'dr. Nurlitta Dwi',
                                );
                              },
                              icon: const Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 14,
                              ),
                              label: const Text(
                                'Pesan dari Dokter',
                                style: TextStyle(fontSize: 11.5),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0284C7),
                                side: const BorderSide(color: Color(0xFFBAE6FD)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                service.simulatePatientMessage(
                                  doctorName: 'dr. Nurlitta Dwi',
                                );
                              },
                              icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 14,
                              ),
                              label: const Text(
                                'Pesan dari Pasien',
                                style: TextStyle(fontSize: 11.5),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF10B981),
                                side: const BorderSide(color: Color(0xFFA7F3D0)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0284C7)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0284C7)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationTile({
    required ChatNotificationItem notif,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isDoctorSender = notif.senderRole == ChatSenderRole.doctor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: notif.isRead
                ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                : (isDark
                    ? const Color(0xFF0C2A40)
                    : const Color(0xFFF0F9FF)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notif.isRead
                  ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                  : (isDark
                      ? const Color(0xFF0284C7)
                      : const Color(0xFFBAE6FD)),
              width: notif.isRead ? 1 : 1.4,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AVATAR
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF0F2B3E)
                          : const Color(0xFFEFF6FF),
                      border: Border.all(
                        color: isDoctorSender
                            ? const Color(0xFF0284C7)
                            : const Color(0xFF10B981),
                        width: 1.5,
                      ),
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
                              size: 26,
                            ),
                    ),
                  ),
                  if (!notif.isRead)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            width: 1.5,
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
                            horizontal: 5,
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
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            isDoctorSender ? 'Dokter' : 'Pasien',
                            style: TextStyle(
                              fontSize: 9,
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
                        fontWeight: FontWeight.w500,
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

              const SizedBox(width: 6),

              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 40,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada notifikasi chat',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pesan masuk dari konsultasi dokter akan muncul di sini',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
