import 'dart:async';

import 'package:flutter/material.dart';
import 'package:heartcare/pages/home_page.dart';
import 'package:heartcare/pages/dokter_page.dart';
import 'package:heartcare/pages/riwayat_page.dart';
import 'package:heartcare/pages/Skrining/screening_input_page.dart';

import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/language_service.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  String selectedLanguage = LanguageService.currentLanguage;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.addListener(_onNotifUpdate);
  }

  @override
  void dispose() {
    NotificationService.instance.removeListener(_onNotifUpdate);
    super.dispose();
  }

  void _onNotifUpdate() {
    if (mounted) setState(() {});
  }

  void _showNotificationTestSheet() {
    final isDark = ThemeService.isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
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
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFF0284C7),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Uji Coba Notifikasi Pop-up Layar",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          "Ketuk salah satu untuk melihat banner di atas layar HP",
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
                ],
              ),
              const SizedBox(height: 18),
              // 1. Chat Dokter ke Pasien
              _buildTestNotifTile(
                icon: Icons.medical_services_rounded,
                iconColor: const Color(0xFF0284C7),
                bgColor: const Color(0xFFE0F2FE),
                title: "1. Chat Dokter ke Pasien",
                subtitle:
                    "Pesan anjuran dan resep dari dokter spesialis jantung",
                onTap: () {
                  Navigator.pop(context);
                  NotificationService.instance.showDoctorChatNotification(
                    context: this.context,
                    doctorName: "dr. Nurlitta Dwi, Sp.JP",
                    message: "Halo, obat kardio diminum teratur pagi ini dan kurangi garam ya.",
                    doctorSpecialty: "Spesialis Jantung & Pembuluh Darah",
                    doctorPhoto: "assets/images/dokter_nurlitta.jpg",
                  );
                },
                isDark: isDark,
              ),
              // 2. Chat Pasien ke Dokter
              _buildTestNotifTile(
                icon: Icons.person_pin_rounded,
                iconColor: const Color(0xFF0284C7),
                bgColor: const Color(0xFFE0F2FE),
                title: "2. Chat Pasien ke Dokter",
                subtitle:
                    "Pasien Valentino mengirim pertanyaan keluhan konsultasi",
                onTap: () {
                  Navigator.pop(context);
                  NotificationService.instance.showPatientChatNotification(
                    context: this.context,
                    patientName: "Valentino (Pasien)",
                    message: "Dok, hasil tensi saya pagi ini 125/80 mmHg, apakah sudah aman?",
                    patientPhoto: "assets/images/profile_woman.png",
                  );
                },
                isDark: isDark,
              ),
              // 3. Pengingat Jadwal Konsultasi
              _buildTestNotifTile(
                icon: Icons.event_available_rounded,
                iconColor: const Color(0xFF0D9488),
                bgColor: const Color(0xFFCCFBF1),
                title: "3. Pengingat Jadwal Konsultasi",
                subtitle: "Sesi konsultasi dokter dijadwalkan pukul 10:00 WIB",
                onTap: () {
                  Navigator.pop(context);
                  NotificationService.instance
                      .showConsultationReminderNotification(
                        context: this.context,
                        doctorName: "dr. Nurlitta Dwi, Sp.JP",
                        scheduledTime:
                            "Jumat, 18 September 2026 pukul 10:00 WIB",
                        doctorPhoto: "assets/images/dokter_nurlitta.jpg",
                        doctorSpecialty: "Spesialis Jantung",
                      );
                },
                isDark: isDark,
              ),
              // 4. Pengingat Minum Obat
              _buildTestNotifTile(
                icon: Icons.medication_rounded,
                iconColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
                title: "4. Pengingat Minum Obat",
                subtitle: "Waktunya minum Aspirin Kardio 100 mg (1 tablet)",
                onTap: () {
                  Navigator.pop(context);
                  NotificationService.instance.showMedicineReminderNotification(
                    context: this.context,
                    medicineName: "Aspirin Kardio 100 mg",
                    dosage: "1 Tablet",
                    instruction: "Setelah sarapan pagi",
                    time: "08.00",
                  );
                },
                isDark: isDark,
              ),
              // 5. Edukasi Kesehatan Jantung
              _buildTestNotifTile(
                icon: Icons.health_and_safety_rounded,
                iconColor: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFEDE9FE),
                title: "5. Edukasi Kesehatan Jantung",
                subtitle: "Kiat harian: Batasi garam < 5g dan tidur cukup",
                onTap: () {
                  Navigator.pop(context);
                  NotificationService.instance.showHealthEducationNotification(
                    context: this.context,
                    title: "Kiat Jantung Hari Ini",
                    message: "Batasi asupan garam < 5g (1 sdt) per hari untuk menjaga tekanan darah dan elastisitas arteri jantung.",
                  );
                },
                isDark: isDark,
              ),
              // 6. Uji Coba Saat Aplikasi Diminimalkan / Ditutup (Jeda 5 Detik)
              _buildTestNotifTile(
                icon: Icons.timer_outlined,
                iconColor: const Color(0xFF10B981),
                bgColor: const Color(0xFFD1FAE5),
                title: "6. Tes Notifikasi Sistem (Jeda 5 Detik)",
                subtitle: "Ketuk lalu segera minimize/tutup app untuk melihat pop-up di layar HP",
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "⏱️ Timer 5 detik aktif! Silakan tekan tombol Home / minimize aplikasi sekarang.",
                      ),
                      duration: Duration(seconds: 4),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF0284C7),
                    ),
                  );
                  Timer(const Duration(seconds: 5), () {
                    NotificationService.triggerSystemNotification(
                      title: "dr. Nurlitta Dwi, Sp.JP",
                      message: "Halo, ini notifikasi chat dokter yang berhasil muncul di HP saat aplikasi diminimalkan/layar kunci!",
                      isCall: false,
                    );
                  });
                },
                isDark: isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestNotifTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: bgColor,
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
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
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
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: iconColor,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final isDark = ThemeService.isDarkMode;
            return Container(
              padding: EdgeInsets.only(
                left: 22,
                right: 22,
                top: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 22,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0098B9), Color(0xFF0284C7)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0098B9)
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr("Ubah Kata Sandi", "Change Password"),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tr(
                                "Masukkan kata sandi baru untuk akun Anda",
                                "Enter a new password for your account",
                              ),
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _passField(
                      tr("Kata Sandi Lama", "Current Password"),
                      oldPassCtrl,
                      obscureOld,
                      () => setSheetState(() => obscureOld = !obscureOld),
                      isDark: isDark,
                    ),
                    _passField(
                      tr("Kata Sandi Baru", "New Password"),
                      newPassCtrl,
                      obscureNew,
                      () => setSheetState(() => obscureNew = !obscureNew),
                      isDark: isDark,
                    ),
                    _passField(
                      tr("Konfirmasi Kata Sandi Baru", "Confirm New Password"),
                      confirmPassCtrl,
                      obscureConfirm,
                      () =>
                          setSheetState(() => obscureConfirm = !obscureConfirm),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0098B9), Color(0xFF0284C7)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0098B9)
                                .withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                final newPass = newPassCtrl.text;
                                final confirmPass = confirmPassCtrl.text;

                                if (oldPassCtrl.text.isEmpty ||
                                    newPass.isEmpty ||
                                    confirmPass.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        tr(
                                          "Semua kolom kata sandi harus diisi",
                                          "All password fields must be filled",
                                        ),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                if (newPass.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        tr(
                                          "Kata sandi baru minimal 6 karakter",
                                          "New password must be at least 6 characters",
                                        ),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                if (newPass != confirmPass) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        tr(
                                          "Konfirmasi kata sandi tidak cocok",
                                          "Password confirmation does not match",
                                        ),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }

                                setSheetState(() => isSaving = true);
                                final error = await AuthService.instance
                                    .updatePassword(newPass);

                                if (!sheetContext.mounted) return;
                                setSheetState(() => isSaving = false);

                                if (error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }

                                Navigator.pop(sheetContext);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      tr(
                                        "Kata sandi berhasil diperbarui",
                                        "Password updated successfully",
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFF0098B9),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                tr("Simpan Kata Sandi", "Save Password"),
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
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
      },
    );
  }

  Widget _passField(
    String label,
    TextEditingController ctrl,
    bool obscure,
    VoidCallback toggle, {
    bool isDark = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: ctrl,
            obscureText: obscure,
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF0098B9),
                  width: 1.5,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                onPressed: toggle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final isDark = ThemeService.isDarkMode;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0098B9).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: Color(0xFF0098B9),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                tr("Pilih Bahasa", "Select Language"),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: selectedLanguage == LanguageService.indonesian
                      ? (isDark
                            ? const Color(0xFF0E2A3B)
                            : const Color(0xFFE0F7FC))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedLanguage == LanguageService.indonesian
                        ? const Color(0xFF0098B9)
                        : (isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: ListTile(
                  title: Text(
                    "Bahasa Indonesia",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selectedLanguage == LanguageService.indonesian
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  trailing: selectedLanguage == LanguageService.indonesian
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF0098B9),
                        )
                      : null,
                  onTap: () async {
                    setState(
                      () => selectedLanguage = LanguageService.indonesian,
                    );
                    await LanguageService.setLanguage(
                      LanguageService.indonesian,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tr(
                              "Bahasa diubah ke Bahasa Indonesia",
                              "Language changed to Indonesian",
                            ),
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: const Color(0xFF0098B9),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: selectedLanguage == LanguageService.english
                      ? (isDark
                            ? const Color(0xFF0E2A3B)
                            : const Color(0xFFE0F7FC))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedLanguage == LanguageService.english
                        ? const Color(0xFF0098B9)
                        : (isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: ListTile(
                  title: Text(
                    "English (US)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selectedLanguage == LanguageService.english
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  trailing: selectedLanguage == LanguageService.english
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF0098B9),
                        )
                      : null,
                  onTap: () async {
                    setState(() => selectedLanguage = LanguageService.english);
                    await LanguageService.setLanguage(LanguageService.english);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tr(
                              "Bahasa berhasil diubah ke English (US)",
                              "Language changed to English (US)",
                            ),
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: const Color(0xFF0098B9),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: LanguageService.languageNotifier,
          builder: (context, activeLang, _) {
            selectedLanguage = activeLang;
            final isDark = themeMode == ThemeMode.dark;

            return Scaffold(
              backgroundColor: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF8FAFC),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.2 : 0.04,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
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
                  tr("Pengaturan", "Settings"),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              body: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.22, 0.6],
                    colors: isDark
                        ? const [
                            Color(0xFF1E293B),
                            Color(0xFF131D2E),
                            Color(0xFF0F172A),
                          ]
                        : const [
                            Color(0xFFE8F6FA),
                            Color(0xFFF4FAFC),
                            Color(0xFFF8FAFC),
                          ],
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==========================================================
                        // SECTION 1: AKUN
                        // ==========================================================
                        Text(
                          tr("Akun", "Account"),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // CARD UBAH KATA SANDI (DENGAN GRADASI BIRU MUDA)
                        _pengaturanCard(
                          icon: Icons.lock_reset_rounded,
                          title: tr("Ubah kata sandi", "Change password"),
                          subtitle: tr(
                            "Perbarui kata sandi akun Anda",
                            "Update your account password",
                          ),
                          onTap: _showChangePasswordDialog,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 22),

                        // ==========================================================
                        // SECTION 2: NOTIFIKASI POP-UP LAYAR HP
                        // ==========================================================
                        Row(
                          children: [
                            Text(
                              tr(
                                "Notifikasi Pop-up Layar",
                                "Screen Pop-up Notifications",
                              ),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "Heads-Up",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // CARD UJI COBA NOTIFIKASI POP-UP
                        _pengaturanCard(
                          icon: Icons.notifications_active_rounded,
                          title: tr(
                            "Uji Coba Notifikasi Pop-up",
                            "Test Pop-up Notifications",
                          ),
                          subtitle: tr(
                            "Simulasi 5 jenis notifikasi melayang di atas layar",
                            "Simulate 5 floating notification types",
                          ),
                          onTap: _showNotificationTestSheet,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_arrow_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  "Tes",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isDark: isDark,
                        ),

                        // TOGGLE CHAT DOKTER & PASIEN
                        _pengaturanCard(
                          icon: Icons.chat_rounded,
                          title: tr(
                            "Notifikasi Chat Pasien & Dokter",
                            "Patient & Doctor Chat Notifications",
                          ),
                          subtitle: NotificationService.instance.enableChat
                              ? tr(
                                  "Pop-up aktif saat pesan baru diterima",
                                  "Pop-up active on new message",
                                )
                              : tr(
                                  "Pop-up chat dinonaktifkan",
                                  "Chat pop-ups disabled",
                                ),
                          onTap: () {
                            final val =
                                !NotificationService.instance.enableChat;
                            NotificationService.instance
                                .setNotificationPreference(enableChat: val);
                          },
                          trailing: Switch.adaptive(
                            value: NotificationService.instance.enableChat,
                            activeTrackColor: const Color(0xFF0098B9),
                            activeThumbColor: Colors.white,
                            onChanged: (val) {
                              NotificationService.instance
                                  .setNotificationPreference(enableChat: val);
                            },
                          ),
                          isDark: isDark,
                        ),

                        // TOGGLE PENGINGAT MINUM OBAT
                        _pengaturanCard(
                          icon: Icons.medication_rounded,
                          title: tr(
                            "Pengingat Minum Obat",
                            "Medicine Reminders",
                          ),
                          subtitle: NotificationService.instance.enableMedicine
                              ? tr(
                                  "Pop-up aktif sesuai jam minum obat",
                                  "Pop-up active based on schedule",
                                )
                              : tr(
                                  "Pop-up pengingat obat dinonaktifkan",
                                  "Medicine reminders disabled",
                                ),
                          onTap: () {
                            final val =
                                !NotificationService.instance.enableMedicine;
                            NotificationService.instance
                                .setNotificationPreference(enableMedicine: val);
                          },
                          trailing: Switch.adaptive(
                            value: NotificationService.instance.enableMedicine,
                            activeTrackColor: const Color(0xFF0098B9),
                            activeThumbColor: Colors.white,
                            onChanged: (val) {
                              NotificationService.instance
                                  .setNotificationPreference(
                                    enableMedicine: val,
                                  );
                            },
                          ),
                          isDark: isDark,
                        ),

                        // TOGGLE PENGINGAT JADWAL KONSULTASI
                        _pengaturanCard(
                          icon: Icons.event_available_rounded,
                          title: tr(
                            "Pengingat Jadwal Konsultasi",
                            "Consultation Schedule Reminders",
                          ),
                          subtitle:
                              NotificationService.instance.enableConsultation
                              ? tr(
                                  "Pop-up aktif sebelum sesi temu dokter",
                                  "Pop-up active before consultation",
                                )
                              : tr(
                                  "Pop-up jadwal konsultasi dinonaktifkan",
                                  "Consultation reminders disabled",
                                ),
                          onTap: () {
                            final val = !NotificationService
                                .instance
                                .enableConsultation;
                            NotificationService.instance
                                .setNotificationPreference(
                                  enableConsultation: val,
                                );
                          },
                          trailing: Switch.adaptive(
                            value:
                                NotificationService.instance.enableConsultation,
                            activeTrackColor: const Color(0xFF0098B9),
                            activeThumbColor: Colors.white,
                            onChanged: (val) {
                              NotificationService.instance
                                  .setNotificationPreference(
                                    enableConsultation: val,
                                  );
                            },
                          ),
                          isDark: isDark,
                        ),

                        // TOGGLE EDUKASI KESEHATAN JANTUNG
                        _pengaturanCard(
                          icon: Icons.health_and_safety_rounded,
                          title: tr(
                            "Edukasi & Tips Jantung Harian",
                            "Daily Heart Tips & Education",
                          ),
                          subtitle: NotificationService.instance.enableEducation
                              ? tr(
                                  "Pop-up kiat kesehatan aktif berkala",
                                  "Health tips pop-up active",
                                )
                              : tr(
                                  "Pop-up edukasi dinonaktifkan",
                                  "Education pop-ups disabled",
                                ),
                          onTap: () {
                            final val =
                                !NotificationService.instance.enableEducation;
                            NotificationService.instance
                                .setNotificationPreference(
                                  enableEducation: val,
                                );
                          },
                          trailing: Switch.adaptive(
                            value: NotificationService.instance.enableEducation,
                            activeTrackColor: const Color(0xFF0098B9),
                            activeThumbColor: Colors.white,
                            onChanged: (val) {
                              NotificationService.instance
                                  .setNotificationPreference(
                                    enableEducation: val,
                                  );
                            },
                          ),
                          isDark: isDark,
                        ),

                        const SizedBox(height: 22),

                        // ==========================================================
                        // SECTION 2: LAINNYA
                        // ==========================================================
                        Text(
                          tr("Lainnya", "Others"),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // CARD BAHASA (DENGAN GRADASI BIRU MUDA)
                        _pengaturanCard(
                          icon: Icons.language_rounded,
                          title: tr("Bahasa", "Language"),
                          subtitle: selectedLanguage,
                          onTap: _showLanguageDialog,
                          isDark: isDark,
                        ),

                        // CARD MODE GELAP (DENGAN GRADASI BIRU MUDA & SWITCH)
                        _pengaturanCard(
                          icon: Icons.nightlight_round,
                          title: tr("Mode Gelap", "Dark Mode"),
                          subtitle: isDark
                              ? tr(
                                  "Mode gelap sedang aktif",
                                  "Dark mode is currently active",
                                )
                              : tr(
                                  "Aktifkan tema tampilan gelap",
                                  "Enable dark display theme",
                                ),
                          onTap: () {
                            final newVal = !ThemeService.isDarkMode;
                            ThemeService.toggleTheme(newVal);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  newVal
                                      ? tr(
                                          "Mode Gelap diaktifkan",
                                          "Dark Mode enabled",
                                        )
                                      : tr(
                                          "Mode Terang diaktifkan",
                                          "Light Mode enabled",
                                        ),
                                ),
                                duration: const Duration(seconds: 1),
                                backgroundColor: const Color(0xFF0098B9),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          trailing: Switch.adaptive(
                            value: isDark,
                            activeTrackColor: const Color(0xFF0098B9),
                            activeThumbColor: Colors.white,
                            onChanged: (val) {
                              ThemeService.toggleTheme(val);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    val
                                        ? tr(
                                            "Mode Gelap diaktifkan",
                                            "Dark Mode enabled",
                                          )
                                        : tr(
                                            "Mode Terang diaktifkan",
                                            "Light Mode enabled",
                                          ),
                                  ),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: const Color(0xFF0098B9),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: _buildBottomNav(context, isDark: isDark),
            );
          },
        );
      },
    );
  }

  Widget _pengaturanCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDark = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1E293B), Color(0xFF0E2536)]
              : const [Color(0xFFE2F7FB), Color(0xFFC7EBF4)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFBCE6F1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0098B9)).withValues(
              alpha: isDark ? 0.25 : 0.08,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : const Color(0xFF0098B9))
                            .withValues(alpha: isDark ? 0.3 : 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isDark
                        ? const Color(0xFF38BDF8)
                        : const Color(0xFF0098B9),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
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
                trailing ??
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A).withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0098B9),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, {bool isDark = false}) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context,
            Icons.home_outlined,
            tr("Home", "Home"),
            0,
            isDark: isDark,
          ),
          _navItem(
            context,
            Icons.favorite_border,
            tr("Skrining", "Screening"),
            1,
            isDark: isDark,
          ),
          _navItem(
            context,
            Icons.person_outline,
            tr("Dokter", "Doctors"),
            2,
            isDark: isDark,
          ),
          _navItem(
            context,
            Icons.description_outlined,
            tr("Riwayat", "History"),
            3,
            isDark: isDark,
          ),
          _navItem(
            context,
            Icons.person_rounded,
            tr("Profil", "Profile"),
            4,
            active: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    int index, {
    bool active = false,
    bool isDark = false,
  }) {
    final activeColor = isDark
        ? const Color(0xFF38BDF8)
        : const Color(0xFF1479F5);
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : Colors.black87;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (active) return;
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScreeningInputPage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PilihDokterPage()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RiwayatPage()),
          );
        }
      },
      child: SizedBox(
        width: 55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: active ? activeColor : inactiveColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
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
