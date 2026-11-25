import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/services/reminder_notification_service.dart';
import 'package:heartcare/widgets/gojek_reminder_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ReminderNotificationService schedules consultation and medicine reminders', () async {
    final service = ReminderNotificationService.instance;
    await service.init();

    HeartCareReminder? receivedReminder;
    final sub = service.onReminder.listen((r) {
      receivedReminder = r;
    });

    // 1. Tes Pengingat Konsultasi Dokter
    await service.scheduleConsultationReminder(
      doctorName: 'dr. Nurlitta Dwi',
      doctorSpecialty: 'Spesialis Jantung',
      timeSlot: '09.00 WIB',
      dateDisplay: 'Senin, 1 September 2026',
      timingLabel: '15 menit sebelumnya',
      notifyImmediately: true,
    );

    expect(receivedReminder, isNotNull);
    expect(receivedReminder!.type, equals(ReminderType.consultation));
    expect(receivedReminder!.title, contains('dr. Nurlitta Dwi'));
    expect(receivedReminder!.time, equals('09.00 WIB'));
    expect(receivedReminder!.actionLabel, equals('Buka Chat'));

    // 2. Tes Pengingat Minum Obat
    await service.triggerMedicineReminder(
      medicineName: 'Bisoprolol 2.5 mg',
      dosage: '1 Tablet',
      scheduleInfo: 'Pagi hari setelah sarapan',
      time: '07.30 WIB',
    );

    expect(receivedReminder, isNotNull);
    expect(receivedReminder!.type, equals(ReminderType.medicine));
    expect(receivedReminder!.title, equals('Waktunya Minum Obat!'));
    expect(receivedReminder!.body, contains('Bisoprolol 2.5 mg'));
    expect(receivedReminder!.actionLabel, equals('Sudah Minum'));

    await sub.cancel();
  });

  testWidgets('GojekReminderBanner renders with Gojek styling, badges, and dismisses on close', (WidgetTester tester) async {
    final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        home: const Scaffold(
          body: Center(child: Text('Home Screen')),
        ),
      ),
    );

    final reminder = HeartCareReminder(
      id: 'test_rem_1',
      type: ReminderType.consultation,
      title: 'Pengingat: dr. Nurlitta Dwi',
      body: 'Jadwal konsultasi akan dimulai pukul 09.00 WIB.',
      time: '09.00 WIB',
      doctorName: 'dr. Nurlitta Dwi',
      doctorSpecialty: 'Spesialis Jantung',
      actionLabel: 'Masuk Chat',
    );

    GojekReminderBannerManager.showWithNavigatorKey(
      navigatorKey: navKey,
      reminder: reminder,
      duration: const Duration(seconds: 10),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verifikasi konten banner ala Gojek muncul di atas layar
    expect(find.text('PENGINGAT KONSULTASI'), findsOneWidget);
    expect(find.text('Pengingat: dr. Nurlitta Dwi'), findsOneWidget);
    expect(find.text('Jadwal konsultasi akan dimulai pukul 09.00 WIB.'), findsOneWidget);
    expect(find.text('Masuk Chat'), findsOneWidget);

    // Verifikasi tombol close menutup banner
    final closeButton = find.byIcon(Icons.close_rounded);
    expect(closeButton, findsOneWidget);
    await tester.tap(closeButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Banner sudah ter-dismiss
    expect(find.text('PENGINGAT KONSULTASI'), findsNothing);
  });

  test('Booking consultation automatically registers reminder without manual user configuration', () async {
    final service = ReminderNotificationService.instance;
    await service.init();

    HeartCareReminder? autoReminder;
    final sub = service.onReminder.listen((r) {
      autoReminder = r;
    });

    // Simulasi booking konsultasi otomatis
    await service.scheduleConsultationReminder(
      doctorName: 'dr. Kavalera Valent',
      doctorSpecialty: 'Spesialis Jantung',
      timeSlot: '14.00–14.30',
      dateDisplay: 'Rabu, 25 November 2026',
      timingLabel: 'Pengingat Otomatis',
      notifyImmediately: true,
    );

    expect(autoReminder, isNotNull);
    expect(autoReminder!.doctorName, equals('dr. Kavalera Valent'));
    expect(autoReminder!.body, contains('Pengingat Otomatis'));
    expect(service.activeReminders.any((r) => r.doctorName == 'dr. Kavalera Valent'), isTrue);

    await sub.cancel();
  });
}

