import 'package:flutter/material.dart';
import 'custom_bottom_nav_bar.dart';
import 'screening_model.dart';
import 'screening_review_page.dart';
import '../../services/theme_service.dart';

/// Halaman Skrining - Input Data dengan Stepper bertahap (1/5 s/d 5/5)
/// Sesuai dengan desain Figma (11 Pertanyaan lengkap + Data Diri)
class ScreeningInputPage extends StatefulWidget {
  const ScreeningInputPage({super.key});

  @override
  State<ScreeningInputPage> createState() => _ScreeningInputPageState();
}

class _ScreeningInputPageState extends State<ScreeningInputPage> {
  static const Color primaryTeal = Color(0xFF079BC1);

  int _currentStep = 1;
  final int _totalSteps = 5;

  // ============================================================
  // FORM STEP 1 - DATA DIRI
  // ============================================================
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;

  // ============================================================
  // FORM STEP 2 - KONDISI KESEHATAN (Pertanyaan 1, 2, 3)
  // ============================================================
  String? _selectedChestPain;
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _cholesterolController = TextEditingController();

  // ============================================================
  // FORM STEP 3 - KONDISI KESEHATAN (Pertanyaan 4, 5, 6)
  // ============================================================
  String? _fastingBloodSugar;
  String? _restingEcg;
  final TextEditingController _maxHeartRateController = TextEditingController();

  // ============================================================
  // FORM STEP 4 - KONDISI KESEHATAN (Pertanyaan 7, 8, 9)
  // ============================================================
  String? _exerciseAngina;
  final TextEditingController _oldpeakController = TextEditingController();
  String? _stSlope;

  // ============================================================
  // FORM STEP 5 - KONDISI KESEHATAN (Pertanyaan 10, 11)
  // ============================================================
  int? _majorVessels;
  String? _thal;

  // ============================================================
  // DISPOSE
  // ============================================================
  @override
  void dispose() {
    _ageController.dispose();
    _systolicController.dispose();
    _cholesterolController.dispose();
    _maxHeartRateController.dispose();
    _oldpeakController.dispose();
    super.dispose();
  }

