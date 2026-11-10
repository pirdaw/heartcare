import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_profile_service.dart';

/// Peran pengirim pesan dalam konsultasi chat
enum ChatSenderRole {
  doctor,
  patient,
}

/// Model untuk setiap pesan chat
class ChatMessageItem {
  final String id;
  final String doctorName;
  final String doctorPhoto;
  final String doctorSpecialty;
  final String patientName;
  final ChatSenderRole senderRole;
  final String senderName;
  final String message;
  final String time;
  final DateTime timestamp;
  bool isRead;
  final String? attachmentType;
  final String? imagePath;

  ChatMessageItem({
    required this.id,
    required this.doctorName,
    required this.doctorPhoto,
    required this.doctorSpecialty,
    required this.patientName,
    required this.senderRole,
    required this.senderName,
    required this.message,
    required this.time,
    required this.timestamp,
    this.isRead = false,
    this.attachmentType,
    this.imagePath,
  });

  bool get isDoctor => senderRole == ChatSenderRole.doctor;
  bool get isPatient => senderRole == ChatSenderRole.patient;

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctorName': doctorName,
        'doctorPhoto': doctorPhoto,
        'doctorSpecialty': doctorSpecialty,
        'patientName': patientName,
        'senderRole': senderRole.name,
        'senderName': senderName,
        'message': message,
        'time': time,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'attachmentType': attachmentType,
        'imagePath': imagePath,
      };

  factory ChatMessageItem.fromJson(Map<String, dynamic> json) {
    return ChatMessageItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      doctorName: json['doctorName'] ?? 'dr. Nurlitta Dwi',
      doctorPhoto: json['doctorPhoto'] ?? 'assets/images/dokter_nurlitta.jpg',
      doctorSpecialty: json['doctorSpecialty'] ?? 'Spesialis Jantung',
      patientName: json['patientName'] ?? 'Pasien',
      senderRole: json['senderRole'] == 'doctor'
          ? ChatSenderRole.doctor
          : ChatSenderRole.patient,
      senderName: json['senderName'] ?? '',
      message: json['message'] ?? '',
      time: json['time'] ?? '10.00',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      attachmentType: json['attachmentType'],
      imagePath: json['imagePath'],
    );
  }
}

/// Model untuk notifikasi pesan masuk chat dengan metadata role dan hak akses akun
class ChatNotificationItem {
  final String id;
  final String? chatId;
  final String? patientId;
  final String? doctorId;
  final String conversationDoctorName;
  final String doctorPhoto;
  final String doctorSpecialty;
  final String patientName;
  final ChatSenderRole senderRole;
  final String senderName;
  final ChatSenderRole recipientRole;
  final String messageSnippet;
  final String time;
  final DateTime timestamp;
  bool isRead;

  ChatNotificationItem({
    required this.id,
    this.chatId,
    this.patientId,
    this.doctorId,
    required this.conversationDoctorName,
    required this.doctorPhoto,
    required this.doctorSpecialty,
    required this.patientName,
    required this.senderRole,
    required this.senderName,
    required this.recipientRole,
    required this.messageSnippet,
    required this.time,
    required this.timestamp,
    this.isRead = false,
  });

