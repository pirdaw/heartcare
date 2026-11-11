import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

/// Layanan Audio Telekonsultasi & Nada Panggilan WhatsApp (Outgoing & Incoming Ringtone)
class VideoCallAudioService {
  VideoCallAudioService._();
  static final VideoCallAudioService instance = VideoCallAudioService._();

  web.AudioContext? _audioContext;
  Timer? _ringingTimer;
  Timer? _incomingTimer;
  bool _isRinging = false;
  bool _isIncomingRinging = false;

  web.AudioContext _getAudioContext() {
    if (_audioContext == null) {
      _audioContext = web.AudioContext();
    }
    if (_audioContext!.state == 'suspended') {
      _audioContext!.resume();
    }
    return _audioContext!;
  }

  /// 1. NADA DERINT KELUAR WHATSAPP (Outgoing Ringtone - Tut... Tut...)
  /// Berbunyi saat pasien/dokter sedang memanggil dan menunggu lawan bicara mengangkat
  void playWhatsAppOutgoingRingtone() {
    if (_isRinging) return;
    _isRinging = true;
    stopWhatsAppIncomingRingtone();

    _playOutgoingDoubleBeep();
    _ringingTimer?.cancel();
    _ringingTimer = Timer.periodic(const Duration(milliseconds: 2800), (_) {
      if (_isRinging) {
        _playOutgoingDoubleBeep();
      }
    });
  }

  void _playOutgoingDoubleBeep() {
    try {
      HapticFeedback.mediumImpact();
      final ctx = _getAudioContext();
      final now = ctx.currentTime;

      // Nada standar telepon internasional (425Hz)
      _createBeep(ctx, freq: 425, start: now, duration: 0.35, gainVal: 0.18);
      _createBeep(ctx, freq: 425, start: now + 0.45, duration: 0.35, gainVal: 0.18);
    } catch (e) {
      debugPrint('[VideoCallAudio] Outgoing ringtone notice: $e');
    }
  }

  void stopWhatsAppOutgoingRingtone() {
    _isRinging = false;
    _ringingTimer?.cancel();
    _ringingTimer = null;
  }

  /// 2. NADA DERING MASUK WHATSAPP (Incoming Ringtone)
  /// Berbunyi di perangkat penerima saat ada panggilan video masuk
  void playWhatsAppIncomingRingtone() {
    if (_isIncomingRinging) return;
    _isIncomingRinging = true;
    stopWhatsAppOutgoingRingtone();

    _playIncomingMelody();
    _incomingTimer?.cancel();
    _incomingTimer = Timer.periodic(const Duration(milliseconds: 2400), (_) {
      if (_isIncomingRinging) {
        _playIncomingMelody();
      }
    });
  }

  void _playIncomingMelody() {
    try {
      HapticFeedback.vibrate();
      final ctx = _getAudioContext();
      final now = ctx.currentTime;

      // Melodi panggilan masuk berirama cerah (chimes E5 - G#5 - B5 - E6)
      final notes = [
        {'freq': 659.25, 'start': 0.0, 'dur': 0.18},
        {'freq': 830.61, 'start': 0.20, 'dur': 0.18},
        {'freq': 987.77, 'start': 0.40, 'dur': 0.22},
        {'freq': 1318.51, 'start': 0.65, 'dur': 0.35},
        {'freq': 987.77, 'start': 1.10, 'dur': 0.18},
        {'freq': 1318.51, 'start': 1.32, 'dur': 0.38},
      ];

      for (final n in notes) {
        _createBeep(
          ctx,
          freq: (n['freq'] as num).toDouble(),
          start: now + (n['start'] as num).toDouble(),
          duration: (n['dur'] as num).toDouble(),
          gainVal: 0.20,
        );
      }
    } catch (e) {
      debugPrint('[VideoCallAudio] Incoming ringtone notice: $e');
    }
  }

  void stopWhatsAppIncomingRingtone() {
    _isIncomingRinging = false;
    _incomingTimer?.cancel();
    _incomingTimer = null;
  }

  /// Helper membuat nada sinus lembut
  void _createBeep(
    web.AudioContext ctx, {
    required double freq,
    required double start,
    required double duration,
    required double gainVal,
  }) {
    final osc = ctx.createOscillator();
    final gain = ctx.createGain();

    osc.frequency.setValueAtTime(freq, start);
    gain.gain.setValueAtTime(0.001, start);
    gain.gain.exponentialRampToValueAtTime(gainVal, start + 0.03);
    gain.gain.exponentialRampToValueAtTime(0.001, start + duration);

    osc.connect(gain);
    gain.connect(ctx.destination);

    osc.start(start);
    osc.stop(start + duration + 0.05);
  }

  /// 3. NADA PANGGILAN TERHUBUNG (Connected Chime)
  void playConnectedChime() {
    stopWhatsAppOutgoingRingtone();
    stopWhatsAppIncomingRingtone();
    try {
      final ctx = _getAudioContext();
      final now = ctx.currentTime;

      final osc = ctx.createOscillator();
      final gain = ctx.createGain();

      osc.frequency.setValueAtTime(523.25, now);
      osc.frequency.setValueAtTime(659.25, now + 0.16);

      gain.gain.setValueAtTime(0.001, now);
      gain.gain.exponentialRampToValueAtTime(0.22, now + 0.03);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.50);

      osc.connect(gain);
      gain.connect(ctx.destination);

      osc.start(now);
      osc.stop(now + 0.55);
    } catch (_) {}
  }

  /// 4. NADA PANGGILAN BERAKHIR / DITOLAK (Call Ended / Rejected Tone)
  void playCallEndedTone() {
    stopWhatsAppOutgoingRingtone();
    stopWhatsAppIncomingRingtone();
    try {
      final ctx = _getAudioContext();
      final now = ctx.currentTime;

      final osc = ctx.createOscillator();
      final gain = ctx.createGain();

      osc.frequency.setValueAtTime(660, now);
      osc.frequency.setValueAtTime(520, now + 0.12);
      osc.frequency.setValueAtTime(390, now + 0.24);

      gain.gain.setValueAtTime(0.18, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.42);

      osc.connect(gain);
      gain.connect(ctx.destination);

      osc.start(now);
      osc.stop(now + 0.45);
    } catch (_) {}
  }

  void stopAll() {
    stopWhatsAppOutgoingRingtone();
    stopWhatsAppIncomingRingtone();
  }

  void dispose() {
    stopAll();
  }
}
