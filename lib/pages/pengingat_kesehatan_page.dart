import 'dart:async';
import 'package:flutter/material.dart';

// ============================================================================
// MODEL DATA PENGINGAT (OBAT & OLAHRAGA RINGAN)
// ============================================================================

/// Model Data Pengingat Obat
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

/// Model Data Pengingat Olahraga Ringan
class ExerciseReminder {
  final String id;
  String activityName; // e.g. "Joging", "Bersepeda", "Yoga", dll
  int durationMinutes; // e.g. 30 menit
  String reminderTime; // e.g. "07.30"
  String repeatFrequency; // e.g. "Setiap Hari", "3x Seminggu", dll
  List<String> repeatDays; // e.g. ["Senin", "Rabu", "Jumat"]
  String note; // e.g. "Setelah makan ya", "Setelah bangun tidur"
  bool isActive;

  ExerciseReminder({
    required this.id,
    required this.activityName,
    this.durationMinutes = 30,
    required this.reminderTime,
    this.repeatFrequency = 'Setiap Hari',
    this.repeatDays = const ['Setiap Hari'],
    this.note = 'Setelah makan ya',
    this.isActive = true,
  });
}

/// Model Pilihan Jenis Olahraga
class ExerciseActivityItem {
  final String name;
  final IconData icon;
  final String description;

  const ExerciseActivityItem({
    required this.name,
    required this.icon,
    required this.description,
  });
}

// ============================================================================
// STATE CONTROLLER & NOTIFIER TERPADU (SINGLETON)
// ============================================================================
class HealthReminderController extends ChangeNotifier {
  static final HealthReminderController _instance =
      HealthReminderController._internal();
  factory HealthReminderController() => _instance;
  HealthReminderController._internal();

  final List<MedicineReminder> medicines = [];
  final List<ExerciseReminder> exercises = [];

  Timer? _timer;
  String? _lastTriggeredMinute;

  // Callback notifikasi yang otomatis dipicu saat jam & jadwal cocok
  void Function(MedicineReminder reminder, String time)? onReminderTriggered;
  void Function(ExerciseReminder reminder, String time)?
      onExerciseReminderTriggered;

  // --- Operasi Obat ---
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

  // --- Operasi Olahraga ---
  void addExercise(ExerciseReminder exercise) {
    exercises.add(exercise);
    notifyListeners();
  }

  void updateExercise(ExerciseReminder exercise) {
    final index = exercises.indexWhere((item) => item.id == exercise.id);
    if (index != -1) {
      exercises[index] = exercise;
    } else {
      exercises.add(exercise);
    }
    notifyListeners();
  }

