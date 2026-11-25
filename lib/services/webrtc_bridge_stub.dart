import 'package:flutter/foundation.dart';

/// Stub implementation for non-web platforms
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

  void init() {}
  void startCall({required String callId, required bool isCaller}) {}
  void sendOffer({required String sdp, required String type}) {}
  void sendAnswer({required String sdp, required String type}) {}
  void sendCandidate(String candidateJson) {}
  void toggleMic(bool enabled) {}
  void toggleCamera(bool enabled) {}
  void endCall() {}
}

