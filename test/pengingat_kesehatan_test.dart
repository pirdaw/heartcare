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

    // Verifikasi Header Pengingat Obat
    expect(find.text('Pengingat Obat'), findsOneWidget);
    expect(find.text('Atur alarm & jadwal minum obat harianmu'), findsOneWidget);

    // Verifikasi Stats Summary Card (Total Obat, Alarm Aktif, Jam Terdekat)
    expect(find.text('Total Obat'), findsOneWidget);
    expect(find.text('Alarm Aktif'), findsWidgets);
    expect(find.text('Jam Terdekat'), findsOneWidget);

    // Verifikasi Header Pilih Menu Pengingat
    expect(find.text('Pilih Menu Pengingat'), findsOneWidget);

    // Verifikasi 2 Card Menu Utama (Bus & MRT style)
    expect(find.text('Jadwal Alarm Obat'), findsWidgets);
    expect(find.text('Daftar Obat yang Dimasukkan'), findsWidgets);

    // Verifikasi Hero Card Alarm pada menu Jadwal Alarm
    expect(find.text('ALARM BERIKUTNYA'), findsOneWidget);
    expect(find.text('Jam HP'), findsWidgets);

    // Tap Card Daftar Obat yang Dimasukkan untuk beralih ke Menu 2
    final card2 = find.text('Daftar Obat yang Dimasukkan').first;
    await tester.ensureVisible(card2);
    await tester.tap(card2);
    await tester.pumpAndSettle();

    // Verifikasi Section Daftar Obat yang Dimasukkan ketika kosong
    expect(find.text('Belum ada obat yang dimasukkan'), findsOneWidget);
    expect(find.text('+ Tambah Obat Baru'), findsOneWidget);
  });

  testWidgets(
      'Navigasi ke Form Tambah Obat dari tombol tambah di PengingatKesehatanPage',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PengingatKesehatanPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap tombol Tambah di header atas
    await tester.tap(find.text('Tambah').first);
    await tester.pumpAndSettle();

    // Cek tampilan Form Tambah Obat (Slide 3)
    expect(find.text('Tambah Obat'), findsOneWidget);
    expect(find.text('Nama Obat'), findsOneWidget);
    expect(find.text('Jumlah Obat'), findsOneWidget);
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

    // Cek masuk langsung ke menu Daftar Obat yang Dimasukkan
    expect(find.text('Daftar Obat yang Dimasukkan'), findsWidgets);
    expect(find.text('Aspirin 300 mg'), findsOneWidget);
  });

  testWidgets('Fitur edit obat mengubah data obat dan kembali ke Gambar 2',
      (WidgetTester tester) async {
    HealthReminderController().addMedicine(
      MedicineReminder(
        id: 'edit_test_1',
        name: 'Aspirin Kardio',
        amount: '1',
        unit: 'Tablet',
        schedule: 'Setelah makan ya',
        reminderTimes: ['08.00'],
        note: 'Setelah sarapan',
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: PengingatKesehatanPage(initialMenuIndex: 1),
      ),
    );
    await tester.pumpAndSettle();

    // Pastikan nama obat awal tampil
    expect(find.text('Aspirin Kardio'), findsOneWidget);

    // Klik tombol edit (ikon pensil)
    final editButton = find.byTooltip('Edit Obat');
    expect(editButton, findsWidgets);
    await tester.ensureVisible(editButton.first);
    await tester.tap(editButton.first);
    await tester.pumpAndSettle();

    // Verifikasi berada di form Edit Obat
    expect(find.text('Edit Obat'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);

    // Ubah nama obat
    final nameField = find.widgetWithText(TextField, 'Aspirin Kardio');
    await tester.enterText(nameField, 'Aspirin Kardio 100 mg');

    // Klik Simpan Perubahan
    await tester.ensureVisible(find.text('Simpan Perubahan'));
    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();

    // Verifikasi langsung kembali ke Gambar 2 dengan data terbaru
    expect(find.text('Daftar Obat yang Dimasukkan'), findsWidgets);
    expect(find.text('Aspirin Kardio 100 mg'), findsOneWidget);
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

  testWidgets(
      'PengingatKesehatanPage displays alarm switches and medicine list when populated',
      (WidgetTester tester) async {
    // Tambahkan obat sample ke controller
    HealthReminderController().addMedicine(
      MedicineReminder(
        id: 'amlodipine_test',
        name: 'Amlodipine 5 mg',
        amount: '1',
        unit: 'Tablet',
        schedule: 'Setelah makan siang (Hipertensi)',
        reminderTimes: ['13.00'],
        note: 'Setelah makan siang ya',
        isAlarmEnabled: true,
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: PengingatKesehatanPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Verifikasi Hero Alarm Card
    expect(find.text('13.00'), findsWidgets);
    expect(find.text('Amlodipine 5 mg (1 Tablet)'), findsOneWidget);
    expect(find.text('1 Alarm'), findsWidgets);

    // Verifikasi Tombol Pasang Alarm HP (Menggantikan Switch)
    final pasangAlarmFinder = find.text('Pasang Alarm HP');
    expect(pasangAlarmFinder, findsWidgets);

    // Tap tombol Pasang Alarm HP
    await tester.ensureVisible(pasangAlarmFinder.first);
    await tester.tap(pasangAlarmFinder.first);
    await tester.pumpAndSettle();

    // Beralih ke Card Daftar Obat yang Dimasukkan
    final daftarObatCard = find.text('Daftar Obat yang Dimasukkan').first;
    await tester.ensureVisible(daftarObatCard);
    await tester.tap(daftarObatCard);
    await tester.pumpAndSettle();

    // Verifikasi daftar obat di bawahnya
    expect(find.text('1 Obat'), findsOneWidget);
    expect(find.text('Amlodipine 5 mg'), findsWidgets);
    expect(find.text('Minum Sekarang'), findsNothing);
    expect(find.text('Belum Diminum'), findsNothing);
  });

  testWidgets('SnackBar notifikasi otomatis hilang setelah beberapa saat',
      (WidgetTester tester) async {
    HealthReminderController().addMedicine(
      MedicineReminder(
        id: 'test_auto_dismiss',
        name: 'Amlodipine 5 mg',
        amount: '1',
        unit: 'Tablet',
        schedule: 'Pagi',
        reminderTimes: ['08.00'],
        note: '',
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: PengingatKesehatanPage(),
      ),
    );
    await tester.pumpAndSettle();

    final pasangAlarmFinder = find.text('Pasang Alarm HP');
    await tester.ensureVisible(pasangAlarmFinder.first);
    await tester.tap(pasangAlarmFinder.first);
    await tester.pump(); // frame saat SnackBar muncul

    // Notifikasi SnackBar muncul
    expect(
        find.textContaining('berhasil dipasang ke jam HP!'), findsOneWidget);

    // Majukan waktu 3 detik melebihi durasi 2500ms
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    // Notifikasi SnackBar sudah otomatis hilang
    expect(
        find.textContaining('berhasil dipasang ke jam HP!'), findsNothing);
  });

  testWidgets('Alarm terurut secara kronologis dan nextAlarmItem menghitung jam terdekat',
      (WidgetTester tester) async {
    final controller = HealthReminderController();
    controller.medicines.clear();

    controller.addMedicine(
      MedicineReminder(
        id: 'amox',
        name: 'Amoxicilin 5 mg',
        amount: '1',
        unit: 'Tablet',
        schedule: 'Setelah makan siang',
        reminderTimes: ['13.00'],
        note: '',
      ),
    );
    controller.addMedicine(
      MedicineReminder(
        id: 'asp',
        name: 'aspirin',
        amount: '3',
        unit: 'Tablet',
        schedule: 'Setelah makan ya',
        reminderTimes: ['07.30', '15.30', '22.00'],
        note: '',
      ),
    );

    // Verifikasi sortedAlarms mengurutkan dari jam terkecil: 07.30, 13.00, 15.30, 22.00
    final sorted = controller.sortedAlarms;
    expect(sorted.length, 4);
    expect(sorted[0].time, '07.30');
    expect(sorted[0].medicine.name, 'aspirin');
    expect(sorted[1].time, '13.00');
    expect(sorted[1].medicine.name, 'Amoxicilin 5 mg');
    expect(sorted[2].time, '15.30');
    expect(sorted[2].medicine.name, 'aspirin');
    expect(sorted[3].time, '22.00');
    expect(sorted[3].medicine.name, 'aspirin');

    // nextAlarmItem menghasilkan alarm yang valid dan tidak null
    final nextAlarm = controller.nextAlarmItem;
    expect(nextAlarm, isNotNull);
  });
}