  // ============================================================
  // NAVIGASI STEP
  // ============================================================
  Future<void> _onNextStep() async {
    if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Selesai Pertanyaan 11 -> Navigasi ke Halaman Review Jawaban
      final data = ScreeningData(
        age: _ageController.text.trim(),
        gender: _selectedGender,
        chestPainType: _selectedChestPain,
        restingBloodPressure: _systolicController.text.trim(),
        cholesterol: _cholesterolController.text.trim(),
        fastingBloodSugar: _fastingBloodSugar,
        restingEcg: _restingEcg,
        maxHeartRate: _maxHeartRateController.text.trim(),
        exerciseAngina: _exerciseAngina,
        oldpeak: _oldpeakController.text.trim(),
        stSlope: _stSlope,
        majorVessels: _majorVessels,
        thal: _thal,
      );

      final selectedStep = await Navigator.push<int>(
        context,
        MaterialPageRoute(
          builder: (context) => ScreeningReviewPage(data: data),
        ),
      );

      // Jika user memilih untuk mengoreksi step tertentu dari Halaman Review
      if (selectedStep != null && mounted) {
        setState(() {
          _currentStep = selectedStep;
        });
      }
    }
  }

  void _onPreviousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  // ============================================================
  // BUILD UTAMA
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // ----------------------------------------------------
                // TOP APP BAR
                // ----------------------------------------------------
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
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F3F6),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.chevron_left,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                              size: 26,
                            ),
                            onPressed: _onPreviousStep,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Skrining - Input Data ($_currentStep/$_totalSteps)',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ----------------------------------------------------
                // STEPPER (5 LANGKAH)
                // ----------------------------------------------------
                Center(
                  child: _buildStepper(isDark),
                ),

                const SizedBox(height: 24),

                // ----------------------------------------------------
                // FORM CONTENT
                // ----------------------------------------------------
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildCurrentStepContent(isDark),
                  ),
                ),

                // ----------------------------------------------------
                // BUTTON LANJUTKAN
                // ----------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onNextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Lanjutkan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // ----------------------------------------------------
                // BOTTOM NAVIGATION
                // ----------------------------------------------------
                const HeartCareBottomNavBar(
                  currentIndex: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // STEPPER (1 sampai 5)
  // ============================================================
  Widget _buildStepper(bool isDark) {
    return SizedBox(
      width: 270,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          _totalSteps * 2 - 1,
          (index) {
            if (index.isOdd) {
              final int stepBefore = (index ~/ 2) + 1;
              final bool isPassed = _currentStep > stepBefore;

              return Expanded(
                child: Container(
                  height: 1.8,
                  color: isPassed
                      ? primaryTeal
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                ),
              );
            } else {
              final int stepNumber = (index ~/ 2) + 1;
              final bool isActive = _currentStep == stepNumber;
              final bool isCompleted = _currentStep > stepNumber;

              return Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isActive || isCompleted)
                      ? primaryTeal
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
                ),
                child: Center(
                  child: Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: (isActive || isCompleted)
                          ? Colors.white
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // ============================================================
  // MENENTUKAN KONTEN STEP
  // ============================================================
  Widget _buildCurrentStepContent(bool isDark) {
    switch (_currentStep) {
      case 1:
        return _buildStep1DataDiri(isDark);
      case 2:
        return _buildStep2Vital(isDark);
      case 3:
        return _buildStep3KondisiKesehatan(isDark);
      case 4:
        return _buildStep4KondisiKesehatan(isDark);
      case 5:
        return _buildStep5KondisiKesehatan(isDark);
      default:
        return _buildStep1DataDiri(isDark);
    }
  }

  // ============================================================
  // STEP 1 - DATA DIRI
  // ============================================================
  Widget _buildStep1DataDiri(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Diri',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Usia',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B),
          ),
        ),

        const SizedBox(height: 8),

        Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFF8BB5CE),
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: 'Contoh: 25',
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Jenis Kelamin',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            _buildRadioOption('Laki-laki', isDark),
            const SizedBox(width: 50),
            _buildRadioOption('Perempuan', isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption(String value, bool isDark) {
    final bool isSelected = _selectedGender == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? primaryTeal : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                width: 1.5,
              ),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryTeal,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 2 - KONDISI KESEHATAN (Pertanyaan 1, 2, 3)
  // ============================================================
  Widget _buildStep2Vital(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kondisi Kesehatan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 12),

        // Pertanyaan 1
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Bagaimana nyeri dada yang anda rasakan?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 14),

              _buildChestPainOption(
                title: 'Typical Angina',
                description:
                    'Rasa tertekan atau tidak nyaman di dada yang biasanya muncul saat beraktivitas dan dapat berkurang saat beristirahat.',
                isDark: isDark,
              ),

              const SizedBox(height: 12),

              _buildChestPainOption(
                title: 'Atypical Angina',
                description:
                    'Rasa tidak nyaman di dada yang mungkin muncul dengan cara berbeda, misalnya tidak selalu terasa tertekan atau tidak selalu muncul saat beraktivitas.',
                isDark: isDark,
              ),

              const SizedBox(height: 12),

              _buildChestPainOption(
                title: 'Non-anginal Pain',
                description:
                    'Nyeri dada yang lebih terasa seperti nyeri pada bagian tertentu, misalnya sakit saat disentuh, atau terasa seperti nyeri terbakar dari kerongkongan.',
                isDark: isDark,
              ),

              const SizedBox(height: 12),

              _buildChestPainOption(
                title: 'Asymptomatic',
                description: 'Tidak mengalami gejala atau nyeri dada.',
                isDark: isDark,
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Pertanyaan 2
        Text(
          '2. Berapa tekanan darah anda saat pemeriksaan?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 8),

        _buildMeasurementInput(
          controller: _systolicController,
          unit: 'mmHg',
          isDark: isDark,
        ),

        const SizedBox(height: 4),

        Text(
          '(Masukkan nilai sistolik, contoh: 120)',
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),

        const SizedBox(height: 18),

        // Pertanyaan 3
        Text(
          '3. Berapa kadar kolestrol anda berdasarkan hasil pemeriksaan?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 8),

        _buildMeasurementInput(
          controller: _cholesterolController,
          unit: 'mg/dL',
          isDark: isDark,
        ),

        const SizedBox(height: 4),

        Text(
          '(contoh: 200)',
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildChestPainOption({
    required String title,
    required String description,
    required bool isDark,
  }) {
    final bool isSelected = _selectedChestPain == title;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedChestPain = title;
        });
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryTeal : (isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1)),
                  width: 1.5,
                ),
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryTeal,
                        ),
                      ),
                    )
                  : null,
            ),
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
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 3 - KONDISI KESEHATAN (Pertanyaan 4, 5, 6)
  // ============================================================
  Widget _buildStep3KondisiKesehatan(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kondisi Kesehatan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 12),

        // Pertanyaan 4
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '4. Apakah kadar gula darah puasa anda lebih dari 120 mg/dL?',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  _buildYesNoChoiceButton(
                    label: 'Tidak',
                    isSelected: _fastingBloodSugar == 'Tidak',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _fastingBloodSugar = 'Tidak';
                      });
                    },
                  ),
                  const SizedBox(width: 14),
                  _buildYesNoChoiceButton(
                    label: 'Ya',
                    isSelected: _fastingBloodSugar == 'Ya',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _fastingBloodSugar = 'Ya';
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Pertanyaan 5
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '5. Bagaimana hasil pemeriksaan EKG saat istirahat?',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 12),

              _buildEcgRadioOption('Normal', isDark),
              const SizedBox(height: 10),
              _buildEcgRadioOption('Terdapat kelainan gelombang ST-T', isDark),
              const SizedBox(height: 10),
              _buildEcgRadioOption('Kemungkinan hipertrofi vertikal kiri', isDark),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Pertanyaan 6
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '6. Berapa detak jantung maksimum yang tercatat saat pemeriksaan?',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 10),

              _buildMeasurementInput(
                controller: _maxHeartRateController,
                unit: 'bpm',
                isDark: isDark,
              ),

              const SizedBox(height: 4),

              Text(
                '(contoh: 150)',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // ============================================================
  // STEP 4 - KONDISI KESEHATAN (Pertanyaan 7, 8, 9)
  // Sesuai Figma Layar 1
  // ============================================================
  Widget _buildStep4KondisiKesehatan(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kondisi Kesehatan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 12),

        // Pertanyaan 7: Nyeri dada saat aktivitas
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '7. Apakah anda mengalami nyeri dada saat melakukan aktivitas atau olahraga?',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  _buildYesNoChoiceButton(
                    label: 'Tidak',
                    isSelected: _exerciseAngina == 'Tidak',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _exerciseAngina = 'Tidak';
                      });
                    },
                  ),
                  const SizedBox(width: 14),
                  _buildYesNoChoiceButton(
                    label: 'Ya',
                    isSelected: _exerciseAngina == 'Ya',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _exerciseAngina = 'Ya';
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Pertanyaan 8: Oldpeak
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '8. Berapa nilai perubahan segmen ST (oldpeak) dari hasil pemeriksaan?',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 10),

              _buildMeasurementInput(
                controller: _oldpeakController,
                unit: '(mm)',
                hintText: 'Contoh: 1.0',
                isDark: isDark,
              ),

              const SizedBox(height: 4),

              Text(
                '(Masukkan nilai depresi ST, contoh: 1.0)',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Pertanyaan 9: Kemiringan ST
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '9. Bagaimana kemiringan segmen ST saat pemeriksaan aktivitas?',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 12),

              _buildSlopeRadioOption('Upsloping (Meningkat)', isDark),
              const SizedBox(height: 10),
              _buildSlopeRadioOption('Flat (Datar)', isDark),
              const SizedBox(height: 10),
              _buildSlopeRadioOption('Downsloping (Menurun)', isDark),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // ============================================================
  // STEP 5 - KONDISI KESEHATAN (Pertanyaan 10, 11)
  // Sesuai Figma Layar 2
  // ============================================================
  Widget _buildStep5KondisiKesehatan(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kondisi Kesehatan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 12),

        // Pertanyaan 10: Pembuluh darah utama (ca: 0 - 4)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '10. Berapa jumlah pembuluh darah yang terlihat pada pemeriksaan',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 16),

              // Pilihan angka melingkar: 0, 1, 2, 3, 4
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMajorVesselOption(0, isDark),
                  _buildMajorVesselOption(1, isDark),
                  _buildMajorVesselOption(2, isDark),
                  _buildMajorVesselOption(3, isDark),
                  _buildMajorVesselOption(4, isDark),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Pertanyaan 11: Hasil pemeriksaan thal
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '11. Bagaimana hasil pemeriksaan thal?',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 12),

              _buildThalRadioOption('Normal', isDark),
              const SizedBox(height: 10),
              _buildThalRadioOption('Fixed defect (Kelainan Menetap)', isDark),
              const SizedBox(height: 10),
              _buildThalRadioOption(
                  'Reversible defect (Kelainan dapat diperbaiki)', isDark),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // ============================================================
  // HELPER WIDGETS
  // ============================================================

  Widget _buildMajorVesselOption(int value, bool isDark) {
    final bool isSelected = _majorVessels == value;

    return InkWell(
      onTap: () {
        setState(() {
          _majorVessels = value;
        });
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? primaryTeal : (isDark ? const Color(0xFF0F172A) : Colors.white),
          border: Border.all(
            color: isSelected ? primaryTeal : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryTeal.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlopeRadioOption(String value, bool isDark) {
    final bool isSelected = _stSlope == value;

    return InkWell(
      onTap: () {
        setState(() {
          _stSlope = value;
        });
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? primaryTeal : (isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1)),
                width: 1.5,
              ),
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryTeal,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThalRadioOption(String value, bool isDark) {
    final bool isSelected = _thal == value;

    return InkWell(
      onTap: () {
        setState(() {
          _thal = value;
        });
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? primaryTeal : (isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1)),
                width: 1.5,
              ),
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryTeal,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYesNoChoiceButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: isSelected ? primaryTeal : (isDark ? const Color(0xFF0F172A) : Colors.white),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? primaryTeal : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEcgRadioOption(String value, bool isDark) {
    final bool isSelected = _restingEcg == value;

    return InkWell(
      onTap: () {
        setState(() {
          _restingEcg = value;
        });
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? primaryTeal : (isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1)),
                width: 1.5,
              ),
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryTeal,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementInput({
    required TextEditingController controller,
    required String unit,
    String? hintText,
    required bool isDark,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFF8BB5CE),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}