import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/services/health_reminder_scheduler_service.dart';
import 'package:heartcare/pages/pengaturan_reminder_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('HealthReminderSchedulerService provides automatic built-in reminders for water, activity, and habits', () {
    final service = HealthReminderSchedulerService.instance;

    final all = service.allReminders;
    expect(all.length, greaterThanOrEqualTo(9));

    // 1. Minum Air Putih (4x sehari)
    final waterReminders = service.getRemindersByCategory(HealthReminderCategory.water);
    expect(waterReminders.length, equals(4));
    expect(waterReminders.any((r) => r.hour == 8 && r.minute == 0), isTrue);
    expect(waterReminders.any((r) => r.hour == 12 && r.minute == 30), isTrue);
    expect(waterReminders.any((r) => r.hour == 16 && r.minute == 0), isTrue);
    expect(waterReminders.any((r) => r.hour == 19 && r.minute == 30), isTrue);

    // 2. Aktivitas Fisik (2x sehari)
    final activityReminders = service.getRemindersByCategory(HealthReminderCategory.activity);
    expect(activityReminders.length, equals(2));
    expect(activityReminders.any((r) => r.hour == 7 && r.minute == 0), isTrue);
    expect(activityReminders.any((r) => r.hour == 17 && r.minute == 0), isTrue);

    // 3. Kebiasaan Sehat Jantung (3x sehari)
    final habitReminders = service.getRemindersByCategory(HealthReminderCategory.habit);
    expect(habitReminders.length, equals(3));
    expect(habitReminders.any((r) => r.hour == 10 && r.minute == 30), isTrue);
    expect(habitReminders.any((r) => r.hour == 12 && r.minute == 0), isTrue);
    expect(habitReminders.any((r) => r.hour == 21 && r.minute == 30), isTrue);
  });

  test('HealthReminderSchedulerService settings toggles work correctly', () async {
    final service = HealthReminderSchedulerService.instance;

    await service.setMasterEnabled(true);
    expect(service.masterEnabled, isTrue);

    await service.setWaterEnabled(false);
    expect(service.waterEnabled, isFalse);

    await service.setWaterEnabled(true);
    expect(service.waterEnabled, isTrue);

    await service.setActivityEnabled(false);
    expect(service.activityEnabled, isFalse);

    await service.setHabitEnabled(false);
    expect(service.habitEnabled, isFalse);
  });

  testWidgets('PengaturanReminderPage renders status banner, master toggle, and all health categories', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PengaturanReminderPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Verifikasi Status Banner
    expect(find.text('Pengaturan Pengingat'), findsOneWidget);
    expect(find.text('Pengingat Otomatis Aktif'), findsOneWidget);
    expect(find.text('Semua Pengingat Otomatis'), findsOneWidget);

    // Verifikasi Kategori
    expect(find.text('Minum Air Putih'), findsOneWidget);
    expect(find.text('Aktivitas Fisik & Peregangan'), findsOneWidget);
    expect(find.text('Kebiasaan Sehat & Kiat Jantung'), findsOneWidget);

    // Verifikasi Uji Coba Notifikasi
    expect(find.text('Uji Coba Notifikasi'), findsOneWidget);
    expect(find.text('💧 Air Putih'), findsOneWidget);
    expect(find.text('🏃 Olahraga'), findsOneWidget);
    expect(find.text('🧘 Kiat Jantung'), findsOneWidget);
  });
}