  /// Format teks notifikasi sesuai permintaan user
  String get notificationTitle => '$senderName mengirim pesan baru';
  String get formattedNotificationText => '$notificationTitle: $messageSnippet';

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'patientId': patientId,
        'doctorId': doctorId,
        'conversationDoctorName': conversationDoctorName,
        'doctorPhoto': doctorPhoto,
        'doctorSpecialty': doctorSpecialty,
        'patientName': patientName,
        'senderRole': senderRole.name,
        'senderName': senderName,
        'recipientRole': recipientRole.name,
        'messageSnippet': messageSnippet,
        'time': time,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory ChatNotificationItem.fromJson(Map<String, dynamic> json) {
    return ChatNotificationItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: json['chatId'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      conversationDoctorName:
          json['conversationDoctorName'] ?? 'dr. Nurlitta Dwi',
      doctorPhoto: json['doctorPhoto'] ?? 'assets/images/dokter_nurlitta.jpg',
      doctorSpecialty: json['doctorSpecialty'] ?? 'Spesialis Jantung',
      patientName: json['patientName'] ?? 'Pasien',
      senderRole: json['senderRole'] == 'doctor'
          ? ChatSenderRole.doctor
          : ChatSenderRole.patient,
      senderName: json['senderName'] ?? '',
      recipientRole: json['recipientRole'] == 'doctor'
          ? ChatSenderRole.doctor
          : ChatSenderRole.patient,
      messageSnippet: json['messageSnippet'] ?? '',
      time: json['time'] ?? '10.00',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}

/// Layanan terpusat untuk konsultasi chat, penyimpanan percakapan,
/// dan sistem notifikasi pesan masuk antara dokter dan pasien dengan hak akses akun.
class ChatNotificationService extends ChangeNotifier {
  ChatNotificationService._internal();
  static final ChatNotificationService instance =
      ChatNotificationService._internal();
  factory ChatNotificationService() => instance;

  static const String _prefConversationsKey = 'heartcare_chat_conversations_v1';
  static const String _prefNotificationsKey = 'heartcare_chat_notifications_v1';

  final Map<String, List<ChatMessageItem>> _conversations = {};
  final List<ChatNotificationItem> _notifications = [];

  /// Stream controller untuk memancarkan event notifikasi baru secara real-time
  final StreamController<ChatNotificationItem> _notificationStreamController =
      StreamController<ChatNotificationItem>.broadcast();

  Stream<ChatNotificationItem> get onNewNotification =>
      _notificationStreamController.stream;

  /// Ruang chat yang sedang aktif dilihat oleh user saat ini
  String? currentActiveDoctorRoom;

  static int _notifSeq = 0;
  bool _initialized = false;

  /// Inisialisasi service dan muat data dari SharedPreferences
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Muat percakapan tersimpan
      final convJson = prefs.getString(_prefConversationsKey);
      if (convJson != null && convJson.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(convJson);
        _conversations.clear();
        decoded.forEach((key, listRaw) {
          if (listRaw is List) {
            _conversations[key] = listRaw
                .map((item) =>
                    ChatMessageItem.fromJson(Map<String, dynamic>.from(item)))
                .toList();
          }
        });
      }

      // Muat notifikasi tersimpan
      final notifJson = prefs.getString(_prefNotificationsKey);
      if (notifJson != null && notifJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(notifJson);
        _notifications.clear();
        for (var item in decodedList) {
          final notif = ChatNotificationItem.fromJson(
              Map<String, dynamic>.from(item));
          if (notif.id != 'demo_notif_1') {
            _notifications.add(notif);
          }
        }
      }
      _cleanMockDemoNotifications();
    } catch (e) {
      debugPrint('[ChatNotificationService] Error initializing: $e');
    }

    // Jika percakapan masih kosong, inisialisasi default struktur percakapan
    if (_conversations.isEmpty) {
      _seedDefaultConversations();
    }

    notifyListeners();
  }

  void _cleanMockDemoNotifications() {
    _notifications.removeWhere((n) =>
        n.id == 'demo_notif_1' ||
        n.id == 'demo_unread_nurlitta' ||
        (n.messageSnippet.contains('Jangan lupa catat tensi dan hindari begadang') &&
            n.conversationDoctorName == 'dr. Nurlitta Dwi' &&
            n.patientName == 'Pasien HeartCare'));
  }

  /// Dapatkan daftar pesan untuk dokter tertentu
  List<ChatMessageItem> getMessages(String doctorName) {
    if (!_conversations.containsKey(doctorName)) {
      _initConversationForDoctor(doctorName);
    }
    return List.unmodifiable(_conversations[doctorName] ?? []);
  }

