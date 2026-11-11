// web/webrtc_call.js
// Implementasi WebRTC Peer-to-Peer Suara & Video Langsung (seperti WhatsApp Call)
(function () {
  'use strict';

  let localStream = null;
  let peerConnection = null;
  let remoteStream = null;
  let activeCallId = null;
  let isCaller = false;

  let localVideoEl = null;
  let remoteVideoEl = null;
  let remoteAudioEl = null;

  const ICE_SERVERS = {
    iceServers: [
      { urls: 'stun:stun.l.google.com:19302' },
      { urls: 'stun:stun1.l.google.com:19302' },
      { urls: 'stun:stun2.l.google.com:19302' }
    ]
  };

  function getOrCreateMediaElements() {
    if (!remoteAudioEl) {
      remoteAudioEl = document.getElementById('webrtc-remote-audio');
      if (!remoteAudioEl) {
        remoteAudioEl = document.createElement('audio');
        remoteAudioEl.id = 'webrtc-remote-audio';
        remoteAudioEl.autoplay = true;
        remoteAudioEl.playsInline = true;
        document.body.appendChild(remoteAudioEl);
      }
    }
    if (!localVideoEl) {
      localVideoEl = document.getElementById('webrtc-local-video');
      if (!localVideoEl) {
        localVideoEl = document.createElement('video');
        localVideoEl.id = 'webrtc-local-video';
        localVideoEl.autoplay = true;
        localVideoEl.playsInline = true;
        localVideoEl.muted = true; // Jangan putar balik suara sendiri agar tidak echo
        localVideoEl.style.width = '100%';
        localVideoEl.style.height = '100%';
        localVideoEl.style.objectFit = 'cover';
        localVideoEl.style.transform = 'scaleX(-1)'; // Cermin kamera depan
      }
    }
    if (!remoteVideoEl) {
      remoteVideoEl = document.getElementById('webrtc-remote-video');
      if (!remoteVideoEl) {
        remoteVideoEl = document.createElement('video');
        remoteVideoEl.id = 'webrtc-remote-video';
        remoteVideoEl.autoplay = true;
        remoteVideoEl.playsInline = true;
        remoteVideoEl.style.width = '100%';
        remoteVideoEl.style.height = '100%';
        remoteVideoEl.style.objectFit = 'cover';
      }
    }
  }

  async function startWebRTC(callId, caller) {
    activeCallId = callId;
    isCaller = caller;
    getOrCreateMediaElements();

    try {
      // 1. Dapatkan izin Mikrofon dan Kamera langsung dari perangkat
      try {
        localStream = await navigator.mediaDevices.getUserMedia({
          audio: {
            echoCancellation: true,
            noiseSuppression: true,
            autoGainControl: true
          },
          video: {
            width: { ideal: 640 },
            height: { ideal: 480 },
            facingMode: 'user'
          }
        });
      } catch (camErr) {
        console.warn('[WebRTC] Kamera gagal atau tidak tersedia, mencoba mikrofon saja:', camErr);
        try {
          localStream = await navigator.mediaDevices.getUserMedia({
            audio: {
              echoCancellation: true,
              noiseSuppression: true,
              autoGainControl: true
            },
            video: false
          });
        } catch (micErr) {
          console.warn('[WebRTC] Mikrofon juga tidak tersedia:', micErr);
          localStream = new MediaStream();
        }
      }

      const hasLocalVideo = localStream.getVideoTracks().length > 0;
      const hasLocalAudio = localStream.getAudioTracks().length > 0;

      // Tampilkan kamera diri sendiri di elemen video lokal
      if (hasLocalVideo && localVideoEl) {
        localVideoEl.srcObject = localStream;
        localVideoEl.play().catch(e => console.log('Local video play notice:', e));
      }

      window.dispatchEvent(new CustomEvent('webrtc_local_ready', {
        detail: {
          hasVideo: hasLocalVideo,
          hasAudio: hasLocalAudio
        }
      }));

      // 2. Buat RTCPeerConnection
      peerConnection = new RTCPeerConnection(ICE_SERVERS);

      // Tambahkan trek audio & video lokal ke koneksi jika ada
      localStream.getTracks().forEach((track) => {
        try {
          peerConnection.addTrack(track, localStream);
        } catch (_) {}
      });

      // Terima trek suara & video dari lawan bicara secara real-time
      peerConnection.ontrack = (event) => {
        console.log('[WebRTC] Trek lawan bicara diterima:', event.track.kind);
        remoteStream = event.streams[0];

        // Putar suara langsung dari mikrofon lawan bicara melalui speaker
        if (remoteAudioEl && remoteStream) {
          remoteAudioEl.srcObject = remoteStream;
          remoteAudioEl.play().catch(e => console.log('Remote audio play notice:', e));
        }

        const hasRemoteVid = remoteStream && remoteStream.getVideoTracks().length > 0;
        if (event.track.kind === 'video' && remoteVideoEl && remoteStream) {
          remoteVideoEl.srcObject = remoteStream;
          remoteVideoEl.play().catch(e => console.log('Remote video play notice:', e));
        }

        window.dispatchEvent(new CustomEvent('webrtc_remote_ready', {
          detail: {
            hasVideo: hasRemoteVid,
            hasAudio: remoteStream ? remoteStream.getAudioTracks().length > 0 : true
          }
        }));
      };

      // Tangkap ICE Candidate dan kirim ke Dart
      peerConnection.onicecandidate = (event) => {
        if (event.candidate) {
          window.dispatchEvent(new CustomEvent('webrtc_candidate_found', {
            detail: {
              candidate: JSON.stringify(event.candidate.toJSON ? event.candidate.toJSON() : {
                candidate: event.candidate.candidate,
                sdpMid: event.candidate.sdpMid,
                sdpMLineIndex: event.candidate.sdpMLineIndex
              })
            }
          }));
        }
      };

      peerConnection.onconnectionstatechange = () => {
        console.log('[WebRTC] Status koneksi:', peerConnection ? peerConnection.connectionState : 'null');
        if (peerConnection && peerConnection.connectionState === 'connected') {
          window.dispatchEvent(new CustomEvent('webrtc_connected'));
        } else if (peerConnection && (peerConnection.connectionState === 'disconnected' || peerConnection.connectionState === 'failed')) {
          window.dispatchEvent(new CustomEvent('webrtc_disconnected'));
        }
      };

      // Jika sebagai Penelepon (Caller): buat SDP Offer
      if (isCaller) {
        const offer = await peerConnection.createOffer({
          offerToReceiveAudio: true,
          offerToReceiveVideo: true
        });
        await peerConnection.setLocalDescription(offer);

        window.dispatchEvent(new CustomEvent('webrtc_offer_ready', {
          detail: {
            sdp: offer.sdp,
            type: offer.type
          }
        }));
      }

    } catch (err) {
      console.error('[WebRTC] Gagal memulai WebRTC:', err);
      window.dispatchEvent(new CustomEvent('webrtc_error', { detail: { message: err.toString() } }));
    }
  }

  // Handle SDP Offer pada Penerima (Receiver)
  async function handleRemoteOffer(sdp, type) {
    if (!peerConnection) return;
    try {
      await peerConnection.setRemoteDescription(new RTCSessionDescription({ sdp, type }));
      const answer = await peerConnection.createAnswer();
      await peerConnection.setLocalDescription(answer);

      window.dispatchEvent(new CustomEvent('webrtc_answer_ready', {
        detail: {
          sdp: answer.sdp,
          type: answer.type
        }
      }));
    } catch (err) {
      console.error('[WebRTC] Error handle remote offer:', err);
    }
  }

  // Handle SDP Answer pada Penelepon (Caller)
  async function handleRemoteAnswer(sdp, type) {
    if (!peerConnection) return;
    try {
      if (peerConnection.signalingState !== 'stable') {
        await peerConnection.setRemoteDescription(new RTCSessionDescription({ sdp, type }));
      }
    } catch (err) {
      console.error('[WebRTC] Error handle remote answer:', err);
    }
  }

  // Handle ICE Candidate
  async function handleAddCandidate(candidateJsonStr) {
    if (!peerConnection) return;
    try {
      const data = typeof candidateJsonStr === 'string' ? JSON.parse(candidateJsonStr) : candidateJsonStr;
      await peerConnection.addIceCandidate(new RTCIceCandidate(data));
    } catch (err) {
      console.warn('[WebRTC] Candidate notice (non-fatal):', err);
    }
  }

  // Mute / Unmute Mikrofon Asli
  function toggleMic(enabled) {
    if (!localStream) return;
    localStream.getAudioTracks().forEach(t => t.enabled = enabled);
  }

  // Kamera On / Off
  function toggleCamera(enabled) {
    if (!localStream) return;
    localStream.getVideoTracks().forEach(t => t.enabled = enabled);
  }

  // Akhiri Panggilan & Hentikan Mikrofon/Kamera
  function endWebRTC() {
    if (localStream) {
      try {
        localStream.getTracks().forEach(t => t.stop());
      } catch (_) {}
      localStream = null;
    }
    if (peerConnection) {
      try {
        peerConnection.close();
      } catch (_) {}
      peerConnection = null;
    }
    if (remoteAudioEl) {
      remoteAudioEl.srcObject = null;
    }
    if (remoteVideoEl) {
      remoteVideoEl.srcObject = null;
    }
    if (localVideoEl) {
      localVideoEl.srcObject = null;
    }
    window.dispatchEvent(new CustomEvent('webrtc_ended'));
  }

  // Listener perintah dari Flutter
  window.addEventListener('webrtc_cmd_start', (e) => {
    startWebRTC(e.detail ? e.detail.callId : null, e.detail ? e.detail.isCaller : false);
  });
  window.addEventListener('webrtc_cmd_offer', (e) => {
    if (e.detail) {
      handleRemoteOffer(e.detail.sdp, e.detail.type);
    }
  });
  window.addEventListener('webrtc_cmd_answer', (e) => {
    if (e.detail) {
      handleRemoteAnswer(e.detail.sdp, e.detail.type);
    }
  });
  window.addEventListener('webrtc_cmd_candidate', (e) => {
    if (e.detail) {
      handleAddCandidate(e.detail.candidate);
    }
  });
  window.addEventListener('webrtc_cmd_toggle_mic', (e) => {
    if (e.detail) {
      toggleMic(e.detail.enabled);
    }
  });
  window.addEventListener('webrtc_cmd_toggle_camera', (e) => {
    if (e.detail) {
      toggleCamera(e.detail.enabled);
    }
  });
  window.addEventListener('webrtc_cmd_end', () => {
    endWebRTC();
  });

  window.HeartCareWebRTC = {
    getLocalVideo: () => localVideoEl,
    getRemoteVideo: () => remoteVideoEl,
    endWebRTC: endWebRTC
  };
})();