  void removeExercise(String id) {
    exercises.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Pengingat Otomatis Berdasarkan Waktu yang Dipilih (Real-time Timer)
  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final currentFormattedDot =
          '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';
      final currentFormattedColon =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      // Cegah trigger berulang pada menit yang sama
      if (_lastTriggeredMinute == currentFormattedDot) return;

      // 1. Cek Jadwal Minum Obat
      for (var med in medicines) {
        for (var timeStr in med.reminderTimes) {
          final cleanTime = timeStr.trim().replaceAll(':', '.');
          if (cleanTime == currentFormattedDot ||
              cleanTime == currentFormattedColon.replaceAll(':', '.')) {
            _lastTriggeredMinute = currentFormattedDot;
            if (onReminderTriggered != null) {
              onReminderTriggered!(med, timeStr);
            }
            return;
          }
        }
      }

      // 2. Cek Jadwal Olahraga Ringan
      for (var ex in exercises) {
        if (!ex.isActive) continue;
        final cleanExTime = ex.reminderTime
            .trim()
            .replaceAll(' WIB', '')
            .replaceAll(':', '.');
        if (cleanExTime == currentFormattedDot ||
            cleanExTime == currentFormattedColon.replaceAll(':', '.')) {
          _lastTriggeredMinute = currentFormattedDot;
          if (onExerciseReminderTriggered != null) {
            onExerciseReminderTriggered!(ex, ex.reminderTime);
          }
          return;
        }
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // Hitung jumlah pengingat aktif hari ini (kombinasi Obat + Olahraga)
  int get activeRemindersCount {
    int count = 0;
    for (var med in medicines) {
      count += med.reminderTimes.length;
    }
    for (var ex in exercises) {
      if (ex.isActive) {
        count += 1;
      }
    }
    // Jika masih awal/kosong, tampilkan 3 sesuai desain mockup iPhone 16 - 112
    return count > 0 ? count : 3;
  }

  // Ringkasan Pengingat Berikutnya (Terpadu antara Obat & Olahraga)
  String get nextReminderSummary {
    if (medicines.isEmpty && exercises.isEmpty) {
      return 'Tidak ada pengingat';
    }

    // Jika ada olahraga aktif
    if (exercises.isNotEmpty && exercises.first.isActive) {
      final ex = exercises.first;
      final cleanTime = ex.reminderTime.replaceAll(' WIB', '').trim();
      return '${ex.activityName} ($cleanTime WIB)';
    }

    // Jika ada obat
    if (medicines.isNotEmpty) {
      final first = medicines.first;
      final time =
          first.reminderTimes.isNotEmpty ? first.reminderTimes.first : '07.30';
      return '${first.name} ($time)';
    }

    return 'Tidak ada pengingat';
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}

// ============================================================================
// DAFTAR PILIHAN OLAHRAGA LENGKAP (SESUAI PERMINTAAN USER: BISA PILIH BANYAK OLAHRAGA)
// ============================================================================
const List<ExerciseActivityItem> kAvailableExerciseActivities = [
  ExerciseActivityItem(
    name: 'Joging',
    icon: Icons.directions_run_rounded,
    description: 'Lari santai untuk meningkatkan kapasitas paru dan jantung',
  ),
  ExerciseActivityItem(
    name: 'Bersepeda',
    icon: Icons.directions_bike_rounded,
    description: 'Mengayuh santai, ramah sendi dan melatih sirkulasi darah',
  ),
  ExerciseActivityItem(
    name: 'Yoga',
    icon: Icons.self_improvement_rounded,
    description: 'Latihan pernapasan dan relaksasi untuk menurunkan stres',
  ),
  ExerciseActivityItem(
    name: 'Jalan Santai',
    icon: Icons.directions_walk_rounded,
    description: 'Jalan kaki ringan di pagi atau sore hari selama 20-30 menit',
  ),
  ExerciseActivityItem(
    name: 'Senam Jantung Sehat',
    icon: Icons.favorite_rounded,
    description: 'Gerakan ritmik terstruktur khusus memelihara denyut jantung',
  ),
  ExerciseActivityItem(
    name: 'Peregangan (Stretching)',
    icon: Icons.accessibility_new_rounded,
    description: 'Melenturkan otot kaku dan melancarkan aliran pembuluh darah',
  ),
  ExerciseActivityItem(
    name: 'Renang Ringan',
    icon: Icons.pool_rounded,
    description: 'Aktivitas air berdaya apung tinggi yang aman bagi jantung',
  ),
  ExerciseActivityItem(
    name: 'Senam Aerobik Ringan',
    icon: Icons.fitness_center_rounded,
    description: 'Gerakan aerobik santai di rumah dengan tempo musik teratur',
  ),
];

// ============================================================================
// SLIDE 1: HALAMAN UTAMA PENGINGAT KESEHATAN (iPhone 16 - 112)
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
  int _currentNavIndex = 3; // Tab Riwayat aktif sesuai desain

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerUpdate);
    _controller.startTimer();

    // Listener pemicu notifikasi otomatis untuk Obat
    _controller.onReminderTriggered = (reminder, time) {
      if (mounted) {
        showModernMedicineReminderDialog(
          context,
          reminder: reminder,
          timeText: time,
        );
      }
    };

    // Listener pemicu notifikasi otomatis untuk Olahraga
    _controller.onExerciseReminderTriggered = (exercise, time) {
      if (mounted) {
        showModernExerciseReminderDialog(
          context,
          reminder: exercise,
          timeText: time,
        );
      }
    };
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.stopTimer();
    super.dispose();
  }

