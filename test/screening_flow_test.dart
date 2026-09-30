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

    test('HeartRiskAnalyzer analyzes high risk scenario from Figma', () async {
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

      final result = await HeartRiskAnalyzer.analyze(data);
      expect(result.title, 'RISIKO TINGGI');
      expect(result.level, RiskLevel.high);
      expect(result.subtitle, 'Terindikasi risiko penyakit jantung');
    });
  });

  group('Screening Widget Tests', () {
    testWidgets('ScreeningInputPage renders stepper with 5 steps',
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
