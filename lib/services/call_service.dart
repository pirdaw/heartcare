import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_service.dart';
import 'notification_service.dart';
import 'video_call_audio.dart';
import 'doctor_service.dart';
import 'profile_service.dart';
import '../pages/video_call_page.dart';

/// Layanan pensinyalan panggilan video real-time (seperti WhatsApp Call)
class CallService extends ChangeNotifier {
  CallService._();
  static final CallService instance = CallService._();

  final String instanceSessionId =
      'call_sess_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';

  String _activeRole = 'patient';
  String get activeRole => _activeRole;

  StreamSubscription<QuerySnapshot>? _callSubscription;
  bool _isShowingIncomingCall = false;
  String? _currentCallId;
  final Map<String, String> _callIdToChatId = {};

  void setActiveRole(String role) {
    final clean = role.toLowerCase().trim();
    if (clean.isNotEmpty) {
      _activeRole = clean;
      debugPrint('[CallService] Active Role disetel ke: $_activeRole (Session: $instanceSessionId)');
    }
  }

  /// Aktifkan pemantau panggilan masuk secara global di seluruh aplikasi
  void initGlobalCallListener() {
    _callSubscription?.cancel();
    try {
      _callSubscription = FirebaseFirestore.instance
          .collection('video_calls')
          .where('status', isEqualTo: 'calling')
          .snapshots()
          .listen(
            (snapshot) => _handleIncomingCallsSnapshot(snapshot),
            onError: (err) {
              debugPrint('[CallService] Listener notice: $err');
            },
          );
      debugPrint('[CallService] Global Video Call Listener Aktif.');
    } catch (e) {
      debugPrint('[CallService] Gagal inisialisasi listener: $e');
    }
  }

