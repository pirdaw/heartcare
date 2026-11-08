import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/services/notification_service.dart';
import 'package:heartcare/pages/pengaturan_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp({Widget? home}) {
    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey,
      home: home ??
          Scaffold(
            body: Center(
              child: const Text('HeartCare Test Home'),
            ),
          ),
    );
  }

  setUp(() async {
    // Reset all notification preferences to enabled
    await NotificationService.instance.setNotificationPreference(
      enableChat: true,
      enableMedicine: true,
      enableConsultation: true,
      enableEducation: true,
    );
  });

  group('Heads-Up Pop-Up Notification Banner Tests', () {
    testWidgets('1. Doctor chat notification appears as heads-up pop-up banner',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Trigger notifikasi chat dokter
      NotificationService.instance.showDoctorChatNotification(
        doctorName: 'dr. Nurlitta Dwi, Sp.JP',
        message: 'Halo, obat kardio diminum teratur ya.',
        doctorSpecialty: 'Spesialis Jantung',
        doctorPhoto: 'assets/images/dokter_nurlitta.jpg',
      );

      // Pump animasi masuk
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      // Verifikasi teks dokter, badge, dan pesan muncul di pop up
      expect(find.text('dr. Nurlitta Dwi, Sp.JP'), findsOneWidget);
      expect(find.textContaining('CHAT DOKTER'), findsOneWidget);
      expect(find.text('Halo, obat kardio diminum teratur ya.'), findsOneWidget);
    });

    testWidgets('2. Patient chat notification appears as heads-up pop-up banner',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Trigger notifikasi chat pasien
      NotificationService.instance.showPatientChatNotification(
        patientName: 'Valentino Pasien',
        message: 'Dok, tekanan darah saya 120/80 mmHg.',
        patientPhoto: 'assets/images/profile_woman.png',
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Valentino Pasien'), findsOneWidget);
      expect(find.text('PESAN PASIEN KONSULTASI'), findsOneWidget);
      expect(find.text('Dok, tekanan darah saya 120/80 mmHg.'), findsOneWidget);
    });

    testWidgets('3. Consultation reminder pop-up notification banner',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      NotificationService.instance.showConsultationReminderNotification(
        doctorName: 'dr. Nurlitta Dwi, Sp.JP',
        scheduledTime: 'Jumat, 18 September 2026 pukul 10:00 WIB',
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Jadwal Konsultasi: dr. Nurlitta Dwi, Sp.JP'), findsOneWidget);
      expect(find.text('PENGINGAT JADWAL KONSULTASI'), findsOneWidget);
      expect(find.textContaining('Jumat, 18 September 2026'), findsOneWidget);
    });

    testWidgets('4. Medicine reminder pop-up notification banner',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      NotificationService.instance.showMedicineReminderNotification(
        medicineName: 'Aspirin Kardio 100 mg',
        dosage: '1 Tablet',
        instruction: 'Setelah sarapan pagi',
        time: '08.00',
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Waktunya Minum: Aspirin Kardio 100 mg'), findsOneWidget);
      expect(find.text('PENGINGAT MINUM OBAT'), findsOneWidget);
      expect(find.textContaining('Pukul 08.00 WIB'), findsOneWidget);
      expect(find.textContaining('1 Tablet (Setelah sarapan pagi)'), findsOneWidget);
    });

    testWidgets('5. Health education pop-up notification banner',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      NotificationService.instance.showHealthEducationNotification(
        title: 'Kiat Jantung Hari Ini',
        message: 'Batasi asupan garam < 5g per hari untuk elastisitas arteri.',
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Kiat Jantung Hari Ini'), findsOneWidget);
      expect(find.text('TIPS KESEHATAN JANTUNG'), findsOneWidget);
      expect(find.textContaining('Batasi asupan garam'), findsOneWidget);
    });

    testWidgets('6. Close button dismisses the pop-up notification',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      NotificationService.instance.showHealthEducationNotification(
        title: 'Tips Hidup Sehat',
        message: 'Olahraga rutin 30 menit sehari.',
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Tips Hidup Sehat'), findsOneWidget);

      // Tap tombol close X di notifikasi
      final closeBtn = find.byIcon(Icons.close_rounded);
      expect(closeBtn, findsOneWidget);
      await tester.tap(closeBtn);

      // Pump animasi reverse / dismiss
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pump(const Duration(milliseconds: 100));

      // Verifikasi notifikasi sudah tertutup dan hilang dari layar
      expect(find.text('Tips Hidup Sehat'), findsNothing);
    });

    testWidgets('7. Disabled notification category does not show pop-up',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Matikan notifikasi chat
      await NotificationService.instance.setNotificationPreference(enableChat: false);

      NotificationService.instance.showDoctorChatNotification(
        doctorName: 'dr. Nurlitta Dwi',
        message: 'Pesan rahasia',
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      // Harus tidak muncul karena dimatikan
      expect(find.text('dr. Nurlitta Dwi'), findsNothing);
    });

    testWidgets('8. PengaturanPage contains pop-up notification controls and test sheet',
        (tester) async {
      await tester.pumpWidget(buildTestApp(home: const PengaturanPage()));
      await tester.pumpAndSettle();

      // Cari section Notifikasi Pop-up Layar
      expect(find.text('Notifikasi Pop-up Layar'), findsOneWidget);
      expect(find.text('Uji Coba Notifikasi Pop-up'), findsOneWidget);

      // Buka bottom sheet Uji Coba
      await tester.tap(find.text('Uji Coba Notifikasi Pop-up'));
      await tester.pumpAndSettle();

      // Verifikasi kelima opsi pengujian tampil di bottom sheet
      expect(find.text('1. Chat Dokter ke Pasien'), findsOneWidget);
      expect(find.text('2. Chat Pasien ke Dokter'), findsOneWidget);
      expect(find.text('3. Pengingat Jadwal Konsultasi'), findsOneWidget);
      expect(find.text('4. Pengingat Minum Obat'), findsOneWidget);
      expect(find.text('5. Edukasi Kesehatan Jantung'), findsOneWidget);

      // Tap salah satu (Pengingat Minum Obat)
      await tester.tap(find.text('4. Pengingat Minum Obat'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      // Pop-up pengingat obat muncul di atas layar!
      expect(find.text('Waktunya Minum: Aspirin Kardio 100 mg'), findsOneWidget);
      expect(find.text('PENGINGAT MINUM OBAT'), findsOneWidget);
    });
  });
}

