import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

bool _viewsRegistered = false;

/// Daftarkan View Factory untuk menampilkan elemen HTML Video Kamera lokal & remote di Flutter Web
void registerWebRtcViewFactories() {
  if (_viewsRegistered) return;
  _viewsRegistered = true;

  ui_web.platformViewRegistry.registerViewFactory(
    'heartcare-local-video-view',
    (int viewId) {
      var el = web.document.getElementById('webrtc-local-video');
      if (el == null) {
        final video = web.HTMLVideoElement()
          ..id = 'webrtc-local-video'
          ..autoplay = true
          ..playsInline = true
          ..muted = true;
        video.style.width = '100%';
        video.style.height = '100%';
        video.style.objectFit = 'cover';
        video.style.transform = 'scaleX(-1)';
        el = video;
      }
      return el;
    },
  );

  ui_web.platformViewRegistry.registerViewFactory(
    'heartcare-remote-video-view',
    (int viewId) {
      var el = web.document.getElementById('webrtc-remote-video');
      if (el == null) {
        final video = web.HTMLVideoElement()
          ..id = 'webrtc-remote-video'
          ..autoplay = true
          ..playsInline = true;
        video.style.width = '100%';
        video.style.height = '100%';
        video.style.objectFit = 'cover';
        el = video;
      }
      return el;
    },
  );
}

