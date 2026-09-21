import 'package:flutter/material.dart';

/// Data Model lengkap untuk 11 Pertanyaan Skrining + Data Diri
class ScreeningData {
  // Data Diri
  String age;
  String? gender;

  // Pertanyaan 1, 2, 3 (Step 2)
  String? chestPainType;
  String restingBloodPressure;
  String cholesterol;

  // Pertanyaan 4, 5, 6 (Step 3)
  String? fastingBloodSugar;
  String? restingEcg;
  String maxHeartRate;

  // Pertanyaan 7, 8, 9 (Step 4)
  String? exerciseAngina; // "Tidak" | "Ya"
  String oldpeak; // Depresi segmen ST (mm), contoh "1.0"
  String? stSlope; // "Upsloping (Meningkat)" | "Flat (Datar)" | "Downsloping (Menurun)"

  // Pertanyaan 10, 11 (Step 5)
  int? majorVessels; // 0, 1, 2, 3, 4
  String? thal; // "Normal" | "Fixed defect (Kelainan Menetap)" | "Reversible defect (Kelainan dapat diperbaiki)"

  ScreeningData({
    this.age = '',
    this.gender,
    this.chestPainType,
    this.restingBloodPressure = '',
    this.cholesterol = '',
    this.fastingBloodSugar,
    this.restingEcg,
    this.maxHeartRate = '',
    this.exerciseAngina,
    this.oldpeak = '',
    this.stSlope,
    this.majorVessels,
    this.thal,
  });

  /// Mengonversi format tampilan untuk ringkasan Review
  String get displayAge => age.isNotEmpty ? '$age tahun' : '-';
  String get displayGender => gender ?? '-';
  String get displayChestPainType => chestPainType ?? '-';
  String get displayBloodPressure =>
      restingBloodPressure.isNotEmpty ? '$restingBloodPressure mmHg' : '-';
  String get displayCholesterol =>
      cholesterol.isNotEmpty ? '$cholesterol mg/dL' : '-';

  String get displayFastingBloodSugar {
    if (fastingBloodSugar == 'Ya') return 'Ya (>120)';
    if (fastingBloodSugar == 'Tidak') return 'Tidak (>120)';
    return '-';
  }

  String get displayEcg => restingEcg ?? '-';
  String get displayMaxHeartRate =>
      maxHeartRate.isNotEmpty ? '$maxHeartRate bpm' : '-';
  String get displayExerciseAngina => exerciseAngina ?? '-';

  String get displayOldpeak {
    if (oldpeak.isEmpty) return '-';
    // Format koma sesuai referensi lokal (contoh 1,0)
    return oldpeak.replaceAll('.', ',');
  }

  String get displayStSlope {
    if (stSlope == null) return '-';
    if (stSlope!.contains('Flat') || stSlope!.contains('Datar')) return 'Datar';
    if (stSlope!.contains('Upsloping') || stSlope!.contains('Meningkat')) {
      return 'Meningkat';
    }
    if (stSlope!.contains('Downsloping') || stSlope!.contains('Menurun')) {
      return 'Menurun';
    }
    return stSlope!;
  }

  String get displayMajorVessels =>
      majorVessels != null ? '$majorVessels' : '-';

  String get displayThal {
    if (thal == null) return '-';
    if (thal!.contains('Normal')) return 'Normal';
    if (thal!.contains('Fixed defect')) return 'Fixed defect';
    if (thal!.contains('Reversible defect')) return 'Reversible defect';
    return thal!;
  }
}

/// Hasil evaluasi risiko penyakit jantung
enum RiskLevel { high, moderate, low }

class HeartRiskResult {
  final RiskLevel level;
  final String title;
  final String subtitle;
  final String description;
  final String advice;
  final Color statusColor;
  final Color backgroundColor;

  HeartRiskResult({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.advice,
    required this.statusColor,
    required this.backgroundColor,
  });
}

