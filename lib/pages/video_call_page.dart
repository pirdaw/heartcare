import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/agora_config.dart';
import '../services/theme_service.dart';
import '../services/doctor_service.dart';
import '../services/profile_service.dart';
import '../services/user_profile_service.dart';
import '../services/chat_service.dart';
import '../services/video_call_audio.dart';
import '../services/call_service.dart';

/// Halaman Panggilan Video Telekonsultasi Real-time menggunakan Agora RTC Engine
/// Menghubungkan audio (suara jernih dengan noise cancellation) dan video HD antara dokter dan pasien
class VideoCallPage extends StatefulWidget {
  final String? callId;
  final bool isCaller;
  final bool isDoctorView;
  final String? doctorId;
  final String doctorName;
  final String doctorPhoto;
  final String doctorSpecialty;
  final String patientName;
  final String? patientPhoto;
  final String? patientId;
  final String? chatId;

  const VideoCallPage({
    super.key,
    this.callId,
    this.isCaller = true,
    this.isDoctorView = false,
    this.doctorId,
    this.doctorName = 'dr. Nurlitta Dwi, Sp.JP',
    this.doctorPhoto = 'assets/images/dokter_nurlitta.jpg',
    this.doctorSpecialty = 'Spesialis Jantung & Pembuluh Darah',
    this.patientName = 'Pasien HeartCare',
    this.patientPhoto,
    this.patientId,
    this.chatId,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage>
    with SingleTickerProviderStateMixin {
  // Identifikasi panggilan & saluran Agora
  late String _callId;
  late String _channelName;
  late bool _isCaller;

  // Engine Agora
  RtcEngine? _engine;
  bool _isAgoraInitialized = false;
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _remoteCameraOff = false;

  // Timer durasi panggilan
  Timer? _durationTimer;
  int _secondsElapsed = 0;

  // Status koneksi & perangkat
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isFrontCamera = true;
  bool _isConnected = false;
  bool _isRejected = false;

  // Profil dinamis dokter & pasien
  late String _patientName;
  String? _patientPhoto;
  late String _doctorName;
  String? _doctorPhoto;

  // Posisi floating window Picture-in-Picture (PiP)
  Offset _pipPosition = const Offset(16, 90);

  // Animasi gelombang audio
  late AnimationController _waveController;

  // Catatan keluhan pasien
  final List<String> _selectedSymptoms = [];
  final TextEditingController _symptomNotesController = TextEditingController();

  StreamSubscription<DocumentSnapshot>? _callDocSub;
  StreamSubscription<DocumentSnapshot>? _chatDocSub;

  static const List<String> _commonSymptoms = [
    'Nyeri Dada',
    'Sesak Napas',
    'Jantung Berdebar',
    'Pusing / Kliyengan',
    'Cepat Lelah',
    'Kaki Bengkak',
    'Keringat Dingin',
    'Tekanan Darah Naik',
  ];

  @override
  void initState() {
    super.initState();

    _callId = widget.callId ??
        'call_${DateTime.now().millisecondsSinceEpoch}';
    _channelName = AgoraConfig.formatChannelName(_callId);
    _isCaller = widget.isCaller;

    _patientName = widget.patientName;
    _patientPhoto = widget.patientPhoto;
    _doctorName = widget.doctorName;
    _doctorPhoto = widget.doctorPhoto;

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Muat foto profil dokter & pasien
    _initProfiles();

    // Jalankan pensinyalan status Firestore & dering
    _initCallSignaling();

    // Inisialisasi Agora RTC Engine
    _initAgora();
  }

  /// Sinkronisasi profil foto dokter & pasien dari cache & Firestore
  Future<void> _initProfiles() async {
    if (!widget.isDoctorView) {
      try {
        final profile = UserProfileService.instance.currentProfile;
        if (profile.nama.isNotEmpty) _patientName = profile.nama;
        if (profile.fotoProfil.isNotEmpty) {
          _patientPhoto = profile.fotoProfil;
        } else if (ProfileService.instance.currentImagePath != null) {
          _patientPhoto = ProfileService.instance.currentImagePath;
        }
      } catch (_) {}
    } else {
      if (widget.patientId != null && widget.patientId!.isNotEmpty) {
        try {
          final pDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.patientId)
              .get();
          if (pDoc.exists && pDoc.data() != null) {
            final data = pDoc.data()!;
            final photo =
                (data['fotoProfil'] as String? ?? data['foto'] as String? ?? '').trim();
            final name =
                (data['nama'] as String? ?? data['name'] as String? ?? '').trim();
            if (photo.isNotEmpty && mounted) {
              setState(() => _patientPhoto = photo);
            }
            if (name.isNotEmpty && mounted) {
              setState(() => _patientName = name);
            }
          }
        } catch (_) {}
      }
    }

    try {
      final cachedDoctors = await DoctorService.instance.getCachedDoctors();
      final targetId = (widget.doctorId ?? '').trim().toLowerCase();
      final targetName = widget.doctorName
          .replaceAll(RegExp(r'(dr\.|dr|sp\.jp|spjp)', caseSensitive: false), '')
          .trim()
          .toLowerCase();

      for (final doc in cachedDoctors) {
        final dId = (doc['id'] as String? ?? doc['uid'] as String? ?? '').toLowerCase();
        final dName = (doc['nama'] as String? ?? doc['name'] as String? ?? '')
            .replaceAll(RegExp(r'(dr\.|dr|sp\.jp|spjp)', caseSensitive: false), '')
            .trim()
            .toLowerCase();

        if ((targetId.isNotEmpty && (dId == targetId || dId.contains(targetId))) ||
            (targetName.isNotEmpty && (dName == targetName || dName.contains(targetName)))) {
          final photo = doc['foto'] as String? ?? doc['photo'] as String?;
          if (photo != null && photo.isNotEmpty && mounted) {
            setState(() => _doctorPhoto = photo);
          }
          break;
        }
      }
    } catch (_) {}

    if (mounted) setState(() {});
  }

  /// Inisialisasi Agora RTC Engine untuk Audio & Video real-time
  Future<void> _initAgora() async {
    try {
      // 1. Meminta izin kamera & mikrofon pada Android / iOS
      if (!kIsWeb) {
        try {
          await [Permission.microphone, Permission.camera].request();
        } catch (e) {
          debugPrint('[Agora] Izin sistem notice: $e');
        }
      }

      // 2. Buat RTC Engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(
        const RtcEngineContext(
          appId: AgoraConfig.appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      // 3. Pasang Event Handler
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint('[Agora] Berhasil masuk channel: ${connection.channelId}');
            if (mounted) {
              setState(() {
                _localUserJoined = true;
              });
            }
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint('[Agora] Lawan bicara terhubung dengan UID: $remoteUid');
            if (mounted) {
              setState(() {
                _remoteUid = remoteUid;
                _remoteCameraOff = false;
              });
              // Tulis status 'connected' ke Firestore agar kedua pihak tersinkron
              _markCallConnected();
              _onCallConnected();
            }
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint('[Agora] Lawan bicara keluar: $remoteUid, alasan: $reason');
            if (mounted) {
              setState(() {
                _remoteUid = null;
              });
              _handleCallEnded();
            }
          },
          onUserMuteVideo: (RtcConnection connection, int remoteUid, bool muted) {
            debugPrint('[Agora] Lawan bicara mengubah status kamera: muted=$muted');
            if (mounted && _remoteUid == remoteUid) {
              setState(() {
                _remoteCameraOff = muted;
              });
            }
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint('[Agora] Error $err: $msg');
          },
        ),
      );

      // 4. Aktifkan video dan mulai preview lokal
      await _engine!.enableVideo();
      await _engine!.startPreview();

      // 5. Masuk ke Channel Agora
      await _engine!.joinChannel(
        token: AgoraConfig.token,
        channelId: _channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      if (mounted) {
        setState(() {
          _isAgoraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('[Agora] Catatan inisialisasi Agora: $e');
    }
  }

  /// Pensinyalan Firestore untuk status panggilan, penolakan, dan dering WhatsApp
  void _initCallSignaling() {
    // Mainkan nada dering keluar WhatsApp jika sebagai Penelepon
    if (_isCaller) {
      VideoCallAudioService.instance.playWhatsAppOutgoingRingtone();
    } else {
      // Sebagai Penerima yang sudah menekan tombol 'Terima', langsung aktifkan state terhubung
      _markCallConnected();
      _onCallConnected();
    }

    // Dengarkan status dokumen Firestore
    _callDocSub = FirebaseFirestore.instance
        .collection('video_calls')
        .doc(_callId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return;
      final data = snapshot.data()!;
      final status = data['status'] as String? ?? '';

      // Lawan bicara menolak panggilan
      if (status == 'rejected' && !_isRejected) {
        _onCallRejected();
        return;
      }

      // Lawan bicara mengakhiri panggilan
      if (status == 'ended') {
        _handleCallEnded();
        return;
      }

      // Lawan bicara terhubung via pensinyalan Firestore
      if (status == 'connected' && !_isConnected) {
        _onCallConnected();
      }
    });

    // Jalur pensinyalan 2: Dengarkan dokumen chats/{chatId} sebagai fallback
    if (widget.chatId != null && widget.chatId!.isNotEmpty) {
      _chatDocSub = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .snapshots()
          .listen((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) return;
        final data = snapshot.data()!;
        final callSession = data['callSession'] as Map<String, dynamic>?;
        if (callSession == null) return;
        final status = callSession['status'] as String? ?? '';
        if (status == 'rejected' && !_isRejected) {
          _onCallRejected();
        } else if (status == 'ended') {
          _handleCallEnded();
        } else if (status == 'connected' && !_isConnected) {
          _onCallConnected();
        }
      });
    }

    // Batas waktu panggilan: jika dalam 45 detik belum diangkat, akhiri panggilan
    Future.delayed(const Duration(seconds: 45), () {
      if (mounted && !_isConnected && !_isRejected) {
        _onCallNoAnswer();
      }
    });
  }

  void _onCallNoAnswer() {
    _durationTimer?.cancel();
    VideoCallAudioService.instance.stopWhatsAppOutgoingRingtone();
    VideoCallAudioService.instance.playCallEndedTone();
    CallService.instance.endCall(_callId, chatId: widget.chatId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Panggilan tidak terjawab / Lawan bicara sedang tidak dapat dihubungi."),
          backgroundColor: Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  void _onCallConnected() {
    if (_isConnected) return;
    VideoCallAudioService.instance.stopWhatsAppOutgoingRingtone();
    VideoCallAudioService.instance.playConnectedChime();

    if (mounted) {
      setState(() {
        _isConnected = true;
      });
      _startCallTimer();
    }
  }

  /// Tulis status 'connected' ke Firestore agar kedua sisi (caller & receiver) sinkron
  Future<void> _markCallConnected() async {
    try {
      await FirebaseFirestore.instance
          .collection('video_calls')
          .doc(_callId)
          .update({
        'status': 'connected',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('[VideoCall] _markCallConnected notice: $e');
    }

    if (widget.chatId != null && widget.chatId!.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .update({'callSession.status': 'connected'});
      } catch (_) {}
    }
  }

  void _onCallRejected() {
    _isRejected = true;
    _durationTimer?.cancel();
    VideoCallAudioService.instance.stopWhatsAppOutgoingRingtone();
    VideoCallAudioService.instance.playCallEndedTone();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Panggilan ditolak atau lawan bicara sedang sibuk."),
          backgroundColor: Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  void _handleCallEnded() {
    _durationTimer?.cancel();
    VideoCallAudioService.instance.stopAll();
    if (mounted && !_isRejected) {
      _showCallSummaryDialog();
    }
  }

  void _startCallTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _callDocSub?.cancel();
    _chatDocSub?.cancel();
    _waveController.dispose();
    _symptomNotesController.dispose();
    VideoCallAudioService.instance.stopAll();
    _disposeAgora();
    super.dispose();
  }

  Future<void> _disposeAgora() async {
    try {
      if (_engine != null) {
        await _engine!.leaveChannel();
        await _engine!.release();
      }
    } catch (e) {
      debugPrint('[Agora] Notice dispose: $e');
    }
  }

  void _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    try {
      await _engine?.muteLocalAudioStream(_isMuted);
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isMuted ? 'Mikrofon Dimatikan' : 'Mikrofon Aktif'),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _isMuted ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        ),
      );
    }
  }

  void _toggleCamera() async {
    setState(() {
      _isCameraOff = !_isCameraOff;
    });
    try {
      await _engine?.muteLocalVideoStream(_isCameraOff);
      if (_isCameraOff) {
        await _engine?.stopPreview();
      } else {
        await _engine?.startPreview();
      }
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isCameraOff ? 'Kamera Dimatikan' : 'Kamera Aktif'),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _switchCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    try {
      await _engine?.switchCamera();
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isFrontCamera ? 'Beralih ke Kamera Depan' : 'Beralih ke Kamera Belakang'),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Membuka lembar catatan keluhan langsung saat video call berlangsung
  void _openSymptomNotesSheet() {
    final isDark = ThemeService.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.assignment_turned_in_rounded,
                          color: Color(0xFF0284C7),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Catatan Keluhan Pasien Langsung",
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              "Pilih gejala yang dirasakan untuk dicatat ke rekam medis",
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _commonSymptoms.map((symptom) {
                      final isSelected = _selectedSymptoms.contains(symptom);
                      return FilterChip(
                        label: Text(symptom),
                        selected: isSelected,
                        onSelected: (selected) {
                          setSheetState(() {
                            if (selected) {
                              _selectedSymptoms.add(symptom);
                            } else {
                              _selectedSymptoms.remove(symptom);
                            }
                          });
                          setState(() {});
                        },
                        selectedColor: const Color(0xFF0284C7).withValues(alpha: 0.2),
                        checkmarkColor: const Color(0xFF0284C7),
                        backgroundColor:
                            isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF0284C7)
                              : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _symptomNotesController,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: "Deskripsi keluhan tambahan (opsional)...",
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _saveSymptomsToChat();
                      },
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text(
                        "Simpan Catatan ke Rekam Medis",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _saveSymptomsToChat() {
    final notes = _symptomNotesController.text.trim();
    if (_selectedSymptoms.isEmpty && notes.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln("📹 [Catatan Telekonsultasi Video Call]");
    if (_selectedSymptoms.isNotEmpty) {
      buffer.writeln("• Gejala: ${_selectedSymptoms.join(', ')}");
    }
    if (notes.isNotEmpty) {
      buffer.writeln("• Catatan: $notes");
    }

    final messageText = buffer.toString().trim();

    if (widget.chatId != null && widget.chatId!.isNotEmpty) {
      ChatService.instance.sendMessage(
        chatId: widget.chatId!,
        message: messageText,
        senderRole: widget.isDoctorView ? 'doctor' : 'patient',
        senderName: widget.isDoctorView ? _doctorName : _patientName,
        patientId: widget.patientId,
        patientName: _patientName,
        patientPhoto: _patientPhoto,
        doctorId: widget.doctorId,
        doctorName: _doctorName,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Catatan keluhan berhasil disimpan ke ruang obrolan konsultasi!"),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Mengakhiri panggilan telepon video
  void _endCall() async {
    _durationTimer?.cancel();
    VideoCallAudioService.instance.playCallEndedTone();
    CallService.instance.endCall(_callId, chatId: widget.chatId);
    try {
      await _engine?.leaveChannel();
    } catch (_) {}
    _showCallSummaryDialog();
  }

  void _showCallSummaryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = ThemeService.isDarkMode;
        final durationStr = _formatDuration(_secondsElapsed);

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_callback_rounded,
                  color: Color(0xFF10B981),
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Sesi Video Call Selesai",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Durasi Konsultasi: $durationStr",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0284C7),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isDoctorView ? "Pasien:" : "Dokter Pemeriksa:",
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      widget.isDoctorView ? _patientName : _doctorName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Selesai & Kembali",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: Stack(
        children: [
          // 1. TAMPILAN UTAMA LAWAN BICARA (HD VIDEO VIA AGORA ATAU AVATAR GLOW)
          Positioned.fill(
            child: _buildRemoteParticipantView(size),
          ),

          // 2. OVERLAY HEADER: DURASI, NAMA, ENKRIPSI MEDIS
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildCallHeader(),
          ),

          // 3. FLOATING PICTURE-IN-PICTURE (KAMERA DIRI SENDIRI)
          Positioned(
            right: _pipPosition.dx,
            top: _pipPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _pipPosition = Offset(
                    (_pipPosition.dx - details.delta.dx).clamp(10.0, size.width - 130),
                    (_pipPosition.dy + details.delta.dy).clamp(70.0, size.height - 220),
                  );
                });
              },
              child: _buildLocalPipWindow(),
            ),
          ),

          // 4. FLOATING ACTION TOOLBAR BAWAH
          Positioned(
            bottom: 24,
            left: 12,
            right: 12,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  /// Tampilan video utama lawan bicara (Dokter untuk Pasien, Pasien untuk Dokter)
  Widget _buildRemoteParticipantView(Size size) {
    final remoteName = widget.isDoctorView ? _patientName : _doctorName;
    final remoteSpecialty = widget.isDoctorView
        ? "Pasien Terhubung • Konsultasi Jantung"
        : widget.doctorSpecialty;
    final remotePhoto = widget.isDoctorView ? _patientPhoto : _doctorPhoto;

    final hasRemoteVideo = _remoteUid != null && !_remoteCameraOff && _engine != null;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF070B14),
            Color(0xFF020617),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Video Langsung Kamera Lawan Bicara melalui Agora Video View
          if (hasRemoteVideo)
            Positioned.fill(
              child: AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine!,
                  canvas: VideoCanvas(uid: _remoteUid!),
                  connection: RtcConnection(channelId: _channelName),
                ),
              ),
            ),

          // Tampilan Avatar jika lawan bicara belum menyalakan kamera / masih menghubungkan
          if (!hasRemoteVideo)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      final waveScale = 1.0 + (_waveController.value * 0.08);
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 175 * waveScale,
                            height: 175 * waveScale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0284C7).withValues(
                                alpha: 0.15 * (1.0 - _waveController.value),
                              ),
                            ),
                          ),
                          Container(
                            width: 148,
                            height: 148,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _isConnected
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF0284C7).withValues(alpha: 0.85),
                                width: 3.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isConnected
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF0284C7))
                                      .withValues(alpha: 0.4),
                                  blurRadius: 26,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: widget.isDoctorView
                                ? ProfileService.buildPatientImage(
                                    remotePhoto,
                                    patientId: widget.patientId,
                                    width: 148,
                                    height: 148,
                                    isDark: true,
                                  )
                                : DoctorService.buildDoctorImage(
                                    remotePhoto,
                                    width: 148,
                                    height: 148,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  Text(
                    remoteName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remoteSpecialty,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: _isConnected
                          ? const Color(0xFF10B981).withValues(alpha: 0.2)
                          : const Color(0xFF0284C7).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isConnected
                            ? const Color(0xFF10B981)
                            : const Color(0xFF0284C7).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      _isConnected ? "Terhubung • Audio & Video HD Agora" : "Menghubungkan...",
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _isConnected ? const Color(0xFF34D399) : const Color(0xFF38BDF8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Overlay Header atas: tombol kembali, live timer, enkripsi medis
  Widget _buildCallHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 44, 16, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black87,
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () {
              _showConfirmExitDialog();
            },
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isConnected ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? _formatDuration(_secondsElapsed) : "Memanggil...",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, color: Color(0xFF10B981), size: 13),
                SizedBox(width: 5),
                Text(
                  "Enkripsi Medis",
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Tinggalkan Panggilan?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Apakah Anda yakin ingin meninggalkan sesi telekonsultasi ini?",
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () {
              Navigator.pop(ctx);
              _endCall();
            },
            child: const Text("Ya, Akhiri", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Floating Window Picture-in-Picture (PiP) Kamera Diri Sendiri
  Widget _buildLocalPipWindow() {
    final localPhoto = widget.isDoctorView ? _doctorPhoto : _patientPhoto;
    final hasLocalVideo = !_isCameraOff && _isAgoraInitialized && _engine != null;

    return Container(
      width: 108,
      height: 148,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0284C7),
          width: 2.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (hasLocalVideo)
            Positioned.fill(
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine!,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            ),

          if (!hasLocalVideo)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF0F172A),
                child: Center(
                  child: widget.isDoctorView
                      ? DoctorService.buildDoctorImage(
                          localPhoto,
                          width: 108,
                          height: 148,
                          fit: BoxFit.cover,
                        )
                      : ProfileService.buildPatientImage(
                          localPhoto,
                          patientId: widget.patientId,
                          width: 108,
                          height: 148,
                        ),
                ),
              ),
            ),

          // Label "Anda"
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "Anda",
                style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Floating action toolbar bawah (seperti tombol WhatsApp Video Call)
  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Mute Mic
          _controlButton(
            icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            label: _isMuted ? "Unmute" : "Mic",
            isActive: _isMuted,
            activeColor: const Color(0xFFEF4444),
            inactiveColor: Colors.white.withValues(alpha: 0.15),
            iconColor: Colors.white,
            onTap: _toggleMute,
          ),

          // 2. Toggle Kamera
          _controlButton(
            icon: _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
            label: _isCameraOff ? "Kamera On" : "Kamera",
            isActive: _isCameraOff,
            activeColor: const Color(0xFFEF4444),
            inactiveColor: Colors.white.withValues(alpha: 0.15),
            iconColor: Colors.white,
            onTap: _toggleCamera,
          ),

          // 3. Balik Kamera Depan / Belakang
          _controlButton(
            icon: Icons.flip_camera_ios_rounded,
            label: "Putar",
            isActive: false,
            activeColor: const Color(0xFF0284C7),
            inactiveColor: Colors.white.withValues(alpha: 0.15),
            iconColor: Colors.white,
            onTap: _switchCamera,
          ),

          // 4. Catat Keluhan Pasien Langsung
          _controlButton(
            icon: Icons.note_alt_rounded,
            label: "Keluhan",
            isActive: _selectedSymptoms.isNotEmpty || _symptomNotesController.text.isNotEmpty,
            activeColor: const Color(0xFF0284C7),
            inactiveColor: const Color(0xFF0284C7).withValues(alpha: 0.25),
            iconColor: const Color(0xFF38BDF8),
            onTap: _openSymptomNotesSheet,
          ),

          // 5. Akhiri Panggilan (End Call - Tombol Merah WhatsApp)
          GestureDetector(
            onTap: _endCall,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.call_end_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? activeColor : inactiveColor,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
