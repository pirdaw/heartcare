import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/pages/pengingat_kesehatan_page.dart';

void main() {
  setUp(() {
    HealthReminderController().medicines.clear();
    HealthReminderController().exercises.clear();
  });

  testWidgets('PengingatKesehatanPage renders all slide 1 elements & quick tests',
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

    // Verifikasi Tombol Uji Notifikasi
    expect(find.text('Uji Tampilan Notifikasi Pengingat'), findsOneWidget);
    expect(find.text('Notif Obat'), findsOneWidget);
    expect(find.text('Notif Olahraga'), findsOneWidget);
  });

  testWidgets(
      'Navigasi Olahraga Ringan: Slide 1 -> Slide 2 (Intro) -> Slide 3 (Form) -> Slide 4 (Atur)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PengingatKesehatanPage(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Tap Olahraga Ringan pada Slide 1
    await tester.tap(find.text('Olahraga Ringan'));
    await tester.pumpAndSettle();

    // 2. Tiba di Slide 2 (Tambah Pengingat Olahraga Intro)
    expect(find.text('Tambah Pengingat'), findsOneWidget);
    expect(find.text('Olahraga Ringan'), findsWidgets);
    expect(
        find.text(
            'Jaga tubuh tetap bugar dengan\nolahraga ringan secara rutin'),
        findsOneWidget);
    expect(find.text('Manfaat'), findsOneWidget);
    expect(find.text('Meningkatkan daya tahan tubuh'), findsOneWidget);
    expect(find.text('Menjaga Kesehatan Jantung'), findsOneWidget);
    expect(find.text('Mengurangi Stres'), findsOneWidget);
    expect(find.text('Atur Pengingat'), findsOneWidget);

    // 3. Tap "Atur Pengingat" pada Slide 2 -> Masuk Slide 3 (Form)
    await tester.tap(find.text('Atur Pengingat'));
    await tester.pumpAndSettle();

    // 4. Verifikasi Form Slide 3 (Awalnya Kosongan Sesuai Desain)
    expect(find.text('Jenis Aktivitas'), findsOneWidget);
    expect(find.text('Joging'), findsWidgets);
    expect(find.text('Bersepeda'), findsWidgets);
    expect(find.text('Yoga'), findsWidgets);
    expect(find.text('Jalan Santai'), findsWidgets);
    expect(find.text('Senam Jantung Sehat'), findsWidgets);
    expect(find.text('Jadwal Olahraga'), findsOneWidget);
    expect(find.text('Pengulangan'), findsOneWidget); // Placeholder Pengulangan
    expect(find.text('Waktu Pengingat'), findsOneWidget);
    expect(find.text('Pilih Jam'), findsOneWidget); // Placeholder Pilih Jam
    expect(find.text('Catatan'), findsOneWidget);

    // Verifikasi Catatan awalnya kosong (hanya placeholder hint text)
    final noteField = find.widgetWithText(TextField, 'Tambahkan catatan......');
    expect(noteField, findsOneWidget);
    expect((tester.widget(noteField) as TextField).controller?.text, isEmpty);

    // Pilih "Yoga"
    await tester.tap(find.text('Yoga'));
    await tester.pumpAndSettle();

    // Isi Catatan
    await tester.enterText(noteField, 'Setelah makan ya');
    await tester.pumpAndSettle();

    // Scroll ke tombol Simpan & klik
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // 5. Tiba di Slide 4 (Atur Pengingat / Ringkasan)
    expect(find.text('Atur Pengingat'), findsOneWidget);
    expect(find.text('Yoga'), findsOneWidget);
    expect(find.text('30 menit'), findsOneWidget);
    expect(find.text('Waktu Pengingat'), findsOneWidget);
    expect(find.text('07.30 WIB'), findsOneWidget);
    expect(find.text('Pengulangan'), findsOneWidget);
    expect(find.text('Setiap Hari'), findsOneWidget);
    expect(find.text('Catatan'), findsOneWidget);
    expect(find.text('Setelah makan ya'), findsOneWidget);

    // Simpan dari Slide 4 untuk kembali ke Slide 1
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // Kembali ke Slide 1 dengan data olahraga aktif
    expect(find.text('Pengingat Kesehatan'), findsOneWidget);
    expect(find.text('Yoga • 30 mnt'), findsOneWidget);
    expect(find.text('Yoga (07.30 WIB)'), findsOneWidget);
  });

  testWidgets(
      'Pop-up Notifikasi Olahraga Modern (Slide 5) tampil estetik & interaktif',
      (WidgetTester tester) async {
    final sampleExercise = ExerciseReminder(
      id: 'ex-1',
      activityName: 'Joging',
      durationMinutes: 30,
      reminderTime: '07.30 WIB',
      repeatFrequency: 'Setiap Hari',
      repeatDays: const ['Setiap Hari'],
      note: 'Setelah bangun tidur',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showModernExerciseReminderDialog(
                      context,
                      reminder: sampleExercise,
                      timeText: '07.30 WIB',
                    );
                  },
                  child: const Text('Buka Notif Olahraga'),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buka Notif Olahraga'));
    await tester.pumpAndSettle();

    // Verifikasi Elemen Notifikasi Modern
    expect(find.text('Pengingat Olahraga Ringan'), findsOneWidget);
    expect(find.text('07.30 WIB'), findsOneWidget);
    expect(find.text('Saatnya olahraga ringan!'), findsOneWidget);
    expect(find.text('Joging'), findsOneWidget);
    expect(find.text('30 Menit'), findsOneWidget);
    expect(find.text('Setiap Hari'), findsOneWidget);
    expect(find.text('Setelah bangun tidur'), findsOneWidget);
    expect(
        find.text(
            '💡 Tips Jantung: Lakukan pemanasan 3-5 menit dan jaga detak napas teratur.'),
        findsOneWidget);
    expect(find.text('Mulai Olahraga'), findsOneWidget);
    expect(find.text('Tunda 10 Menit'), findsOneWidget);

    // Klik Mulai Olahraga
    await tester.tap(find.text('Mulai Olahraga'));
    await tester.pumpAndSettle();

    expect(find.text('Saatnya olahraga ringan!'), findsNothing);
  });

  testWidgets(
      'Pop-up Notifikasi Minum Obat Modern tampil estetik & terpadu',
      (WidgetTester tester) async {
    final sampleMedicine = MedicineReminder(
      id: 'med-1',
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
                    showModernMedicineReminderDialog(
                      context,
                      reminder: sampleMedicine,
                      timeText: '07.30 WIB',
                    );
                  },
                  child: const Text('Buka Notif Obat'),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buka Notif Obat'));
    await tester.pumpAndSettle();

    // Verifikasi Elemen Notifikasi Obat Modern
    expect(find.text('Pengingat Minum Obat'), findsOneWidget);
    expect(find.text('07.30 WIB'), findsOneWidget);
    expect(find.text('Saatnya Minum Obat!'), findsOneWidget);
    expect(find.text('Aspirin 300 mg'), findsOneWidget);
    expect(find.text('1 Tablet'), findsOneWidget);
    expect(find.text('Setelah makan ya'), findsWidgets);
    expect(find.text('Sudah Minum'), findsOneWidget);
    expect(find.text('Tunda 10 Menit'), findsOneWidget);

    // Klik Sudah Minum
    await tester.tap(find.text('Sudah Minum'));
    await tester.pumpAndSettle();

    expect(find.text('Saatnya Minum Obat!'), findsNothing);
  });

  testWidgets('Integrasi Sinkronisasi Controller Obat & Olahraga',
      (WidgetTester tester) async {
    final controller = HealthReminderController();

    // Tambah Obat
    controller.addMedicine(
      MedicineReminder(
        id: 'med-1',
        name: 'Aspirin 300 mg',
        amount: '1',
        unit: 'Tablet',
        schedule: 'Setelah makan ya',
        reminderTimes: ['07.30', '15.30'],
        note: 'Minum teratur',
      ),
    );

    // Tambah Olahraga
    controller.addExercise(
      ExerciseReminder(
        id: 'ex-1',
        activityName: 'Bersepeda',
        durationMinutes: 45,
        reminderTime: '06.30 WIB',
        repeatFrequency: 'Setiap Hari',
        repeatDays: const ['Setiap Hari'],
        note: 'Pagi hari',
      ),
    );

    // Total pengingat hari ini = 2 waktu obat + 1 olahraga = 3
    expect(controller.activeRemindersCount, 3);

    // Pengingat berikutnya memprioritaskan olahraga yang aktif
    expect(controller.nextReminderSummary, 'Bersepeda (06.30 WIB)');
  });
}
