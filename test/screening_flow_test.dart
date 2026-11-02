import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/pages/Skrining/screening_model.dart';
import 'package:heartcare/pages/Skrining/screening_input_page.dart';
import 'package:heartcare/pages/Skrining/screening_review_page.dart';
import 'package:heartcare/pages/Skrining/screening_result_page.dart';

void main() {
  group('Screening Model & Analyzer Tests', () {
    test('ScreeningData formatting displays correct strings', () {
      final data = ScreeningData(
        age: '25',
        gender: 'Laki-laki',
        chestPainType: 'Typical Angina',
        restingBloodPressure: '120',
        cholesterol: '200',
        fastingBloodSugar: 'Tidak',
        restingEcg: 'Normal',
        maxHeartRate: '150',
        exerciseAngina: 'Tidak',
        oldpeak: '1.0',
        stSlope: 'Flat (Datar)',
        majorVessels: 0,
        thal: 'Normal',
      );

      expect(data.displayAge, '25 tahun');
      expect(data.displayGender, 'Laki-laki');
      expect(data.displayChestPainType, 'Typical Angina');
      expect(data.displayBloodPressure, '120 mmHg');
      expect(data.displayCholesterol, '200 mg/dL');
      expect(data.displayFastingBloodSugar, 'Tidak (>120)');
      expect(data.displayEcg, 'Normal');
      expect(data.displayMaxHeartRate, '150 bpm');
      expect(data.displayExerciseAngina, 'Tidak');
      expect(data.displayOldpeak, '1,0');
      expect(data.displayStSlope, 'Datar');
      expect(data.displayMajorVessels, '0');
      expect(data.displayThal, 'Normal');
    });

    // Model dimuat langsung dari file (tanpa rootBundle) agar tes tetap sederhana.
    // Nilai probabilitas yang diharapkan dihitung dari scikit-learn
    // (ml/train_heart.py) dengan model yang sama.
    late HeartModel model;
    setUpAll(() {
      final raw = File('assets/model/heart_model.json').readAsStringSync();
      model = HeartModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    });

    test('toModelFeatures memakai kode yang sama dengan dataset', () {
      final f = ScreeningData(
        age: '60',
        gender: 'Laki-laki',
        chestPainType: 'Asymptomatic',
        restingBloodPressure: '150',
        cholesterol: '260',
        fastingBloodSugar: 'Ya',
        restingEcg: 'Kemungkinan hipertrofi vertikal kiri',
        maxHeartRate: '120',
        exerciseAngina: 'Ya',
        oldpeak: '2.5',
        stSlope: 'Flat (Datar)',
        majorVessels: 2,
        thal: 'Reversible defect (Kelainan dapat diperbaiki)',
      ).toModelFeatures();

      expect(f['sex'], 1);
      expect(f['fbs'], 1);
      expect(f['exang'], 1);
      expect(f['ca'], 2);
      expect(f['cp_0'], 1); // Asymptomatic = 0
      expect(f['restecg_0'], 1); // hipertrofi = 0
      expect(f['slope_1'], 1); // datar = 1
      expect(f['thal_3'], 1); // reversible = 3
    });

    test('skenario risiko tinggi menghasilkan RISIKO TINGGI', () {
      final data = ScreeningData(
        age: '60',
        gender: 'Laki-laki',
        chestPainType: 'Asymptomatic',
        restingBloodPressure: '150',
        cholesterol: '260',
        fastingBloodSugar: 'Ya',
        restingEcg: 'Kemungkinan hipertrofi vertikal kiri',
        maxHeartRate: '120',
        exerciseAngina: 'Ya',
        oldpeak: '2.5',
        stSlope: 'Flat (Datar)',
        majorVessels: 2,
        thal: 'Reversible defect (Kelainan dapat diperbaiki)',
      );

      final result = HeartRiskAnalyzer.analyzeWith(model, data);
      expect(result.probability, closeTo(0.981579, 1e-4));
      expect(result.title, 'RISIKO TINGGI');
      expect(result.level, RiskLevel.high);
      expect(result.subtitle, 'Terindikasi risiko penyakit jantung');
    });

    test('skenario sehat menghasilkan RISIKO RENDAH', () {
      final data = ScreeningData(
        age: '35',
        gender: 'Perempuan',
        chestPainType: 'Atypical Angina',
        restingBloodPressure: '115',
        cholesterol: '180',
        fastingBloodSugar: 'Tidak',
        restingEcg: 'Normal',
        maxHeartRate: '185',
        exerciseAngina: 'Tidak',
        oldpeak: '0.0',
        stSlope: 'Upsloping (Meningkat)',
        majorVessels: 0,
        thal: 'Normal',
      );

      final result = HeartRiskAnalyzer.analyzeWith(model, data);
      expect(result.probability, closeTo(0.032898, 1e-4));
      expect(result.level, RiskLevel.low);
    });

    test('sampel Figma (25 th, Typical Angina) kini dinilai oleh model', () {
      // Pada aturan poin lama sampel ini TINGGI. Pada data Cleveland, Typical
      // Angina justru jarang disertai penyakit, sehingga model menilai RENDAH.
      final data = ScreeningData(
        age: '25',
        gender: 'Laki-laki',
        chestPainType: 'Typical Angina',
        restingBloodPressure: '120',
        cholesterol: '200',
        fastingBloodSugar: 'Tidak',
        restingEcg: 'Normal',
        maxHeartRate: '150',
        exerciseAngina: 'Tidak',
        oldpeak: '1.0',
        stSlope: 'Flat (Datar)',
        majorVessels: 0,
        thal: 'Normal',
      );

      final result = HeartRiskAnalyzer.analyzeWith(model, data);
      expect(result.probability, closeTo(0.199710, 1e-4));
      expect(result.level, RiskLevel.low);
    });

    test('batas ambang risiko', () {
      expect(HeartRiskAnalyzer.resultFor(0.29).level, RiskLevel.low);
      expect(HeartRiskAnalyzer.resultFor(0.30).level, RiskLevel.moderate);
      expect(HeartRiskAnalyzer.resultFor(0.49).level, RiskLevel.moderate);
      expect(HeartRiskAnalyzer.resultFor(0.50).level, RiskLevel.high);
    });
  });

  group('Screening Widget Tests', () {
    testWidgets('ScreeningInputPage renders stepper with 5 steps and validates required fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScreeningInputPage(),
        ),
      );

      expect(find.text('Skrining - Input Data (1/5)'), findsOneWidget);
      expect(find.text('Data Diri'), findsOneWidget);
      expect(find.text('Usia'), findsOneWidget);
      expect(find.text('Jenis Kelamin'), findsOneWidget);
      expect(find.text('Laki-laki'), findsOneWidget);
      expect(find.text('Perempuan'), findsOneWidget);
      expect(find.text('Lanjutkan'), findsOneWidget);

      // Tapping Lanjutkan without filling in age or gender should block progress
      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();

      // Still on step 1 (does NOT advance to step 2)
      expect(find.text('Skrining - Input Data (1/5)'), findsOneWidget);
      expect(find.text('Mohon masukkan usia Anda terlebih dahulu.'), findsOneWidget);

      // Fill age only
      await tester.enterText(find.byType(TextField), '30');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();

      // Still on step 1, now asking for gender
      expect(find.text('Skrining - Input Data (1/5)'), findsOneWidget);
      expect(find.text('Mohon pilih jenis kelamin Anda (Laki-laki / Perempuan).'), findsOneWidget);

      // Select gender
      await tester.tap(find.text('Laki-laki'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();

      // Successfully advances to step 2!
      expect(find.text('Skrining - Input Data (2/5)'), findsOneWidget);
      expect(find.text('1. Bagaimana nyeri dada yang anda rasakan?'), findsOneWidget);

      // Tapping Lanjutkan on step 2 without filling questions blocks progress
      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();
      expect(find.text('Skrining - Input Data (2/5)'), findsOneWidget);
      expect(find.text('Mohon pilih jenis nyeri dada yang Anda rasakan (Pertanyaan 1).'), findsOneWidget);
    });

    testWidgets('ScreeningReviewPage renders all 11 fields and confirmation dialog',
        (WidgetTester tester) async {
      final data = ScreeningData(
        age: '25',
        gender: 'Laki-laki',
        chestPainType: 'Typical Angina',
        restingBloodPressure: '120',
        cholesterol: '200',
        fastingBloodSugar: 'Tidak',
        restingEcg: 'Normal',
        maxHeartRate: '150',
        exerciseAngina: 'Tidak',
        oldpeak: '1.0',
        stSlope: 'Flat (Datar)',
        majorVessels: 0,
        thal: 'Normal',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ScreeningReviewPage(data: data),
        ),
      );

      expect(find.text('Periksa kembali data Anda'), findsOneWidget);
      expect(find.text('Usia'), findsOneWidget);
      expect(find.text('25 tahun'), findsOneWidget);
      expect(find.text('Jenis Kelamin'), findsOneWidget);
      expect(find.text('Laki-laki'), findsOneWidget);
      expect(find.text('Jenis Nyeri Dada'), findsOneWidget);
      expect(find.text('Typical Angina'), findsOneWidget);
      expect(find.text('Tekanan Darah'), findsOneWidget);
      expect(find.text('120 mmHg'), findsOneWidget);
      expect(find.text('Kolestrol Total'), findsOneWidget);
      expect(find.text('200 mg/dL'), findsOneWidget);
      expect(find.text('Gula Darah Puasa'), findsOneWidget);
      expect(find.text('Tidak (>120)'), findsOneWidget);
      expect(find.text('EKG'), findsOneWidget);
      expect(find.text('Normal'), findsNWidgets(2)); // EKG & Thal
      expect(find.text('Detak Jantung Maksimum'), findsOneWidget);
      expect(find.text('150 bpm'), findsOneWidget);
      expect(find.text('Nyeri Dada Saat Aktivitas'), findsOneWidget);
      expect(find.text('Oldpeak'), findsOneWidget);
      expect(find.text('1,0'), findsOneWidget);
      expect(find.text('Kemiringan ST'), findsOneWidget);
      expect(find.text('Datar'), findsOneWidget);
      expect(find.text('Pembuluh darah utama'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Hasil pemeriksaan thal'), findsOneWidget);

      // Tap Lanjutkan -> opens confirmation dialog
      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Jawaban'), findsOneWidget);
      expect(find.text('Periksa Lagi'), findsOneWidget);
      expect(find.text('Ya, Analisis'), findsOneWidget);
    });

    testWidgets('ScreeningResultPage renders result card, advice and actions',
        (WidgetTester tester) async {
      final data = ScreeningData(age: '25');
      final result = HeartRiskResult(
        level: RiskLevel.high,
        title: 'RISIKO TINGGI',
        subtitle: 'Terindikasi risiko penyakit jantung',
        description:
            'Berdasarkan data yang anda telah masukkan, terdapat kemungkinan terindikasi penyakit jantung.',
        advice:
            'Disarankan untuk berkonsultasi dengan dokter untuk pemeriksaan lebih lanjut.',
        statusColor: const Color(0xFFDC2626),
        backgroundColor: const Color(0xFFFFD5D5),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ScreeningResultPage(result: result, data: data),
        ),
      );

      expect(find.text('Hasil Skrining'), findsOneWidget);
      expect(find.text('RISIKO TINGGI'), findsOneWidget);
      expect(find.text('Terindikasi risiko penyakit jantung'), findsOneWidget);
      expect(
        find.text(
            'Berdasarkan data yang anda telah masukkan, terdapat kemungkinan terindikasi penyakit jantung.'),
        findsOneWidget,
      );
      expect(find.text('Saran'), findsOneWidget);
      expect(
        find.text(
            'Disarankan untuk berkonsultasi dengan dokter untuk pemeriksaan lebih lanjut.'),
        findsOneWidget,
      );
      expect(find.text('Konsultasi Dokter'), findsOneWidget);
      expect(find.text('Beranda'), findsOneWidget);
    });
  });
}