  void _handleIncomingCallsSnapshot(QuerySnapshot snapshot) {
    if (snapshot.docs.isEmpty) {
      if (_isShowingIncomingCall) {
        VideoCallAudioService.instance.stopWhatsAppIncomingRingtone();
        _isShowingIncomingCall = false;
      }
      return;
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) continue;

      final callId = doc.id;
      final senderSessionId = data['callerSessionId'] as String? ?? '';
      final receiverRole = (data['receiverRole'] as String? ?? '').toLowerCase();
      final status = data['status'] as String? ?? '';
      final createdAt = data['createdAt'] as int? ?? nowMs;

      // Abaikan jika panggilan dari tab/window ini sendiri
      if (senderSessionId == instanceSessionId) continue;

      // Abaikan jika penerima bukan role yang sedang aktif di tab ini
      if (receiverRole.isNotEmpty && receiverRole != _activeRole) continue;

      // Abaikan panggilan kadaluarsa (> 60 detik)
      if ((nowMs - createdAt).abs() > 60000) continue;

      // Tampilkan banner panggilan masuk jika status masih 'calling'
      if (status == 'calling' && !_isShowingIncomingCall) {
        _showIncomingCallUi(callId, data);
        break;
      }
    }
  }

  /// Tangani sinyal panggilan masuk yang disalurkan melalui koleksi chats
  void handleIncomingCallFromChat(Map<String, dynamic> data, String chatId) {
    final status = data['status'] as String? ?? '';
    final senderSessionId = data['callerSessionId'] as String? ?? '';
    final receiverRole = (data['receiverRole'] as String? ?? '').toLowerCase();
    final createdAt = data['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    // Abaikan jika panggilan dari sesi ini sendiri
    if (senderSessionId == instanceSessionId) return;

    // Abaikan jika role penerima bukan role portal ini
    if (receiverRole.isNotEmpty && receiverRole != _activeRole) return;

    // Abaikan panggilan kadaluarsa (> 60 detik)
    if ((nowMs - createdAt).abs() > 60000) return;

    final callId = data['callId'] as String? ?? 'call_$chatId';
    _callIdToChatId[callId] = chatId;

    if (status == 'calling' && !_isShowingIncomingCall) {
      _showIncomingCallUi(callId, data);
    } else if ((status == 'ended' || status == 'rejected') && _isShowingIncomingCall) {
      VideoCallAudioService.instance.stopWhatsAppIncomingRingtone();
      _isShowingIncomingCall = false;
    }
  }

  void _showIncomingCallUi(String callId, Map<String, dynamic> data) {
    final context = _getValidContext();
    if (context == null) {
      debugPrint('[CallService] Context navigator belum siap untuk menampilkan incoming call.');
      return;
    }

    _isShowingIncomingCall = true;
    _currentCallId = callId;

    // 1. Mainkan nada dering masuk WhatsApp
    VideoCallAudioService.instance.playWhatsAppIncomingRingtone();

    final callerName = data['callerName'] as String? ?? 'Panggilan Masuk';
    final callerPhoto = data['callerPhoto'] as String?;
    final callerRole = data['callerRole'] as String? ?? 'patient';
    final isCallerDoctor = callerRole == 'doctor';

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      pageBuilder: (ctx, anim1, anim2) {
        return _WhatsAppIncomingCallSheet(
          callId: callId,
          callerName: callerName,
          callerPhoto: callerPhoto,
          isCallerDoctor: isCallerDoctor,
          onAccept: () {
            VideoCallAudioService.instance.stopWhatsAppIncomingRingtone();
            _isShowingIncomingCall = false;
            Navigator.of(ctx).pop();

            // Tandai status panggilan 'connected' di Firestore agar caller tahu
            acceptCall(callId, chatId: data['chatId'] as String?);

            // Buka layar panggilan video sebagai Receiver (Penerima)
            NotificationService.navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => VideoCallPage(
                  callId: callId,
                  isCaller: false,
                  isDoctorView: _activeRole == 'doctor',
                  doctorId: data['doctorId'] as String?,
                  doctorName: isCallerDoctor
                      ? callerName
                      : (data['doctorName'] as String? ?? 'dr. Nurlitta Dwi, Sp.JP'),
                  doctorPhoto: (isCallerDoctor
                          ? callerPhoto
                          : (data['doctorPhoto'] as String?)) ??
                      'assets/images/dokter_nurlitta.jpg',
                  doctorSpecialty: data['doctorSpecialty'] as String? ??
                      'Spesialis Jantung & Pembuluh Darah',
                  patientId: data['patientId'] as String?,
                  patientName: !isCallerDoctor
                      ? callerName
                      : (data['patientName'] as String? ?? 'Pasien HeartCare'),
                  patientPhoto: !isCallerDoctor
                      ? callerPhoto
                      : (data['patientPhoto'] as String?),
                  chatId: data['chatId'] as String?,
                ),
              ),
            );
          },
          onReject: () {
            VideoCallAudioService.instance.stopWhatsAppIncomingRingtone();
            _isShowingIncomingCall = false;
            Navigator.of(ctx).pop();
            rejectCall(callId);
          },
        );
      },
    );
  }

  /// Membuat sesi panggilan baru di Firestore (sebagai Penelepon)
  Future<String> createCallSession({
    required String callerName,
    String? callerPhoto,
    required String callerRole,
    required String receiverRole,
    String? doctorId,
    String? doctorName,
    String? doctorPhoto,
    String? doctorSpecialty,
    String? patientId,
    String? patientName,
    String? patientPhoto,
    String? chatId,
  }) async {
    final callId = 'call_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
    _currentCallId = callId;

    // Pastikan ID pasien, dokter, dan chatId selalu terdefinisi
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final resolvedPatientId = (patientId != null && patientId.isNotEmpty)
        ? patientId
        : (currentUid.isNotEmpty ? currentUid : 'patient_${callerName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase()}');
    final resolvedDoctorId = (doctorId != null && doctorId.isNotEmpty)
        ? doctorId
        : (doctorName != null && doctorName.isNotEmpty
            ? doctorName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase()
            : 'doctor_default');
    final resolvedChatId = (chatId != null && chatId.isNotEmpty)
        ? chatId
        : ChatService.instance.computeChatId(
            patientId: resolvedPatientId,
            doctorId: resolvedDoctorId,
          );

    _callIdToChatId[callId] = resolvedChatId;

    final callMap = {
      'callId': callId,
      'callerSessionId': instanceSessionId,
      'callerName': callerName,
      'callerPhoto': callerPhoto,
      'callerRole': callerRole,
      'receiverRole': receiverRole,
      'doctorId': resolvedDoctorId,
      'doctorName': doctorName,
      'doctorPhoto': doctorPhoto,
      'doctorSpecialty': doctorSpecialty,
      'patientId': resolvedPatientId,
      'patientName': patientName,
      'patientPhoto': patientPhoto,
      'chatId': resolvedChatId,
      'status': 'calling',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };

    // Jalur 1: Simpan di video_calls
    try {
      await FirebaseFirestore.instance
          .collection('video_calls')
          .doc(callId)
          .set(callMap)
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[CallService] Notice simpan video_calls (non-fatal): $e');
    }

    // Jalur 2: Simpan di chats/{resolvedChatId} (Pasti diizinkan Firestore & dipantau real-time)
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(resolvedChatId)
          .set({
            'chatId': resolvedChatId,
            'doctorId': resolvedDoctorId,
            'doctorName': doctorName ?? 'dr. Dokter HeartCare',
            if (doctorPhoto != null && doctorPhoto.isNotEmpty) 'doctorPhoto': doctorPhoto,
            if (doctorSpecialty != null && doctorSpecialty.isNotEmpty)
              'doctorSpecialty': doctorSpecialty,
            'patientId': resolvedPatientId,
            'patientName': patientName ?? callerName,
            if (patientPhoto != null && patientPhoto.isNotEmpty)
              'patientPhoto': patientPhoto,
            'callSession': callMap,
            'lastMessage': '📹 Panggilan Video Masuk...',
            'lastMessageTime': FieldValue.serverTimestamp(),
            'lastSenderRole': callerRole,
            'lastSenderName': callerName,
            'senderSessionId': instanceSessionId,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 3));
      debugPrint('[CallService] Sukses simpan callSession ke chats/$resolvedChatId');
    } catch (e) {
      debugPrint('[CallService] Notice simpan chats (non-fatal): $e');
    }

    return callId;
  }

  /// Menerima panggilan – tandai status 'connected' di Firestore agar caller tahu
  Future<void> acceptCall(String callId, {String? chatId}) async {
    final targetChatId = chatId ?? _callIdToChatId[callId];

    try {
      await FirebaseFirestore.instance.collection('video_calls').doc(callId).update({
        'status': 'connected',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('[CallService] Notice acceptCall video_calls: $e');
    }

    if (targetChatId != null && targetChatId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('chats').doc(targetChatId).update({
          'callSession.status': 'connected',
        });
      } catch (_) {}
    }
  }

  /// Menolak panggilan masuk
  Future<void> rejectCall(String callId, {String? chatId}) async {
    VideoCallAudioService.instance.stopAll();
    _isShowingIncomingCall = false;
    final targetChatId = chatId ?? _callIdToChatId[callId];

    try {
      await FirebaseFirestore.instance.collection('video_calls').doc(callId).update({
        'status': 'rejected',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}

    if (targetChatId != null && targetChatId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('chats').doc(targetChatId).update({
          'callSession.status': 'rejected',
        });
      } catch (_) {}
    }
  }

  /// Mengakhiri panggilan
  Future<void> endCall(String callId, {String? chatId}) async {
    VideoCallAudioService.instance.stopAll();
    _isShowingIncomingCall = false;
    final targetChatId = chatId ?? _callIdToChatId[callId];

    try {
      await FirebaseFirestore.instance.collection('video_calls').doc(callId).update({
        'status': 'ended',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}

    if (targetChatId != null && targetChatId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('chats').doc(targetChatId).update({
          'callSession.status': 'ended',
        });
      } catch (_) {}
    }
  }

  BuildContext? _getValidContext() {
    return NotificationService.navigatorKey.currentContext ??
        NotificationService.navigatorKey.currentState?.context;
  }
}

/// Tampilan Panggilan Video Masuk gaya WhatsApp (WhatsApp Incoming Video Call Screen)
class _WhatsAppIncomingCallSheet extends StatefulWidget {
  final String callId;
  final String callerName;
  final String? callerPhoto;
  final bool isCallerDoctor;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _WhatsAppIncomingCallSheet({
    required this.callId,
    required this.callerName,
    this.callerPhoto,
    required this.isCallerDoctor,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<_WhatsAppIncomingCallSheet> createState() => _WhatsAppIncomingCallSheetState();
}

class _WhatsAppIncomingCallSheetState extends State<_WhatsAppIncomingCallSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF075E54).withValues(alpha: 0.94),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // Header WhatsApp Telekonsultasi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.videocam_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Panggilan Video Masuk • HeartCare",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Nama Penelepon
              Text(
                widget.callerName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.isCallerDoctor
                    ? "Dokter Spesialis Jantung Sedang Menghubungi Anda..."
                    : "Pasien Menghubungi untuk Sesi Telekonsultasi Langsung...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13.5,
                ),
              ),

              const Spacer(),

              // Foto Profil Bergelombang (Pulsing WhatsApp Avatar)
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final scale = 1.0 + (_animController.value * 0.12);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 170 * scale,
                        height: 170 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF25D366).withValues(
                            alpha: 0.25 * (1.0 - _animController.value),
                          ),
                        ),
                      ),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF25D366), width: 3.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF25D366).withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: widget.isCallerDoctor
                            ? DoctorService.buildDoctorImage(
                                widget.callerPhoto,
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                              )
                            : ProfileService.buildPatientImage(
                                widget.callerPhoto,
                                width: 140,
                                height: 140,
                              ),
                      ),
                    ],
                  );
                },
              ),

              const Spacer(),

              // Tombol Terima & Tolak Bergaya WhatsApp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Tombol Tolak (Merah)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: widget.onReject,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE11D48),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x66E11D48),
                                blurRadius: 14,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.call_end_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Tolak",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Tombol Terima (Hijau WhatsApp)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: widget.onAccept,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF25D366),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x6625D366),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.videocam_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Terima",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
