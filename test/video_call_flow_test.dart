import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/pages/video_call_page.dart';
import 'package:heartcare/pages/pilih_jadwal_page.dart';
import 'package:heartcare/pages/konfirmasi_jadwal_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Teleconsultation Video Call Tests', () {
    testWidgets('1. VideoCallPage renders remote doctor view, PiP, and control toolbar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VideoCallPage(
            isDoctorView: false,
            doctorName: 'dr. Nurlitta Dwi, Sp.JP',
            doctorSpecialty: 'Spesialis Jantung & Pembuluh Darah',
            patientName: 'Valentino Pasien',
          ),
        ),
      );

      // Settle initial frame
      await tester.pump();

      // Verifikasi nama dokter dan spesialisasi muncul di layar
      expect(find.text('dr. Nurlitta Dwi, Sp.JP'), findsOneWidget);
      expect(find.text('Spesialis Jantung & Pembuluh Darah'), findsOneWidget);

      // Verifikasi badge enkripsi medis
      expect(find.text('Enkripsi Medis'), findsOneWidget);

      // Verifikasi floating PiP window lokal ("Anda")
      expect(find.text('Anda'), findsOneWidget);

      // Verifikasi tombol-tombol kontrol bawah
      expect(find.text('Mic'), findsOneWidget);
      expect(find.text('Kamera'), findsOneWidget);
      expect(find.text('Putar'), findsOneWidget);
      expect(find.text('Keluhan'), findsOneWidget);
      expect(find.byIcon(Icons.call_end_rounded), findsOneWidget);

      // Uji toggle mute mic
      await tester.tap(find.text('Mic'));
      await tester.pump();
      expect(find.text('Unmute'), findsOneWidget);
    });

    testWidgets('2. VideoCallPage opens symptom notes bottom sheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VideoCallPage(
            isDoctorView: false,
            doctorName: 'dr. Nurlitta Dwi',
            patientName: 'Valentino Pasien',
          ),
        ),
      );

      await tester.pump();

      // Buka bottom sheet keluhan
      await tester.tap(find.text('Keluhan'));
      await tester.pumpAndSettle();

      // Verifikasi komponen catatan keluhan terbuka
      expect(find.text('Catatan Keluhan Pasien Langsung'), findsOneWidget);
      expect(find.text('Nyeri Dada'), findsOneWidget);
      expect(find.text('Sesak Napas'), findsOneWidget);
      expect(find.text('Jantung Berdebar'), findsOneWidget);
      expect(find.text('Simpan Catatan ke Rekam Medis'), findsOneWidget);
    });

    testWidgets('3. PilihJadwalPage includes Video Call and Chat selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PilihJadwalPage(
            doctorName: 'dr. Nurlitta Dwi',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi opsi Video Call dan Chat ada di menu pilih jadwal
      expect(find.text('Pilih Metode Konsultasi:'), findsOneWidget);
      expect(find.text('Video Call'), findsOneWidget);
      expect(find.text('Chat Online'), findsOneWidget);
      expect(find.text('Rekomendasi'), findsOneWidget);
    });

    testWidgets('4. KonfirmasiJadwalPage renders Video Call button when selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: KonfirmasiJadwalPage(
            doctorName: 'dr. Nurlitta Dwi',
            selectedDate: 'Sel, 2 September 2026',
            selectedTime: '09.00',
            consultationType: 'video',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi ringkasan metode konsultasi
      expect(find.text('Video Call (Tatap Muka)'), findsOneWidget);
      expect(find.text('Mulai Video Call Langsung'), findsOneWidget);
      expect(find.text('Buka Chat Konsultasi'), findsOneWidget);
    });
  });
}

