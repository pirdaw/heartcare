import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

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

  /// Mengubah isian pasien menjadi fitur numerik dengan kode PERSIS seperti
  /// dataset pelatihan (heart_baru.xlsx). Nama fitur harus sama dengan
  /// daftar "features" di assets/model/heart_model.json.
  ///
  /// Kolom kategori memakai one-hot: hanya kategori terpilih yang diisi 1,
  /// sisanya dianggap 0 oleh HeartModel.
  Map<String, double> toModelFeatures() {
    final f = <String, double>{
      'age': double.tryParse(age) ?? 0,
      'trestbps': double.tryParse(restingBloodPressure) ?? 0,
      'chol': double.tryParse(cholesterol) ?? 0,
      'thalach': double.tryParse(maxHeartRate) ?? 0,
      'oldpeak': double.tryParse(oldpeak.replaceAll(',', '.')) ?? 0,
      // Dataset hanya memuat ca 0-3 (nilai 4 tidak valid)
      'ca': (majorVessels ?? 0).clamp(0, 3).toDouble(),
      'sex': gender == 'Laki-laki' ? 1.0 : 0.0,
      'fbs': fastingBloodSugar == 'Ya' ? 1.0 : 0.0,
      'exang': exerciseAngina == 'Ya' ? 1.0 : 0.0,
    };

    // cp: 0 = Asymptomatic, 1 = Atypical, 2 = Non-anginal, 3 = Typical Angina
    final cp = chestPainType;
    if (cp != null) {
      if (cp.contains('Asymptomatic')) {
        f['cp_0'] = 1;
      } else if (cp.contains('Atypical')) {
        f['cp_1'] = 1;
      } else if (cp.contains('Non-anginal')) {
        f['cp_2'] = 1;
      } else if (cp.contains('Typical')) {
        f['cp_3'] = 1;
      }
    }

    // restecg: 0 = hipertrofi ventrikel kiri, 1 = normal, 2 = kelainan ST-T
    final ecg = restingEcg;
    if (ecg != null) {
      if (ecg.contains('ST-T')) {
        f['restecg_2'] = 1;
      } else if (ecg.toLowerCase().contains('hipertrofi')) {
        f['restecg_0'] = 1;
      } else if (ecg.contains('Normal')) {
        f['restecg_1'] = 1;
      }
    }

    // slope: 0 = menurun, 1 = datar, 2 = menanjak
    final sl = stSlope;
    if (sl != null) {
      if (sl.contains('Downsloping') || sl.contains('Menurun')) {
        f['slope_0'] = 1;
      } else if (sl.contains('Flat') || sl.contains('Datar')) {
        f['slope_1'] = 1;
      } else if (sl.contains('Upsloping') || sl.contains('Meningkat')) {
        f['slope_2'] = 1;
      }
    }

    // thal: 1 = fixed defect, 2 = normal, 3 = reversible defect
    final th = thal;
    if (th != null) {
      if (th.contains('Fixed')) {
        f['thal_1'] = 1;
      } else if (th.contains('Normal')) {
        f['thal_2'] = 1;
      } else if (th.contains('Reversible')) {
        f['thal_3'] = 1;
      }
    }

    return f;
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'gender': gender,
      'chestPainType': chestPainType,
      'restingBloodPressure': restingBloodPressure,
      'cholesterol': cholesterol,
      'fastingBloodSugar': fastingBloodSugar,
      'restingEcg': restingEcg,
      'maxHeartRate': maxHeartRate,
      'exerciseAngina': exerciseAngina,
      'oldpeak': oldpeak,
      'stSlope': stSlope,
      'majorVessels': majorVessels,
      'thal': thal,
    };
  }

  factory ScreeningData.fromMap(Map<String, dynamic> map) {
    return ScreeningData(
      age: (map['age'] ?? '').toString(),
      gender: map['gender'] as String?,
      chestPainType: map['chestPainType'] as String?,
      restingBloodPressure: (map['restingBloodPressure'] ?? '').toString(),
      cholesterol: (map['cholesterol'] ?? '').toString(),
      fastingBloodSugar: map['fastingBloodSugar'] as String?,
      restingEcg: map['restingEcg'] as String?,
      maxHeartRate: (map['maxHeartRate'] ?? '').toString(),
      exerciseAngina: map['exerciseAngina'] as String?,
      oldpeak: (map['oldpeak'] ?? '').toString(),
      stSlope: map['stSlope'] as String?,
      majorVessels: map['majorVessels'] is num
          ? (map['majorVessels'] as num).toInt()
          : int.tryParse(map['majorVessels']?.toString() ?? ''),
      thal: map['thal'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ScreeningData.fromJson(String source) =>
      ScreeningData.fromMap(jsonDecode(source) as Map<String, dynamic>);

  String toDoctorReport({
    String? patientName,
    HeartRiskResult? result,
  }) {
    final buffer = StringBuffer();
    buffer.writeln("📋 LAPORAN HASIL SKRINING JANTUNG (AI HeartCare)");
    if (patientName != null && patientName.isNotEmpty) {
      buffer.writeln("Nama Pasien: $patientName");
    }
    if (result != null) {
      final pct = result.probability != null
          ? ' (${(result.probability! * 100).toStringAsFixed(1)}%)'
          : '';
      buffer.writeln("Tingkat Risiko: ${result.title}$pct");
      buffer.writeln("Indikasi: ${result.subtitle}");
    }
    buffer.writeln("-----------------------------------------");
    buffer.writeln("PARAMETER KLINIS:");
    buffer.writeln("• Usia: $displayAge | Jenis Kelamin: $displayGender");
    buffer.writeln("• Tipe Nyeri Dada: $displayChestPainType");
    buffer.writeln("• Tekanan Darah Istirahat: $displayBloodPressure");
    buffer.writeln("• Kolesterol Total: $displayCholesterol");
    buffer.writeln("• Gula Darah Puasa (>120 mg/dL): $displayFastingBloodSugar");
    buffer.writeln("• EKG Istirahat: $displayEcg");
    buffer.writeln("• Detak Jantung Maksimum: $displayMaxHeartRate");
    buffer.writeln("• Angina Akibat Aktivitas: $displayExerciseAngina");
    buffer.writeln("• Depresi ST (Oldpeak): $displayOldpeak mm");
    buffer.writeln("• Kemiringan ST: $displayStSlope");
    buffer.writeln("• Pembuluh Darah Utama: $displayMajorVessels");
    buffer.writeln("• Pemeriksaan Thalassemia: $displayThal");
    if (result != null && result.advice.isNotEmpty) {
      buffer.writeln("-----------------------------------------");
      buffer.writeln("Saran AI: ${result.advice}");
    }
    return buffer.toString().trim();
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

  /// Probabilitas berisiko dari model (0.0 - 1.0)
  final double? probability;

  HeartRiskResult({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.advice,
    required this.statusColor,
    required this.backgroundColor,
    this.probability,
  });

  Map<String, dynamic> toMap() {
    return {
      'level': level.name,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'advice': advice,
      'probability': probability,
    };
  }

  factory HeartRiskResult.fromMap(Map<String, dynamic> map) {
    final prob = (map['probability'] as num?)?.toDouble();
    if (prob != null) {
      return HeartRiskAnalyzer.resultFor(prob);
    }
    final lvlStr = (map['level'] as String? ?? 'low').toLowerCase();
    final lvl = RiskLevel.values.firstWhere(
      (e) => e.name.toLowerCase() == lvlStr,
      orElse: () => RiskLevel.low,
    );
    return HeartRiskResult(
      level: lvl,
      title: map['title'] as String? ?? 'RISIKO RENDAH',
      subtitle: map['subtitle'] as String? ?? '',
      description: map['description'] as String? ?? '',
      advice: map['advice'] as String? ?? '',
      statusColor: lvl == RiskLevel.high
          ? const Color(0xFFDC2626)
          : (lvl == RiskLevel.moderate
              ? const Color(0xFFD97706)
              : const Color(0xFF0D9488)),
      backgroundColor: lvl == RiskLevel.high
          ? const Color(0xFFFFD5D5)
          : (lvl == RiskLevel.moderate
              ? const Color(0xFFFEF3C7)
              : const Color(0xFFCCFBF1)),
      probability: prob,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory HeartRiskResult.fromJson(String source) =>
      HeartRiskResult.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

/// Model Logistic Regression hasil pelatihan (lihat ml/train_heart.py).
/// Dimuat dari assets/model/heart_model.json.
class HeartModel {
  static const String assetPath = 'assets/model/heart_model.json';

  final List<String> features;
  final List<double> mean;
  final List<double> scale;
  final List<double> coef;
  final double intercept;

  const HeartModel({
    required this.features,
    required this.mean,
    required this.scale,
    required this.coef,
    required this.intercept,
  });

  factory HeartModel.fromJson(Map<String, dynamic> j) {
    List<double> nums(String k) =>
        (j[k] as List).map((e) => (e as num).toDouble()).toList();
    return HeartModel(
      features: (j['features'] as List).map((e) => e as String).toList(),
      mean: nums('mean'),
      scale: nums('scale'),
      coef: nums('coef'),
      intercept: (j['intercept'] as num).toDouble(),
    );
  }

  static HeartModel? _cache;

  static Future<HeartModel> load() async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(assetPath);
    final model = HeartModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _cache = model;
    return model;
  }

  /// Probabilitas berisiko penyakit jantung (0.0 - 1.0).
  /// Fitur yang tidak ada di [input] dianggap 0 (kategori one-hot tidak terpilih).
  double predictProbability(Map<String, double> input) {
    var z = intercept;
    for (var i = 0; i < features.length; i++) {
      final x = input[features[i]] ?? 0.0;
      z += coef[i] * (x - mean[i]) / scale[i];
    }
    return 1.0 / (1.0 + math.exp(-z));
  }
}

/// Modul Evaluasi Risiko Jantung berbasis model machine learning
/// (Logistic Regression, dilatih dari dataset Cleveland / heart_baru.xlsx).
class HeartRiskAnalyzer {
  /// Ambang batas dari validasi silang (out-of-fold):
  /// < 0.30  -> rendah  (hanya ~12% pasien sakit yang jatuh di sini)
  /// 0.30-0.50 -> sedang
  /// >= 0.50 -> tinggi  (presisi ~0.88)
  static const double moderateThreshold = 0.30;
  static const double highThreshold = 0.50;

  static Future<HeartRiskResult> analyze(ScreeningData data) async {
    final model = await HeartModel.load();
    return analyzeWith(model, data);
  }

  /// Versi sinkron, dipakai juga oleh unit test tanpa rootBundle.
  static HeartRiskResult analyzeWith(HeartModel model, ScreeningData data) {
    final p = model.predictProbability(data.toModelFeatures());
    return resultFor(p);
  }

  static HeartRiskResult resultFor(double p) {
    if (p >= highThreshold) {
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
        probability: p,
      );
    } else if (p >= moderateThreshold) {
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
        probability: p,
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
        probability: p,
      );
    }
  }
}
