import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

    DateTime ts;
    final rawTs = data['timestamp'];
    if (rawTs is Timestamp) {
      ts = rawTs.toDate();
    } else {
      ts = DateTime.now();
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderRole': senderRole,
      'senderName': senderName,
      'message': message,
      'attachmentType': attachmentType,
      'imagePath': imagePath,
      'timestamp': FieldValue.serverTimestamp(),
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
}

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _cleanId(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
  }

  /// Mendapatkan atau membuat ruang chat antara pasien dan dokter secara deterministik di Firestore
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
        'guest_patient';

    final resolvedDoctorId = doctorId ?? _cleanId(doctorName);

    final chatId = 'chat_${resolvedPatientId}_$resolvedDoctorId';
    final chatDocRef = _firestore.collection('chats').doc(chatId);

    try {
      final docSnap = await chatDocRef.get();
      if (!docSnap.exists) {
        final resolvedPatientName = patientName ??
            (currentUser?.displayName?.isNotEmpty == true
                ? currentUser!.displayName!
                : 'Pasien HeartCare');

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
          'lastSenderRole': 'doctor',
          'lastSenderId': resolvedDoctorId,
          'unreadCountDoctor': 0,
          'unreadCountPatient': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Buat pesan sambutan awal otomatis dari dokter
        final initialMsgRef = chatDocRef.collection('messages').doc();
        final now = DateTime.now();
        final timeStr =
            "${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}";

        await initialMsgRef.set({
          'id': initialMsgRef.id,
          'senderId': resolvedDoctorId,
          'senderRole': 'doctor',
          'senderName': doctorName,
          'message':
              'Halo $resolvedPatientName, Selamat datang di layanan konsultasi HeartCare!\nSaya $doctorName, ada yang bisa saya bantu hari ini?',
          'attachmentType': null,
          'imagePath': null,
          'timestamp': FieldValue.serverTimestamp(),
          'clientTime': timeStr,
          'isRead': false,
        });
      }
    } catch (e) {
      debugPrint('[ChatService] getOrCreateChatRoom error: $e');
    }

    return chatId;
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
    try {
      final currentUser = _auth.currentUser;
      final senderId = currentUser?.uid ??
          (senderRole == 'doctor' ? 'doctor_id' : 'patient_id');

      final msgRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      final now = DateTime.now();
      final timeStr =
          "${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}";

      await msgRef.set({
        'id': msgRef.id,
        'senderId': senderId,
        'senderRole': senderRole,
        'senderName': senderName,
        'message': message,
        'attachmentType': attachmentType,
        'imagePath': imagePath,
        'timestamp': FieldValue.serverTimestamp(),
        'clientTime': timeStr,
        'isRead': false,
      });

      // Update ringkasan ruang chat
      final snippet = message.isNotEmpty
          ? message
          : (attachmentType == 'image'
              ? '📷 Mengirim foto keluhan'
              : (attachmentType == 'screening'
                  ? '📊 Mengirim hasil skrining jantung'
                  : '📄 Mengirim lampiran'));

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': snippet,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderRole': senderRole,
        'lastSenderId': senderId,
        'updatedAt': FieldValue.serverTimestamp(),
        if (senderRole == 'patient')
          'unreadCountDoctor': FieldValue.increment(1),
        if (senderRole == 'doctor')
          'unreadCountPatient': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('[ChatService] sendMessage error: $e');
    }
  }

  /// Real-time stream pesan untuk room chat tertentu
  Stream<List<ChatMessage>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    });
  }

  /// Real-time stream daftar chat untuk dokter tertentu (inbox dokter)
  Stream<List<ChatRoom>> getDoctorChatsStream(String doctorName,
      {String? doctorId}) {
    return _firestore
        .collection('chats')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ChatRoom.fromFirestore(doc))
          .where((room) {
        if (doctorId != null &&
            doctorId.isNotEmpty &&
            room.doctorId == doctorId) {
          return true;
        }
        final dName = room.doctorName.toLowerCase();
        final target = doctorName.toLowerCase();
        return dName.contains(target) || target.contains(dName);
      }).toList();

      list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return list;
    });
  }

  /// Real-time stream daftar chat untuk pasien tertentu
  Stream<List<ChatRoom>> getPatientChatsStream(String patientId) {
    return _firestore
        .collection('chats')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
      final list =
          snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList();
      list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return list;
    });
  }

  /// Menandai pesan telah dibaca (mereset unread counter)
  Future<void> markMessagesAsRead(String chatId, String currentRole) async {
    try {
      final roomRef = _firestore.collection('chats').doc(chatId);
      if (currentRole == 'doctor') {
        await roomRef.update({'unreadCountDoctor': 0});
      } else {
        await roomRef.update({'unreadCountPatient': 0});
      }
    } catch (_) {}
  }
}
