import 'package:flutter/material.dart';
import 'package:heartcare/pages/home_page.dart';
import 'package:heartcare/pages/dokter_page.dart';
import 'package:heartcare/pages/riwayat_page.dart';
import 'package:heartcare/pages/Skrining/screening_input_page.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  String selectedLanguage = "Bahasa Indonesia";

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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
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
                              "Ubah Kata Sandi",
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
                              "Masukkan kata sandi baru untuk akun Anda",
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
                      "Kata Sandi Lama",
                      oldPassCtrl,
                      obscureOld,
                      () => setSheetState(() => obscureOld = !obscureOld),
                      isDark: isDark,
                    ),
                    _passField(
                      "Kata Sandi Baru",
                      newPassCtrl,
                      obscureNew,
                      () => setSheetState(() => obscureNew = !obscureNew),
                      isDark: isDark,
                    ),
                    _passField(
                      "Konfirmasi Kata Sandi Baru",
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
                          colors: [
                            Color(0xFF0098B9),
                            Color(0xFF0284C7),
                          ],
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
                                    const SnackBar(
                                      content: Text(
                                          "Semua kolom kata sandi harus diisi"),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                if (newPass.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Kata sandi baru minimal 6 karakter"),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                if (newPass != confirmPass) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Konfirmasi kata sandi tidak cocok"),
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
                                  const SnackBar(
                                    content:
                                        Text("Kata sandi berhasil diperbarui"),
                                    backgroundColor: Color(0xFF0098B9),
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
                            : const Text(
                                "Simpan Kata Sandi",
                                style: TextStyle(
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
                borderSide: const BorderSide(color: Color(0xFF0098B9), width: 1.5),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                "Pilih Bahasa",
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
                  color: selectedLanguage == "Bahasa Indonesia"
                      ? (isDark
                          ? const Color(0xFF0E2A3B)
                          : const Color(0xFFE0F7FC))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedLanguage == "Bahasa Indonesia"
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
                      fontWeight: selectedLanguage == "Bahasa Indonesia"
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  trailing: selectedLanguage == "Bahasa Indonesia"
                      ? const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF0098B9))
                      : null,
                  onTap: () {
                    setState(() => selectedLanguage = "Bahasa Indonesia");
                    Navigator.pop(context);
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: selectedLanguage == "English (US)"
                      ? (isDark
                          ? const Color(0xFF0E2A3B)
                          : const Color(0xFFE0F7FC))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedLanguage == "English (US)"
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
                      fontWeight: selectedLanguage == "English (US)"
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  trailing: selectedLanguage == "English (US)"
                      ? const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF0098B9))
                      : null,
                  onTap: () {
                    setState(() => selectedLanguage = "English (US)");
                    Navigator.pop(context);
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
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
              "Pengaturan",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================================
                    // SECTION 1: AKUN
                    // ==========================================================
                    Text(
                      "Akun",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // CARD UBAH KATA SANDI (DENGAN GRADASI BIRU MUDA)
                    _pengaturanCard(
                      icon: Icons.lock_reset_rounded,
                      title: "Ubah kata sandi",
                      subtitle: "Perbarui kata sandi akun Anda",
                      onTap: _showChangePasswordDialog,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 22),

                    // ==========================================================
                    // SECTION 2: LAINNYA
                    // ==========================================================
                    Text(
                      "Lainnya",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // CARD BAHASA (DENGAN GRADASI BIRU MUDA)
                    _pengaturanCard(
                      icon: Icons.language_rounded,
                      title: "Bahasa",
                      subtitle: selectedLanguage,
                      onTap: _showLanguageDialog,
                      isDark: isDark,
                    ),

                    // CARD MODE GELAP (DENGAN GRADASI BIRU MUDA & SWITCH)
                    _pengaturanCard(
                      icon: Icons.nightlight_round,
                      title: "Mode Gelap",
                      subtitle: isDark
                          ? "Mode gelap sedang aktif"
                          : "Aktifkan tema tampilan gelap",
                      onTap: () {
                        final newVal = !ThemeService.isDarkMode;
                        ThemeService.toggleTheme(newVal);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              newVal
                                  ? "Mode Gelap diaktifkan"
                                  : "Mode Terang diaktifkan",
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
                                    ? "Mode Gelap diaktifkan"
                                    : "Mode Terang diaktifkan",
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
              ? const [
                  Color(0xFF1E293B),
                  Color(0xFF0E2536),
                ]
              : const [
                  Color(0xFFE2F7FB),
                  Color(0xFFC7EBF4),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFBCE6F1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0098B9))
                .withValues(alpha: isDark ? 0.25 : 0.08),
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
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
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
          _navItem(context, Icons.home_outlined, "Home", 0, isDark: isDark),
          _navItem(context, Icons.favorite_border, "Skrining", 1,
              isDark: isDark),
          _navItem(context, Icons.person_outline, "Dokter", 2, isDark: isDark),
          _navItem(context, Icons.description_outlined, "Riwayat", 3,
              isDark: isDark),
          _navItem(context, Icons.person_rounded, "Profil", 4,
              active: true, isDark: isDark),
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
    final activeColor =
        isDark ? const Color(0xFF38BDF8) : const Color(0xFF1479F5);
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
              MaterialPageRoute(
                  builder: (context) => const ScreeningInputPage()));
        } else if (index == 2) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PilihDokterPage()));
        } else if (index == 3) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const RiwayatPage()));
        }
      },
      child: SizedBox(
        width: 55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: active ? activeColor : inactiveColor,
            ),
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