/// Modul Evaluasi Risiko Jantung (Struktur Siap Integrasi AI / TFLite / REST API)
class HeartRiskAnalyzer {
  /// Evaluasi klinis modular berdasarkan standar Cleveland Heart Disease dataset
  /// Struktur ini dapat dengan mudah dialihkan ke pemanggilan model AI nyata.
  static Future<HeartRiskResult> analyze(ScreeningData data) async {
    // Simulasi delay komputasi / latency model AI
    await Future.delayed(const Duration(milliseconds: 2200));

    int riskPoints = 0;

    // 1. Usia & Gender
    final int age = int.tryParse(data.age) ?? 30;
    if (data.gender == 'Laki-laki' && age >= 45) {
      riskPoints += 1;
    } else if (data.gender == 'Perempuan' && age >= 55) {
      riskPoints += 1;
    }

    // 2. Jenis Nyeri Dada (Typical Angina berisiko paling tinggi)
    if (data.chestPainType == 'Typical Angina') {
      riskPoints += 3;
    } else if (data.chestPainType == 'Atypical Angina') {
      riskPoints += 2;
    } else if (data.chestPainType == 'Non-anginal Pain') {
      riskPoints += 1;
    }

    // 3. Tekanan Darah Sistolik
    final double bp = double.tryParse(data.restingBloodPressure) ?? 120;
    if (bp >= 140) {
      riskPoints += 2;
    } else if (bp >= 130) {
      riskPoints += 1;
    }

    // 4. Kolesterol Total
    final double chol = double.tryParse(data.cholesterol) ?? 180;
    if (chol >= 240) {
      riskPoints += 2;
    } else if (chol >= 200) {
      riskPoints += 1;
    }

    // 5. Gula Darah Puasa > 120 mg/dL
    if (data.fastingBloodSugar == 'Ya') {
      riskPoints += 1;
    }

    // 6. EKG Istirahat
    if (data.restingEcg != null && !data.restingEcg!.contains('Normal')) {
      riskPoints += 2;
    }

    // 7. Nyeri Dada Saat Aktivitas (Exercise Angina)
    if (data.exerciseAngina == 'Ya') {
      riskPoints += 2;
    }

    // 8. Oldpeak (ST depression)
    final double oldpeak =
        double.tryParse(data.oldpeak.replaceAll(',', '.')) ?? 0;
    if (oldpeak >= 2.0) {
      riskPoints += 3;
    } else if (oldpeak >= 1.0) {
      riskPoints += 2;
    }

    // 9. Kemiringan ST (Flat / Downsloping)
    if (data.stSlope != null &&
        (data.stSlope!.contains('Flat') ||
            data.stSlope!.contains('Downsloping'))) {
      riskPoints += 2;
    }

    // 10. Pembuluh darah utama (ca > 0)
    final int vessels = data.majorVessels ?? 0;
    if (vessels > 0) {
      riskPoints += vessels * 2;
    }

    // 11. Hasil Thal (defect)
    if (data.thal != null && !data.thal!.contains('Normal')) {
      riskPoints += 3;
    }

    // Penentuan Kategori Risiko (Figma menampilkan skenario RISIKO TINGGI)
    // Sesuai sampel pada desain Figma: Typical Angina + Kolestrol 200 + ST Datar + Oldpeak 1.0 -> Risiko Tinggi
    if (riskPoints >= 5) {
      return HeartRiskResult(
        level: RiskLevel.high,
        title: 'RISIKO TINGGI',
        subtitle: 'Terindikasi risiko penyakit jantung',
        description:
            'Berdasarkan data yang anda telah masukkan, terdapat kemungkinan terindikasi penyakit jantung.',
        advice:
            'Disarankan untuk berkonsultasi dengan dokter untuk pemeriksaan lebih lanjut.',
        statusColor: const Color(0xFFDC2626), // Merah tegas
        backgroundColor: const Color(0xFFFFD5D5), // Pink salmon lembut Figma
      );
    } else if (riskPoints >= 3) {
      return HeartRiskResult(
        level: RiskLevel.moderate,
        title: 'RISIKO SEDANG',
        subtitle: 'Perlu perhatian pada beberapa indikator kesehatan',
        description:
            'Berdasarkan data yang anda masukkan, terdapat beberapa indikator yang perlu diperhatikan dan dipantau.',
        advice:
            'Disarankan menjaga pola hidup sehat dan menjadwalkan pemeriksaan berkala ke dokter spesialis jantung.',
        statusColor: const Color(0xFFD97706), // Amber
        backgroundColor: const Color(0xFFFEF3C7), // Light amber
      );
    } else {
      return HeartRiskResult(
        level: RiskLevel.low,
        title: 'RISIKO RENDAH',
        subtitle: 'Kondisi jantung dalam batas normal',
        description:
            'Berdasarkan data yang anda masukkan, parameter kesehatan jantung Anda saat ini tergolong normal.',
        advice:
            'Tetap pertahankan gaya hidup sehat, rutin berolahraga, dan konsumsi makanan bergizi seimbang.',
        statusColor: const Color(0xFF0D9488), // Teal
        backgroundColor: const Color(0xFFCCFBF1), // Light teal
      );
    }
  }
}
