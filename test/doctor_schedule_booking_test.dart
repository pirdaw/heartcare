import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/services/booking_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Doctor Practice Schedule & Booking Unit Tests', () {
    final bookingService = BookingService.instance;

    test('DoctorPracticeSchedule model toJson and fromJson', () {
      final schedule = DoctorPracticeSchedule(
        id: 'sched_doc1_2026-09-02',
        doctorId: 'doc1',
        doctorName: 'dr. Nurlitta Dwi',
        dateKey: '2026-09-02',
        dateDisplay: 'Sel, 2 September 2026',
        dayName: 'Selasa',
        dayNumber: '2',
        startMinutes: 480, // 08:00
        endMinutes: 720, // 12:00
        durationMinutes: 30,
        hasBreak: true,
        breakStartMinutes: 600, // 10:00
        breakEndMinutes: 630, // 10:30
        isActive: true,
      );

      final json = schedule.toJson();
      expect(json['id'], 'sched_doc1_2026-09-02');
      expect(json['startMinutes'], 480);
      expect(json['endMinutes'], 720);
      expect(json['hasBreak'], true);

      final reconstructed = DoctorPracticeSchedule.fromJson(json);
      expect(reconstructed.id, schedule.id);
      expect(reconstructed.doctorId, schedule.doctorId);
      expect(reconstructed.startMinutes, 480);
      expect(reconstructed.endMinutes, 720);
      expect(reconstructed.durationMinutes, 30);
      expect(reconstructed.hasBreak, true);
      expect(reconstructed.breakStartMinutes, 600);
      expect(reconstructed.breakEndMinutes, 630);
      expect(reconstructed.isActive, true);
    });

    test('DoctorBooking status serialization and updates', () {
      final booking = DoctorBooking(
        id: 'booking_123',
        doctorId: 'doc1',
        doctorName: 'dr. Nurlitta Dwi',
        doctorSpecialty: 'Spesialis Jantung & Konsultan Aritmia',
        doctorPhoto: 'assets/images/doctor.png',
        dateDisplay: 'Sel, 2 September 2026',
        dateKey: '2026-09-02',
        timeSlot: '08.00–08.30',
        durationMinutes: 30,
        patientName: 'Nadea Fieldzah Putri',
        patientPhoto: 'https://example.com/nadea.jpg',
        patientPhone: '081234567890',
        status: 'Menunggu Konfirmasi',
        startMinutes: 480,
        endMinutes: 510,
      );

      final json = booking.toJson();
      expect(json['status'], 'Menunggu Konfirmasi');
      expect(json['patientName'], 'Nadea Fieldzah Putri');

      final reconstructed = DoctorBooking.fromJson(json);
      expect(reconstructed.status, 'Menunggu Konfirmasi');
      expect(reconstructed.patientName, 'Nadea Fieldzah Putri');

      final accepted = reconstructed.copyWith(status: 'Diterima');
      expect(accepted.status, 'Diterima');

      final rejected = reconstructed.copyWith(
        status: 'Ditolak',
        rejectionReason: 'Ada tindakan operasi darurat',
      );
      expect(rejected.status, 'Ditolak');
      expect(rejected.rejectionReason, 'Ada tindakan operasi darurat');
    });

    test('generateSlots generates accurate slots based on doctor practice schedule', () {
      final schedule = DoctorPracticeSchedule(
        id: 'sched_doc1_2026-09-02',
        doctorId: 'doc1',
        doctorName: 'dr. Nurlitta Dwi',
        dateKey: '2026-09-02',
        dateDisplay: 'Sel, 2 September 2026',
        dayName: 'Selasa',
        dayNumber: '2',
        startMinutes: 480, // 08:00
        endMinutes: 720, // 12:00
        durationMinutes: 30,
        hasBreak: true,
        breakStartMinutes: 600, // 10:00
        breakEndMinutes: 630, // 10:30 (jeda 30 menit)
        isActive: true,
      );

      bookingService.simulateScheduleForTesting(schedule);

      final slots = bookingService.generateSlots(
        durationMinutes: 30,
        doctorId: 'doc1',
        dateKey: '2026-09-02',
      );

      // Harusnya ada slot dari 08:00 sampai 12:00 kecuali jeda 10:00-10:30:
      // 08.00–08.30, 08.30–09.00, 09.00–09.30, 09.30–10.00,
      // (10.00-10.30 jeda di-skip),
      // 10.30–11.00, 11.00–11.30, 11.30–12.00
      // Total = 7 slot aktif!
      expect(slots.length, 7);
      expect(slots.first.label, '08.00–08.30');
      expect(slots.last.label, '11.30–12.00');

      final slotStrings = slots.map((s) => s.label).toList();
      expect(slotStrings.contains('10.00–10.30'), isFalse);
      expect(slotStrings.contains('10.30–11.00'), isTrue);
    });

    test('Inactive schedule produces zero slots for patients', () {
      final inactiveSchedule = DoctorPracticeSchedule(
        id: 'sched_doc1_2026-09-03',
        doctorId: 'doc1',
        doctorName: 'dr. Nurlitta Dwi',
        dateKey: '2026-09-03',
        dateDisplay: 'Rab, 3 September 2026',
        dayName: 'Rabu',
        dayNumber: '3',
        startMinutes: 480,
        endMinutes: 720,
        durationMinutes: 30,
        isActive: false, // Dokter libur / nonaktif
      );

      bookingService.simulateScheduleForTesting(inactiveSchedule);

      final slots = bookingService.generateSlots(
        durationMinutes: 30,
        doctorId: 'doc1',
        dateKey: '2026-09-03',
      );

      expect(slots.isEmpty, isTrue);
    });

    test('Booking status affects slot availability: Menunggu Konfirmasi & Diterima locks, Ditolak unlocks', () {
      final testBooking = DoctorBooking(
        id: 'booking_slot_1',
        doctorId: 'doc1',
        doctorName: 'dr. Nurlitta Dwi',
        doctorSpecialty: 'Spesialis Jantung & Konsultan Aritmia',
        doctorPhoto: 'assets/images/doctor.png',
        dateDisplay: 'Sel, 2 September 2026',
        dateKey: '2026-09-02',
        timeSlot: '08.00–08.30',
        durationMinutes: 30,
        patientName: 'Ahmad Pasien',
        status: 'Menunggu Konfirmasi',
        startMinutes: 480,
        endMinutes: 510,
      );

      bookingService.simulateBookingForTesting(testBooking);

      // Slot harus terdeteksi booked
      expect(
        bookingService.isSlotBooked(
          doctorId: 'doc1',
          dateKey: '2026-09-02',
          startMinutes: 480,
          endMinutes: 510,
        ),
        isTrue,
      );

      // Dokter menerima booking -> slot tetap terkunci
      final acceptedBooking = testBooking.copyWith(status: 'Diterima');
      bookingService.simulateBookingForTesting(acceptedBooking);
      expect(
        bookingService.isSlotBooked(
          doctorId: 'doc1',
          dateKey: '2026-09-02',
          startMinutes: 480,
          endMinutes: 510,
        ),
        isTrue,
      );

      // Dokter menolak booking -> slot harus kembali tersedia
      final rejectedBooking = testBooking.copyWith(status: 'Ditolak');
      bookingService.simulateBookingForTesting(rejectedBooking);
      expect(
        bookingService.isSlotBooked(
          doctorId: 'doc1',
          dateKey: '2026-09-02',
          startMinutes: 480,
          endMinutes: 510,
        ),
        isFalse,
      );
    });
  });
}
