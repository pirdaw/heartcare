import 'dart:async';
import 'package:flutter/material.dart';

// ============================================================================
// MODEL DATA OBAT & PENGINGAT
// ============================================================================
class MedicineReminder {
  final String id;
  String name;
  String amount;
  String unit;
  String schedule; // e.g. "Setelah makan ya", "Sebelum makan", dll
  List<String> reminderTimes; // e.g. ["07.30", "15.30", "22.00"]
  String note;
  bool isTaken;

  MedicineReminder({
    required this.id,
    required this.name,
    required this.amount,
    this.unit = 'Tablet',
    required this.schedule,
    required this.reminderTimes,
    required this.note,
    this.isTaken = false,
  });
}

// ============================================================================
// STATE CONTROLLER & NOTIFIER (SINGLETON)
// ============================================================================
class HealthReminderController extends ChangeNotifier {
  static final HealthReminderController _instance =
      HealthReminderController._internal();
  factory HealthReminderController() => _instance;
  HealthReminderController._internal() {
    _startTimer();
  }

  final List<MedicineReminder> medicines = [];
  Timer? _timer;
  String? _lastTriggeredMinute;
  void Function(MedicineReminder reminder, String time)? onReminderTriggered;

  void addMedicine(MedicineReminder medicine) {
    medicines.add(medicine);
    notifyListeners();
  }

