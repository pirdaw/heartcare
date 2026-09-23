import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/pages/home_page.dart';
import 'package:heartcare/pages/konfirmasi_jadwal_page.dart';
import 'package:heartcare/pages/konsultasi_dokter_page.dart';
import 'package:heartcare/pages/pilih_jadwal_page.dart';

void main() {
  testWidgets('PilihJadwalPage renders all days, time slots, and navigates to KonfirmasiJadwalPage (not a dialog)', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PilihJadwalPage(
          doctorName: 'dr. Andi Pratama',
          doctorSpecialty: 'Spesialis Jantung & Pembuluh Darah',
          doctorPhoto: 'assets/images/dokter_andi.jpg',
        ),
      ),
    );

    // Verify Title & Month
    expect(find.text('Pilih Jadwal'), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);

    // Verify Days are rendered
    expect(find.text('Sen'), findsOneWidget);
    expect(find.text('Sel'), findsOneWidget);
    expect(find.text('Rab'), findsOneWidget);
    expect(find.text('Kam'), findsOneWidget);
    expect(find.text('Jum'), findsOneWidget);
    expect(find.text('Sab'), findsOneWidget);
    expect(find.text('Min'), findsOneWidget);

    // Verify Time sections
    expect(find.text('Pagi'), findsOneWidget);
    expect(find.text('Siang'), findsOneWidget);
    expect(find.text('Sore'), findsOneWidget);

    // Select day 3 (Rab) and time 13.00
    await tester.tap(find.text('Rab'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('13.00'));
    await tester.pumpAndSettle();

    // Tap on Konfirmasi Jadwal
    await tester.tap(find.text('Konfirmasi Jadwal'));
    await tester.pumpAndSettle();

    // Verify NO AlertDialog popup was opened
    expect(find.byType(AlertDialog), findsNothing);

    // Verify it navigated to KonfirmasiJadwalPage
    expect(find.byType(KonfirmasiJadwalPage), findsOneWidget);
    expect(find.text('Jadwal Berhasil Dipilih!'), findsOneWidget);
    expect(find.text('dr. Andi Pratama'), findsOneWidget);
    expect(find.text('Rab, 3 September 2026'), findsOneWidget);
    expect(find.text('Pukul 13.00 WIB'), findsOneWidget);

    // Verify the two requested action buttons exist
    expect(find.text('Konsultasi Dokter Lewat Chat'), findsOneWidget);
    expect(find.text('Kembali ke Beranda'), findsOneWidget);

    // Test Action 1: Tapping "Konsultasi Dokter Lewat Chat" opens KonsultasiDokterPage
    await tester.tap(find.text('Konsultasi Dokter Lewat Chat'));
    await tester.pumpAndSettle();
    expect(find.byType(KonsultasiDokterPage), findsOneWidget);
    expect(find.text('dr. Andi Pratama'), findsOneWidget);
  });

  testWidgets('KonfirmasiJadwalPage tapping Kembali ke Beranda returns to HomePage', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: KonfirmasiJadwalPage(
          doctorName: 'dr. Sinta Maharani',
          doctorSpecialty: 'Spesialis Jantung & Kardiovaskular',
          doctorPhoto: 'assets/images/dokter_sinta.jpg',
          selectedDate: 'Jum, 5 September 2026',
          selectedTime: '10.00',
        ),
      ),
    );

    expect(find.byType(KonfirmasiJadwalPage), findsOneWidget);
    expect(find.text('Kembali ke Beranda'), findsOneWidget);

    // Scroll to make sure button is within viewport bounds
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();

    // Tap Kembali ke Beranda
    await tester.tap(find.text('Kembali ke Beranda'));
    await tester.pumpAndSettle();

    // Verify it navigated to HomePage
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(KonfirmasiJadwalPage), findsNothing);
  });
}
