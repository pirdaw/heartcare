import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartcare/services/chat_notification_service.dart';

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
  });
}