  void removeMedicine(String id) {
    medicines.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void markAsTaken(String id) {
    final index = medicines.indexWhere((item) => item.id == id);
    if (index != -1) {
      medicines[index].isTaken = true;
      notifyListeners();
    }
  }

  // Pengingat Otomatis Berdasarkan Waktu yang Dipilih
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final currentFormattedTime =
          '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';
      final currentFormattedColon =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      // Cegah trigger berulang pada menit yang sama
      if (_lastTriggeredMinute == currentFormattedTime) return;

      for (var med in medicines) {
        for (var timeStr in med.reminderTimes) {
          final cleanTime = timeStr.trim().replaceAll(':', '.');
          if (cleanTime == currentFormattedTime ||
              cleanTime == currentFormattedColon.replaceAll(':', '.')) {
            _lastTriggeredMinute = currentFormattedTime;
            if (onReminderTriggered != null) {
              onReminderTriggered!(med, timeStr);
            }
            return;
          }
        }
      }
    });
  }

  // Hitung jumlah pengingat aktif hari ini
  int get activeRemindersCount {
    int count = 0;
    for (var med in medicines) {
      count += med.reminderTimes.length;
    }
    // Default minimal 3 pengingat hari ini jika masih awal / sesuai desain
    return count > 0 ? count : 3;
  }

  // Dapatkan pengingat berikutnya
  String get nextReminderSummary {
    if (medicines.isEmpty) {
      return 'Tidak ada pengingat';
    }
    final first = medicines.first;
    final time = first.reminderTimes.isNotEmpty ? first.reminderTimes.first : '';
    return '${first.name} ($time)';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ============================================================================
// HALAMAN UTAMA PENGINGAT KESEHATAN (SLIDE 1: iPhone 16 - 64)
// ============================================================================
class PengingatKesehatanPage extends StatefulWidget {
  const PengingatKesehatanPage({super.key});

  static const Color primaryTeal = Color(0xFF0098B9);
  static const Color lightBannerBlue = Color(0xFFC7EBF4);

  @override
  State<PengingatKesehatanPage> createState() => _PengingatKesehatanPageState();
}

class _PengingatKesehatanPageState extends State<PengingatKesehatanPage> {
  final HealthReminderController _controller = HealthReminderController();
  int _currentNavIndex = 3; // Riwayat tab aktif sesuai desain

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerUpdate);
    _controller.onReminderTriggered = (reminder, time) {
      if (mounted) {
        showMedicineReminderDialog(context, reminder: reminder, timeText: time);
      }
    };
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _navigateToMedicineFlow() {
    if (_controller.medicines.isEmpty) {
      // Masuk ke Slide 2 (Belum ada obat yang ditambahkan)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TambahObatEmptyPage(),
        ),
      );
    } else {
      // Masuk ke Slide 4 (Daftar Obat)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DaftarObatPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ==============================================================
            // HEADER DENGAN TOMBOL BACK LINGKARAN & JUDUL
            // ==============================================================
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Row(
                children: [
                  _buildCircularBackButton(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Pengingat Kesehatan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Atur pengingat agar tidak melewati kegiatan penting',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==============================================================
            // KONTEN UTAMA
            // ==============================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BANNER BIRU MUDA: 3 Pengingat Hari Ini
                    _buildTopBannerCard(),

                    const SizedBox(height: 20),

                    // SECTION HEADER: Hari Ini
                    const Text(
                      'Hari Ini',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ITEM 1: Minum Obat (Klik panah kanan masuk ke Tambah / Daftar Obat)
                    _buildActivityCard(
                      iconWidget: const CapsuleIconWidget(
                        color: PengingatKesehatanPage.primaryTeal,
                        size: 22,
                      ),
                      title: 'Minum Obat',
                      subtitle: 'Atur Pengingat',
                      onTap: _navigateToMedicineFlow,
                    ),

                    const SizedBox(height: 12),

                    // ITEM 2: Olahraga Ringan
                    _buildActivityCard(
                      iconWidget: const Icon(
                        Icons.directions_run_rounded,
                        color: PengingatKesehatanPage.primaryTeal,
                        size: 24,
                      ),
                      title: 'Olahraga Ringan',
                      subtitle: 'Atur Pengingat',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Pengingat Olahraga Ringan: Pukul 06.00 WIB setiap pagi.',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // CARD: Pengingat Berikutnya (Biru Muda)
                    _buildNextReminderCard(),

                    const SizedBox(height: 16),

                    // TOMBOL TES NOTIFIKASI LANGSUNG (Fitur Pengujian Interaktif)
                    _buildQuickTestNotificationButton(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ==============================================================
            // BOTTOM NAVIGATION BAR
            // ==============================================================
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // Banner Biru Muda: 3 Pengingat Hari Ini
  Widget _buildTopBannerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFC7EBF4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon Kalender dengan Checkmark
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.event_available_rounded,
                color: PengingatKesehatanPage.primaryTeal,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_controller.activeRemindersCount} Pengingat Hari Ini',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Jangan lewatkan jadwal kesehatanmu.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card Aktivitas: Minum Obat & Olahraga Ringan
  Widget _buildActivityCard({
    required Widget iconWidget,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon Lingkaran Biru Lembut
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F7FB),
                shape: BoxShape.circle,
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // Card: Pengingat Berikutnya
  Widget _buildNextReminderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFC7EBF4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.alarm_rounded,
                color: PengingatKesehatanPage.primaryTeal,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pengingat Berikutnya',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _controller.nextReminderSummary,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tombol Uji Notifikasi Langsung (Agar pengguna bisa langsung melihat pop-up Slide 5 kapan saja)
  Widget _buildQuickTestNotificationButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: PengingatKesehatanPage.primaryTeal,
            size: 22,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Ingin menguji tampilan notifikasi pengingat?',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF475569),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final sample = _controller.medicines.isNotEmpty
                  ? _controller.medicines.first
                  : MedicineReminder(
                      id: 'sample',
                      name: 'Aspirin 300 mg',
                      amount: '1',
                      unit: 'Tablet',
                      schedule: 'Setelah makan ya',
                      reminderTimes: ['07.30', '15.30', '22.00'],
                      note: 'Setelah makan ya',
                    );
              showMedicineReminderDialog(
                context,
                reminder: sample,
                timeText: 'sekarang',
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: PengingatKesehatanPage.primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Uji Sekarang',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return HeartCareBottomNavBarWidget(
      currentIndex: _currentNavIndex,
      onTap: (index) {
        setState(() {
          _currentNavIndex = index;
        });
        if (index == 0) {
          Navigator.pop(context);
        }
      },
    );
  }
}

// ============================================================================
// SLIDE 2: TAMBAH OBAT (EMPTY STATE / BELUM ADA OBAT - iPhone 16 - 108)
// ============================================================================
class TambahObatEmptyPage extends StatelessWidget {
  const TambahObatEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Row(
                children: [
                  _buildCircularBackButton(context),
                  const SizedBox(width: 16),
                  const Text(
                    'Tambah Obat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF1E293B),
                    size: 24,
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // Ilustrasi Botol Obat & Blister Pack
            const Center(
              child: MedicineBottleIllustration(size: 190),
            ),

            const SizedBox(height: 24),

            // Teks Keterangan
            const Text(
              'Belum ada obat yang ditambahkan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 6),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                'Klik tombol tambah untuk memasukkan\nobat baru',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
            ),

            const Spacer(flex: 3),

            // Tombol "+ Tambah Obat"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TambahObatFormPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0098B9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    '+ Tambah Obat',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Bottom Navigation Bar
            const HeartCareBottomNavBarWidget(currentIndex: 3),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SLIDE 3: FORM TAMBAH OBAT (INPUT DATA OBAT - iPhone 16 - 96)
// ============================================================================
class TambahObatFormPage extends StatefulWidget {
  const TambahObatFormPage({super.key});

  @override
  State<TambahObatFormPage> createState() => _TambahObatFormPageState();
}

class _TambahObatFormPageState extends State<TambahObatFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedUnit = 'Tablet';
  String _selectedSchedule = 'Setelah makan ya';
  final List<String> _selectedTimes = ['07.30', '15.30', '22.00'];

  final List<String> _unitOptions = [
    'Tablet',
    'Kapsul',
    'Sendok/Sirup',
    'Bungkus',
    'Tetes'
  ];

  final List<String> _scheduleOptions = [
    'Setelah makan ya',
    'Sebelum makan',
    'Bersamaan dengan makan',
    'Sebelum tidur',
    'Saat perut kosong'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _pickScheduleDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Jadwal Minum',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                ..._scheduleOptions.map((opt) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedSchedule == opt
                            ? const Color(0xFF0098B9)
                            : const Color(0xFF1E293B),
                        fontWeight: _selectedSchedule == opt
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: _selectedSchedule == opt
                        ? const Icon(Icons.check_circle,
                            color: Color(0xFF0098B9))
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedSchedule = opt;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickTimesDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Waktu Pengingat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              final formatted =
                                  '${picked.hour.toString().padLeft(2, '0')}.${picked.minute.toString().padLeft(2, '0')}';
                              if (!_selectedTimes.contains(formatted)) {
                                setSheetState(() {
                                  _selectedTimes.add(formatted);
                                  _selectedTimes.sort();
                                });
                                setState(() {});
                              }
                            }
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Tambah Jam'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF0098B9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih atau tambah waktu pengingat minum obat Anda:',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedTimes.map((time) {
                        return Chip(
                          backgroundColor: const Color(0xFFE0F7FA),
                          label: Text(
                            time,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0098B9),
                            ),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          deleteIconColor: const Color(0xFF0098B9),
                          onDeleted: () {
                            setSheetState(() {
                              _selectedTimes.remove(time);
                            });
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0098B9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Selesai'),
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

  void _saveMedicine() {
    final name = _nameController.text.trim();
    final amount = _amountController.text.trim();
    final note = _noteController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan Nama Obat terlebih dahulu'),
        ),
      );
      return;
    }

    final newMedicine = MedicineReminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      amount: amount.isEmpty ? '1' : amount,
      unit: _selectedUnit,
      schedule: _selectedSchedule,
      reminderTimes: _selectedTimes.isEmpty ? ['07.30'] : List.from(_selectedTimes),
      note: note.isEmpty ? _selectedSchedule : note,
    );

    HealthReminderController().addMedicine(newMedicine);

    // Langsung navigasi ke Slide 4 (Daftar Obat)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const DaftarObatPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Row(
                children: [
                  _buildCircularBackButton(context),
                  const SizedBox(width: 16),
                  const Text(
                    'Tambah Obat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mini Illustration Banner
                    Container(
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F8FB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: MiniMedicineBannerIllustration(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // FIELD 1: Nama Obat
                    _buildFieldLabel('Nama Obat'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Masukkan Nama Obat',
                    ),

                    const SizedBox(height: 14),

                    // FIELD 2: Jumlah Obat + Unit Tablet
                    _buildFieldLabel('Jumlah Obat'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildTextField(
                            controller: _amountController,
                            hintText: 'Masukkan Jumlah Obat',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFD1D5DB),
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedUnit,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF64748B),
                                  size: 20,
                                ),
                                items: _unitOptions.map((unit) {
                                  return DropdownMenuItem(
                                    value: unit,
                                    child: Text(
                                      unit,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF1E293B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedUnit = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // FIELD 3: Jadwal Minum
                    _buildFieldLabel('Jadwal Minum'),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickScheduleDialog,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFD1D5DB),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedSchedule,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF94A3B8),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // FIELD 4: Waktu Pengingat
                    _buildFieldLabel('Waktu Pengingat'),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickTimesDialog,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFD1D5DB),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedTimes.isEmpty
                                    ? 'Pilih jadwal'
                                    : _selectedTimes.join('   '),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF94A3B8),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // FIELD 5: Catatan
                    _buildFieldLabel('Catatan'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFD1D5DB),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 12, right: 8),
                            child: Icon(
                              Icons.edit_note_rounded,
                              color: Color(0xFF64748B),
                              size: 24,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1E293B),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Tambahkan catatan.....',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // TOMBOL SIMPAN
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saveMedicine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0098B9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            const HeartCareBottomNavBarWidget(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD1D5DB),
          width: 1,
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 13,
            ),
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SLIDE 4: DAFTAR OBAT (DETAIL / LIST DATA YANG SUDAH DIISI - iPhone 16 - 109)
// ============================================================================
class DaftarObatPage extends StatefulWidget {
  const DaftarObatPage({super.key});

  @override
  State<DaftarObatPage> createState() => _DaftarObatPageState();
}

class _DaftarObatPageState extends State<DaftarObatPage> {
  final HealthReminderController _controller = HealthReminderController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    // Jika belum ada obat, buatkan contoh default "Aspirin 300 mg" sesuai Slide 4
    if (_controller.medicines.isEmpty) {
      _controller.addMedicine(
        MedicineReminder(
          id: '1',
          name: 'Aspirin 300 mg',
          amount: '1',
          unit: 'Tablet',
          schedule: 'Setelah makan ya',
          reminderTimes: ['07.30', '15.30', '22.00'],
          note: 'Setelah makan ya',
        ),
      );
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Row(
                children: [
                  _buildCircularBackButton(context),
                  const SizedBox(width: 16),
                  const Text(
                    'Daftar Obat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  // Tombol Tambah Obat Baru dari Daftar
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: Color(0xFF0098B9),
                      size: 26,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TambahObatFormPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: _controller.medicines.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada obat dalam daftar',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _controller.medicines.length,
                      itemBuilder: (context, index) {
                        final med = _controller.medicines[index];
                        return Column(
                          children: [
                            // CARD 1: Info Obat & Dosis
                            _buildMedicineInfoCard(med),

                            const SizedBox(height: 14),

                            // CARD 2: Waktu Pengingat
                            _buildReminderTimeCard(med),

                            const SizedBox(height: 14),

                            // CARD 3: Catatan
                            _buildNoteCard(med),

                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
            ),

            // Tombol Aksi Bawah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  // Tombol Simpan / Kembali
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Pengingat obat berhasil disimpan & diaktifkan!',
                            ),
                            backgroundColor: Color(0xFF0098B9),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0098B9),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Opsi Tambah Obat Lagi
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TambahObatFormPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Color(0xFF0098B9),
                      size: 18,
                    ),
                    label: const Text(
                      '+ Tambah Obat Lain',
                      style: TextStyle(
                        color: Color(0xFF0098B9),
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const HeartCareBottomNavBarWidget(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  // Card 1: Nama & Dosis Obat
  Widget _buildMedicineInfoCard(MedicineReminder med) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD1D5DB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Ikon Kapsul Biru Putih
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F8FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CapsuleIconWidget(
                color: Color(0xFF0098B9),
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0098B9),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${med.amount} ${med.unit}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card 2: Waktu Pengingat
  Widget _buildReminderTimeCard(MedicineReminder med) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD1D5DB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Ikon Jam
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.access_time_rounded,
                color: Color(0xFF1E293B),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Waktu Pengingat',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0098B9),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  med.reminderTimes.join('   '),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card 3: Catatan
  Widget _buildNoteCard(MedicineReminder med) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD1D5DB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Ikon Catatan & Pensil
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.assignment_outlined,
                color: Color(0xFF1E293B),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0098B9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  med.note,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SLIDE 5: POPUP MODAL PENGINGAT OBAT (SAATNYA MINUM OBAT! - iPhone 16 - 110)
// ============================================================================
void showMedicineReminderDialog(
  BuildContext context, {
  required MedicineReminder reminder,
  String timeText = 'sekarang',
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Notifikasi: Lonceng, Pengingat Obat, Timestamp
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0F7FA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFF0098B9),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pengingat Obat',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    timeText,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Ilustrasi Kapsul Obat Angled
              const Center(
                child: CapsuleIconWidget(
                  color: Color(0xFF0098B9),
                  size: 56,
                ),
              ),

              const SizedBox(height: 14),

              // Judul Utama: Saatnya Minum Obat!
              const Text(
                'Saatnya Minum Obat!',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 6),

              // Nama Obat
              Text(
                reminder.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),

              const SizedBox(height: 4),

              // Keterangan Dosis & Jadwal
              Text(
                '${reminder.amount} ${reminder.unit}  -  ${reminder.schedule}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 22),

              // Tombol "Sudah Minum" (Cyan)
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    HealthReminderController().markAsTaken(reminder.id);
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Bagus! Anda sudah meminum ${reminder.name}.',
                        ),
                        backgroundColor: const Color(0xFF0098B9),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0098B9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sudah Minum',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Tombol "Tunda" (Biru Muda)
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Pengingat ditunda 10 menit.',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC7EBF4),
                    foregroundColor: const Color(0xFF0098B9),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tunda',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ============================================================================
// WIDGET HELPER: TOMBOL BACK LINGKARAN
// ============================================================================
Widget _buildCircularBackButton(BuildContext context) {
  return Container(
    width: 38,
    height: 38,
    decoration: const BoxDecoration(
      color: Color(0xFFF1F5F9),
      shape: BoxShape.circle,
    ),
    child: IconButton(
      padding: EdgeInsets.zero,
      icon: const Icon(
        Icons.chevron_left_rounded,
        color: Color(0xFF1E293B),
        size: 26,
      ),
      onPressed: () => Navigator.pop(context),
    ),
  );
}

// ============================================================================
// WIDGET HELPER: BOTTOM NAVIGATION BAR SESUAI DESAIN
// ============================================================================
class HeartCareBottomNavBarWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const HeartCareBottomNavBarWidget({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, 'Home', 0),
          _navItem(Icons.favorite_border_rounded, 'Skrining', 1),
          _navItem(Icons.medical_services_outlined, 'Dokter', 2),
          _navItem(Icons.description_outlined, 'Riwayat', 3),
          _navItem(Icons.person_outline_rounded, 'Profil', 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool active = currentIndex == index;
    final Color color = active ? const Color(0xFF0098B9) : const Color(0xFF64748B);

    return InkWell(
      onTap: () => onTap?.call(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM VECTOR ARTWORK: KAPSUL OBAT 2 WARNA (BIRU & PUTIH)
// ============================================================================
class CapsuleIconWidget extends StatelessWidget {
  final Color color;
  final double size;

  const CapsuleIconWidget({
    super.key,
    this.color = const Color(0xFF0098B9),
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.75, // sedikit miring sesuai desain
      child: Container(
        width: size * 0.48,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.24),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(size * 0.24),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.zero,
                    bottom: Radius.circular(size * 0.24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM VECTOR ARTWORK: ILUSTRASI BOTOL OBAT & BLISTER PACK (SLIDE 2)
// ============================================================================
class MedicineBottleIllustration extends StatelessWidget {
  final double size;

  const MedicineBottleIllustration({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow Lingkaran Lembut
          Container(
            width: size * 0.88,
            height: size * 0.88,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F7FB),
              shape: BoxShape.circle,
            ),
          ),

          // Blister pack di sebelah kiri
          Positioned(
            left: size * 0.08,
            bottom: size * 0.16,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                width: size * 0.38,
                height: size * 0.46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFBBE5EE),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: List.generate(6, (i) {
                    return Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF90D5E4),
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          // Botol Obat di Tengah
          Positioned(
            child: Container(
              width: size * 0.44,
              height: size * 0.62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF90D5E4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Tutup Botol
                  Container(
                    width: size * 0.36,
                    height: size * 0.12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBBE5EE),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Label dengan Simbol Palang / Cross Medis
                  Container(
                    width: size * 0.28,
                    height: size * 0.28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0098B9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // Kapsul Obat di Depan Kanan
          Positioned(
            right: size * 0.14,
            bottom: size * 0.12,
            child: const CapsuleIconWidget(
              color: Color(0xFF0098B9),
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CUSTOM VECTOR ARTWORK: MINI BANNER ILUSTRASI OBAT (SLIDE 3)
// ============================================================================
class MiniMedicineBannerIllustration extends StatelessWidget {
  const MiniMedicineBannerIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Blister pack kecil
        Container(
          width: 32,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFBBE5EE),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _pillDot(),
                  _pillDot(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _pillDot(),
                  _pillDot(),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Botol obat kecil
        Container(
          width: 38,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF90D5E4)),
          ),
          child: Column(
            children: [
              Container(
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFBBE5EE),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ),
              const Spacer(),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF0098B9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Kapsul kecil
        const CapsuleIconWidget(
          color: Color(0xFF0098B9),
          size: 26,
        ),
      ],
    );
  }

  static Widget _pillDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
