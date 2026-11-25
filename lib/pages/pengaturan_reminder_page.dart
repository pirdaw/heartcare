import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';
import '../services/health_reminder_scheduler_service.dart';

class PengaturanReminderPage extends StatefulWidget {
  const PengaturanReminderPage({super.key});

  @override
  State<PengaturanReminderPage> createState() => _PengaturanReminderPageState();
}

class _PengaturanReminderPageState extends State<PengaturanReminderPage> {
  final HealthReminderSchedulerService _service =
      HealthReminderSchedulerService.instance;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            centerTitle: true,
            title: Text(
              tr("Pengaturan Pengingat", "Reminder Settings"),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. KARTU STATUS OTOMATIS AKTIF
                  _buildStatusBanner(isDark),

                  const SizedBox(height: 20),

                  // 2. MASTER TOGGLE SWITCH
                  _buildMasterSwitchCard(isDark),

                  const SizedBox(height: 24),

                  // 3. KATEGORI MINUM AIR PUTIH
                  _buildCategorySection(
                    isDark: isDark,
                    category: HealthReminderCategory.water,
                    title: tr("Minum Air Putih", "Water Hydration"),
                    subtitle: tr("4 jadwal rutin per hari untuk hidrasi optimal",
                        "4 daily routines for optimal hydration"),
                    icon: Icons.water_drop_rounded,
                    iconColor: const Color(0xFF0284C7),
                    isEnabled: _service.waterEnabled,
                    onToggle: (val) => _service.setWaterEnabled(val),
                  ),

                  const SizedBox(height: 20),

                  // 4. KATEGORI AKTIVITAS FISIK
                  _buildCategorySection(
                    isDark: isDark,
                    category: HealthReminderCategory.activity,
                    title: tr("Aktivitas Fisik & Peregangan", "Physical Activity"),
                    subtitle: tr("Jalan santai & peregangan untuk kesehatan jantung",
                        "Walking & stretching for heart health"),
                    icon: Icons.directions_run_rounded,
                    iconColor: const Color(0xFF10B981),
                    isEnabled: _service.activityEnabled,
                    onToggle: (val) => _service.setActivityEnabled(val),
                  ),

                  const SizedBox(height: 20),

                  // 5. KATEGORI KEBIASAAN SEHAT & KIAT JANTUNG
                  _buildCategorySection(
                    isDark: isDark,
                    category: HealthReminderCategory.habit,
                    title: tr("Kebiasaan Sehat & Kiat Jantung", "Healthy Heart Habits"),
                    subtitle: tr("Relaksasi, batas natrium, dan tidur berkualitas",
                        "Relaxation, sodium limits, and quality sleep"),
                    icon: Icons.favorite_rounded,
                    iconColor: const Color(0xFFEF4444),
                    isEnabled: _service.habitEnabled,
                    onToggle: (val) => _service.setHabitEnabled(val),
                  ),

                  const SizedBox(height: 26),

                  // 6. UJI COBA NOTIFIKASI LANGSUNG
                  _buildTestNotificationCard(isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBanner(bool isDark) {
    final bool active = _service.masterEnabled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: active
              ? (isDark
                  ? const [Color(0xFF064E3B), Color(0xFF0F172A)]
                  : const [Color(0xFFECFDF5), Color(0xFFD1FAE5)])
              : (isDark
                  ? const [Color(0xFF334155), Color(0xFF1E293B)]
                  : const [Color(0xFFF1F5F9), Color(0xFFE2E8F0)]),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? (isDark ? const Color(0xFF059669) : const Color(0xFFA7F3D0))
              : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      active
                          ? tr("Pengingat Otomatis Aktif", "Auto Reminders Active")
                          : tr("Pengingat Sedang Nonaktif", "Reminders Inactive"),
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF10B981)
                            : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  active
                      ? tr(
                          "Notifikasi lokal Android akan muncul otomatis sesuai jadwal meskipun aplikasi sedang ditutup.",
                          "Android local notifications will trigger automatically on schedule even when the app is closed.")
                      : tr(
                          "Aktifkan tombol master di bawah untuk menjalankan kembali pengingat kesehatan rutin.",
                          "Enable the master toggle below to resume scheduled health reminders."),
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
    );
  }

  Widget _buildMasterSwitchCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr("Semua Pengingat Otomatis", "All Auto Reminders"),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tr("Jalankan notifikasi harian di latar belakang HP",
                      "Run daily notifications in the background"),
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
          Switch(
            value: _service.masterEnabled,
            activeColor: const Color(0xFF0284C7),
            onChanged: (val) => _service.setMasterEnabled(val),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required bool isDark,
    required HealthReminderCategory category,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isEnabled,
    required Function(bool) onToggle,
  }) {
    final reminders = _service.getRemindersByCategory(category);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          // Header Kategori dengan Switch
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isEnabled && _service.masterEnabled,
                  activeColor: iconColor,
                  onChanged: _service.masterEnabled ? onToggle : null,
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),

          // Daftar Jadwal Waktu
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollButtonPhysics(),
            itemCount: reminders.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 52,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
            ),
            itemBuilder: (context, index) {
              final item = reminders[index];
              final bool itemActive =
                  isEnabled && _service.masterEnabled && item.isEnabled;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: itemActive
                            ? iconColor.withValues(alpha: 0.1)
                            : (isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.timeFormatted,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: itemActive
                              ? iconColor
                              : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: itemActive
                                  ? (isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A))
                                  : (isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8)),
                            ),
                          ),
                          Text(
                            item.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        size: 18,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      tooltip: "Uji notifikasi ini",
                      onPressed: () {
                        _service.triggerTestNotification(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Notifikasi ${item.title} terkirim!"),
                            backgroundColor: const Color(0xFF0284C7),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestNotificationCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            children: [
              const Icon(Icons.touch_app_rounded,
                  size: 18, color: Color(0xFF0284C7)),
              const SizedBox(width: 8),
              Text(
                tr("Uji Coba Notifikasi", "Test Notifications"),
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            tr("Tekan tombol di bawah untuk melihat contoh notifikasi lokal yang akan muncul otomatis di status bar HP Anda.",
                "Tap below to preview local notifications that appear automatically in your phone status bar."),
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _testPillButton(
                label: "💧 Air Putih",
                color: const Color(0xFF0284C7),
                onTap: () {
                  final item = _service.allReminders.firstWhere(
                    (r) => r.category == HealthReminderCategory.water,
                  );
                  _service.triggerTestNotification(item);
                },
              ),
              _testPillButton(
                label: "🏃 Olahraga",
                color: const Color(0xFF10B981),
                onTap: () {
                  final item = _service.allReminders.firstWhere(
                    (r) => r.category == HealthReminderCategory.activity,
                  );
                  _service.triggerTestNotification(item);
                },
              ),
              _testPillButton(
                label: "🧘 Kiat Jantung",
                color: const Color(0xFFEF4444),
                onTap: () {
                  final item = _service.allReminders.firstWhere(
                    (r) => r.category == HealthReminderCategory.habit,
                  );
                  _service.triggerTestNotification(item);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _testPillButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        onTap();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Notifikasi $label terkirim ke status bar HP!"),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