  // Navigasi ke Alur Minum Obat
  void _navigateToMedicineFlow() {
    if (_controller.medicines.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TambahObatEmptyPage(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DaftarObatPage(),
        ),
      );
    }
  }

  // Navigasi ke Alur Olahraga Ringan
  void _navigateToExerciseFlow() {
    if (_controller.exercises.isEmpty) {
      // Masuk ke Slide 2: Tambah Pengingat (Intro Olahraga Ringan)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TambahOlahragaIntroPage(),
        ),
      );
    } else {
      // Masuk ke Slide 4: Atur Pengingat (Ringkasan Olahraga yang sudah diisi)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AturPengingatOlahragaPage(
            reminder: _controller.exercises.first,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasExercise = _controller.exercises.isNotEmpty;
    final String exerciseSubtitle = hasExercise
        ? '${_controller.exercises.first.activityName} • ${_controller.exercises.first.durationMinutes} mnt'
        : 'Atur Pengingat';

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
                  buildCircularBackButton(context),
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

                    // ITEM 1: Minum Obat
                    _buildActivityCard(
                      iconWidget: const CapsuleIconWidget(
                        color: PengingatKesehatanPage.primaryTeal,
                        size: 22,
                      ),
                      title: 'Minum Obat',
                      subtitle: _controller.medicines.isEmpty
                          ? 'Atur Pengingat'
                          : '${_controller.medicines.length} Obat Aktif',
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
                      subtitle: exerciseSubtitle,
                      onTap: _navigateToExerciseFlow,
                    ),

                    const SizedBox(height: 14),

                    // CARD: Pengingat Berikutnya (Biru Muda)
                    _buildNextReminderCard(),

                    const SizedBox(height: 18),

                    // QUICK TEST NOTIFIKASI INTERAKTIF (Obat & Olahraga)
                    _buildInteractiveTestNotificationCard(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ==============================================================
            // BOTTOM NAVIGATION BAR
            // ==============================================================
            HeartCareBottomNavBarWidget(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                setState(() => _currentNavIndex = index);
                if (index == 0) Navigator.pop(context);
              },
            ),
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
                      Expanded(
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
              color: Colors.white.withOpacity(0.9),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tombol Uji Pop-up Notifikasi (Desain Baru yang Lebih Menarik)
  Widget _buildInteractiveTestNotificationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.notifications_active_outlined,
                color: PengingatKesehatanPage.primaryTeal,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Uji Tampilan Notifikasi Pengingat',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Klik tombol di bawah untuk melihat tampilan notifikasi pop-up modern:',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final sampleMedicine = _controller.medicines.isNotEmpty
                        ? _controller.medicines.first
                        : MedicineReminder(
                            id: 'sample-med',
                            name: 'Aspirin 300 mg',
                            amount: '1',
                            unit: 'Tablet',
                            schedule: 'Setelah makan ya',
                            reminderTimes: ['07.30', '15.30', '22.00'],
                            note: 'Setelah makan ya',
                          );
                    showModernMedicineReminderDialog(
                      context,
                      reminder: sampleMedicine,
                      timeText: '07.30 WIB',
                    );
                  },
                  icon: const Icon(Icons.medication_rounded, size: 16),
                  label: const Text('Notif Obat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0098B9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final sampleExercise = _controller.exercises.isNotEmpty
                        ? _controller.exercises.first
                        : ExerciseReminder(
                            id: 'sample-ex',
                            activityName: 'Joging',
                            durationMinutes: 30,
                            reminderTime: '07.30 WIB',
                            repeatFrequency: 'Setiap Hari',
                            repeatDays: const ['Setiap Hari'],
                            note: 'Setelah makan ya',
                          );
                    showModernExerciseReminderDialog(
                      context,
                      reminder: sampleExercise,
                      timeText: '07.30 WIB',
                    );
                  },
                  icon: const Icon(Icons.directions_run_rounded, size: 16),
                  label: const Text('Notif Olahraga'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC7EBF4),
                    foregroundColor: const Color(0xFF0098B9),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SLIDE 2: TAMBAH PENGINGAT (INTRO / EMPTY STATE OLAHRAGA - iPhone 16 - 113)
// ============================================================================
class TambahOlahragaIntroPage extends StatelessWidget {
  const TambahOlahragaIntroPage({super.key});

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
                  buildCircularBackButton(context),
                  const SizedBox(width: 16),
                  const Text(
                    'Tambah Pengingat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 14),

                    // Ilustrasi Vektor Pelari Cantik
                    const Center(
                      child: ExerciseRunnerCircularIllustration(size: 175),
                    ),

                    const SizedBox(height: 20),

                    // Judul & Subtitle
                    const Text(
                      'Olahraga Ringan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Jaga tubuh tetap bugar dengan\nolahraga ringan secara rutin',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Kartu Manfaat (Background Biru Muda Cyan)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC7EBF4).withOpacity(0.65),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFB5E4F0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text(
                                '💖',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Manfaat',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0098B9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _benefitBullet('Meningkatkan daya tahan tubuh'),
                          const SizedBox(height: 4),
                          _benefitBullet('Menjaga Kesehatan Jantung'),
                          const SizedBox(height: 4),
                          _benefitBullet('Mengurangi Stres'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Tombol "Atur Pengingat"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TambahOlahragaFormPage(),
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
                    'Atur Pengingat',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            const HeartCareBottomNavBarWidget(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  static Widget _benefitBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            color: Color(0xFF334155),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SLIDE 3: FORM TAMBAH PENGINGAT OLAHRAGA (iPhone 16 - 114)
// ============================================================================
class TambahOlahragaFormPage extends StatefulWidget {
  const TambahOlahragaFormPage({super.key});

  @override
  State<TambahOlahragaFormPage> createState() => _TambahOlahragaFormPageState();
}

class _TambahOlahragaFormPageState extends State<TambahOlahragaFormPage> {
  // Pilihan Jenis Olahraga (bisa pilih banyak olahraga) - Awalnya belum dipilih
  String? _selectedActivity;
  int _selectedDurationMinutes = 30; // default 30 menit
  String? _selectedTime; // Awalnya null -> menampilkan placeholder "Pilih Jam"
  String? _selectedSchedule; // Awalnya null -> menampilkan placeholder "Pengulangan"
  List<String> _selectedDays = [];
  final TextEditingController _noteController =
      TextEditingController(); // Awalnya kosongan

  final List<ExerciseActivityItem> _activities = List.from(kAvailableExerciseActivities);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Dialog Pemilihan Frekuensi & Hari (seminggu brp kali & hari apa aja)
  void _openScheduleBottomSheet() {
    final allDays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    List<String> tempDays = List.from(_selectedDays);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isEveryDay = tempDays.contains('Setiap Hari') ||
                tempDays.length == allDays.length;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Jadwal & Pengulangan Olahraga',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pilih seberapa sering dan di hari apa saja Anda ingin diingatkan:',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),

                    // Opsi Cepat
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Setiap Hari (7x seminggu)'),
                          selected: isEveryDay,
                          selectedColor: const Color(0xFF0098B9),
                          labelStyle: TextStyle(
                            color: isEveryDay ? Colors.white : const Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                tempDays = ['Setiap Hari'];
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Hari Kerja (Sen - Jum)'),
                          selected: !tempDays.contains('Setiap Hari') &&
                              tempDays.length == 5 &&
                              tempDays.contains('Senin') &&
                              tempDays.contains('Jumat'),
                          selectedColor: const Color(0xFF0098B9),
                          labelStyle: TextStyle(
                            color: (!tempDays.contains('Setiap Hari') &&
                                    tempDays.length == 5 &&
                                    tempDays.contains('Senin') &&
                                    tempDays.contains('Jumat'))
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              tempDays = [
                                'Senin',
                                'Selasa',
                                'Rabu',
                                'Kamis',
                                'Jumat'
                              ];
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('3x Seminggu (Sen, Rab, Jum)'),
                          selected: tempDays.length == 3 &&
                              tempDays.contains('Senin') &&
                              tempDays.contains('Rabu') &&
                              tempDays.contains('Jumat'),
                          selectedColor: const Color(0xFF0098B9),
                          labelStyle: TextStyle(
                            color: (tempDays.length == 3 &&
                                    tempDays.contains('Senin') &&
                                    tempDays.contains('Rabu') &&
                                    tempDays.contains('Jumat'))
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              tempDays = ['Senin', 'Rabu', 'Jumat'];
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      'Pilih Hari Spesifik:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Chip Hari
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allDays.map((day) {
                        final isSelected =
                            tempDays.contains(day) || tempDays.contains('Setiap Hari');
                        return FilterChip(
                          label: Text(day),
                          selected: isSelected,
                          selectedColor: const Color(0xFFC7EBF4),
                          checkmarkColor: const Color(0xFF0098B9),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF0098B9)
                                : const Color(0xFF475569),
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                          onSelected: (bool selected) {
                            setModalState(() {
                              if (tempDays.contains('Setiap Hari')) {
                                tempDays = List.from(allDays);
                              }
                              if (selected) {
                                if (!tempDays.contains(day)) tempDays.add(day);
                              } else {
                                tempDays.remove(day);
                              }
                              if (tempDays.length == allDays.length) {
                                tempDays = ['Setiap Hari'];
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (tempDays.isEmpty) {
                              _selectedDays = ['Setiap Hari'];
                              _selectedSchedule = 'Setiap Hari';
                            } else if (tempDays.contains('Setiap Hari') ||
                                tempDays.length == 7) {
                              _selectedDays = ['Setiap Hari'];
                              _selectedSchedule = 'Setiap Hari';
                            } else {
                              _selectedDays = tempDays;
                              _selectedSchedule =
                                  '${tempDays.join(', ')} (${tempDays.length}x seminggu)';
                            }
                          });
                          Navigator.pop(ctx);
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
                          'Terapkan Jadwal',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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

  // Dialog Pemilihan Waktu Pengingat & Durasi Olahraga
  void _openTimeAndDurationBottomSheet() {
    int tempDuration = _selectedDurationMinutes;
    String tempTime = _selectedTime ?? '07.30 WIB';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Waktu & Durasi Olahraga',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 1. Pilih Jam Mulai
                    const Text(
                      'Jam Mulai:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 7, minute: 30),
                        );
                        if (picked != null) {
                          final formatted =
                              '${picked.hour.toString().padLeft(2, '0')}.${picked.minute.toString().padLeft(2, '0')} WIB';
                          setModalState(() {
                            tempTime = formatted;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFF0098B9),
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              tempTime,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Ubah Jam',
                              style: TextStyle(
                                color: Color(0xFF0098B9),
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 2. Pilih Berapa Menit Olahraganya
                    const Text(
                      'Berapa Menit Melakukan Olahraga?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: [15, 20, 30, 45, 60].map((mins) {
                        final isSel = tempDuration == mins;
                        return ChoiceChip(
                          label: Text('$mins Menit'),
                          selected: isSel,
                          selectedColor: const Color(0xFF0098B9),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => tempDuration = mins);
                            }
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedTime = tempTime;
                            _selectedDurationMinutes = tempDuration;
                          });
                          Navigator.pop(ctx);
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
                          'Selesai',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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

  // Dialog Tambah Olahraga Kustom (Jika ingin olahraga lainnya)
  void _openAddCustomSportDialog() {
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Tambah Jenis Olahraga',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: textCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Contoh: Senam Lansia, Pilates...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = textCtrl.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _activities.add(
                      ExerciseActivityItem(
                        name: name,
                        icon: Icons.fitness_center_rounded,
                        description: 'Aktivitas olahraga kustom pilihan Anda',
                      ),
                    );
                    _selectedActivity = name;
                  });
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0098B9),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _saveExerciseReminder() {
    if (_selectedActivity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih jenis aktivitas olahraga terlebih dahulu'),
          backgroundColor: Color(0xFF0098B9),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final note = _noteController.text.trim();
    final time = _selectedTime ?? '07.30 WIB';
    final schedule = _selectedSchedule ?? 'Setiap Hari';
    final days = _selectedDays.isEmpty ? ['Setiap Hari'] : _selectedDays;

    final newExercise = ExerciseReminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      activityName: _selectedActivity!,
      durationMinutes: _selectedDurationMinutes,
      reminderTime: time,
      repeatFrequency: schedule,
      repeatDays: days,
      note: note.isEmpty ? 'Setelah makan ya' : note,
      isActive: true,
    );

    HealthReminderController().updateExercise(newExercise);

    // Navigasi ke Slide 4: Atur Pengingat (Detail yang sudah diisi)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AturPengingatOlahragaPage(reminder: newExercise),
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
                  buildCircularBackButton(context),
                  const SizedBox(width: 16),
                  const Text(
                    'Tambah Pengingat',
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
                    // Mini Illustration Banner (Pemandangan Lari Outdoor)
                    Container(
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F8FB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: ExerciseBannerIllustration(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SECTION 1: Jenis Aktivitas (bisa memilih banyak olahraga)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Jenis Aktivitas',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _openAddCustomSportDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Olahraga Lain'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF0098B9),
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // List Pilihan Olahraga Ringan
                    ..._activities.map((item) {
                      final isSelected = _selectedActivity == item.name;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedActivity = item.name;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFF0FAFC)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0098B9)
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F7FA),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      item.icon,
                                      color: const Color(0xFF0098B9),
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF0098B9)
                                          : const Color(0xFFCBD5E1),
                                      width: isSelected ? 6 : 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 14),

                    // SECTION 2: Jadwal Olahraga (Pengulangan & Hari)
                    const Text(
                      'Jadwal Olahraga',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _openScheduleBottomSheet,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
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
                                _selectedSchedule ?? 'Pengulangan',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _selectedSchedule != null
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFF94A3B8),
                                  fontWeight: _selectedSchedule != null
                                      ? FontWeight.w500
                                      : FontWeight.w400,
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

                    // SECTION 3: Waktu Pengingat & Durasi Olahraga
                    const Text(
                      'Waktu Pengingat',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _openTimeAndDurationBottomSheet,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
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
                                _selectedTime != null
                                    ? '$_selectedTime  •  $_selectedDurationMinutes menit'
                                    : 'Pilih Jam',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _selectedTime != null
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFF94A3B8),
                                  fontWeight: _selectedTime != null
                                      ? FontWeight.w600
                                      : FontWeight.w400,
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

                    // SECTION 4: Catatan
                    const Text(
                      'Catatan',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
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
                                hintText: 'Tambahkan catatan......',
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
                        onPressed: _saveExerciseReminder,
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
}

// ============================================================================
// SLIDE 4: ATUR PENGINGAT (RINGKASAN DATA OLAHRAGA - iPhone 16 - 115)
// ============================================================================
class AturPengingatOlahragaPage extends StatefulWidget {
  final ExerciseReminder reminder;

  const AturPengingatOlahragaPage({
    super.key,
    required this.reminder,
  });

  @override
  State<AturPengingatOlahragaPage> createState() =>
      _AturPengingatOlahragaPageState();
}

class _AturPengingatOlahragaPageState extends State<AturPengingatOlahragaPage> {
  late ExerciseReminder _reminder;

  @override
  void initState() {
    super.initState();
    _reminder = widget.reminder;
  }

  IconData _getActivityIcon(String name) {
    for (var act in kAvailableExerciseActivities) {
      if (act.name.toLowerCase() == name.toLowerCase()) {
        return act.icon;
      }
    }
    return Icons.directions_run_rounded;
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
                  buildCircularBackButton(context),
                  const SizedBox(width: 16),
                  const Text(
                    'Atur Pengingat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  // Tombol Edit/Ubah Pengaturan
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF0098B9),
                      size: 22,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TambahOlahragaFormPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // CARD 1: Jenis Olahraga & Durasi Menit
                    _buildSummaryCard(
                      iconWidget: Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0F7FA),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _getActivityIcon(_reminder.activityName),
                            color: const Color(0xFF0098B9),
                            size: 26,
                          ),
                        ),
                      ),
                      title: _reminder.activityName,
                      subtitle: '${_reminder.durationMinutes} menit',
                      titleColor: const Color(0xFF0098B9),
                      titleBold: true,
                    ),

                    const SizedBox(height: 14),

                    // CARD 2: Waktu Pengingat
                    _buildSummaryCard(
                      iconWidget: Container(
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
                            size: 26,
                          ),
                        ),
                      ),
                      title: 'Waktu Pengingat',
                      subtitle: _reminder.reminderTime,
                      subtitleBold: true,
                      titleColor: const Color(0xFF0098B9),
                    ),

                    const SizedBox(height: 14),

                    // CARD 3: Pengulangan (Jadwal Hari)
                    _buildSummaryCard(
                      iconWidget: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.calendar_month_outlined,
                            color: Color(0xFF1E293B),
                            size: 26,
                          ),
                        ),
                      ),
                      title: 'Pengulangan',
                      subtitle: _reminder.repeatFrequency,
                      subtitleBold: true,
                      titleColor: const Color(0xFF0098B9),
                    ),

                    const SizedBox(height: 14),

                    // CARD 4: Catatan
                    _buildSummaryCard(
                      iconWidget: Container(
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
                            size: 26,
                          ),
                        ),
                      ),
                      title: 'Catatan',
                      subtitle: _reminder.note,
                      subtitleBold: true,
                      titleColor: const Color(0xFF0098B9),
                    ),

                    const SizedBox(height: 24),

                    // FITUR PREVIEW: Uji Notifikasi Langsung Dari Sini
                    InkWell(
                      onTap: () {
                        showModernExerciseReminderDialog(
                          context,
                          reminder: _reminder,
                          timeText: _reminder.reminderTime,
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFB5E4F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.notifications_active_rounded,
                              color: Color(0xFF0098B9),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Lihat Contoh Notifikasi Olahraga Ini',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0098B9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Tombol Simpan / Selesai
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(context);
                    final nav = Navigator.of(context);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Pengingat olahraga ${_reminder.activityName} berhasil diaktifkan!',
                        ),
                        backgroundColor: const Color(0xFF0098B9),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    nav.popUntil((route) => route.isFirst);
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
            ),

            const HeartCareBottomNavBarWidget(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required Widget iconWidget,
    required String title,
    required String subtitle,
    Color titleColor = const Color(0xFF1E293B),
    bool titleBold = false,
    bool subtitleBold = false,
  }) {
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
          iconWidget,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: titleBold ? FontWeight.w700 : FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        subtitleBold ? FontWeight.w700 : FontWeight.w500,
                    color: const Color(0xFF1E293B),
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
// SLIDE 5: POP-UP NOTIFIKASI MODERN & ELEGAN (iPhone 16 - 116 DIPERCANTIK)
// ============================================================================

/// Tampilan Pop-up Notifikasi Olahraga Ringan (Modern, Estetik, & Terpadu)
void showModernExerciseReminderDialog(
  BuildContext context, {
  required ExerciseReminder reminder,
  String timeText = '07.30 WIB',
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0098B9).withOpacity(0.18),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Badge: Lonceng Cyan, Judul Pengingat, Waktu
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F7FA),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF90D5E4),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFF0098B9),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Pengingat Olahraga Ringan',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      timeText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Ilustrasi Runner Cantik dengan Radial Glow
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFC7EBF4),
                      const Color(0xFFE9F8FB),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: ExerciseRunnerCircularIllustration(size: 80),
                ),
              ),

              const SizedBox(height: 14),

              // Pesan Utama
              const Text(
                'Saatnya olahraga ringan!',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 8),

              // Info Badge: Aktivitas, Durasi, Jadwal
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  _infoChip(
                    Icons.directions_run_rounded,
                    reminder.activityName,
                  ),
                  _infoChip(
                    Icons.timer_outlined,
                    '${reminder.durationMinutes} Menit',
                  ),
                  _infoChip(
                    Icons.event_repeat_rounded,
                    reminder.repeatFrequency,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Kartu Catatan Tambahan
              if (reminder.note.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sticky_note_2_outlined,
                        size: 16,
                        color: Color(0xFF0098B9),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reminder.note,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              // Tips Kesehatan Jantung
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '💡 Tips Jantung: Lakukan pemanasan 3-5 menit dan jaga detak napas teratur.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF007A94),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tombol Utama: "Mulai Olahraga" (Teal)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Semangat berolahraga ${reminder.activityName}! Jaga ritme dan minum air secukupnya.',
                        ),
                        backgroundColor: const Color(0xFF0098B9),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text(
                    'Mulai Olahraga',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0098B9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Tombol Sekunder: "Tunda" (Biru Muda)
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pengingat olahraga ditunda 10 menit.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC7EBF4),
                    foregroundColor: const Color(0xFF0098B9),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tunda 10 Menit',
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

/// Tampilan Pop-up Notifikasi Minum Obat (Modern, Estetik, & Terpadu)
void showModernMedicineReminderDialog(
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0098B9).withOpacity(0.18),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Badge
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F7FA),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF90D5E4),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.medication_rounded,
                      color: Color(0xFF0098B9),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Pengingat Minum Obat',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      timeText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Ilustrasi Kapsul dengan Glow
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFC7EBF4),
                      const Color(0xFFE9F8FB),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CapsuleIconWidget(
                    color: Color(0xFF0098B9),
                    size: 52,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Judul Utama
              const Text(
                'Saatnya Minum Obat!',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 8),

              // Chips Dosis & Jadwal
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  _infoChip(
                    Icons.healing_rounded,
                    reminder.name,
                  ),
                  _infoChip(
                    Icons.science_outlined,
                    '${reminder.amount} ${reminder.unit}',
                  ),
                  _infoChip(
                    Icons.access_time_rounded,
                    reminder.schedule,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Box Catatan & Tips
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'Catatan: ${reminder.note}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tombol Sudah Minum (Teal)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
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
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text(
                    'Sudah Minum',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0098B9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Tombol Tunda (Biru Muda)
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pengingat minum obat ditunda 10 menit.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC7EBF4),
                    foregroundColor: const Color(0xFF0098B9),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tunda 10 Menit',
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

// Kompatibilitas mundur untuk pemanggilan lama
void showMedicineReminderDialog(
  BuildContext context, {
  required MedicineReminder reminder,
  String timeText = 'sekarang',
}) {
  showModernMedicineReminderDialog(context,
      reminder: reminder, timeText: timeText);
}

Widget _infoChip(IconData icon, String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFE9F8FB),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFBBE5EE)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF0098B9)),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0098B9),
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// ALUR TAMBAH & DAFTAR OBAT (SLIDE SEBELUMNYA DIJAGA INTEGRITASNYA)
// ============================================================================

