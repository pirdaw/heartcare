import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/services/chat_service.dart';

void main() {
  group('Doctor Chat Room Separation Tests', () {
    final now = DateTime.now();

    final roomDrValent1 = ChatRoom(
      id: 'chat_pasien1_dr_kavalera_valent',
      patientId: 'pasien1',
      patientName: 'Kavalera Valent (Pasien)',
      patientPhoto: '',
      doctorId: 'valent_uid_123',
      doctorName: 'dr. Kavalera Valent, S.T., Sp.JP',
      doctorPhoto: '',
      doctorSpecialty: 'Spesialis Jantung & Pembuluh Darah',
      lastMessage: 'Laporan Hasil Skrining Jantung',
      lastMessageTime: now,
      lastSenderRole: 'patient',
      unreadCountDoctor: 1,
      unreadCountPatient: 0,
      updatedAt: now,
    );

    final roomDrValent2 = ChatRoom(
      id: 'chat_pasien2_valent',
      patientId: 'pasien2',
      patientName: 'Siska',
      patientPhoto: '',
      doctorId: 'valent_uid_123',
      doctorName: 'dr. Kavalera Valent',
      doctorPhoto: '',
      doctorSpecialty: 'Spesialis Jantung & Pembuluh Darah',
      lastMessage: 'Halo dok',
      lastMessageTime: now,
      lastSenderRole: 'patient',
      unreadCountDoctor: 1,
      unreadCountPatient: 0,
      updatedAt: now,
    );

    final roomDrAsya1 = ChatRoom(
      id: 'chat_pasien3_dr_asya_catherine',
      patientId: 'pasien3',
      patientName: 'Ahmad',
      patientPhoto: '',
      doctorId: 'asya_uid_456',
      doctorName: 'dr. Asya Catherine',
      doctorPhoto: '',
      doctorSpecialty: 'Spesialis Jantung',
      lastMessage: 'Dok, jadwal kontrol saya kapan ya?',
      lastMessageTime: now,
      lastSenderRole: 'patient',
      unreadCountDoctor: 1,
      unreadCountPatient: 0,
      updatedAt: now,
    );

    final allRooms = [roomDrValent1, roomDrValent2, roomDrAsya1];

    test('dr. Asya ONLY sees consultations directed to dr. Asya', () {
      final asyaRooms = ChatService.filterDoctorRooms(
        allRooms,
        'dr. Asya Catherine',
        doctorId: 'asya_uid_456',
      );

      expect(asyaRooms.length, 1);
      expect(asyaRooms.first.doctorName, contains('Asya'));
      expect(asyaRooms.first.patientName, 'Ahmad');

      // Pastikan pasien dr. Valent TIDAK ADA di dr. Asya
      for (final r in asyaRooms) {
        expect(r.doctorName, isNot(contains('Valent')));
        expect(r.doctorName, isNot(contains('Kavalera')));
      }
    });

    test('dr. Kavalera Valent ONLY sees consultations directed to dr. Valent', () {
      final valentRooms = ChatService.filterDoctorRooms(
        allRooms,
        'dr. Kavalera Valent, S.T., Sp.JP',
        doctorId: 'valent_uid_123',
      );

      expect(valentRooms.length, 2);
      for (final r in valentRooms) {
        expect(r.doctorName, contains('Valent'));
        expect(r.doctorName, isNot(contains('Asya')));
      }
    });

    test('Empty chats for dr. Asya does NOT leak other doctors chats', () {
      final roomsWithoutAsya = [roomDrValent1, roomDrValent2];
      final asyaRooms = ChatService.filterDoctorRooms(
        roomsWithoutAsya,
        'dr. Asya Catherine',
        doctorId: 'asya_uid_456',
      );

      expect(asyaRooms.isEmpty, isTrue);
    });
  });
}
