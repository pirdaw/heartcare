import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartcare/services/chat_notification_service.dart';
import 'package:heartcare/services/chat_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ChatNotificationService.instance.resetForTesting();
  });

  group('ChatNotificationService Tests', () {
    test('Doctor sending message generates notification for Patient with proper format and unread count', () async {
      await ChatNotificationService.instance.sendMessage(
        doctorName: 'dr. Nurlitta Dwi',
        message: 'Bagaimana kondisi tekanan darah Anda pagi ini?',
        senderRole: ChatSenderRole.doctor,
        senderNameOverride: 'dr. Nurlitta Dwi',
      );

      final notifs = ChatNotificationService.instance.getNotifications();
      expect(notifs.isNotEmpty, isTrue);

      final notif = notifs.first;
      expect(notif.senderName, 'dr. Nurlitta Dwi');
      expect(notif.senderRole, ChatSenderRole.doctor);
      expect(notif.recipientRole, ChatSenderRole.patient);
      expect(notif.notificationTitle, 'dr. Nurlitta Dwi mengirim pesan baru');
      expect(
        notif.formattedNotificationText,
        'dr. Nurlitta Dwi mengirim pesan baru: Bagaimana kondisi tekanan darah Anda pagi ini?',
      );
      expect(notif.isRead, isFalse);

      // Verify unread counts
      expect(ChatNotificationService.instance.unreadCountForPatient, 1);
      expect(ChatNotificationService.instance.totalUnreadNotificationCount, 1);
      expect(ChatNotificationService.instance.getUnreadCountForDoctorName('dr. Nurlitta Dwi'), 1);
    });

    test('Patient sending message generates notification for Doctor with proper format and unread count', () async {
      await ChatNotificationService.instance.sendMessage(
        doctorName: 'dr. Andi Pratama',
        message: 'Halo dok, dada saya terasa sedikit berdebar.',
        senderRole: ChatSenderRole.patient,
        senderNameOverride: 'Ahmad Faiz',
      );

      final notifs = ChatNotificationService.instance.getNotifications();
      expect(notifs.isNotEmpty, isTrue);

      final notif = notifs.first;
      expect(notif.senderName, 'Ahmad Faiz');
      expect(notif.senderRole, ChatSenderRole.patient);
      expect(notif.recipientRole, ChatSenderRole.doctor);
      expect(notif.notificationTitle, 'Ahmad Faiz mengirim pesan baru');
      expect(
        notif.formattedNotificationText,
        'Ahmad Faiz mengirim pesan baru: Halo dok, dada saya terasa sedikit berdebar.',
      );
      expect(notif.isRead, isFalse);

      // Verify doctor unread counts
      expect(ChatNotificationService.instance.unreadCountForDoctorOverall, 1);
      expect(ChatNotificationService.instance.unreadCountForPatient, 0);
      expect(ChatNotificationService.instance.totalUnreadNotificationCount, 1);
    });

    test('Conversations are strictly isolated between different doctors', () async {
      await ChatNotificationService.instance.sendMessage(
        doctorName: 'dr. Andi Pratama',
        message: 'Halo Ahmad dari dr. Andi',
        senderRole: ChatSenderRole.doctor,
        senderNameOverride: 'dr. Andi Pratama',
      );

      await ChatNotificationService.instance.sendMessage(
        doctorName: 'dr. Nurlitta Dwi',
        message: 'Halo Ahmad dari dr. Nurlitta',
        senderRole: ChatSenderRole.doctor,
        senderNameOverride: 'dr. Nurlitta Dwi',
      );

      final notifs = ChatNotificationService.instance.getNotifications();
      expect(notifs.length, 2);
      expect(ChatNotificationService.instance.unreadCountForPatient, 2);

      // Dr. Andi count vs Dr. Nurlitta count
      expect(ChatNotificationService.instance.getUnreadCountForDoctorName('dr. Andi Pratama'), 1);
      expect(ChatNotificationService.instance.getUnreadCountForDoctorName('dr. Nurlitta Dwi'), 1);

      // Patient sends specifically to Dr. Andi
      await ChatNotificationService.instance.sendMessage(
        doctorName: 'dr. Andi Pratama',
        message: 'Pertanyaan khusus untuk dr. Andi',
        senderRole: ChatSenderRole.patient,
        senderNameOverride: 'Ahmad Faiz',
      );

      // Dr. Andi conversation messages should have 3 total (including initial seed)
      final andiMessages = ChatNotificationService.instance.getMessages('dr. Andi Pratama');
      final nurlittaMessages = ChatNotificationService.instance.getMessages('dr. Nurlitta Dwi');

      expect(andiMessages.any((m) => m.message == 'Pertanyaan khusus untuk dr. Andi'), isTrue);
      expect(nurlittaMessages.any((m) => m.message == 'Pertanyaan khusus untuk dr. Andi'), isFalse);
    });

    test('markAsRead clears unread count for specific room and marks notification items as read', () async {
      await ChatNotificationService.instance.sendMessage(
        doctorName: 'dr. Nurlitta Dwi',
        message: 'Pesan pertama',
        senderRole: ChatSenderRole.doctor,
        senderNameOverride: 'dr. Nurlitta Dwi',
      );

      await ChatNotificationService.instance.sendMessage(
        doctorName: 'dr. Nurlitta Dwi',
        message: 'Pesan kedua',
        senderRole: ChatSenderRole.doctor,
        senderNameOverride: 'dr. Nurlitta Dwi',
      );

      expect(ChatNotificationService.instance.unreadCountForPatient, 2);
      expect(ChatNotificationService.instance.totalUnreadNotificationCount, 2);

      // Mark as read for dr. Nurlitta
      await ChatNotificationService.instance.markAsRead('dr. Nurlitta Dwi');

      expect(ChatNotificationService.instance.unreadCountForPatient, 0);
      expect(ChatNotificationService.instance.totalUnreadNotificationCount, 0);
      expect(ChatNotificationService.instance.getNotifications().every((n) => n.isRead), isTrue);
    });

    test('Notifications are suppressed when user is currently active in that chat room', () async {
      ChatNotificationService.instance.currentActiveDoctorRoom = 'dr. Nurlitta Dwi';

      await ChatNotificationService.instance.sendMessage(
        doctorName: 'dr. Nurlitta Dwi',
        message: 'Pesan saat room sedang terbuka',
        senderRole: ChatSenderRole.doctor,
        senderNameOverride: 'dr. Nurlitta Dwi',
      );

      // Notification should be marked as already read because recipient is actively viewing
      final notifs = ChatNotificationService.instance.getNotifications();
      expect(notifs.first.isRead, isTrue);
      expect(ChatNotificationService.instance.unreadCountForPatient, 0);
      expect(ChatNotificationService.instance.totalUnreadNotificationCount, 0);
    });

    test('Simulated doctor-initiated message creates valid notification and item', () async {
      await ChatNotificationService.instance.simulateDoctorInitiatedMessage(
        doctorName: 'dr. Nurlitta Dwi',
        doctorSpecialty: 'Spesialis Jantung & Konsultan Aritmia',
      );

      final notifs = ChatNotificationService.instance.getNotifications();
      expect(notifs.isNotEmpty, isTrue);

      final notif = notifs.first;
      expect(notif.senderRole, ChatSenderRole.doctor);
      expect(notif.conversationDoctorName, 'dr. Nurlitta Dwi');
      expect(notif.recipientRole, ChatSenderRole.patient);
      expect(ChatNotificationService.instance.unreadCountForPatient, 1);
    });

    test('Simulated patient message creates valid notification for doctor', () async {
      await ChatNotificationService.instance.simulatePatientMessage(
        doctorName: 'dr. Andi Pratama',
      );

      final notifs = ChatNotificationService.instance.getNotifications();
      expect(notifs.isNotEmpty, isTrue);

      final notif = notifs.first;
      expect(notif.senderRole, ChatSenderRole.patient);
      expect(notif.recipientRole, ChatSenderRole.doctor);
      expect(ChatNotificationService.instance.unreadCountForDoctorOverall, 1);
    });

    test('Patient Account Isolation: Patient 1 only sees notifications for Patient 1, not Patient 2', () async {
      // Doctor sends message to Patient 1
      ChatNotificationService.instance.notifyIncomingMessage(
        senderName: 'dr. Asya Catherine',
        message: 'Hasil pemeriksaan Anda sudah keluar, Mas Budi.',
        senderRole: ChatSenderRole.doctor,
        conversationDoctorName: 'dr. Asya Catherine',
        doctorPhoto: 'assets/images/dokter_asya.jpg',
        doctorSpecialty: 'Spesialis Jantung',
        patientName: 'Budi Santoso',
        patientId: 'patient_budi_001',
        doctorId: 'doctor_asya_001',
      );

      // Doctor sends message to Patient 2
      ChatNotificationService.instance.notifyIncomingMessage(
        senderName: 'dr. Asya Catherine',
        message: 'Jadwal kontrol Anda besok, Mbak Siti.',
        senderRole: ChatSenderRole.doctor,
        conversationDoctorName: 'dr. Asya Catherine',
        doctorPhoto: 'assets/images/dokter_asya.jpg',
        doctorSpecialty: 'Spesialis Jantung',
        patientName: 'Siti Rahma',
        patientId: 'patient_siti_002',
        doctorId: 'doctor_asya_001',
      );

      // Patient Budi notifications check
      final budiNotifs = ChatNotificationService.instance.getNotificationsForUser(
        viewerRole: ChatSenderRole.patient,
        patientId: 'patient_budi_001',
        patientName: 'Budi Santoso',
      );
      expect(budiNotifs.length, 1);
      expect(budiNotifs.first.patientName, 'Budi Santoso');
      expect(budiNotifs.first.messageSnippet, contains('Mas Budi'));
      expect(
        ChatNotificationService.instance.getUnreadCountForPatientAccount(
          patientId: 'patient_budi_001',
          patientName: 'Budi Santoso',
        ),
        1,
      );

      // Patient Siti notifications check
      final sitiNotifs = ChatNotificationService.instance.getNotificationsForUser(
        viewerRole: ChatSenderRole.patient,
        patientId: 'patient_siti_002',
        patientName: 'Siti Rahma',
      );
      expect(sitiNotifs.length, 1);
      expect(sitiNotifs.first.patientName, 'Siti Rahma');
      expect(sitiNotifs.first.messageSnippet, contains('Mbak Siti'));
      expect(
        ChatNotificationService.instance.getUnreadCountForPatientAccount(
          patientId: 'patient_siti_002',
          patientName: 'Siti Rahma',
        ),
        1,
      );
    });

    test('Doctor Account Isolation: dr. Asya only sees her own consultations, not dr. Valent', () async {
      // Patient consults dr. Asya
      ChatNotificationService.instance.notifyIncomingMessage(
        senderName: 'Firdaa',
        message: 'Halo dr. Asya, dada saya sesak saat jalan menanjak.',
        senderRole: ChatSenderRole.patient,
        conversationDoctorName: 'dr. Asya Catherine',
        doctorPhoto: 'assets/images/dokter_asya.jpg',
        doctorSpecialty: 'Spesialis Jantung',
        patientName: 'Firdaa',
        patientId: 'patient_firda_001',
        doctorId: 'doctor_asya_uid',
      );

      // Patient consults dr. Kavalera Valent
      ChatNotificationService.instance.notifyIncomingMessage(
        senderName: 'Siska',
        message: 'Halo dr. Valent, saya ingin tanya hasil EKG kemarin.',
        senderRole: ChatSenderRole.patient,
        conversationDoctorName: 'dr. Kavalera Valent',
        doctorPhoto: 'assets/images/dokter_valent.jpg',
        doctorSpecialty: 'Spesialis Jantung & Pembuluh Darah',
        patientName: 'Siska',
        patientId: 'patient_siska_002',
        doctorId: 'doctor_valent_uid',
      );

      // dr. Asya notification check
      final asyaNotifs = ChatNotificationService.instance.getNotificationsForUser(
        viewerRole: ChatSenderRole.doctor,
        doctorId: 'doctor_asya_uid',
        doctorName: 'dr. Asya Catherine',
      );
      expect(asyaNotifs.length, 1);
      expect(asyaNotifs.first.patientName, 'Firdaa');
      expect(asyaNotifs.first.conversationDoctorName, 'dr. Asya Catherine');
      expect(
        ChatNotificationService.instance.getUnreadCountForDoctorAccount(
          doctorId: 'doctor_asya_uid',
          doctorName: 'dr. Asya Catherine',
        ),
        1,
      );

      // dr. Valent notification check
      final valentNotifs = ChatNotificationService.instance.getNotificationsForUser(
        viewerRole: ChatSenderRole.doctor,
        doctorId: 'doctor_valent_uid',
        doctorName: 'dr. Kavalera Valent',
      );
      expect(valentNotifs.length, 1);
      expect(valentNotifs.first.patientName, 'Siska');
      expect(valentNotifs.first.conversationDoctorName, 'dr. Kavalera Valent');
      expect(
        ChatNotificationService.instance.getUnreadCountForDoctorAccount(
          doctorId: 'doctor_valent_uid',
          doctorName: 'dr. Kavalera Valent',
        ),
        1,
      );
    });

    test('Bot message only sent once on first chat with doctor, not on subsequent messages', () async {
      const chatIdAsya = 'chat_patient01_doctor_asya';

      // Sebelum chat pertama kali, bot belum membalas
      final beforeFirstChat = await ChatService.instance.hasInitialBotReplied(
        chatId: chatIdAsya,
        patientId: 'patient01',
        doctorName: 'dr. Asya Catherine',
      );
      expect(beforeFirstChat, isFalse);

      // Pasien mengirim pesan pertama -> tandai bot awal sudah membalas
      await ChatService.instance.markInitialBotReplied(
        chatId: chatIdAsya,
        patientId: 'patient01',
        doctorName: 'dr. Asya Catherine',
      );

      // Pengecekan berikutnya untuk chat room dr. Asya harus bernilai true (bot TIDAK membalas lagi)
      final afterFirstChat = await ChatService.instance.hasInitialBotReplied(
        chatId: chatIdAsya,
        patientId: 'patient01',
        doctorName: 'dr. Asya Catherine',
      );
      expect(afterFirstChat, isTrue);

      // Dokter lain (dr. Kavalera Valent) tetap bernilai false hingga pasien chat pertama kali ke dr. Valent
      const chatIdValent = 'chat_patient01_doctor_valent';
      final valentCheck = await ChatService.instance.hasInitialBotReplied(
        chatId: chatIdValent,
        patientId: 'patient01',
        doctorName: 'dr. Kavalera Valent',
      );
      expect(valentCheck, isFalse);
    });

    test('Delete notification deletes single item and clearAllNotificationsForUser isolates account deletion', () async {
      // Create notif for patient 1
      ChatNotificationService.instance.notifyIncomingMessage(
        conversationDoctorName: 'dr. Asya Catherine',
        doctorPhoto: 'assets/images/dokter_asya.jpg',
        doctorSpecialty: 'Spesialis Jantung',
        patientName: 'Firdaa',
        senderRole: ChatSenderRole.doctor,
        senderName: 'dr. Asya Catherine',
        message: 'Pesan ke Firdaa 1',
        patientId: 'patient_firdaa',
        doctorId: 'doc_asya',
      );

      ChatNotificationService.instance.notifyIncomingMessage(
        conversationDoctorName: 'dr. Asya Catherine',
        doctorPhoto: 'assets/images/dokter_asya.jpg',
        doctorSpecialty: 'Spesialis Jantung',
        patientName: 'Firdaa',
        senderRole: ChatSenderRole.doctor,
        senderName: 'dr. Asya Catherine',
        message: 'Pesan ke Firdaa 2',
        patientId: 'patient_firdaa',
        doctorId: 'doc_asya',
      );

      // Create notif for patient 2
      ChatNotificationService.instance.notifyIncomingMessage(
        conversationDoctorName: 'dr. Kavalera Valent',
        doctorPhoto: 'assets/images/dokter_valent.jpg',
        doctorSpecialty: 'Spesialis Jantung & Pembuluh Darah',
        patientName: 'Budi',
        senderRole: ChatSenderRole.doctor,
        senderName: 'dr. Kavalera Valent',
        message: 'Pesan ke Budi',
        patientId: 'patient_budi',
        doctorId: 'doc_valent',
      );

      var firdaaNotifs = ChatNotificationService.instance.getNotificationsForUser(
        viewerRole: ChatSenderRole.patient,
        patientId: 'patient_firdaa',
        patientName: 'Firdaa',
      );
      expect(firdaaNotifs.length, 2);

      // Test delete single notification
      final toDeleteId = firdaaNotifs.first.id;
      await ChatNotificationService.instance.deleteNotification(toDeleteId);

      firdaaNotifs = ChatNotificationService.instance.getNotificationsForUser(
        viewerRole: ChatSenderRole.patient,
        patientId: 'patient_firdaa',
        patientName: 'Firdaa',
      );
      expect(firdaaNotifs.length, 1);
      expect(firdaaNotifs.first.id, isNot(toDeleteId));

      // Budi's notifications must still be intact
      var budiNotifs = ChatNotificationService.instance.getNotificationsForUser(
        viewerRole: ChatSenderRole.patient,
        patientId: 'patient_budi',
        patientName: 'Budi',
      );
      expect(budiNotifs.length, 1);

      // Test clearAllNotificationsForUser: only Firdaa's notifications are cleared
      await ChatNotificationService.instance.clearAllNotificationsForUser(
        viewerRole: ChatSenderRole.patient,
        patientId: 'patient_firdaa',
        patientName: 'Firdaa',
      );

      firdaaNotifs = ChatNotificationService.instance.getNotificationsForUser(
        viewerRole: ChatSenderRole.patient,
        patientId: 'patient_firdaa',
        patientName: 'Firdaa',
      );
      expect(firdaaNotifs.isEmpty, isTrue);

      // Budi's notification is preserved!
      budiNotifs = ChatNotificationService.instance.getNotificationsForUser(
        viewerRole: ChatSenderRole.patient,
        patientId: 'patient_budi',
        patientName: 'Budi',
      );
      expect(budiNotifs.length, 1);
    });
  });
}
