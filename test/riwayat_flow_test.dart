import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/pages/riwayat_page.dart';
import 'package:heartcare/pages/detail_riwayat_skrining_page.dart';
import 'package:heartcare/pages/detail_riwayat_konsultasi_page.dart';

void main() {
  testWidgets('RiwayatPage renders all 3 history cards with clean screening results and doctor card', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RiwayatPage(),
      ),
    );

    // Verify Title & Header
    expect(find.text('Riwayat'), findsNWidgets(2)); // AppBar + Bottom Nav
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

    // Verify Card 1 (Screening TINGGI - Hasil Skrining)
    expect(find.text('12 November 2025 • 10.59'), findsOneWidget);
    expect(find.text('TINGGI'), findsOneWidget);
    expect(find.text('Hasil Skrining: Risiko Tinggi'), findsOneWidget);

    // Verify Card 2 (Konsultasi SELESAI)
    expect(find.text('dr. Nurlitta Dwi'), findsOneWidget);
    expect(find.text('06 Agustus 2025 • 17.23'), findsOneWidget);
    expect(find.text('Konsultasi online'), findsOneWidget);
    expect(find.text('SELESAI'), findsOneWidget);

    // Verify Card 3 (Screening RENDAH - Hasil Skrining)
    expect(find.text('12 April 2025 • 10.59'), findsOneWidget);
    expect(find.text('RENDAH'), findsOneWidget);
    expect(find.text('Hasil Skrining: Risiko Rendah'), findsOneWidget);

    // Verify 3 "Lihat Detail" buttons
    expect(find.text('Lihat Detail'), findsNWidgets(3));
  });

  testWidgets('Tapping Lihat Detail on Card 1 opens DetailRiwayatSkriningPage with high risk data', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RiwayatPage(),
      ),
    );

    // Tap first Lihat Detail
    await tester.tap(find.text('Lihat Detail').first);
    await tester.pumpAndSettle();

    // Verify DetailRiwayatSkriningPage is opened
    expect(find.byType(DetailRiwayatSkriningPage), findsOneWidget);
    expect(find.text('Detail Riwayat Skrining'), findsOneWidget);
    expect(find.text('TINGGI'), findsOneWidget);
    expect(find.text('Hasil Skrining: Risiko Tinggi'), findsOneWidget);

    // Verify user input section & vital parameters
    expect(find.text('Data yang Dimasukkan'), findsOneWidget);
    expect(find.text('Data Diri & Pengukuran Vital'), findsOneWidget);
    expect(find.text('52 tahun'), findsOneWidget);
    expect(find.text('Laki-laki'), findsOneWidget);
    expect(find.text('160 mmHg'), findsOneWidget);
    expect(find.text('280 mg/dL'), findsOneWidget);

    // Verify cardiac details
    expect(find.text('Typical Angina'), findsOneWidget);
    expect(find.text('Hypertrophy'), findsOneWidget);
    expect(find.text('180 bpm'), findsOneWidget);

    // Verify buttons
    expect(find.text('Konsultasi Dokter Sekarang'), findsOneWidget);
    expect(find.text('Kembali ke Riwayat'), findsOneWidget);

    // Tap back button in AppBar
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(RiwayatPage), findsOneWidget);
  });

  testWidgets('Tapping Lihat Detail on Card 2 opens DetailRiwayatKonsultasiPage with only session info and 3 action buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RiwayatPage(),
      ),
    );

    // Tap second Lihat Detail (Doctor consultation)
    await tester.tap(find.text('Lihat Detail').at(1));
    await tester.pumpAndSettle();

    // Verify DetailRiwayatKonsultasiPage is opened
    expect(find.byType(DetailRiwayatKonsultasiPage), findsOneWidget);
    expect(find.text('Detail Riwayat Konsultasi'), findsOneWidget);
    expect(find.text('dr. Nurlitta Dwi'), findsOneWidget);
    expect(find.text('SELESAI'), findsOneWidget);
    expect(find.text('RS Harapan Jantung, Jember'), findsOneWidget);

    // Verify Session Info (Waktu, Jenis Layanan, No. SIP)
    expect(find.text('Informasi Sesi Konsultasi'), findsOneWidget);
    expect(find.text('Waktu Konsultasi'), findsOneWidget);
    expect(find.text('Jenis Layanan'), findsOneWidget);
    expect(find.text('No. SIP Dokter'), findsOneWidget);
    expect(find.text('1804/SIP/2021'), findsOneWidget);

    // Verify NO diagnosis notes or prescriptions
    expect(find.text('Diagnosis & Catatan Medis'), findsNothing);
    expect(find.text('Anjuran Tindak Lanjut'), findsNothing);
    expect(find.text('Rekomendasi Terapi / Obat'), findsNothing);

    // Verify 3 specified action buttons
    expect(find.text('Lihat Ruang Chat'), findsOneWidget);
    expect(find.text('Konsultasi ke Dokter Lainnya'), findsOneWidget);
    expect(find.text('Kembali ke Menu Riwayat'), findsOneWidget);

    // Tap Kembali ke Menu Riwayat
    await tester.tap(find.text('Kembali ke Menu Riwayat'));
    await tester.pumpAndSettle();

    expect(find.byType(RiwayatPage), findsOneWidget);
  });

  testWidgets('Tapping Lihat Detail on Card 3 opens DetailRiwayatSkriningPage with low risk data', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RiwayatPage(),
      ),
    );

    // Scroll down slightly so card 3 button is fully in view
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    // Tap third Lihat Detail
    await tester.tap(find.text('Lihat Detail').last);
    await tester.pumpAndSettle();

    // Verify DetailRiwayatSkriningPage is opened
    expect(find.byType(DetailRiwayatSkriningPage), findsOneWidget);
    expect(find.text('RENDAH'), findsOneWidget);
    expect(find.text('Hasil Skrining: Risiko Rendah'), findsOneWidget);

    // Verify user input data
    expect(find.text('24 tahun'), findsOneWidget);
    expect(find.text('Perempuan'), findsOneWidget);
    expect(find.text('115 mmHg'), findsOneWidget);
    expect(find.text('175 mg/dL'), findsOneWidget);
  });
}