/// Empty State Obat (Slide 2 Alur Obat)
class TambahObatEmptyPage extends StatelessWidget {
  const TambahObatEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Row(
                children: [
                  buildCircularBackButton(context),
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
            const Spacer(flex: 2),
            const Center(
              child: MedicineBottleIllustration(size: 190),
            ),
            const SizedBox(height: 24),
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
            const HeartCareBottomNavBarWidget(currentIndex: 3),
          ],
        ),
      ),
    );
  }
}

/// Form Tambah Obat (Slide 3 Alur Obat)
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
      reminderTimes:
          _selectedTimes.isEmpty ? ['07.30'] : List.from(_selectedTimes),
      note: note.isEmpty ? _selectedSchedule : note,
    );

    HealthReminderController().addMedicine(newMedicine);

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
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Row(
                children: [
                  buildCircularBackButton(context),
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
                    _buildFieldLabel('Nama Obat'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Masukkan Nama Obat',
                    ),
                    const SizedBox(height: 14),
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
                                    setState(() => _selectedUnit = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildFieldLabel('Jadwal Minum'),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (ctx) {
                            return SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
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
                                          setState(() => _selectedSchedule = opt);
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
                      },
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
                    _buildFieldLabel('Waktu Pengingat'),
                    const SizedBox(height: 6),
                    Container(
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
                              _selectedTimes.join('   '),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
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
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Tambahkan catatan.....',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
    );
  }
}

/// Daftar Obat (Slide 4 Alur Obat)
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
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Row(
                children: [
                  buildCircularBackButton(context),
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
                            _buildCard(
                              icon: const CapsuleIconWidget(
                                color: Color(0xFF0098B9),
                                size: 26,
                              ),
                              title: med.name,
                              subtitle: '${med.amount} ${med.unit}',
                              titleColor: const Color(0xFF0098B9),
                            ),
                            const SizedBox(height: 14),
                            _buildCard(
                              icon: const Icon(Icons.access_time_rounded,
                                  color: Color(0xFF1E293B), size: 28),
                              title: 'Waktu Pengingat',
                              subtitle: med.reminderTimes.join('   '),
                              titleColor: const Color(0xFF0098B9),
                              subtitleBold: true,
                            ),
                            const SizedBox(height: 14),
                            _buildCard(
                              icon: const Icon(Icons.assignment_outlined,
                                  color: Color(0xFF1E293B), size: 28),
                              title: 'Catatan',
                              subtitle: med.note,
                              titleColor: const Color(0xFF0098B9),
                              subtitleBold: true,
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: SizedBox(
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
            ),
            const HeartCareBottomNavBarWidget(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required Widget icon,
    required String title,
    required String subtitle,
    Color titleColor = const Color(0xFF1E293B),
    bool subtitleBold = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        subtitleBold ? FontWeight.w700 : FontWeight.normal,
                    color: const Color(0xFF1E293B),
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
// WIDGET HELPER: TOMBOL BACK LINGKARAN & NAV BAR
// ============================================================================
Widget buildCircularBackButton(BuildContext context) {
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
    final Color color =
        active ? const Color(0xFF0098B9) : const Color(0xFF64748B);

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
// CUSTOM VECTOR ARTWORK: KAPSUL OBAT
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
      angle: -0.75,
      child: Container(
        width: size * 0.48,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.24),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
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
// CUSTOM VECTOR ARTWORK: PELARI LINGKARAN (SLIDE 113 & NOTIFIKASI)
// ============================================================================
class ExerciseRunnerCircularIllustration extends StatelessWidget {
  final double size;

  const ExerciseRunnerCircularIllustration({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _RunnerCirclePainter(),
      ),
    );
  }
}

class _RunnerCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Lingkaran Background Biru Lembut
    final bgPaint = Paint()
      ..color = const Color(0xFFE2F4F8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Clip ke lingkaran agar elemen di dalam tidak keluar
    canvas.save();
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);

    // 2. Awan Putih Halus di Belakang
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.7);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.28), size.width * 0.14, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.24), size.width * 0.16, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.28), size.width * 0.13, cloudPaint);

    // 3. Bukit Rumput Hijau Tosca di Bagian Bawah
    final hillPaint = Paint()
      ..color = const Color(0xFFA5E3DB)
      ..style = PaintingStyle.fill;
    final hillPath = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.65,
        size.width,
        size.height * 0.74,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath, hillPaint);

    // Lapisan Rumput Kedua (Sedikit Lebih Tua)
    final pathGrass = Paint()..color = const Color(0xFF6ED0C2);
    final grassPath = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.78,
        size.width,
        size.height * 0.86,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(grassPath, pathGrass);

    // 4. Karakter Pelari (Wanita/Pria Sporty dengan Baju Biru)
    final scale = size.width / 180;
    canvas.translate(size.width * 0.5, size.height * 0.48);

    // Warna Pelari
    final skinPaint = Paint()..color = const Color(0xFFFFD1B3);
    final hairPaint = Paint()..color = const Color(0xFF2C3E50);
    final clothPaint = Paint()..color = const Color(0xFF0098B9);
    final pantsPaint = Paint()..color = const Color(0xFF1E293B);
    final shoePaint = Paint()..color = Colors.white;

    // Rambut Kuncir Kuda Melayang
    final hairPath = Path()
      ..moveTo(-12 * scale, -32 * scale)
      ..quadraticBezierTo(-32 * scale, -28 * scale, -28 * scale, -14 * scale)
      ..quadraticBezierTo(-18 * scale, -20 * scale, -10 * scale, -24 * scale)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Kepala
    canvas.drawCircle(Offset(0, -28 * scale), 12 * scale, skinPaint);
    // Rambut Depan
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, -28 * scale), radius: 12.5 * scale),
      3.14,
      3.14,
      true,
      hairPaint,
    );

    // Badan / Baju Kaos Biru
    final bodyPath = Path()
      ..moveTo(-8 * scale, -15 * scale)
      ..lineTo(8 * scale, -15 * scale)
      ..lineTo(11 * scale, 12 * scale)
      ..lineTo(-11 * scale, 12 * scale)
      ..close();
    canvas.drawPath(bodyPath, clothPaint);

    // Celana Pendek Sporty
    final pantsPath = Path()
      ..moveTo(-11 * scale, 12 * scale)
      ..lineTo(11 * scale, 12 * scale)
      ..lineTo(14 * scale, 26 * scale)
      ..lineTo(1 * scale, 24 * scale)
      ..lineTo(-2 * scale, 24 * scale)
      ..lineTo(-15 * scale, 26 * scale)
      ..close();
    canvas.drawPath(pantsPath, pantsPaint);

    // Kaki Depan (Lari Maju)
    final legFront = Paint()
      ..color = const Color(0xFFFFD1B3)
      ..strokeWidth = 6.5 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(8 * scale, 25 * scale),
      Offset(22 * scale, 45 * scale),
      legFront,
    );
    canvas.drawLine(
      Offset(22 * scale, 45 * scale),
      Offset(18 * scale, 65 * scale),
      legFront,
    );
    // Sepatu Depan
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(14 * scale, 64 * scale, 16 * scale, 8 * scale),
        Radius.circular(4 * scale),
      ),
      shoePaint,
    );

    // Kaki Belakang (Terangkat)
    final legBack = Paint()
      ..color = const Color(0xFFFFC3A0)
      ..strokeWidth = 6.5 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(-10 * scale, 25 * scale),
      Offset(-24 * scale, 40 * scale),
      legBack,
    );
    canvas.drawLine(
      Offset(-24 * scale, 40 * scale),
      Offset(-38 * scale, 35 * scale),
      legBack,
    );
    // Sepatu Belakang
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-48 * scale, 32 * scale, 14 * scale, 7 * scale),
        Radius.circular(4 * scale),
      ),
      shoePaint,
    );

    // Lengan Belakang
    final armBack = Paint()
      ..color = const Color(0xFFFFC3A0)
      ..strokeWidth = 5.5 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(-6 * scale, -10 * scale),
      Offset(-20 * scale, -2 * scale),
      armBack,
    );
    canvas.drawLine(
      Offset(-20 * scale, -2 * scale),
      Offset(-18 * scale, 12 * scale),
      armBack,
    );

    // Lengan Depan
    final armFront = Paint()
      ..color = const Color(0xFFFFD1B3)
      ..strokeWidth = 5.5 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(6 * scale, -10 * scale),
      Offset(20 * scale, -2 * scale),
      armFront,
    );
    canvas.drawLine(
      Offset(20 * scale, -2 * scale),
      Offset(14 * scale, -16 * scale),
      armFront,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// CUSTOM VECTOR ARTWORK: MINI BANNER PELARI LANDSCAPE (SLIDE 114)
// ============================================================================
class ExerciseBannerIllustration extends StatelessWidget {
  const ExerciseBannerIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pohon Sejuk 1
        _buildTree(36, const Color(0xFFA0E7E5)),
        const SizedBox(width: 8),
        _buildTree(46, const Color(0xFF74D6D0)),
        const SizedBox(width: 14),

        // Pelari Mini
        const ExerciseRunnerCircularIllustration(size: 64),

        const SizedBox(width: 14),
        // Pohon Sejuk 2
        _buildTree(48, const Color(0xFF74D6D0)),
        const SizedBox(width: 8),
        _buildTree(34, const Color(0xFFA0E7E5)),
      ],
    );
  }

  static Widget _buildTree(double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: height * 0.58,
          height: height * 0.72,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height * 0.29),
          ),
        ),
        Container(
          width: 4,
          height: height * 0.22,
          color: const Color(0xFFB5C2C7),
        ),
      ],
    );
  }
}

// ============================================================================
// CUSTOM VECTOR ARTWORK: BOTOL OBAT & BLISTER PACK (SLIDE OBAT)
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
          Container(
            width: size * 0.88,
            height: size * 0.88,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F7FB),
              shape: BoxShape.circle,
            ),
          ),
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
                      color: Colors.black.withOpacity(0.06),
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
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: size * 0.36,
                    height: size * 0.12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFBBE5EE),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                  const Spacer(),
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

class MiniMedicineBannerIllustration extends StatelessWidget {
  const MiniMedicineBannerIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
