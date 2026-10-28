import 'package:flutter/material.dart';
import 'custom_bottom_nav_bar.dart';

/// Halaman Skrining - Input Data dengan Stepper bertahap (1/3 s/d 3/3)
class ScreeningInputPage extends StatefulWidget {
  const ScreeningInputPage({super.key});

  @override
  State<ScreeningInputPage> createState() => _ScreeningInputPageState();
}

class _ScreeningInputPageState extends State<ScreeningInputPage> {
  static const Color primaryTeal = Color(0xFF0098B9);

  int _currentStep = 1;
  final int _totalSteps = 3;

  // ============================================================
  // FORM STEP 1 - DATA DIRI
  // ============================================================

  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;

  // ============================================================
  // FORM STEP 2 - KONDISI KESEHATAN
  // ============================================================

  String? _selectedChestPain;
  final TextEditingController _systolicController =
      TextEditingController();
  final TextEditingController _cholesterolController =
      TextEditingController();

  // ============================================================
  // FORM STEP 3 - KONDISI KESEHATAN LANJUTAN
  // ============================================================

  String? _fastingBloodSugar;
  String? _restingEcg;
  final TextEditingController _maxHeartRateController =
      TextEditingController();

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _ageController.dispose();
    _systolicController.dispose();
    _cholesterolController.dispose();
    _maxHeartRateController.dispose();
    super.dispose();
  }

  // ============================================================
  // NAVIGASI STEP
  // ============================================================

  void _onNextStep() {
    if (_currentStep == 1) {
      // Validasi sederhana jika diperlukan
      if (_ageController.text.isEmpty && _selectedGender == null) {
        // Tetap diperbolehkan lanjut
      }
    }

    if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
      });
    } else {
      _showResultDialog();
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
  // HASIL ANALISIS
  // ============================================================

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.favorite,
              color: primaryTeal,
            ),
            SizedBox(width: 8),
            Text('Hasil Analisis AI'),
          ],
        ),
        content: const Text(
          'Data skrining kesehatan jantung Anda telah berhasil dianalisis dengan AI HeartCare.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Selesai',
              style: TextStyle(
                color: primaryTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD UTAMA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        onPressed: _onPreviousStep,
                      ),
                    ),
                  ),

                  Center(
                    child: Text(
                      'Skrining - Input Data ($_currentStep/$_totalSteps)',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ----------------------------------------------------
            // STEPPER
            // ----------------------------------------------------

            Center(
              child: _buildStepper(),
            ),

            const SizedBox(height: 28),

            // ----------------------------------------------------
            // FORM CONTENT
            // ----------------------------------------------------

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildCurrentStepContent(),
              ),
            ),

            // ----------------------------------------------------
            // BUTTON
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
                  child: Text(
                    _currentStep == _totalSteps
                        ? 'Analisis Sekarang'
                        : 'Lanjutkan',
                    style: const TextStyle(
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
  }

  // ============================================================
  // STEPPER
  // ============================================================

  Widget _buildStepper() {
    return SizedBox(
      width: 215,
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
                      : const Color(0xFFD1D5DB),
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
                      : const Color(0xFFE5E7EB),
                ),
                child: Center(
                  child: Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: (isActive || isCompleted)
                          ? Colors.white
                          : const Color(0xFF6B7280),
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

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1DataDiri();

      case 2:
        return _buildStep2Vital();

      case 3:
        return _buildStep3KondisiKesehatan();

      default:
        return _buildStep1DataDiri();
    }
  }

  // ============================================================
  // STEP 1 - DATA DIRI
  // ============================================================

  Widget _buildStep1DataDiri() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Diri',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Usia',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
        ),

        const SizedBox(height: 8),

        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF8BB5CE),
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF111827),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Jenis Kelamin',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            _buildRadioOption('Laki-laki'),
            const SizedBox(width: 50),
            _buildRadioOption('Perempuan'),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption(String value) {
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
                color: isSelected
                    ? primaryTeal
                    : const Color(0xFF94A3B8),
                width: 1.5,
              ),
              color: Colors.white,
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
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 2 - KONDISI KESEHATAN
  // ============================================================

  Widget _buildStep2Vital() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kondisi Kesehatan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '1. Bagaimana nyeri dada yang anda rasakan?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 14),

              _buildChestPainOption(
                title: 'Typical Angina',
                description:
                    'Rasa tertekan atau tidak nyaman di dada yang biasanya muncul saat beraktivitas dan dapat berkurang saat beristirahat.',
              ),

              const SizedBox(height: 12),

              _buildChestPainOption(
                title: 'Atypical Angina',
                description:
                    'Rasa tidak nyaman di dada yang mungkin muncul dengan cara berbeda, misalnya tidak selalu terasa tertekan atau tidak selalu muncul saat beraktivitas.',
              ),

              const SizedBox(height: 12),

              _buildChestPainOption(
                title: 'Non-anginal Pain',
                description:
                    'Nyeri dada yang lebih terasa seperti nyeri pada bagian tertentu, misalnya sakit saat disentuh, atau terasa seperti nyeri terbakar dari kerongkongan.',
              ),

              const SizedBox(height: 12),

              _buildChestPainOption(
                title: 'Asymptomatic',
                description:
                    'Tidak mengalami gejala atau nyeri dada.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          '2. Berapa tekanan darah anda saat pemeriksaan?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 8),

        _buildMeasurementInput(
          controller: _systolicController,
          unit: 'mmHg',
        ),

        const SizedBox(height: 4),

        const Text(
          '(Masukkan nilai sistolik, contoh: 130)',
          style: TextStyle(
            fontSize: 11.5,
            color: Color(0xFF64748B),
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          '3. Berapa kadar kolestrol anda berdasarkan hasil pemeriksaan?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 8),

        _buildMeasurementInput(
          controller: _cholesterolController,
          unit: 'mg/dL',
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildChestPainOption({
    required String title,
    required String description,
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
                  color: isSelected
                      ? primaryTeal
                      : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
                color: Colors.white,
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
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF475569),
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

  Widget _buildMeasurementInput({
    required TextEditingController controller,
    required String unit,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF8BB5CE),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF111827),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          Text(
            unit,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 3 - KONDISI KESEHATAN LANJUTAN
  // ============================================================

  Widget _buildStep3KondisiKesehatan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kondisi Kesehatan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '4. Apakah kadar gula darah puasa anda lebih dari 120 mg/dL?',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  _buildYesNoChoiceButton(
                    label: 'Tidak',
                    isSelected: _fastingBloodSugar == 'Tidak',
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

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '5. Bagaimana hasil pemeriksaan EKG saat istirahat?',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 12),

              _buildEcgRadioOption('Normal'),

              const SizedBox(height: 10),

              _buildEcgRadioOption(
                'Terdapat kelainan gelombang ST-T',
              ),

              const SizedBox(height: 10),

              _buildEcgRadioOption(
                'Kemungkinan hipertrofi vertikal kiri',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '6. Berapa detak jantung maksimum yang tercatat saat pemeriksaan?',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 10),

              _buildMeasurementInput(
                controller: _maxHeartRateController,
                unit: 'bpm',
              ),

              const SizedBox(height: 4),

              const Text(
                '(contoh: 150)',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildYesNoChoiceButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: isSelected
                ? primaryTeal
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? primaryTeal
                  : const Color(0xFFCBD5E1),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF1E293B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEcgRadioOption(String value) {
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
                color: isSelected
                    ? primaryTeal
                    : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
              color: Colors.white,
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
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}