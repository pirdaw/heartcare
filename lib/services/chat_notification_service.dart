import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

/// Model untuk notifikasi pesan masuk chat
class ChatNotificationItem {
  final String id;
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
  /// Contoh: "dr. Nurlitta Dwi mengirim pesan baru: Bagaimana kondisi Anda hari ini?"
  String get notificationTitle => '$senderName mengirim pesan baru';
  String get formattedNotificationText => '$notificationTitle: $messageSnippet';

  Map<String, dynamic> toJson() => {
        'id': id,
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
      conversationDoctorName: json['conversationDoctorName'] ?? 'dr. Nurlitta Dwi',
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
/// dan sistem notifikasi pesan masuk antara dokter dan pasien.
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
  /// agar banner in-app dapat langsung ditampilkan di layar mana pun.
  final StreamController<ChatNotificationItem> _notificationStreamController =
      StreamController<ChatNotificationItem>.broadcast();

  Stream<ChatNotificationItem> get onNewNotification =>
      _notificationStreamController.stream;

  /// Ruang chat yang sedang aktif dilihat oleh user saat ini
  /// (jika user sedang berada di ruang chat dokter X, pesan dari dokter X
  /// tidak akan memunculkan banner notifikasi yang mengganggu).
  String? currentActiveDoctorRoom;

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
          _notifications.add(ChatNotificationItem.fromJson(
              Map<String, dynamic>.from(item)));
        }
      }
    } catch (e) {
      debugPrint('[ChatNotificationService] Error initializing: $e');
    }

    // Jika percakapan masih kosong, inisialisasi default
    if (_conversations.isEmpty) {
      _seedDefaultConversations();
    }

    notifyListeners();
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

  /// Jumlah pesan belum dibaca yang ditujukan untuk Pasien (dari seluruh dokter)
  int get unreadCountForPatient {
    int count = 0;
    for (var list in _conversations.values) {
      for (var msg in list) {
        if (msg.senderRole == ChatSenderRole.doctor && !msg.isRead) {
          count++;
        }
      }
    }
    return count;
  }

  /// Jumlah pesan belum dibaca yang ditujukan untuk Dokter
  int get unreadCountForDoctorOverall {
    int count = 0;
    for (var list in _conversations.values) {
      for (var msg in list) {
        if (msg.senderRole == ChatSenderRole.patient && !msg.isRead) {
          count++;
        }
      }
    }
    return count;
  }

  /// Jumlah pesan belum dibaca dari dokter tertentu untuk pasien
  int getUnreadCountForDoctorName(String doctorName) {
    final list = _conversations[doctorName];
    if (list == null) return 0;
    return list
        .where((msg) => msg.senderRole == ChatSenderRole.doctor && !msg.isRead)
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

    // Jika ruang chat dokter sedang aktif dibuka di layar, langsung anggap terbaca
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

    // Buat objek notifikasi untuk penerima
    final ChatSenderRole recipientRole = (senderRole == ChatSenderRole.doctor)
        ? ChatSenderRole.patient
        : ChatSenderRole.doctor;

    final notifId = 'notif_${now.millisecondsSinceEpoch}';
    final snippet = message.length > 60
        ? '${message.substring(0, 57)}...'
        : message;

    final notif = ChatNotificationItem(
      id: notifId,
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

    // Batasi riwayat notifikasi maksimal 50 agar hemat memori
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }

    await _saveToPrefs();
    notifyListeners();

    // Pancarkan event notifikasi real-time jika penerima tidak sedang di ruang chat
    if (emitNotification && !isRecipientViewingChat) {
      _notificationStreamController.add(notif);
    }

    return newMsg;
  }

  /// Tandai seluruh pesan dalam percakapan dokter tertentu sebagai sudah dibaca
  Future<void> markAsRead(String doctorName, {ChatSenderRole? viewerRole}) async {
    bool changed = false;

    // Default: jika viewerRole tidak dispesifikasikan, tandai pesan yang dikirim oleh
    // pihak lawan sebagai sudah dibaca
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

    // Tandai juga notifikasi terkait dokter ini sebagai sudah dibaca
    for (var notif in _notifications) {
      if (notif.conversationDoctorName == doctorName && !notif.isRead) {
        if (viewerRole == null || notif.recipientRole == viewerRole) {
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

  /// Tandai semua notifikasi sebagai sudah dibaca
  Future<void> markAllNotificationsAsRead() async {
    for (var notif in _notifications) {
      notif.isRead = true;
    }
    // Tandai semua pesan masuk juga sebagai terbaca
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
    String? time,
    bool isRead = false,
  }) {
    final now = DateTime.now();
    final timeStr = time ??
        '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';
    final notifId = 'notif_${now.millisecondsSinceEpoch}_${now.microsecond % 1000}';
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
  }) async {
    final String msg = customMessage ??
        "Halo, bagaimana perkembangan keluhan nyeri dada dan ritme detak jantung Anda hari ini? Mohon infokan jika ada keluhan baru.";

    await sendMessage(
      doctorName: doctorName,
      message: msg,
      senderRole: ChatSenderRole.doctor,
      doctorPhoto: doctorPhoto,
      doctorSpecialty: doctorSpecialty,
      emitNotification: true,
    );
  }

  /// Simulasi pesan masuk dari pasien ke dokter (untuk menguji notifikasi sisi dokter)
  Future<void> simulatePatientMessage({
    required String doctorName,
    String? customMessage,
  }) async {
    final patientName = getPatientName();
    final String msg = customMessage ??
        "Dok, hasil tensi saya pagi ini 145/95 mmHg dan kepala terasa agak pusing. Apakah perlu penyesuaian dosis obat?";

    await sendMessage(
      doctorName: doctorName,
      message: msg,
      senderRole: ChatSenderRole.patient,
      senderNameOverride: patientName,
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
        message: "Halo $patientName, Selamat datang di layanan konsultasi online HeartCare. Ada yang bisa saya bantu terkait kesehatan jantung Anda?",
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
        message: "Dok, saya tadi melakukan skrining mandiri di aplikasi, hasilnya terindikasi risiko tinggi. Apa langkah awal yang harus saya lakukan?",
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
        message: "Baik, jangan panik ya. Saya siap membantu evaluasi klinis. Apakah Anda merasakan keluhan fisik seperti nyeri dada menjalar, jantung berdebar, atau sesak nafas saat beraktivitas?",
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

    // Tambahkan 1 pesan belum dibaca dari dr. Nurlitta Dwi agar ada demo realistis
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';

    final demoMsg = ChatMessageItem(
      id: 'demo_unread_nurlitta',
      doctorName: 'dr. Nurlitta Dwi',
      doctorPhoto: 'assets/images/dokter_nurlitta.jpg',
      doctorSpecialty: 'Spesialis Jantung & Konsultan Aritmia',
      patientName: getPatientName(),
      senderRole: ChatSenderRole.doctor,
      senderName: 'dr. Nurlitta Dwi',
      message: 'Bagaimana kondisi Anda hari ini? Jangan lupa catat tensi dan hindari begadang ya.',
      time: timeStr,
      timestamp: now.subtract(const Duration(minutes: 5)),
      isRead: false,
    );
    _conversations['dr. Nurlitta Dwi']!.add(demoMsg);

    _notifications.add(
      ChatNotificationItem(
        id: 'demo_notif_1',
        conversationDoctorName: 'dr. Nurlitta Dwi',
        doctorPhoto: 'assets/images/dokter_nurlitta.jpg',
        doctorSpecialty: 'Spesialis Jantung & Konsultan Aritmia',
        patientName: getPatientName(),
        senderRole: ChatSenderRole.doctor,
        senderName: 'dr. Nurlitta Dwi',
        recipientRole: ChatSenderRole.patient,
        messageSnippet:
            'Bagaimana kondisi Anda hari ini? Jangan lupa catat tensi dan hindari begadang ya.',
        time: timeStr,
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
    );
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

  @override
  void dispose() {
    _notificationStreamController.close();
    super.dispose();
  }
}