  /// Dapatkan seluruh riwayat notifikasi (diurutkan dari yang terbaru)
  List<ChatNotificationItem> getNotifications({ChatSenderRole? filterRecipientRole}) {
    final list = List<ChatNotificationItem>.from(_notifications);
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (filterRecipientRole != null) {
      return list.where((n) => n.recipientRole == filterRecipientRole).toList();
    }
    return list;
  }

  /// Helper untuk mencocokkan notifikasi dengan akun pasien
  bool _matchesPatient(ChatNotificationItem notif,
      {String? patientId, String? patientName}) {
    final cleanPId = (patientId ?? '').trim().toLowerCase();
    final cleanPName = (patientName ?? '').trim().toLowerCase();

    // 1. Cocokkan berdasarkan patientId jika ada
    if (notif.patientId != null && notif.patientId!.isNotEmpty) {
      final notifPid = notif.patientId!.trim().toLowerCase();
      if (cleanPId.isNotEmpty) {
        if (notifPid == cleanPId ||
            notifPid.contains(cleanPId) ||
            cleanPId.contains(notifPid)) {
          return true;
        }
      }
    }

    // 2. Cocokkan berdasarkan nama pasien
    if (cleanPName.isNotEmpty && notif.patientName.isNotEmpty) {
      final notifPName = notif.patientName.trim().toLowerCase();
      if (notifPName == cleanPName ||
          notifPName.contains(cleanPName) ||
          cleanPName.contains(notifPName)) {
        return true;
      }
    }

    // 3. Fallback jika patientId & patientName kosong
    if (cleanPId.isEmpty && cleanPName.isEmpty) {
      return true;
    }

    return false;
  }

  /// Helper untuk mencocokkan notifikasi dengan akun dokter
  bool _matchesDoctor(ChatNotificationItem notif,
      {String? doctorId, String? doctorName}) {
    final cleanDId = (doctorId ?? '').trim().toLowerCase();
    final cleanDName = (doctorName ?? '').trim().toLowerCase();

    final notifDocName = notif.conversationDoctorName.trim().toLowerCase();
    final notifDocId = (notif.doctorId ?? '').trim().toLowerCase();

    // Isolasi ketat untuk dua dokter utama (dr. Asya dan dr. Valent)
    final isTargetAsya = cleanDName.contains('asya') ||
        cleanDName.contains('catherine') ||
        cleanDId.contains('asya');
    final isTargetValent = cleanDName.contains('valent') ||
        cleanDName.contains('kavalera') ||
        cleanDId.contains('valent') ||
        cleanDId.contains('kavalera');

    final isNotifAsya = notifDocName.contains('asya') ||
        notifDocName.contains('catherine') ||
        notifDocId.contains('asya');
    final isNotifValent = notifDocName.contains('valent') ||
        notifDocName.contains('kavalera') ||
        notifDocId.contains('valent') ||
        notifDocId.contains('kavalera');

    if (isTargetAsya) {
      if (isNotifValent && !isNotifAsya) return false;
      return isNotifAsya ||
          (cleanDId.isNotEmpty && notifDocId.isNotEmpty && notifDocId == cleanDId);
    }

    if (isTargetValent) {
      if (isNotifAsya && !isNotifValent) return false;
      return isNotifValent ||
          (cleanDId.isNotEmpty && notifDocId.isNotEmpty && notifDocId == cleanDId);
    }

    if (cleanDId.isNotEmpty && notifDocId.isNotEmpty) {
      if (notifDocId == cleanDId ||
          notifDocId.contains(cleanDId) ||
          cleanDId.contains(notifDocId)) {
        return true;
      }
    }

    if (cleanDName.isNotEmpty && notifDocName.isNotEmpty) {
      if (notifDocName == cleanDName ||
          notifDocName.contains(cleanDName) ||
          cleanDName.contains(notifDocName)) {
        return true;
      }
    }

    if (cleanDId.isEmpty && cleanDName.isEmpty) {
      return true;
    }

    return false;
  }

