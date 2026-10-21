import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderRole; // 'patient' atau 'doctor'
  final String senderName;
  final String message;
  final String? attachmentType; // 'image', 'screening', 'prescription'
  final String? imagePath;
  final DateTime timestamp;
  final String timeFormatted;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.senderName,
    required this.message,
    this.attachmentType,
    this.imagePath,
    required this.timestamp,
    required this.timeFormatted,
    this.isRead = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime ts = DateTime.now();
    final rawTs = data['timestamp'];
    final rawLocalTs = data['localTimestamp'];

    if (rawTs is Timestamp) {
      ts = rawTs.toDate();
    } else if (rawLocalTs is num) {
      ts = DateTime.fromMillisecondsSinceEpoch(rawLocalTs.toInt());
    } else if (rawTs is num) {
      ts = DateTime.fromMillisecondsSinceEpoch(rawTs.toInt());
    }

    final clientTime = (data['clientTime'] as String?)?.trim();
    String timeStr;
    if (clientTime != null && clientTime.isNotEmpty) {
      timeStr = clientTime;
    } else {
      final h = ts.hour.toString().padLeft(2, '0');
      final m = ts.minute.toString().padLeft(2, '0');
      timeStr = "$h.$m";
    }

    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderRole: data['senderRole'] ?? 'patient',
      senderName: data['senderName'] ?? '',
      message: data['message'] ?? '',
      attachmentType: data['attachmentType'],
      imagePath: data['imagePath'],
      timestamp: ts,
      timeFormatted: timeStr,
      isRead: data['isRead'] ?? false,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final tsMillis = json['localTimestamp'] as num? ??
        (json['timestampMillis'] as num?) ??
        DateTime.now().millisecondsSinceEpoch;

    return ChatMessage(
      id: json['id'] as String? ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: json['senderId'] as String? ?? '',
      senderRole: json['senderRole'] as String? ?? 'patient',
      senderName: json['senderName'] as String? ?? '',
      message: json['message'] as String? ?? '',
      attachmentType: json['attachmentType'] as String?,
      imagePath: json['imagePath'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(tsMillis.toInt()),
      timeFormatted: json['timeFormatted'] as String? ??
          json['clientTime'] as String? ??
          '${DateTime.now().hour.toString().padLeft(2, '0')}.${DateTime.now().minute.toString().padLeft(2, '0')}',
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderRole': senderRole,
      'senderName': senderName,
      'message': message,
      'attachmentType': attachmentType,
      'imagePath': imagePath,
      'localTimestamp': timestamp.millisecondsSinceEpoch,
      'clientTime': timeFormatted,
      'isRead': isRead,
    };
  }
}

class ChatRoom {
  final String id;
  final String patientId;
  final String patientName;
  final String patientPhoto;
  final String doctorId;
  final String doctorName;
  final String doctorPhoto;
  final String doctorSpecialty;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastSenderRole;
  final int unreadCountDoctor;
  final int unreadCountPatient;
  final DateTime updatedAt;

