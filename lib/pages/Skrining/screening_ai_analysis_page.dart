import 'package:flutter/material.dart';
import 'screening_model.dart';
import 'screening_result_page.dart';
import 'custom_bottom_nav_bar.dart';
import 'package:heartcare/pages/riwayat_model.dart';

/// Halaman Proses Analisis AI dengan animasi detak jantung dan status tahapan
class ScreeningAiAnalysisPage extends StatefulWidget {
  final ScreeningData data;

  const ScreeningAiAnalysisPage({
    super.key,
    required this.data,
  });

  @override
  State<ScreeningAiAnalysisPage> createState() =>
      _ScreeningAiAnalysisPageState();
}

class _ScreeningAiAnalysisPageState extends State<ScreeningAiAnalysisPage>
    with SingleTickerProviderStateMixin {
  static const Color primaryTeal = Color(0xFF079BC1);

  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  String _currentStepStatus = 'Memvalidasi data parameter kesehatan...';
  double _progressValue = 0.25;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnalysisProcess();
  }

  Future<void> _startAnalysisProcess() async {
    // Tahap 1
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _currentStepStatus =
          'Mengevaluasi 11 parameter risiko kardiovaskular...';
      _progressValue = 0.65;
    });

    // Tahap 2 & Panggilan Evaluasi AI
    final result = await HeartRiskAnalyzer.analyze(widget.data);
    if (!mounted) return;

    setState(() {
      _currentStepStatus = 'Menyusun rekomendasi klinis dan hasil...';
      _progressValue = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Simpan ke Riwayat
    RiwayatService().addScreeningRecord(
      data: widget.data,
      result: result,
    );

    // Pindah ke Halaman Hasil Skrining
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScreeningResultPage(
          result: result,
          data: widget.data,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 8,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F3F6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFF1E293B),
                          size: 26,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Analisis AI',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Konten Tengah
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lingkaran Animasi Denyut Jantung
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE0F2FE),
                          boxShadow: [
                            BoxShadow(
                              color: primaryTeal.withValues(alpha: 0.25),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryTeal,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 38),

                    // Judul Proses
                    const Text(
                      'AI Sedang Menganalisis Data Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Deskripsi Status
                    Text(
                      _currentStepStatus,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 6,
                        child: LinearProgressIndicator(
                          value: _progressValue,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            primaryTeal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            const HeartCareBottomNavBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }
}
