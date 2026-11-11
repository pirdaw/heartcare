import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Implementasi Bridge WebRTC untuk platform Web (Chrome / Edge / Firefox / Safari)
class WebRtcBridge {
  WebRtcBridge._();
  static final WebRtcBridge instance = WebRtcBridge._();

  Function(String sdp, String type)? onOfferReady;
  Function(String sdp, String type)? onAnswerReady;
  Function(String candidateJson)? onCandidateFound;
  Function(bool hasVideo, bool hasAudio)? onLocalReady;
  Function(bool hasVideo, bool hasAudio)? onRemoteReady;
  VoidCallback? onConnected;
  VoidCallback? onDisconnected;
  VoidCallback? onEnded;

  bool _isInitialized = false;

  void init() {
    if (_isInitialized) return;
    _isInitialized = true;

    web.window.addEventListener(
      'webrtc_local_ready',
      (web.Event e) {
        final ce = e as web.CustomEvent;
        bool hasVideo = false;
        bool hasAudio = false;
        if (ce.detail != null) {
          final detail = ce.detail as JSObject;
          hasVideo = (detail['hasVideo'] as JSBoolean?)?.toDart ?? false;
          hasAudio = (detail['hasAudio'] as JSBoolean?)?.toDart ?? false;
        }
        onLocalReady?.call(hasVideo, hasAudio);
      }.toJS,
    );

    web.window.addEventListener(
      'webrtc_offer_ready',
      (web.Event e) {
        final ce = e as web.CustomEvent;
        if (ce.detail != null) {
          final detail = ce.detail as JSObject;
          final sdp = (detail['sdp'] as JSString?)?.toDart ?? '';
          final type = (detail['type'] as JSString?)?.toDart ?? 'offer';
          onOfferReady?.call(sdp, type);
        }
      }.toJS,
    );

    web.window.addEventListener(
      'webrtc_answer_ready',
      (web.Event e) {
        final ce = e as web.CustomEvent;
        if (ce.detail != null) {
          final detail = ce.detail as JSObject;
          final sdp = (detail['sdp'] as JSString?)?.toDart ?? '';
          final type = (detail['type'] as JSString?)?.toDart ?? 'answer';
          onAnswerReady?.call(sdp, type);
        }
      }.toJS,
    );

    web.window.addEventListener(
      'webrtc_candidate_found',
      (web.Event e) {
        final ce = e as web.CustomEvent;
        if (ce.detail != null) {
          final detail = ce.detail as JSObject;
          final cand = (detail['candidate'] as JSString?)?.toDart ?? '';
          onCandidateFound?.call(cand);
        }
      }.toJS,
    );

    web.window.addEventListener(
      'webrtc_remote_ready',
      (web.Event e) {
        final ce = e as web.CustomEvent;
        bool hasVideo = true;
        bool hasAudio = true;
        if (ce.detail != null) {
          final detail = ce.detail as JSObject;
          hasVideo = (detail['hasVideo'] as JSBoolean?)?.toDart ?? true;
          hasAudio = (detail['hasAudio'] as JSBoolean?)?.toDart ?? true;
        }
        onRemoteReady?.call(hasVideo, hasAudio);
      }.toJS,
    );

    web.window.addEventListener(
      'webrtc_connected',
      (web.Event e) {
        onConnected?.call();
      }.toJS,
    );

    web.window.addEventListener(
      'webrtc_disconnected',
      (web.Event e) {
        onDisconnected?.call();
      }.toJS,
    );

    web.window.addEventListener(
      'webrtc_ended',
      (web.Event e) {
        onEnded?.call();
      }.toJS,
    );
  }

  void startCall({required String callId, required bool isCaller}) {
    init();
    final detail = JSObject();
    detail['callId'] = callId.toJS;
    detail['isCaller'] = isCaller.toJS;

    final event = web.CustomEvent(
      'webrtc_cmd_start',
      web.CustomEventInit(detail: detail),
    );
    web.window.dispatchEvent(event);
  }

  void sendOffer({required String sdp, required String type}) {
    final detail = JSObject();
    detail['sdp'] = sdp.toJS;
    detail['type'] = type.toJS;

    final event = web.CustomEvent(
      'webrtc_cmd_offer',
      web.CustomEventInit(detail: detail),
    );
    web.window.dispatchEvent(event);
  }

  void sendAnswer({required String sdp, required String type}) {
    final detail = JSObject();
    detail['sdp'] = sdp.toJS;
    detail['type'] = type.toJS;

    final event = web.CustomEvent(
      'webrtc_cmd_answer',
      web.CustomEventInit(detail: detail),
    );
    web.window.dispatchEvent(event);
  }

  void sendCandidate(String candidateJson) {
    final detail = JSObject();
    detail['candidate'] = candidateJson.toJS;

    final event = web.CustomEvent(
      'webrtc_cmd_candidate',
      web.CustomEventInit(detail: detail),
    );
    web.window.dispatchEvent(event);
  }

  void toggleMic(bool enabled) {
    final detail = JSObject();
    detail['enabled'] = enabled.toJS;

    final event = web.CustomEvent(
      'webrtc_cmd_toggle_mic',
      web.CustomEventInit(detail: detail),
    );
    web.window.dispatchEvent(event);
  }

  void toggleCamera(bool enabled) {
    final detail = JSObject();
    detail['enabled'] = enabled.toJS;

    final event = web.CustomEvent(
      'webrtc_cmd_toggle_camera',
      web.CustomEventInit(detail: detail),
    );
    web.window.dispatchEvent(event);
  }

  void endCall() {
    web.window.dispatchEvent(web.CustomEvent('webrtc_cmd_end'));
  }
}

