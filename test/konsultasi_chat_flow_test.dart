import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/pages/konsultasi_dokter_page.dart';
import 'package:heartcare/pages/home_page.dart';

void main() {
  testWidgets('KonsultasiDokterPage renders initial messages and sends new message with doctor reply', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: KonsultasiDokterPage(
          doctorName: 'dr. Andi Pratama',
          doctorPhoto: 'assets/images/dokter_andi.jpg',
          doctorSpecialty: 'Spesialis Jantung & Pembuluh Darah',
        ),
      ),
    );

    // Initial check: header and initial chat items
    expect(find.text('Konsultasi dengan'), findsOneWidget);
    expect(find.text('dr. Andi Pratama'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Hari ini'), findsOneWidget);
    expect(find.textContaining('Halo Nadea, Selamat datang!'), findsOneWidget);
    expect(find.textContaining('hasilnya risiko tinggi'), findsOneWidget);

    // Send a new message
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, 'Dok, apakah dada berdebar kencang saat tidur normal?');
    await tester.pump();

    // Tap Send button
    final sendButton = find.byIcon(Icons.send);
    expect(sendButton, findsOneWidget);
    await tester.tap(sendButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify typing indicator shown
    expect(find.text('Sedang mengetik...'), findsOneWidget);

    // Fast-forward 1.5 seconds for simulated doctor response
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify typing indicator finished, doctor replied, and user message is present
    expect(find.text('Sedang mengetik...'), findsNothing);
    expect(find.text('Online'), findsOneWidget);
    expect(find.textContaining('Dok, apakah dada berdebar kencang'), findsOneWidget);
    expect(
      find.textContaining('keluhan sesak nafas atau nyeri dada'),
      findsOneWidget,
    );
  });

  testWidgets('KonsultasiDokterPage opens attachment sheet and sends screening attachment', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: KonsultasiDokterPage(
          doctorName: 'dr. Sinta Maharani',
          doctorPhoto: 'assets/images/dokter_sinta.jpg',
          doctorSpecialty: 'Spesialis Jantung Klinis',
        ),
      ),
    );

    // Tap camera / attachment icon
    final cameraIcon = find.byIcon(Icons.camera_alt_outlined);
    expect(cameraIcon, findsOneWidget);
    await tester.tap(cameraIcon);
    await tester.pumpAndSettle();

    // Check bottom sheet contents
    expect(find.text('Kirim Lampiran Medis'), findsOneWidget);
    expect(find.text('Hasil Skrining Jantung'), findsOneWidget);
    expect(find.text('Ambil Foto Keluhan / Resep'), findsOneWidget);

    // Tap on Hasil Skrining Jantung
    await tester.tap(find.text('Hasil Skrining Jantung'));
    await tester.pumpAndSettle();

    // Verify attachment message appears
    expect(find.textContaining('📎 Lampiran: Hasil Skrining Jantung HeartCare'), findsOneWidget);

    // Advance for doctor reply
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(find.textContaining('Terima kasih atas lampirannya'), findsOneWidget);
  });

  testWidgets('KonsultasiDokterPage opens reminder sheet from header', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: KonsultasiDokterPage(
          doctorName: 'dr. Rina Amelia',
          doctorPhoto: 'assets/images/dokter_rina.jpg',
          doctorSpecialty: 'Spesialis Aritmia & Jantung',
        ),
      ),
    );

    // Tap notification bell in header
    final reminderIcon = find.byIcon(Icons.notifications_none_rounded);
    expect(reminderIcon, findsOneWidget);
    await tester.tap(reminderIcon);
    await tester.pumpAndSettle();

    // Check reminder sheet opens
    expect(find.text('Atur Pengingat Konsultasi'), findsOneWidget);
    expect(find.text('dr. Rina Amelia'), findsNWidgets(2)); // header + sheet
    expect(find.text('Simpan Pengingat'), findsOneWidget);
  });

  testWidgets('KonsultasiDokterPage back button returns to HomePage', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: KonsultasiDokterPage(
          doctorName: 'dr. Andi Pratama',
        ),
      ),
    );

    // Tap top-left chevron back button
    final backButton = find.byIcon(Icons.chevron_left);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Verify user is navigated to HomePage
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Hallo, Nadea...'), findsOneWidget);
  });
}