  ChatRoom({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhoto,
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhoto,
    required this.doctorSpecialty,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastSenderRole,
    required this.unreadCountDoctor,
    required this.unreadCountPatient,
    required this.updatedAt,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime lastTime = DateTime.now();
    if (data['lastMessageTime'] is Timestamp) {
      lastTime = (data['lastMessageTime'] as Timestamp).toDate();
    } else if (data['lastMessageLocalTime'] is num) {
      lastTime = DateTime.fromMillisecondsSinceEpoch(
          (data['lastMessageLocalTime'] as num).toInt());
    }

    DateTime updated = DateTime.now();
    if (data['updatedAt'] is Timestamp) {
      updated = (data['updatedAt'] as Timestamp).toDate();
    }

    return ChatRoom(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? 'Pasien HeartCare',
      patientPhoto: data['patientPhoto'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? 'dr. Spesialis Jantung',
      doctorPhoto: data['doctorPhoto'] ?? 'assets/images/dokter_nurlitta.jpg',
      doctorSpecialty: data['doctorSpecialty'] ?? 'Spesialis Jantung',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: lastTime,
      lastSenderRole: data['lastSenderRole'] ?? '',
      unreadCountDoctor: (data['unreadCountDoctor'] as num?)?.toInt() ?? 0,
      unreadCountPatient: (data['unreadCountPatient'] as num?)?.toInt() ?? 0,
      updatedAt: updated,
    );
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    final lastTimeMillis = json['lastMessageLocalTime'] as num? ??
        DateTime.now().millisecondsSinceEpoch;
    return ChatRoom(
      id: json['id'] as String? ?? json['chatId'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? 'Pasien HeartCare',
      patientPhoto: json['patientPhoto'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? 'dr. Spesialis Jantung',
      doctorPhoto: json['doctorPhoto'] as String? ?? 'assets/images/dokter_nurlitta.jpg',
      doctorSpecialty: json['doctorSpecialty'] as String? ?? 'Spesialis Jantung',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(lastTimeMillis.toInt()),
      lastSenderRole: json['lastSenderRole'] as String? ?? '',
      unreadCountDoctor: (json['unreadCountDoctor'] as num?)?.toInt() ?? 0,
      unreadCountPatient: (json['unreadCountPatient'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(lastTimeMillis.toInt()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': id,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhoto': patientPhoto,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorPhoto': doctorPhoto,
      'doctorSpecialty': doctorSpecialty,
      'lastMessage': lastMessage,
      'lastMessageLocalTime': lastMessageTime.millisecondsSinceEpoch,
      'lastSenderRole': lastSenderRole,
      'unreadCountDoctor': unreadCountDoctor,
      'unreadCountPatient': unreadCountPatient,
    };
  }
}

class ChatService {
  ChatService._() {
    _loadCache();
  }
  static final ChatService instance = ChatService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // In-memory instant message cache
  final Map<String, List<ChatMessage>> _localMessages = {};
  final Map<String, ChatRoom> _localRooms = {};

  static const String _prefPrefixMessages = 'chat_messages_v2_';
  static const String _prefKeyRooms = 'chat_rooms_cache_v2';

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomsList = prefs.getStringList(_prefKeyRooms) ?? [];
      for (final item in roomsList) {
        try {
          final room = ChatRoom.fromJson(jsonDecode(item) as Map<String, dynamic>);
          _localRooms[room.id] = room;
        } catch (_) {}
      }
    } catch (_) {}
  }

  String _cleanId(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
  }

  /// Mendapatkan atau membuat ruang chat antara pasien dan dokter secara deterministik di Firestore & Cache
  Future<String> getOrCreateChatRoom({
    required String doctorName,
    required String doctorPhoto,
    required String doctorSpecialty,
    String? doctorId,
    String? patientId,
    String? patientName,
    String? patientPhoto,
  }) async {
    final currentUser = _auth.currentUser;
    final resolvedPatientId = patientId ??
        currentUser?.uid ??
        currentUser?.email?.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_') ??
        'patient_user';

    final resolvedDoctorId = (doctorId != null && doctorId.isNotEmpty)
        ? doctorId
        : _cleanId(doctorName);

    final chatId = 'chat_${_cleanId(resolvedPatientId)}_${_cleanId(resolvedDoctorId)}';
    final resolvedPatientName = patientName ??
        (currentUser?.displayName?.isNotEmpty == true
            ? currentUser!.displayName!
            : 'Pasien HeartCare');

    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}";

    // Simpan ke local cache ruangan langsung
    final initialRoom = ChatRoom(
      id: chatId,
      patientId: resolvedPatientId,
      patientName: resolvedPatientName,
      patientPhoto: patientPhoto ?? '',
      doctorId: resolvedDoctorId,
      doctorName: doctorName,
      doctorPhoto: doctorPhoto,
      doctorSpecialty: doctorSpecialty,
      lastMessage:
          'Halo $resolvedPatientName, Selamat datang di layanan konsultasi HeartCare. Ada yang bisa saya bantu?',
      lastMessageTime: now,
      lastSenderRole: 'doctor',
      unreadCountDoctor: 0,
      unreadCountPatient: 0,
      updatedAt: now,
    );
    _localRooms[chatId] = initialRoom;
    _saveRoomToLocal(initialRoom);

    // Simpan ke Firestore
    try {
      final chatDocRef = _firestore.collection('chats').doc(chatId);
      DocumentSnapshot<Map<String, dynamic>>? docSnap;
      try {
        docSnap = await chatDocRef.get();
      } catch (_) {}

      if (docSnap == null || !docSnap.exists) {
        await chatDocRef.set({
          'chatId': chatId,
          'patientId': resolvedPatientId,
          'patientName': resolvedPatientName,
          'patientPhoto': patientPhoto ?? '',
          'doctorId': resolvedDoctorId,
          'doctorName': doctorName,
          'doctorPhoto': doctorPhoto,
          'doctorSpecialty': doctorSpecialty,
          'lastMessage':
              'Halo $resolvedPatientName, Selamat datang di layanan konsultasi HeartCare. Ada yang bisa saya bantu?',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessageLocalTime': now.millisecondsSinceEpoch,
          'lastSenderRole': 'doctor',
          'lastSenderId': resolvedDoctorId,
          'unreadCountDoctor': 0,
          'unreadCountPatient': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Buat pesan sambutan awal otomatis dari dokter
        final initialMsgRef = chatDocRef.collection('messages').doc('welcome_msg');
        final welcomeMsg = {
          'id': 'welcome_msg',
          'senderId': resolvedDoctorId,
          'senderRole': 'doctor',
          'senderName': doctorName,
          'message':
              'Halo $resolvedPatientName, Selamat datang di layanan konsultasi HeartCare!\nSaya $doctorName, ada yang bisa saya bantu hari ini?',
          'attachmentType': null,
          'imagePath': null,
          'timestamp': FieldValue.serverTimestamp(),
          'localTimestamp': now.millisecondsSinceEpoch,
          'clientTime': timeStr,
          'isRead': false,
        };

        await initialMsgRef.set(welcomeMsg, SetOptions(merge: true));

        _addLocalMessage(
          chatId,
          ChatMessage(
            id: 'welcome_msg',
            senderId: resolvedDoctorId,
            senderRole: 'doctor',
            senderName: doctorName,
            message:
                'Halo $resolvedPatientName, Selamat datang di layanan konsultasi HeartCare!\nSaya $doctorName, ada yang bisa saya bantu hari ini?',
            timestamp: now,
            timeFormatted: timeStr,
            isRead: false,
          ),
        );
      }
    } catch (e) {
      debugPrint('[ChatService] getOrCreateChatRoom error: $e');
    }

    return chatId;
  }

  void _addLocalMessage(String chatId, ChatMessage msg) {
    final list = _localMessages[chatId] ?? [];
    list.removeWhere((m) => m.id == msg.id);
    list.add(msg);
    _localMessages[chatId] = list;
    _saveMessagesToLocal(chatId, list);
  }

  Future<void> _saveMessagesToLocal(String chatId, List<ChatMessage> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = list.map((m) => jsonEncode(m.toJson())).toList();
      await prefs.setStringList('$_prefPrefixMessages$chatId', encoded);
    } catch (_) {}
  }

  Future<List<ChatMessage>> _loadLocalMessages(String chatId) async {
    if (_localMessages.containsKey(chatId) && _localMessages[chatId]!.isNotEmpty) {
      return _localMessages[chatId]!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('$_prefPrefixMessages$chatId') ?? [];
      final result = <ChatMessage>[];
      for (final item in list) {
        try {
          result.add(ChatMessage.fromJson(jsonDecode(item) as Map<String, dynamic>));
        } catch (_) {}
      }
      _localMessages[chatId] = result;
      return result;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveRoomToLocal(ChatRoom room) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefKeyRooms) ?? [];
      final decoded = <Map<String, dynamic>>[];
      for (final item in list) {
        try {
          decoded.add(jsonDecode(item) as Map<String, dynamic>);
        } catch (_) {}
      }
      decoded.removeWhere((r) => r['id'] == room.id || r['chatId'] == room.id);
      decoded.add(room.toJson());
      await prefs.setStringList(
          _prefKeyRooms, decoded.map((e) => jsonEncode(e)).toList());
    } catch (_) {}
  }

  /// Mengirim pesan baru ke ruang chat real-time
  Future<void> sendMessage({
    required String chatId,
    required String message,
    required String senderRole, // 'patient' atau 'doctor'
    required String senderName,
    String? attachmentType,
    String? imagePath,
  }) async {
    final currentUser = _auth.currentUser;
    final senderId = currentUser?.uid ??
        (senderRole == 'doctor' ? 'doctor_user' : 'patient_user');

    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}";
    final msgId = 'msg_${now.millisecondsSinceEpoch}_${now.microsecond % 1000}';

    final localMsg = ChatMessage(
      id: msgId,
      senderId: senderId,
      senderRole: senderRole,
      senderName: senderName,
      message: message,
      attachmentType: attachmentType,
      imagePath: imagePath,
      timestamp: now,
      timeFormatted: timeStr,
      isRead: false,
    );

    // 1. Tambahkan ke memori lokal seketika (Optimistic UI)
    _addLocalMessage(chatId, localMsg);

    // 2. Perbarui ringkasan room lokal
    final snippet = message.isNotEmpty
        ? message
        : (attachmentType == 'image'
            ? '📷 Mengirim foto keluhan'
            : (attachmentType == 'screening'
                ? '📊 Mengirim hasil skrining jantung'
                : '📄 Mengirim lampiran'));

    final existingRoom = _localRooms[chatId];
    if (existingRoom != null) {
      final updatedRoom = ChatRoom(
        id: existingRoom.id,
        patientId: existingRoom.patientId,
        patientName: existingRoom.patientName,
        patientPhoto: existingRoom.patientPhoto,
        doctorId: existingRoom.doctorId,
        doctorName: existingRoom.doctorName,
        doctorPhoto: existingRoom.doctorPhoto,
        doctorSpecialty: existingRoom.doctorSpecialty,
        lastMessage: snippet,
        lastMessageTime: now,
        lastSenderRole: senderRole,
        unreadCountDoctor: senderRole == 'patient'
            ? existingRoom.unreadCountDoctor + 1
            : existingRoom.unreadCountDoctor,
        unreadCountPatient: senderRole == 'doctor'
            ? existingRoom.unreadCountPatient + 1
            : existingRoom.unreadCountPatient,
        updatedAt: now,
      );
      _localRooms[chatId] = updatedRoom;
      _saveRoomToLocal(updatedRoom);
    }

    // 3. Simpan ke Firestore secara background
    try {
      final msgRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(msgId);

      await msgRef.set({
        'id': msgId,
        'senderId': senderId,
        'senderRole': senderRole,
        'senderName': senderName,
        'message': message,
        'attachmentType': attachmentType,
        'imagePath': imagePath,
        'timestamp': FieldValue.serverTimestamp(),
        'localTimestamp': now.millisecondsSinceEpoch,
        'clientTime': timeStr,
        'isRead': false,
      });

      // Update ringkasan ruang chat (gunakan set dengan merge agar fail-safe)
      await _firestore.collection('chats').doc(chatId).set({
        'chatId': chatId,
        'lastMessage': snippet,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageLocalTime': now.millisecondsSinceEpoch,
        'lastSenderRole': senderRole,
        'lastSenderId': senderId,
        'updatedAt': FieldValue.serverTimestamp(),
        if (senderRole == 'patient')
          'unreadCountDoctor': FieldValue.increment(1),
        if (senderRole == 'doctor')
          'unreadCountPatient': FieldValue.increment(1),
      }, SetOptions(merge: true));

      debugPrint('[ChatService] Sukses kirim pesan ke Firestore: $chatId');
    } catch (e) {
      debugPrint('[ChatService] sendMessage Firestore warning (tersimpan di lokal): $e');
    }
  }

  /// Real-time stream pesan untuk room chat tertentu (menggabungkan Firestore dan Cache Lokal)
  Stream<List<ChatMessage>> getMessagesStream(String chatId) {
    // Ambil pesan lokal terlebih dahulu agar UI instan
    final localFuture = _loadLocalMessages(chatId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .snapshots()
        .asyncMap((snapshot) async {
      final localList = await localFuture;
      final Map<String, ChatMessage> map = {};

      // 1. Muat dari lokal
      for (final m in localList) {
        map[m.id] = m;
      }
      final inMem = _localMessages[chatId] ?? [];
      for (final m in inMem) {
        map[m.id] = m;
      }

      // 2. Timpa dengan data Firestore yang terkonfirmasi
      for (final doc in snapshot.docs) {
        try {
          final m = ChatMessage.fromFirestore(doc);
          map[m.id] = m;
        } catch (_) {}
      }

      final list = map.values.toList();
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Simpan sinkronisasi terbaru ke lokal
      _localMessages[chatId] = list;
      _saveMessagesToLocal(chatId, list);

      return list;
    }).handleError((error) async {
      debugPrint('[ChatService] getMessagesStream fallback to local cache: $error');
      final list = await _loadLocalMessages(chatId);
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return list;
    });
  }

  /// Real-time stream daftar chat untuk dokter tertentu (inbox dokter di portal dokter)
  Stream<List<ChatRoom>> getDoctorChatsStream(String doctorName,
      {String? doctorId}) {
    return _firestore.collection('chats').snapshots().map((snapshot) {
      final Map<String, ChatRoom> map = {};

      // 1. Masukkan data lokal
      for (final r in _localRooms.values) {
        map[r.id] = r;
      }

      // 2. Masukkan data Firestore
      for (final doc in snapshot.docs) {
        try {
          final r = ChatRoom.fromFirestore(doc);
          map[r.id] = r;
        } catch (_) {}
      }

      final targetName = doctorName.replaceAll(RegExp(r'(dr\.|dr|sp\.jp|spjp)', caseSensitive: false), '').trim().toLowerCase();
      final targetId = (doctorId ?? '').trim().toLowerCase();

      final list = map.values.where((room) {
        // Cek kecocokan ID
        if (targetId.isNotEmpty) {
          final rDoctorId = room.doctorId.toLowerCase();
          if (rDoctorId == targetId ||
              rDoctorId.contains(targetId) ||
              targetId.contains(rDoctorId)) {
            return true;
          }
        }

        // Cek kecocokan Nama Dokter
        final rName = room.doctorName.replaceAll(RegExp(r'(dr\.|dr|sp\.jp|spjp)', caseSensitive: false), '').trim().toLowerCase();
        if (targetName.isNotEmpty && rName.isNotEmpty) {
          if (rName.contains(targetName) || targetName.contains(rName)) {
            return true;
          }
        }

        // Fallback untuk akun dokter default / pengetesan
        if (targetName.isEmpty || targetName.contains('heartcare') || rName.contains('heartcare') || rName.contains('valent')) {
          return true;
        }

        return false;
      }).toList();

      list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return list;
    }).handleError((error) {
      debugPrint('[ChatService] getDoctorChatsStream fallback: $error');
      final list = _localRooms.values.toList();
      list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return list;
    });
  }

  /// Real-time stream daftar chat untuk pasien tertentu
  Stream<List<ChatRoom>> getPatientChatsStream(String patientId) {
    final cleanPId = _cleanId(patientId);

    return _firestore.collection('chats').snapshots().map((snapshot) {
      final Map<String, ChatRoom> map = {};
      for (final r in _localRooms.values) {
        if (_cleanId(r.patientId).contains(cleanPId) || cleanPId.contains(_cleanId(r.patientId))) {
          map[r.id] = r;
        }
      }

      for (final doc in snapshot.docs) {
        try {
          final r = ChatRoom.fromFirestore(doc);
          final rPId = _cleanId(r.patientId);
          if (rPId == cleanPId || rPId.contains(cleanPId) || cleanPId.contains(rPId)) {
            map[r.id] = r;
          }
        } catch (_) {}
      }

      final list = map.values.toList();
      list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return list;
    });
  }

  /// Menandai pesan telah dibaca (mereset unread counter)
  Future<void> markMessagesAsRead(String chatId, String currentRole) async {
    try {
      final room = _localRooms[chatId];
      if (room != null) {
        final updated = ChatRoom(
          id: room.id,
          patientId: room.patientId,
          patientName: room.patientName,
          patientPhoto: room.patientPhoto,
          doctorId: room.doctorId,
          doctorName: room.doctorName,
          doctorPhoto: room.doctorPhoto,
          doctorSpecialty: room.doctorSpecialty,
          lastMessage: room.lastMessage,
          lastMessageTime: room.lastMessageTime,
          lastSenderRole: room.lastSenderRole,
          unreadCountDoctor: currentRole == 'doctor' ? 0 : room.unreadCountDoctor,
          unreadCountPatient: currentRole == 'patient' ? 0 : room.unreadCountPatient,
          updatedAt: DateTime.now(),
        );
        _localRooms[chatId] = updated;
        _saveRoomToLocal(updated);
      }

      final roomRef = _firestore.collection('chats').doc(chatId);
      if (currentRole == 'doctor') {
        await roomRef.set({'unreadCountDoctor': 0}, SetOptions(merge: true));
      } else {
        await roomRef.set({'unreadCountPatient': 0}, SetOptions(merge: true));
      }
    } catch (_) {}
  }
}
