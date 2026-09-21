import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/pages/pengingat_kesehatan_page.dart';

void main() {
  setUp(() {
    HealthReminderController().medicines.clear();
  });

  testWidgets('PengingatKesehatanPage renders all slide 1 elements',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PengingatKesehatanPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Verifikasi Header
    expect(find.text('Pengingat Kesehatan'), findsOneWidget);
    expect(find.text('Atur pengingat agar tidak melewati kegiatan penting'),
        findsOneWidget);

    // Verifikasi Banner
    expect(find.text('3 Pengingat Hari Ini'), findsOneWidget);
    expect(find.text('Jangan lewatkan jadwal kesehatanmu.'), findsOneWidget);

    // Verifikasi Section "Hari Ini"
    expect(find.text('Hari Ini'), findsOneWidget);
    expect(find.text('Minum Obat'), findsOneWidget);
    expect(find.text('Olahraga Ringan'), findsOneWidget);

    // Verifikasi Pengingat Berikutnya
    expect(find.text('Pengingat Berikutnya'), findsOneWidget);
    expect(find.text('Tidak ada pengingat'), findsOneWidget);
  });

  testWidgets(
      'Navigasi dari Minum Obat saat kosong masuk ke TambahObatEmptyPage (Slide 2)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PengingatKesehatanPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap card Minum Obat
    await tester.tap(find.text('Minum Obat'));
    await tester.pumpAndSettle();

    // Cek tampilan Slide 2
    expect(find.text('Tambah Obat'), findsOneWidget);
    expect(find.text('Belum ada obat yang ditambahkan'), findsOneWidget);
    expect(find.text('+ Tambah Obat'), findsOneWidget);
  });

  testWidgets(
      'Navigasi dari Slide 2 ke Form Tambah Obat (Slide 3) dan Simpan ke Daftar Obat (Slide 4)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TambahObatEmptyPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Klik tombol + Tambah Obat
    await tester.tap(find.text('+ Tambah Obat'));
    await tester.pumpAndSettle();

    // Cek form Slide 3
    expect(find.text('Nama Obat'), findsOneWidget);
    expect(find.text('Jumlah Obat'), findsOneWidget);
    expect(find.text('Jadwal Minum'), findsOneWidget);
    expect(find.text('Waktu Pengingat'), findsOneWidget);
    expect(find.text('Catatan'), findsOneWidget);

    // Isi Nama Obat
    final nameField = find.widgetWithText(TextField, 'Masukkan Nama Obat');
    await tester.enterText(nameField, 'Aspirin 300 mg');

    // Scroll ke tombol Simpan & klik
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // Cek masuk ke Slide 4 (Daftar Obat)
    expect(find.text('Daftar Obat'), findsOneWidget);
    expect(find.text('Aspirin 300 mg'), findsOneWidget);
    expect(find.text('Waktu Pengingat'), findsOneWidget);
    expect(find.text('Catatan'), findsOneWidget);
  });

  testWidgets('Pop-up Pengingat Obat (Slide 5) tampil dengan benar',
      (WidgetTester tester) async {
    final sampleMedicine = MedicineReminder(
      id: 'test-1',
      name: 'Aspirin 300 mg',
      amount: '1',
      unit: 'Tablet',
      schedule: 'Setelah makan ya',
      reminderTimes: ['07.30', '15.30', '22.00'],
      note: 'Setelah makan ya',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showMedicineReminderDialog(
                      context,
                      reminder: sampleMedicine,
                      timeText: 'sekarang',
                    );
                  },
                  child: const Text('Tampilkan Pop-up'),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Buka dialog
    await tester.tap(find.text('Tampilkan Pop-up'));
    await tester.pumpAndSettle();

    // Cek elemen Slide 5
    expect(find.text('Pengingat Obat'), findsOneWidget);
    expect(find.text('sekarang'), findsOneWidget);
    expect(find.text('Saatnya Minum Obat!'), findsOneWidget);
    expect(find.text('Aspirin 300 mg'), findsOneWidget);
    expect(find.text('Sudah Minum'), findsOneWidget);
    expect(find.text('Tunda'), findsOneWidget);

    // Klik tombol Sudah Minum
    await tester.tap(find.text('Sudah Minum'));
    await tester.pumpAndSettle();

    // Dialog tertutup
    expect(find.text('Saatnya Minum Obat!'), findsNothing);
  });
}