  /// Dapatkan seluruh notifikasi yang disesuaikan dengan hak akses peran (Pasien atau Dokter)
  /// dan akun pengguna yang sedang login saat ini.
  List<ChatNotificationItem> getNotificationsForUser({
    required ChatSenderRole viewerRole,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    bool? unreadOnly,
  }) {
    final all = getNotifications(filterRecipientRole: viewerRole);

    return all.where((n) {
      if (unreadOnly == true && n.isRead) return false;

      if (viewerRole == ChatSenderRole.patient) {
        return _matchesPatient(n,
            patientId: patientId, patientName: patientName);
      } else {
        return _matchesDoctor(n,
            doctorId: doctorId, doctorName: doctorName);
      }
    }).toList();
  }

  /// Memeriksa apakah notifikasi masuk ditujukan untuk akun yang sedang login saat ini
  bool isNotificationForCurrentAccount(ChatNotificationItem notif) {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final profile = UserProfileService.instance.currentProfile;

      final isDoctor = (user?.email?.toLowerCase().contains('dokter') ?? false) ||
          (user?.displayName?.toLowerCase().startsWith('dr.') ?? false) ||
          (profile.nama.toLowerCase().startsWith('dr.'));

      if (isDoctor) {
        if (notif.recipientRole != ChatSenderRole.doctor) return false;
        return _matchesDoctor(
          notif,
          doctorId: user?.uid,
          doctorName: user?.displayName ?? profile.nama,
        );
      } else {
        if (notif.recipientRole != ChatSenderRole.patient) return false;
        return _matchesPatient(
          notif,
          patientId: user?.uid ?? user?.email ?? profile.nama,
          patientName:
              profile.nama.isNotEmpty ? profile.nama : user?.displayName,
        );
      }
    } catch (_) {
      return true;
    }
  }

  /// Jumlah pesan belum dibaca khusus akun Pasien tertentu
  int getUnreadCountForPatientAccount({
    String? patientId,
    String? patientName,
  }) {
    return getNotificationsForUser(
      viewerRole: ChatSenderRole.patient,
      patientId: patientId,
      patientName: patientName,
      unreadOnly: true,
    ).length;
  }

  /// Jumlah pesan belum dibaca khusus akun Dokter tertentu
  int getUnreadCountForDoctorAccount({
    String? doctorId,
    String? doctorName,
  }) {
    return getNotificationsForUser(
      viewerRole: ChatSenderRole.doctor,
      doctorId: doctorId,
      doctorName: doctorName,
      unreadOnly: true,
    ).length;
  }

  /// Jumlah pesan belum dibaca yang ditujukan untuk Pasien (global/fallback)
  int get unreadCountForPatient {
    return _notifications
        .where((n) => n.recipientRole == ChatSenderRole.patient && !n.isRead)
        .length;
  }

  /// Jumlah pesan belum dibaca yang ditujukan untuk Dokter (global/fallback)
  int get unreadCountForDoctorOverall {
    return _notifications
        .where((n) => n.recipientRole == ChatSenderRole.doctor && !n.isRead)
        .length;
  }

  /// Jumlah pesan belum dibaca dari dokter tertentu untuk pasien
  int getUnreadCountForDoctorName(String doctorName) {
    return _notifications
        .where((n) =>
            n.conversationDoctorName == doctorName &&
            n.recipientRole == ChatSenderRole.patient &&
            !n.isRead)
        .length;
  }

  /// Jumlah total notifikasi yang belum dibaca
  int get totalUnreadNotificationCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  /// Dapatkan nama pasien dari profil pengguna yang sedang login
  String getPatientName() {
    try {
      final profile = UserProfileService.instance.currentProfile;
      if (profile.nama.trim().isNotEmpty) {
        return profile.nama.trim();
      }
    } catch (_) {}
    return 'Pasien HeartCare';
  }

  /// Kirim pesan baru (bisa dari dokter maupun pasien)
  Future<ChatMessageItem> sendMessage({
    required String doctorName,
    required String message,
    required ChatSenderRole senderRole,
    String? chatId,
    String? patientId,
    String? doctorId,
    String? senderNameOverride,
    String? doctorPhoto,
    String? doctorSpecialty,
    String? attachmentType,
    String? imagePath,
    bool emitNotification = true,
  }) async {
    final photo = doctorPhoto ?? _getDefaultDoctorPhoto(doctorName);
    final specialty = doctorSpecialty ?? _getDefaultDoctorSpecialty(doctorName);
    final patientName = getPatientName();

    final String senderName = senderNameOverride ??
        (senderRole == ChatSenderRole.doctor ? doctorName : patientName);

    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';

    final msgId = 'msg_${now.millisecondsSinceEpoch}_${_conversations.length}';

    final bool isRecipientViewingChat = (currentActiveDoctorRoom == doctorName);

    final newMsg = ChatMessageItem(
      id: msgId,
      doctorName: doctorName,
      doctorPhoto: photo,
      doctorSpecialty: specialty,
      patientName: patientName,
      senderRole: senderRole,
      senderName: senderName,
      message: message,
      time: timeStr,
      timestamp: now,
      isRead: isRecipientViewingChat,
      attachmentType: attachmentType,
      imagePath: imagePath,
    );

    if (!_conversations.containsKey(doctorName)) {
      _conversations[doctorName] = [];
    }
    _conversations[doctorName]!.add(newMsg);

    final ChatSenderRole recipientRole = (senderRole == ChatSenderRole.doctor)
        ? ChatSenderRole.patient
        : ChatSenderRole.doctor;

    final notifId = 'notif_${now.millisecondsSinceEpoch}_${++_notifSeq}';
    final snippet = message.length > 60
        ? '${message.substring(0, 57)}...'
        : message;

    final notif = ChatNotificationItem(
      id: notifId,
      chatId: chatId,
      patientId: patientId,
      doctorId: doctorId,
      conversationDoctorName: doctorName,
      doctorPhoto: photo,
      doctorSpecialty: specialty,
      patientName: patientName,
      senderRole: senderRole,
      senderName: senderName,
      recipientRole: recipientRole,
      messageSnippet: snippet,
      time: timeStr,
      timestamp: now,
      isRead: isRecipientViewingChat,
    );

    _notifications.insert(0, notif);

    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }

    await _saveToPrefs();
    notifyListeners();

    if (emitNotification && !isRecipientViewingChat) {
      _notificationStreamController.add(notif);
    }

    return newMsg;
  }

  /// Tandai seluruh pesan dalam percakapan dokter tertentu sebagai sudah dibaca
  Future<void> markAsRead(
    String doctorName, {
    ChatSenderRole? viewerRole,
    String? patientId,
    String? doctorId,
  }) async {
    bool changed = false;

    final list = _conversations[doctorName];
    if (list != null) {
      for (var msg in list) {
        if (!msg.isRead) {
          if (viewerRole == null || msg.senderRole != viewerRole) {
            msg.isRead = true;
            changed = true;
          }
        }
      }
    }

    for (var notif in _notifications) {
      if (notif.conversationDoctorName == doctorName && !notif.isRead) {
        if (viewerRole == null || notif.recipientRole == viewerRole) {
          if (viewerRole == ChatSenderRole.patient &&
              patientId != null &&
              patientId.isNotEmpty) {
            if (!_matchesPatient(notif, patientId: patientId)) {
              continue;
            }
          } else if (viewerRole == ChatSenderRole.doctor &&
              doctorId != null &&
              doctorId.isNotEmpty) {
            if (!_matchesDoctor(notif,
                doctorId: doctorId, doctorName: doctorName)) {
              continue;
            }
          }
          notif.isRead = true;
          changed = true;
        }
      }
    }

    if (changed) {
      await _saveToPrefs();
      notifyListeners();
    }
  }

  /// Tandai semua notifikasi untuk akun user tertentu sebagai sudah dibaca
  Future<void> markAllNotificationsAsReadForUser({
    required ChatSenderRole viewerRole,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
  }) async {
    final userNotifs = getNotificationsForUser(
      viewerRole: viewerRole,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
    );
    for (var notif in userNotifs) {
      notif.isRead = true;
    }
    await _saveToPrefs();
    notifyListeners();
  }

  /// Tandai semua notifikasi sebagai sudah dibaca (global)
  Future<void> markAllNotificationsAsRead() async {
    for (var notif in _notifications) {
      notif.isRead = true;
    }
    for (var list in _conversations.values) {
      for (var msg in list) {
        msg.isRead = true;
      }
    }
    await _saveToPrefs();
    notifyListeners();
  }

  /// Hapus satu notifikasi dari daftar
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveToPrefs();
    notifyListeners();
  }

  /// Hapus semua notifikasi dari daftar
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveToPrefs();
    notifyListeners();
  }

  /// Hapus semua notifikasi milik akun user tertentu
  Future<void> clearAllNotificationsForUser({
    required ChatSenderRole viewerRole,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
  }) async {
    final userNotifs = getNotificationsForUser(
      viewerRole: viewerRole,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
    );
    final userNotifIds = userNotifs.map((n) => n.id).toSet();
    _notifications.removeWhere((n) => userNotifIds.contains(n.id));
    await _saveToPrefs();
    notifyListeners();
  }

  /// Reset state percakapan dan notifikasi untuk keperluan testing
  Future<void> resetForTesting({bool seed = false}) async {
    _conversations.clear();
    _notifications.clear();
    currentActiveDoctorRoom = null;
    if (seed) {
      _seedDefaultConversations();
    }
    await _saveToPrefs();
    notifyListeners();
  }

  /// Simulasi balasan dokter yang cerdas dan realistis
  Future<void> simulateDoctorReply({
    required String doctorName,
    required String userMessage,
    String? doctorPhoto,
    String? doctorSpecialty,
    Duration delay = const Duration(milliseconds: 2200),
  }) async {
    await Future.delayed(delay);

    final replyText = getClinicalReply(userMessage);

    await sendMessage(
      doctorName: doctorName,
      message: replyText,
      senderRole: ChatSenderRole.doctor,
      doctorPhoto: doctorPhoto,
      doctorSpecialty: doctorSpecialty,
      emitNotification: true,
    );
  }

  /// Panggil fungsi ini dari mana pun (misal ChatService) ketika ada pesan masuk baru
  void notifyIncomingMessage({
    required String conversationDoctorName,
    required String doctorPhoto,
    required String doctorSpecialty,
    required String patientName,
    required ChatSenderRole senderRole,
    required String senderName,
    required String message,
    String? chatId,
    String? patientId,
    String? doctorId,
    String? time,
    bool isRead = false,
  }) {
    final now = DateTime.now();
    final timeStr = time ??
        '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';
    final notifId =
        'notif_${now.millisecondsSinceEpoch}_${++_notifSeq}';
    final recipientRole = (senderRole == ChatSenderRole.doctor)
        ? ChatSenderRole.patient
        : ChatSenderRole.doctor;

    final snippet = message.length > 70
        ? '${message.substring(0, 67)}...'
        : message;

    final bool isRecipientViewingChat =
        (currentActiveDoctorRoom == conversationDoctorName);

    final notif = ChatNotificationItem(
      id: notifId,
      chatId: chatId,
      patientId: patientId,
      doctorId: doctorId,
      conversationDoctorName: conversationDoctorName,
      doctorPhoto: doctorPhoto,
      doctorSpecialty: doctorSpecialty,
      patientName: patientName,
      senderRole: senderRole,
      senderName: senderName,
      recipientRole: recipientRole,
      messageSnippet: snippet,
      time: timeStr,
      timestamp: now,
      isRead: isRead || isRecipientViewingChat,
    );

    _notifications.insert(0, notif);
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }

    _saveToPrefs();
    notifyListeners();

    if (!isRecipientViewingChat && !isRead) {
      _notificationStreamController.add(notif);
    }
  }

  /// Simulasi pesan inisiatif dari dokter (misal follow up kondisi)
  Future<void> simulateDoctorInitiatedMessage({
    required String doctorName,
    String? customMessage,
    String? doctorPhoto,
    String? doctorSpecialty,
    String? patientId,
    String? doctorId,
  }) async {
    final String msg = customMessage ??
        "Halo, bagaimana perkembangan keluhan nyeri dada dan ritme detak jantung Anda hari ini? Mohon infokan jika ada keluhan baru.";

    await sendMessage(
      doctorName: doctorName,
      message: msg,
      senderRole: ChatSenderRole.doctor,
      doctorPhoto: doctorPhoto,
      doctorSpecialty: doctorSpecialty,
      patientId: patientId,
      doctorId: doctorId,
      emitNotification: true,
    );
  }

  /// Simulasi pesan masuk dari pasien ke dokter (untuk menguji notifikasi sisi dokter)
  Future<void> simulatePatientMessage({
    required String doctorName,
    String? customMessage,
    String? patientId,
    String? doctorId,
  }) async {
    final patientName = getPatientName();
    final String msg = customMessage ??
        "Dok, hasil tensi saya pagi ini 145/95 mmHg dan kepala terasa agak pusing. Apakah perlu penyesuaian dosis obat?";

    await sendMessage(
      doctorName: doctorName,
      message: msg,
      senderRole: ChatSenderRole.patient,
      senderNameOverride: patientName,
      patientId: patientId,
      doctorId: doctorId,
      emitNotification: true,
    );
  }

  // ==========================================================
  // HELPER INTERNAL
  // ==========================================================

  String getClinicalReply(String userText) {
    final lower = userText.toLowerCase();

    if (lower.contains("sesak") ||
        lower.contains("nafas") ||
        lower.contains("dada") ||
        lower.contains("nyeri") ||
        lower.contains("sakit")) {
      return "Baik, keluhan sesak nafas atau nyeri dada adalah gejala penting yang memerlukan perhatian. Sebaiknya batasi aktivitas berat terlebih dahulu dan usahakan duduk tegak rileks. Apakah ada riwayat hipertensi sebelumnya?";
    } else if (lower.contains("obat") ||
        lower.contains("resep") ||
        lower.contains("minum") ||
        lower.contains("dosis")) {
      return "Untuk konsumsi obat jantung, sangat disarankan disesuaikan dengan hasil pemeriksaan fisik dan rekam medis terbaru. Tolong hindari mengubah dosis obat tanpa anjuran ya.";
    } else if (lower.contains("tensi") ||
        lower.contains("tekanan darah") ||
        lower.contains("darah tinggi") ||
        lower.contains("hipertensi")) {
      return "Catatan tensi sangat berharga. Disarankan mengukur tekanan darah 2x sehari (pagi dan malam). Jika angka sistolik di atas 140 mmHg, segera istirahat dan kurangi konsumsi garam.";
    } else if (lower.contains("terima kasih") ||
        lower.contains("makasih") ||
        lower.contains("baik dok") ||
        lower.contains("oke dok") ||
        lower.contains("siap")) {
      return "Sama-sama. Tetap jaga pola makan rendah garam, cukup istirahat, dan kurangi stres. Jika ada keluhan darurat mendadak, segera gunakan tombol darurat 119 ya!";
    } else {
      return "Saya telah menerima informasi yang Anda sampaikan. Tetap tenang dan istirahat yang cukup. Apakah ada keluhan lain yang dirasakan saat ini?";
    }
  }

  String _getDefaultDoctorPhoto(String doctorName) {
    if (doctorName.contains('Andi')) {
      return 'assets/images/dokter_andi.jpg';
    } else if (doctorName.contains('Sinta')) {
      return 'assets/images/dokter_sinta.jpg';
    } else if (doctorName.contains('Rina')) {
      return 'assets/images/dokter_rina.jpg';
    }
    return 'assets/images/dokter_nurlitta.jpg';
  }

  String _getDefaultDoctorSpecialty(String doctorName) {
    if (doctorName.contains('Andi')) {
      return 'Spesialis Jantung & Pembuluh Darah';
    } else if (doctorName.contains('Sinta')) {
      return 'Spesialis Jantung & Kardiovaskular';
    } else if (doctorName.contains('Rina')) {
      return 'Spesialis Jantung & Prevensi Kardio';
    }
    return 'Spesialis Jantung & Konsultan Aritmia';
  }

  void _initConversationForDoctor(String doctorName) {
    final patientName = getPatientName();
    final photo = _getDefaultDoctorPhoto(doctorName);
    final specialty = _getDefaultDoctorSpecialty(doctorName);

    _conversations[doctorName] = [
      ChatMessageItem(
        id: 'init_${doctorName}_1',
        doctorName: doctorName,
        doctorPhoto: photo,
        doctorSpecialty: specialty,
        patientName: patientName,
        senderRole: ChatSenderRole.doctor,
        senderName: doctorName,
        message:
            "Halo $patientName, Selamat datang di layanan konsultasi online HeartCare. Ada yang bisa saya bantu terkait kesehatan jantung Anda?",
        time: "14.00",
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: true,
      ),
      ChatMessageItem(
        id: 'init_${doctorName}_2',
        doctorName: doctorName,
        doctorPhoto: photo,
        doctorSpecialty: specialty,
        patientName: patientName,
        senderRole: ChatSenderRole.patient,
        senderName: patientName,
        message:
            "Dok, saya tadi melakukan skrining mandiri di aplikasi, hasilnya terindikasi risiko tinggi. Apa langkah awal yang harus saya lakukan?",
        time: "14.02",
        timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
        isRead: true,
      ),
      ChatMessageItem(
        id: 'init_${doctorName}_3',
        doctorName: doctorName,
        doctorPhoto: photo,
        doctorSpecialty: specialty,
        patientName: patientName,
        senderRole: ChatSenderRole.doctor,
        senderName: doctorName,
        message:
            "Baik, jangan panik ya. Saya siap membantu evaluasi klinis. Apakah Anda merasakan keluhan fisik seperti nyeri dada menjalar, jantung berdebar, atau sesak nafas saat beraktivitas?",
        time: "14.03",
        timestamp: DateTime.now().subtract(const Duration(minutes: 27)),
        isRead: true,
      ),
    ];
  }

  void _seedDefaultConversations() {
    _initConversationForDoctor('dr. Nurlitta Dwi');
    _initConversationForDoctor('dr. Andi Pratama');
    _initConversationForDoctor('dr. Sinta Maharani');
    _initConversationForDoctor('dr. Rina Amelia');
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final Map<String, dynamic> convMap = {};
      _conversations.forEach((k, v) {
        convMap[k] = v.map((e) => e.toJson()).toList();
      });
      await prefs.setString(_prefConversationsKey, jsonEncode(convMap));

      final List<Map<String, dynamic>> notifList =
          _notifications.map((e) => e.toJson()).toList();
      await prefs.setString(_prefNotificationsKey, jsonEncode(notifList));
    } catch (e) {
      debugPrint('[ChatNotificationService] Error saving to prefs: $e');
    }
  }
}
