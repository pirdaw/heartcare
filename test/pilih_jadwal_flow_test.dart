import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/pages/home_page.dart';
import 'package:heartcare/pages/konfirmasi_jadwal_page.dart';
import 'package:heartcare/pages/konsultasi_dokter_page.dart';
import 'package:heartcare/pages/pilih_jadwal_page.dart';
import 'package:heartcare/services/booking_service.dart';

void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('PilihJadwalPage renders doctor info, duration options, status badges, and navigates to KonfirmasiJadwalPage', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PilihJadwalPage(
          doctorName: 'dr. Andi Pratama',
          doctorSpecialty: 'Spesialis Jantung & Pembuluh Darah',
          doctorPhoto: 'assets/images/dokter_andi.jpg',
          isOnline: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verifikasi Informasi Dokter (Nama, Spesialisasi, Status Aktif)
    expect(find.text('dr. Andi Pratama'), findsOneWidget);
    expect(find.text('Spesialis Jantung & Pembuluh Darah'), findsOneWidget);
    expect(find.text('Status: Aktif'), findsOneWidget);

    // 2. Verifikasi Header Tanggal Konsultasi
    expect(find.text('Pilih Jadwal'), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);

    // Verifikasi 7 Kapsul Hari
    expect(find.text('Sen'), findsOneWidget);
    expect(find.text('Sel'), findsOneWidget);
    expect(find.text('Rab'), findsOneWidget);
    expect(find.text('Kam'), findsOneWidget);
    expect(find.text('Jum'), findsOneWidget);
    expect(find.text('Sab'), findsOneWidget);
    expect(find.text('Min'), findsOneWidget);

    // 3. Verifikasi Pilihan Durasi per Sesi (15, 30, 45, 60 Menit)
    expect(find.text('Pilihan Durasi per Sesi'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);

    // 4. Verifikasi Legenda Status Jadwal
    expect(find.text('Tersedia'), findsWidgets);
    expect(find.text('Sudah Dibooking'), findsWidgets);

    // 5. Verifikasi Bagian Waktu (Pagi, Siang, Sore)
    expect(find.text('Pagi'), findsOneWidget);
    expect(find.text('Siang'), findsOneWidget);
    expect(find.text('Sore'), findsOneWidget);

    // 6. Pilih hari Rab (3 September 2026) dan durasi default 30 menit
    await tester.tap(find.text('Rab'));
    await tester.pumpAndSettle();

    // Pilih slot 13.00–13.30
    expect(find.text('13.00–13.30'), findsOneWidget);
    await tester.tap(find.text('13.00–13.30'));
    await tester.pumpAndSettle();

    // 7. Konfirmasi Jadwal
    await tester.tap(find.text('Konfirmasi Jadwal'));
    await tester.pumpAndSettle();

    // Verifikasi navigasi ke KonfirmasiJadwalPage
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(KonfirmasiJadwalPage), findsOneWidget);
    expect(find.text('Jadwal Berhasil Dipilih!'), findsOneWidget);
    expect(find.text('dr. Andi Pratama'), findsOneWidget);
    expect(find.text('Rab, 3 September 2026'), findsOneWidget);
    expect(find.text('30 Menit'), findsOneWidget);
    expect(find.text('Pukul 13.00–13.30 WIB'), findsOneWidget);
    expect(find.text('Dokter Aktif'), findsOneWidget);

    // Verifikasi tombol aksi
    expect(find.text('Konsultasi Dokter Lewat Chat'), findsOneWidget);
    expect(find.text('Kembali ke Beranda'), findsOneWidget);

    // Aksi 1: Konsultasi Dokter Lewat Chat membuka KonsultasiDokterPage
    await tester.tap(find.text('Konsultasi Dokter Lewat Chat'));
    await tester.pumpAndSettle();
    expect(find.byType(KonsultasiDokterPage), findsOneWidget);
  });

  testWidgets('Durasi 60 menit otomatis menyesuaikan slot waktu (08.00–09.00, 09.00–10.00)', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PilihJadwalPage(
          doctorName: 'dr. Andi Pratama',
          doctorSpecialty: 'Spesialis Jantung',
          isOnline: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap durasi 60 Menit
    await tester.tap(find.text('60'));
    await tester.pumpAndSettle();

    // Verifikasi slot 60 menit ter-generate
    expect(find.text('08.00–09.00'), findsOneWidget);
    expect(find.text('09.00–10.00'), findsOneWidget);
    expect(find.text('10.00–11.00'), findsOneWidget);
    expect(find.text('13.00–14.00'), findsOneWidget);
    expect(find.text('14.00–15.00'), findsOneWidget);
    expect(find.text('16.00–17.00'), findsOneWidget);
    expect(find.text('17.00–18.00'), findsOneWidget);
  });

  testWidgets('Pencegahan tabrakan jadwal (slot overlap): slot yang sudah dibooking tidak bisa dipilih', (WidgetTester tester) async {
    // 09.00–09.30 sudah di-seed default sebagai 'Sudah Dibooking'
    await tester.pumpWidget(
      const MaterialApp(
        home: PilihJadwalPage(
          doctorName: 'dr. Nurlitta Dwi',
          doctorSpecialty: 'Spesialis Jantung',
          isOnline: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Slot 09.00–09.30 berstatus Sudah Dibooking
    expect(find.text('09.00–09.30'), findsOneWidget);

    // Tap slot yang sudah dibooking
    await tester.tap(find.text('09.00–09.30'));
    await tester.pump();

    // Verifikasi snackbar pencegahan muncul
    expect(find.textContaining('sudah dibooking'), findsOneWidget);
  });

  testWidgets('KonfirmasiJadwalPage tapping Kembali ke Beranda returns to HomePage', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: KonfirmasiJadwalPage(
          doctorName: 'dr. Sinta Maharani',
          doctorSpecialty: 'Spesialis Jantung & Kardiovaskular',
          doctorPhoto: 'assets/images/dokter_sinta.jpg',
          selectedDate: 'Jum, 5 September 2026',
          selectedTime: '10.00–10.30',
          durationMinutes: 30,
        ),
      ),
    );

    expect(find.byType(KonfirmasiJadwalPage), findsOneWidget);
    expect(find.text('Kembali ke Beranda'), findsOneWidget);

    // Scroll jika perlu
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();

    // Tap Kembali ke Beranda
    await tester.tap(find.text('Kembali ke Beranda'));
    await tester.pumpAndSettle();

    // Verifikasi kembali ke HomePage
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(KonfirmasiJadwalPage), findsNothing);
  });
}
