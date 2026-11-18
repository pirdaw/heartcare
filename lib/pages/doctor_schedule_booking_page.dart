import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:heartcare/services/booking_service.dart';
import 'package:heartcare/services/doctor_service.dart';
import 'package:heartcare/services/theme_service.dart';
import 'package:heartcare/services/language_service.dart';
import 'konsultasi_dokter_page.dart';

/// Halaman terpadu Portal Dokter untuk:
/// 1. Manajemen Booking Pasien (Lihat, Terima, Tolak, Selesai, Detail)
/// 2. Atur Jadwal Praktik Dokter (Tanggal, Jam, Durasi, Istirahat, Slot Otomatis)
class DoctorScheduleBookingPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorPhoto;

  const DoctorScheduleBookingPage({
    super.key,
    required this.doctorId,
    this.doctorName = 'dr. Asya Catherine',
    this.doctorSpecialty = 'Spesialis Jantung & Pembuluh Darah',
    this.doctorPhoto = '',
  });

  @override
  State<DoctorScheduleBookingPage> createState() =>
      _DoctorScheduleBookingPageState();
}

class _DoctorScheduleBookingPageState extends State<DoctorScheduleBookingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filter status booking pasien
  String _selectedStatusFilter = 'Semua';

  // Tanggal yang sedang aktif dilihat pada tab Atur Jadwal
  String _selectedDateKey = '2026-09-02';
  String _selectedDateDisplay = 'Sel, 2 September 2026';
  String _selectedDayName = 'Sel';
  String _selectedDayNumber = '2';

  // Daftar 7 hari September 2026
  final List<Map<String, String>> _defaultDays = [
    {'key': '2026-09-01', 'full': 'Sen, 1 September 2026', 'day': 'Sen', 'num': '1'},
    {'key': '2026-09-02', 'full': 'Sel, 2 September 2026', 'day': 'Sel', 'num': '2'},
    {'key': '2026-09-03', 'full': 'Rab, 3 September 2026', 'day': 'Rab', 'num': '3'},
    {'key': '2026-09-04', 'full': 'Kam, 4 September 2026', 'day': 'Kam', 'num': '4'},
    {'key': '2026-09-05', 'full': 'Jum, 5 September 2026', 'day': 'Jum', 'num': '5'},
    {'key': '2026-09-06', 'full': 'Sab, 6 September 2026', 'day': 'Sab', 'num': '6'},
    {'key': '2026-09-07', 'full': 'Min, 7 September 2026', 'day': 'Min', 'num': '7'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    BookingService.instance.addListener(_onServiceChanged);
    BookingService.instance.init();
  }

  @override
  void dispose() {
    BookingService.instance.removeListener(_onServiceChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
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
            final pendingCount = BookingService.instance.getPendingBookingsCount(
              widget.doctorId,
              doctorName: widget.doctorName,
            );

            return Scaffold(
              backgroundColor:
                  isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              appBar: _buildAppBar(isDark),
              body: Column(
                children: [
                  _buildTabBar(isDark, pendingCount),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // TAB 1: MANAJEMEN BOOKING PASIEN
                        _buildBookingManagementTab(isDark),

                        // TAB 2: ATUR JADWAL PRAKTIK
                        _buildScheduleManagementTab(isDark),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================================
  // APPBAR DENGAN TEMA PORTAL DOKTER
  // ==========================================================================
  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        tooltip: 'Kembali ke Portal',
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Jadwal & Booking',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                widget.doctorName,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: _buildDoctorAvatarImage(widget.doctorPhoto, size: 36),
        ),
      ],
    );
  }

  // ==========================================================================
  // TABBAR MODERN ELEGAN
  // ==========================================================================
  Widget _buildTabBar(bool isDark, int pendingCount) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF0284C7),
        indicatorWeight: 3,
        labelColor: const Color(0xFF0284C7),
        unselectedLabelColor:
            isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_alt_rounded, size: 17),
                const SizedBox(width: 6),
                const Text('Booking Pasien'),
                if (pendingCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$pendingCount',
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
          ),
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tune_rounded, size: 17),
                SizedBox(width: 6),
                Text('Atur Jadwal Praktik'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 1: MANAJEMEN BOOKING PASIEN
  // ==========================================================================
  Widget _buildBookingManagementTab(bool isDark) {
    final allBookings = BookingService.instance.getDoctorBookings(
      widget.doctorId,
      doctorName: widget.doctorName,
    );

    final filteredBookings = allBookings.where((b) {
      if (_selectedStatusFilter == 'Semua') return true;
      return b.status.toLowerCase() == _selectedStatusFilter.toLowerCase();
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RINGKASAN STATISTIK BOOKING KILAT
          _buildBookingSummaryStats(isDark, allBookings),

          const SizedBox(height: 14),

          // CHIPS FILTER STATUS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua', isDark),
                _buildFilterChip('Menunggu Konfirmasi', isDark),
                _buildFilterChip('Diterima', isDark),
                _buildFilterChip('Selesai', isDark),
                _buildFilterChip('Ditolak', isDark),
                _buildFilterChip('Dibatalkan', isDark),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // DAFTAR PERMINTAAN BOOKING
          if (filteredBookings.isEmpty)
            _buildEmptyBookingState(isDark)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredBookings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = filteredBookings[index];
                return _buildBookingCard(booking, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBookingSummaryStats(bool isDark, List<DoctorBooking> bookings) {
    final pending = bookings.where((b) {
      final s = b.status.toLowerCase();
      return s == 'menunggu konfirmasi' || s == 'pending';
    }).length;
    final accepted = bookings.where((b) {
      final s = b.status.toLowerCase();
      return s == 'diterima' || s == 'accepted' || s == 'booked';
    }).length;
    final completed = bookings.where((b) => b.status.toLowerCase() == 'selesai').length;

    return Row(
      children: [
        Expanded(
          child: _summaryStatCard(
            title: 'Menunggu',
            count: pending,
            color: const Color(0xFFF59E0B),
            icon: Icons.hourglass_top_rounded,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryStatCard(
            title: 'Diterima',
            count: accepted,
            color: const Color(0xFF10B981),
            icon: Icons.check_circle_outline_rounded,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryStatCard(
            title: 'Selesai',
            count: completed,
            color: const Color(0xFF0284C7),
            icon: Icons.task_alt_rounded,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _summaryStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final active = _selectedStatusFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => setState(() => _selectedStatusFilter = label),
        selectedColor: const Color(0xFF0284C7),
        labelStyle: TextStyle(
          color: active
              ? Colors.white
              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
          fontWeight: active ? FontWeight.bold : FontWeight.w500,
          fontSize: 11.5,
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        side: BorderSide(
          color: active
              ? const Color(0xFF0284C7)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildBookingCard(DoctorBooking booking, bool isDark) {
    final statusColor = _getStatusColor(booking.status);
    final statusText = _getStatusDisplay(booking.status);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: booking.status == 'Menunggu Konfirmasi'
              ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: booking.status == 'Menunggu Konfirmasi' ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BARIS PASIEN & STATUS
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPatientAvatar(booking.patientPhoto, booking.patientName),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.patientName?.isNotEmpty == true
                            ? booking.patientName!
                            : 'Pasien HeartCare',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Dipesan: ${_formatBookingTime(booking.createdAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.8),
            const SizedBox(height: 12),

            // INFORMASI JADWAL
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event_rounded, size: 15, color: Color(0xFF0284C7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.dateDisplay,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF0284C7)),
                      const SizedBox(width: 8),
                      Text(
                        'Pukul ${booking.timeSlot} WIB',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${booking.durationMinutes} Menit',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (booking.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note_alt_outlined, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            booking.notes!,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // TOMBOL AKSI BERDASARKAN STATUS
            _buildActionButtons(booking, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(DoctorBooking booking, bool isDark) {
    final status = booking.status.trim().toLowerCase();
    final isPending = status == 'menunggu konfirmasi' || status == 'pending';
    final isAccepted = status == 'diterima' || status == 'accepted' || status == 'booked';

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // TOMBOL DETAIL
        TextButton.icon(
          onPressed: () => _showBookingDetailModal(booking),
          icon: const Icon(Icons.info_outline_rounded, size: 16),
          label: const Text('Detail', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          style: TextButton.styleFrom(
            foregroundColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
        ),

        if (isPending) ...[
          const SizedBox(width: 6),
          // TOMBOL TOLAK
          OutlinedButton.icon(
            onPressed: () => _showRejectDialog(booking),
            icon: const Icon(Icons.close_rounded, size: 15),
            label: const Text('Tolak', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFFCA5A5)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 8),
          // TOMBOL TERIMA
          ElevatedButton.icon(
            onPressed: () => _handleAcceptBooking(booking),
            icon: const Icon(Icons.check_rounded, size: 15),
            label: const Text('Terima', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ] else if (isAccepted) ...[
          const SizedBox(width: 8),
          // TOMBOL TANDAI SELESAI
          ElevatedButton.icon(
            onPressed: () => _handleCompleteBooking(booking),
            icon: const Icon(Icons.task_alt_rounded, size: 15),
            label: const Text('Selesai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ],
    );
  }

  void _handleAcceptBooking(DoctorBooking booking) async {
    await BookingService.instance.updateBookingStatus(booking.id, 'Diterima');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Permintaan booking ${booking.patientName ?? "pasien"} berhasil disetujui.',
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleCompleteBooking(DoctorBooking booking) async {
    await BookingService.instance.updateBookingStatus(booking.id, 'Selesai');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Konsultasi bersama ${booking.patientName ?? "pasien"} telah ditandai Selesai.',
        ),
        backgroundColor: const Color(0xFF0284C7),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRejectDialog(DoctorBooking booking) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tolak Permintaan Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menolak booking dari ${booking.patientName ?? "pasien"} pada jam ${booking.timeSlot}?',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Alasan penolakan (opsional, misal: ada operasi darurat)',
                hintStyle: TextStyle(fontSize: 12),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext);
              await BookingService.instance.updateBookingStatus(
                booking.id,
                'Ditolak',
                rejectionReason: reasonController.text.trim(),
              );
              if (!mounted) return;
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Booking ditolak. Slot waktu kembali dibuka untuk pasien lain.'),
                  backgroundColor: Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Tolak Booking'),
          ),
        ],
      ),
    );
  }

  void _showBookingDetailModal(DoctorBooking booking) {
    final isDark = ThemeService.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildPatientAvatar(booking.patientPhoto, booking.patientName, size: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.patientName?.isNotEmpty == true
                            ? booking.patientName!
                            : 'Pasien HeartCare',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      if (booking.patientPhone?.isNotEmpty == true)
                        Text(
                          'No. HP: ${booking.patientPhone}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _detailRow('Status Booking', booking.status, isDark, isHighlight: true),
            _detailRow('Tanggal', booking.dateDisplay, isDark),
            _detailRow('Jam Konsultasi', '${booking.timeSlot} WIB', isDark),
            _detailRow('Durasi', '${booking.durationMinutes} Menit', isDark),
            _detailRow('Waktu Pesan', _formatBookingTime(booking.createdAt), isDark),
            if (booking.rejectionReason?.isNotEmpty == true)
              _detailRow('Alasan Penolakan', booking.rejectionReason!, isDark, isAlert: true),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KonsultasiDokterPage(
                            doctorId: widget.doctorId,
                            doctorName: widget.doctorName,
                            doctorSpecialty: widget.doctorSpecialty,
                            doctorPhoto: widget.doctorPhoto,
                            isDoctorView: true,
                            patientName: booking.patientName,
                            patientId: booking.patientId,
                            patientPhoto: booking.patientPhoto,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                    label: const Text('Chat Pasien'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isDark,
      {bool isHighlight = false, bool isAlert = false}) {
    Color valColor = isDark ? Colors.white : const Color(0xFF0F172A);
    if (isHighlight) valColor = const Color(0xFF0284C7);
    if (isAlert) valColor = const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                color: valColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBookingState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_rounded, size: 40, color: Color(0xFF0284C7)),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum Ada Booking Pasien',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Permintaan konsultasi yang masuk dari pasien akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // TAB 2: ATUR JADWAL PRAKTIK
  // ==========================================================================
  Widget _buildScheduleManagementTab(bool isDark) {
    final currentSchedule = BookingService.instance.getDoctorScheduleForDate(
      widget.doctorId,
      _selectedDateKey,
      doctorName: widget.doctorName,
    );

    final generatedSlots = BookingService.instance.generateSlots(
      durationMinutes: currentSchedule?.durationMinutes ?? 30,
      doctorId: widget.doctorId,
      dateKey: _selectedDateKey,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER & KALENDER HARI (Sen 1 s/d Min 7)
          _buildDayPickerStrip(isDark),

          const SizedBox(height: 16),

          // 2. KARTU STATUS PRAKTIK HARI INI
          _buildScheduleStatusCard(currentSchedule, isDark),

          const SizedBox(height: 16),

          // 3. PRATINJAU PEMBAGIAN SLOT KONSULTASI OTOMATIS
          _buildSlotPreviewSection(currentSchedule, generatedSlots, isDark),

          const SizedBox(height: 20),

          // 4. TOMBOL TAMBAH / SESUAIKAN JADWAL
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _showEditScheduleModal(currentSchedule),
              icon: const Icon(Icons.edit_calendar_rounded, size: 18),
              label: Text(
                currentSchedule != null
                    ? 'Ubah Jadwal Praktik Hari Ini'
                    : 'Tambah Jadwal Praktik Hari Ini',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 1,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 5. DAFTAR SEMUA JADWAL PRAKTIK TERDAFTAR
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Semua Jadwal Praktik Mingguan',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildAllSchedulesList(isDark),
        ],
      ),
    );
  }

  Widget _buildDayPickerStrip(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 15, color: Color(0xFF0284C7)),
                const SizedBox(width: 6),
                Text(
                  'September 2026',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Text(
              _selectedDateDisplay,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0284C7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: _defaultDays.map((d) {
            final isSelected = d['key'] == _selectedDateKey;
            final sched = BookingService.instance.getDoctorScheduleForDate(
              widget.doctorId,
              d['key']!,
              doctorName: widget.doctorName,
            );
            final bool hasActiveSchedule = sched?.isActive ?? true;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDateKey = d['key']!;
                        _selectedDateDisplay = d['full']!;
                        _selectedDayName = d['day']!;
                        _selectedDayNumber = d['num']!;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                              )
                            : null,
                        color: isSelected
                            ? null
                            : (isDark ? const Color(0xFF1E293B) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0284C7)
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            d['day']!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            d['num']!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasActiveSchedule
                                  ? (isSelected ? Colors.white : const Color(0xFF10B981))
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildScheduleStatusCard(DoctorPracticeSchedule? sched, bool isDark) {
    final bool isActive = sched?.isActive ?? true;
    final int startM = sched?.startMinutes ?? 480;
    final int endM = sched?.endMinutes ?? 720;
    final int dur = sched?.durationMinutes ?? 30;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? const Color(0xFF0284C7).withValues(alpha: 0.3)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8))
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                      color: isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isActive ? 'Praktik Dibuka' : 'Praktik Ditutup (Libur)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              Switch(
                value: isActive,
                activeThumbColor: const Color(0xFF10B981),
                onChanged: (val) async {
                  if (sched != null) {
                    await BookingService.instance.toggleScheduleActive(sched.id, val);
                  } else {
                    final newSched = DoctorPracticeSchedule(
                      id: 'sched_${widget.doctorId}_$_selectedDateKey',
                      doctorId: widget.doctorId,
                      doctorName: widget.doctorName,
                      dateKey: _selectedDateKey,
                      dateDisplay: _selectedDateDisplay,
                      dayName: _selectedDayName,
                      dayNumber: _selectedDayNumber,
                      isActive: val,
                    );
                    await BookingService.instance.savePracticeSchedule(newSched);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 0.8),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _miniInfoItem(
                  icon: Icons.access_time_rounded,
                  label: 'Jam Praktik',
                  value: '${BookingService.formatMinutes(startM)} – ${BookingService.formatMinutes(endM)} WIB',
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _miniInfoItem(
                  icon: Icons.timer_outlined,
                  label: 'Durasi Sesi',
                  value: '$dur Menit',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          if (sched?.hasBreak == true && sched?.breakStartMinutes != null) ...[
            const SizedBox(height: 8),
            _miniInfoItem(
              icon: Icons.coffee_rounded,
              label: 'Jeda / Istirahat',
              value: '${BookingService.formatMinutes(sched!.breakStartMinutes!)} – ${BookingService.formatMinutes(sched.breakEndMinutes!)} WIB',
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF0284C7)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSlotPreviewSection(
    DoctorPracticeSchedule? sched,
    List<TimeSlotItem> slots,
    bool isDark,
  ) {
    final bool isActive = sched?.isActive ?? true;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pembagian Slot Konsultasi (Tampilan Pasien)',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${slots.length} Slot',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Sistem otomatis membagi rentang waktu praktik menjadi slot konsultasi.',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),

          if (!isActive || slots.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Tidak ada slot konsultasi (Praktik Libur).',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots.map((slot) {
                final isBooked = slot.isBooked;

                return Container(
                  width: 155,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isBooked
                        ? (isDark ? const Color(0xFF331D24) : const Color(0xFFFEE2E2))
                        : (isDark ? const Color(0xFF0F2B26) : const Color(0xFFECFDF5)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isBooked
                          ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                          : const Color(0xFF10B981).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            slot.label,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isBooked
                                  ? const Color(0xFFEF4444)
                                  : (isDark ? const Color(0xFF34D399) : const Color(0xFF059669)),
                            ),
                          ),
                          Icon(
                            isBooked ? Icons.lock_outline_rounded : Icons.check_circle_outline,
                            size: 13,
                            color: isBooked ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isBooked
                            ? (slot.booking?.patientName ?? 'Sudah Dibooking')
                            : 'Tersedia',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isBooked
                              ? const Color(0xFFEF4444)
                              : (isDark ? const Color(0xFF34D399) : const Color(0xFF059669)),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAllSchedulesList(bool isDark) {
    final allSchedules = BookingService.instance.getDoctorSchedules(
      widget.doctorId,
      doctorName: widget.doctorName,
    );

    if (allSchedules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text('Belum ada jadwal praktik tersimpan.'),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allSchedules.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final sched = allSchedules[index];
        final isActive = sched.isActive;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: (isActive ? const Color(0xFF0284C7) : const Color(0xFF94A3B8))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    sched.dayName.isNotEmpty ? sched.dayName : 'Jadwal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: isActive ? const Color(0xFF0284C7) : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sched.dateDisplay,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${BookingService.formatMinutes(sched.startMinutes)}–${BookingService.formatMinutes(sched.endMinutes)} WIB • Sesi ${sched.durationMinutes} Menit',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isActive,
                activeThumbColor: const Color(0xFF10B981),
                onChanged: (val) {
                  BookingService.instance.toggleScheduleActive(sched.id, val);
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Ubah Jadwal',
                onPressed: () => _showEditScheduleModal(sched),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // MODAL FORM ATUR / TAMBAH JADWAL PRAKTIK
  // ==========================================================================
  void _showEditScheduleModal(DoctorPracticeSchedule? existing) {
    final isDark = ThemeService.isDarkMode;

    int startM = existing?.startMinutes ?? 480; // 08:00
    int endM = existing?.endMinutes ?? 720;     // 12:00
    int duration = existing?.durationMinutes ?? 30;
    bool hasBreak = existing?.hasBreak ?? false;
    int breakStartM = existing?.breakStartMinutes ?? 720;
    int breakEndM = existing?.breakEndMinutes ?? 780;
    bool active = existing?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Hitung estimasi slot yang dihasilkan
            int totalMinutes = endM - startM;
            if (hasBreak && breakEndM > breakStartM) {
              totalMinutes -= (breakEndM - breakStartM);
            }
            final estimatedSlots = totalMinutes > 0 ? (totalMinutes ~/ duration) : 0;

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      existing != null ? 'Ubah Jadwal Praktik' : 'Tambah Jadwal Praktik',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Atur rentang jam kerja dan durasi konsultasi untuk $_selectedDateDisplay',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // PILIHAN DURASI KONSULTASI
                    Text(
                      'Durasi Konsultasi per Sesi:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [15, 30, 45, 60].map((dur) {
                        final isSel = duration == dur;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: ChoiceChip(
                              label: Text('$dur Mnt'),
                              selected: isSel,
                              onSelected: (_) => setModalState(() => duration = dur),
                              selectedColor: const Color(0xFF0284C7),
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // JAM MULAI DAN JAM SELESAI
                    Row(
                      children: [
                        Expanded(
                          child: _timePickerButton(
                            label: 'Jam Mulai Praktik',
                            minutes: startM,
                            isDark: isDark,
                            onPick: (m) => setModalState(() => startM = m),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _timePickerButton(
                            label: 'Jam Selesai Praktik',
                            minutes: endM,
                            isDark: isDark,
                            onPick: (m) => setModalState(() => endM = m),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // PENGATURAN ISTIRAHAT / JEDA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sediakan Jam Istirahat / Jeda Praktik',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Switch(
                          value: hasBreak,
                          activeThumbColor: const Color(0xFF0284C7),
                          onChanged: (val) => setModalState(() => hasBreak = val),
                        ),
                      ],
                    ),

                    if (hasBreak) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _timePickerButton(
                              label: 'Mulai Istirahat',
                              minutes: breakStartM,
                              isDark: isDark,
                              onPick: (m) => setModalState(() => breakStartM = m),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _timePickerButton(
                              label: 'Selesai Istirahat',
                              minutes: breakEndM,
                              isDark: isDark,
                              onPick: (m) => setModalState(() => breakEndM = m),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // LIVE BANNER ESTIMASI SLOT
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF0284C7), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Rentang ${BookingService.formatMinutes(startM)}–${BookingService.formatMinutes(endM)} dengan durasi $duration menit akan menghasilkan $estimatedSlots slot konsultasi untuk pasien.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? const Color(0xFFBAE6FD) : const Color(0xFF0369A1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TOMBOL SIMPAN
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (endM <= startM) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Jam selesai harus lebih besar dari jam mulai.'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          Navigator.pop(context);

                          final scheduleId = existing?.id ??
                              'sched_${widget.doctorId}_$_selectedDateKey';

                          final newSchedule = DoctorPracticeSchedule(
                            id: scheduleId,
                            doctorId: widget.doctorId,
                            doctorName: widget.doctorName,
                            dateKey: _selectedDateKey,
                            dateDisplay: _selectedDateDisplay,
                            dayName: _selectedDayName,
                            dayNumber: _selectedDayNumber,
                            startMinutes: startM,
                            endMinutes: endM,
                            durationMinutes: duration,
                            hasBreak: hasBreak,
                            breakStartMinutes: hasBreak ? breakStartM : null,
                            breakEndMinutes: hasBreak ? breakEndM : null,
                            isActive: active,
                            updatedAt: DateTime.now(),
                          );

                          final messenger = ScaffoldMessenger.of(context);
                          await BookingService.instance.savePracticeSchedule(newSchedule);

                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Jadwal praktik $_selectedDateDisplay berhasil disimpan.',
                              ),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Simpan Jadwal Praktik',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _timePickerButton({
    required String label,
    required int minutes,
    required bool isDark,
    required Function(int) onPick,
  }) {
    final timeStr = BookingService.formatMinutes(minutes);

    return InkWell(
      onTap: () async {
        final initialTime = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
        final picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
        );
        if (picked != null) {
          onPick(picked.hour * 60 + picked.minute);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Color(0xFF0284C7)),
                const SizedBox(width: 4),
                Text(
                  '$timeStr WIB',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // HELPER WIDGETS
  // ==========================================================================
  Widget _buildPatientAvatar(String? photo, String? name, {double size = 42}) {
    final initial = (name?.isNotEmpty == true) ? name![0].toUpperCase() : 'P';

    if (photo != null && photo.trim().isNotEmpty) {
      final trimmed = photo.trim();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.network(
            trimmed,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _avatarFallback(initial, size),
          ),
        );
      }
      if (trimmed.startsWith('data:image') || trimmed.length > 200) {
        try {
          String cleanBase64 = trimmed;
          if (cleanBase64.contains(',')) {
            cleanBase64 = cleanBase64.split(',').last;
          }
          final bytes = base64Decode(cleanBase64);
          return ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: Image.memory(
              bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _avatarFallback(initial, size),
            ),
          );
        } catch (_) {}
      }
      if (trimmed.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.asset(
            trimmed,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _avatarFallback(initial, size),
          ),
        );
      }
      if (!kIsWeb &&
          (trimmed.startsWith('/') ||
              trimmed.contains(':\\') ||
              trimmed.contains(':/'))) {
        try {
          final f = File(trimmed);
          if (f.existsSync()) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: Image.file(
                f,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _avatarFallback(initial, size),
              ),
            );
          }
        } catch (_) {}
      }
    }

    return _avatarFallback(initial, size);
  }

  Widget _avatarFallback(String initial, double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorAvatarImage(String photo, {double size = 36}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: DoctorService.buildDoctorImage(
        photo,
        width: size,
        height: size,
      ),
    );
  }

  Color _getStatusColor(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'menunggu konfirmasi' || s == 'pending') {
      return const Color(0xFFF59E0B); // Amber / Kuning
    }
    if (s == 'diterima' || s == 'accepted' || s == 'booked') {
      return const Color(0xFF10B981); // Hijau Emerald
    }
    if (s == 'selesai' || s == 'completed') {
      return const Color(0xFF0284C7); // Biru Sky
    }
    if (s == 'ditolak' || s == 'rejected') {
      return const Color(0xFFEF4444); // Merah
    }
    return const Color(0xFF64748B); // Slate / Dibatalkan
  }

  String _getStatusDisplay(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'menunggu konfirmasi' || s == 'pending') return 'Menunggu Konfirmasi';
    if (s == 'diterima' || s == 'accepted' || s == 'booked') return 'Diterima';
    if (s == 'selesai' || s == 'completed') return 'Selesai';
    if (s == 'ditolak' || s == 'rejected') return 'Ditolak';
    if (s == 'dibatalkan' || s == 'cancelled') return 'Dibatalkan';
    return status;
  }

  String _formatBookingTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mnt yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    } else {
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }
}
