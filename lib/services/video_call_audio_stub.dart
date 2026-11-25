import 'dart:async';
import 'package:flutter/services.dart';

/// Implementasi Audio & Getaran Panggilan untuk platform Mobile (HP / Android / iOS)
class VideoCallAudioService {
  VideoCallAudioService._();
  static final VideoCallAudioService instance = VideoCallAudioService._();

  Timer? _vibrationTimer;
  bool _isVibrating = false;

  void playWhatsAppOutgoingRingtone() {
    stopWhatsAppOutgoingRingtone();
    _isVibrating = true;
    HapticFeedback.mediumImpact();
    // Getaran ringan periodik saat menunggu lawan bicara mengangkat (tut... tut...)
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (_isVibrating) {
        HapticFeedback.mediumImpact();
      }
    });
  }

  void stopWhatsAppOutgoingRingtone() {
    _isVibrating = false;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
  }

  void playWhatsAppIncomingRingtone() {
    stopWhatsAppIncomingRingtone();
    _isVibrating = true;
    // Getaran fisik HP kuat & berulang saat ada panggilan masuk layaknya nada dering telepon HP
    HapticFeedback.vibrate();
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (_isVibrating) {
        HapticFeedback.vibrate();
      }
    });
  }

  void stopWhatsAppIncomingRingtone() {
    _isVibrating = false;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
  }

  void playConnectedChime() {
    stopAll();
    HapticFeedback.lightImpact();
  }

  void playCallEndedTone() {
    stopAll();
    HapticFeedback.heavyImpact();
  }

  void stopAll() {
    stopWhatsAppOutgoingRingtone();
    stopWhatsAppIncomingRingtone();
  }

  void dispose() {
    stopAll();
  }
}
