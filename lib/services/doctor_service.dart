import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Layanan terpusat untuk registrasi, sinkronisasi, dan penemuan akun dokter autentik
/// dengan sinkronisasi Firestore (users & doctors) + Cache Lokal (SharedPreferences).
class DoctorService {
  DoctorService._();
  static final DoctorService instance = DoctorService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _prefKeyDoctors = 'heartcare_registered_doctors_v2';

  /// Cek apakah suatu dokumen adalah akun dokter
  static bool isDoctorDocument(Map<String, dynamic> data) {
    final role = (data['role'] as String? ?? '').trim().toLowerCase();
    if (role == 'doctor' || role == 'dokter') return true;

    final spesialis = (data['spesialis'] as String? ?? '').trim();
    if (spesialis.isNotEmpty) return true;

    final sip = (data['sip'] as String? ?? '').trim();
    if (sip.isNotEmpty) return true;

    final nama = (data['nama'] as String? ?? '').trim().toLowerCase();
    if (nama.startsWith('dr.') || nama.startsWith('dr ') || nama.contains('dokter')) {
      return true;
    }

    final email = (data['email'] as String? ?? '').trim().toLowerCase();
    if (email.contains('dokter') || email.contains('doctor')) {
      return true;
    }

    return false;
  }

  /// Cek apakah akun dokter adalah akun asli (BUKAN dummy yang di-generate tanpa akun)
  static bool isRealDoctorAccount(Map<String, dynamic> data, String id) {
    final cleanId = id.trim().toLowerCase();
    // Filter akun dummy yang di-generate sebelumnya
    if (cleanId.startsWith('dr_valent_') ||
        cleanId.startsWith('dummy_') ||
        cleanId.contains('dummy')) {
      return false;
    }

    final email = (data['email'] as String? ?? '').trim().toLowerCase();
    if (email == 'dr.valent@heartcare.id' && cleanId.startsWith('dr_valent_')) {
      return false;
    }

    return isDoctorDocument(data);
  }

  /// Bersihkan data dokter dummy dari Cache Lokal dan Firestore
  Future<void> cleanupDummyDoctors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList(_prefKeyDoctors) ?? [];
      final List<Map<String, dynamic>> cleanList = [];

      for (final item in list) {
        try {
          final decoded = jsonDecode(item) as Map<String, dynamic>;
          final id = (decoded['id'] ?? decoded['uid'] ?? '').toString();
          if (isRealDoctorAccount(decoded, id)) {
            cleanList.add(decoded);
          }
        } catch (_) {}
      }

      final encoded = cleanList.map((e) => jsonEncode(e)).toList();
      await prefs.setStringList(_prefKeyDoctors, encoded);

      // Bersihkan juga dari Firestore jika ada dokumen dummy dr_valent_*
      try {
        final dummyUsers = await _firestore.collection('users').get();
        for (final doc in dummyUsers.docs) {
          if (doc.id.startsWith('dr_valent_') || doc.id.startsWith('dummy_')) {
            await doc.reference.delete();
          }
        }
        final dummyDoctors = await _firestore.collection('doctors').get();
        for (final doc in dummyDoctors.docs) {
          if (doc.id.startsWith('dr_valent_') || doc.id.startsWith('dummy_')) {
            await doc.reference.delete();
          }
        }
      } catch (e) {
        debugPrint('[DoctorService] Info cleanup Firestore: $e');
      }
    } catch (e) {
      debugPrint('[DoctorService] Gagal membersihkan dummy doctors: $e');
    }
  }

  /// Normalisasi data dokter ke format standar `Map<String, dynamic>`
  static Map<String, dynamic> normalizeDoctorData({
    required String id,
    required Map<String, dynamic> data,
  }) {
    String nama = (data['nama'] as String? ?? '').trim();
    if (nama.isEmpty) {
      nama = (data['name'] as String? ?? 'dr. Dokter HeartCare').trim();
    }
    if (!nama.toLowerCase().startsWith('dr.') && !nama.toLowerCase().startsWith('dr ')) {
      nama = 'dr. $nama';
    }

    String spesialis = (data['spesialis'] as String? ?? '').trim();
    if (spesialis.isEmpty) {
      spesialis = 'Spesialis Jantung & Pembuluh Darah';
    }

    String foto = (data['foto'] as String? ?? '').trim();
    if (foto.isEmpty) {
      foto = 'assets/images/dokter_nurlitta.jpg';
    }

    String pengalaman = (data['pengalaman'] as String? ?? '').trim();
    if (pengalaman.isEmpty) {
      pengalaman = '10 tahun';
    }

    String sip = (data['sip'] as String? ?? '').trim();
    if (sip.isEmpty) {
      sip = 'SIP-${id.length > 4 ? id.substring(0, 4).toUpperCase() : "2026"}/2026';
    }

    String lokasi = (data['lokasi'] as String? ?? '').trim();
    if (lokasi.isEmpty) {
      lokasi = 'Klinik Jantung HeartCare';
    }

    String tentang = (data['tentang'] as String? ?? '').trim();
    if (tentang.isEmpty) {
      tentang =
          'Dokter spesialis jantung dan kardiovaskular bersertifikasi yang berdedikasi melayani konsultasi kesehatan jantung pasien secara komprehensif.';
    }

    final bool isOnline = data['isOnline'] as bool? ?? true;
    final String email = (data['email'] as String? ?? '').trim();
    final String telepon = ((data['telepon'] ??
            data['noWa'] ??
            data['whatsapp'] ??
            data['noTelepon'] ??
            data['phone']) as String? ??
            '')
        .trim();

    return {
      'id': id,
      'uid': id,
      'nama': nama,
      'spesialis': spesialis,
      'foto': foto,
      'pengalaman': pengalaman,
      'sip': sip,
      'lokasi': lokasi,
      'tentang': tentang,
      'isOnline': isOnline,
      'email': email,
      'telepon': telepon,
      'noWa': telepon,
      'whatsapp': telepon,
      'role': 'doctor',
    };
  }

  /// Simpan dokter ke SharedPreferences agar selalu ada fallback instan offline
  Future<void> cacheDoctor(Map<String, dynamic> doctor) async {
    try {
      final docId = (doctor['id'] ?? doctor['uid'] ?? '').toString();
      // Jangan pernah simpan dokter dummy ke cache
      if (!isRealDoctorAccount(doctor, docId)) return;

      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList(_prefKeyDoctors) ?? [];
      final List<Map<String, dynamic>> decoded = [];

      for (final item in list) {
        try {
          final d = jsonDecode(item) as Map<String, dynamic>;
          final id = (d['id'] ?? d['uid'] ?? '').toString();
          if (isRealDoctorAccount(d, id)) {
            decoded.add(d);
          }
        } catch (_) {}
      }

      final docEmail = doctor['email'];

      decoded.removeWhere((d) {
        if (docId.isNotEmpty && (d['id'] == docId || d['uid'] == docId)) {
          return true;
        }
        if (docEmail != null && docEmail.isNotEmpty && d['email'] == docEmail) {
          return true;
        }
        return false;
      });

      decoded.add(doctor);

      final encoded = decoded.map((e) => jsonEncode(e)).toList();
      await prefs.setStringList(_prefKeyDoctors, encoded);
    } catch (e) {
      debugPrint('[DoctorService] Gagal menyimpan cache dokter: $e');
    }
  }

  /// Ambil daftar dokter dari SharedPreferences (hanya akun asli)
  Future<List<Map<String, dynamic>>> getCachedDoctors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList(_prefKeyDoctors) ?? [];
      final List<Map<String, dynamic>> result = [];
      for (final item in list) {
        try {
          final d = jsonDecode(item) as Map<String, dynamic>;
          final id = (d['id'] ?? d['uid'] ?? '').toString();
          if (isRealDoctorAccount(d, id)) {
            result.add(d);
          }
        } catch (_) {}
      }
      return result;
    } catch (e) {
      debugPrint('[DoctorService] Gagal membaca cache dokter: $e');
      return [];
    }
  }

  /// Simpan dokter ke Firestore (koleksi users dan doctors) sekaligus cache lokal
  Future<void> registerOrUpdateDoctorInFirestore(
    Map<String, dynamic> doctorData, {
    String? uid,
  }) async {
    final doctorId = uid ?? doctorData['uid'] ?? doctorData['id'];
    if (doctorId == null || doctorId.toString().isEmpty) return;

    final normalized = normalizeDoctorData(
      id: doctorId.toString(),
      data: doctorData,
    );

    // Simpan ke cache lokal langsung
    await cacheDoctor(normalized);

    // Simpan ke Firestore users/{uid} dan doctors/{uid}
    try {
      final payload = {
        'nama': normalized['nama'],
        'email': normalized['email'],
        'telepon': normalized['telepon'],
        'role': 'doctor',
        'spesialis': normalized['spesialis'],
        'sip': normalized['sip'],
        'lokasi': normalized['lokasi'],
        'pengalaman': normalized['pengalaman'],
        'tentang': normalized['tentang'],
        'foto': normalized['foto'],
        'isOnline': normalized['isOnline'],
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(doctorId.toString())
          .set(payload, SetOptions(merge: true));

      await _firestore
          .collection('doctors')
          .doc(doctorId.toString())
          .set(payload, SetOptions(merge: true));

      debugPrint(
        '[DoctorService] Sukses update dokter di Firestore: $doctorId (${normalized['nama']})',
      );
    } catch (e) {
      debugPrint('[DoctorService] Peringatan: Firestore write error: $e');
    }
  }

  /// Perbarui profil dokter (Nama, SIP, Spesialisasi, Lokasi, Bio, Telepon)
  Future<bool> updateDoctorProfile({
    required String uid,
    required String nama,
    required String sip,
    required String spesialis,
    required String lokasi,
    required String pengalaman,
    required String telepon,
    required String tentang,
    String? foto,
  }) async {
    try {
      String formattedName = nama.trim();
      if (!formattedName.toLowerCase().startsWith('dr.') &&
          !formattedName.toLowerCase().startsWith('dr ')) {
        formattedName = 'dr. $formattedName';
      }

      final payload = <String, dynamic>{
        'nama': formattedName,
        'sip': sip.trim(),
        'spesialis': spesialis.trim(),
        'lokasi': lokasi.trim(),
        'pengalaman': pengalaman.trim(),
        'telepon': telepon.trim(),
        'noWa': telepon.trim(),
        'whatsapp': telepon.trim(),
        'tentang': tentang.trim(),
        'role': 'doctor',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (foto != null && foto.isNotEmpty) {
        payload['foto'] = foto;
      }

      // Update Firestore users & doctors
      await _firestore
          .collection('users')
          .doc(uid)
          .set(payload, SetOptions(merge: true));

      await _firestore
          .collection('doctors')
          .doc(uid)
          .set(payload, SetOptions(merge: true));

      // Update Firebase Auth display name jika user sedang login
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        await currentUser.updateDisplayName(formattedName);
      }

      // Update cache
      final cachedDoc = normalizeDoctorData(
        id: uid,
        data: {
          ...payload,
          'uid': uid,
          'email': currentUser?.email ?? '',
        },
      );
      await cacheDoctor(cachedDoc);

      return true;
    } catch (e) {
      debugPrint('[DoctorService] Gagal update profil dokter: $e');
      return false;
    }
  }

  /// Perbarui status Online/Offline dokter di Firestore & Cache
  Future<void> updateDoctorOnlineStatus({
    required String uid,
    required bool isOnline,
  }) async {
    try {
      final payload = {
        'isOnline': isOnline,
        'lastActiveAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(uid)
          .set(payload, SetOptions(merge: true));

      await _firestore
          .collection('doctors')
          .doc(uid)
          .set(payload, SetOptions(merge: true));

      // Update cache
      final cached = await getCachedDoctors();
      for (final doc in cached) {
        if (doc['id'] == uid || doc['uid'] == uid) {
          doc['isOnline'] = isOnline;
          await cacheDoctor(doc);
          break;
        }
      }
    } catch (e) {
      debugPrint('[DoctorService] Error updateDoctorOnlineStatus: $e');
    }
  }

  /// Perbarui foto profil dokter (Base64 atau URL)
  Future<bool> updateDoctorPhoto({
    required String uid,
    required String photoData,
  }) async {
    try {
      final payload = {
        'foto': photoData,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(uid)
          .set(payload, SetOptions(merge: true));

      await _firestore
          .collection('doctors')
          .doc(uid)
          .set(payload, SetOptions(merge: true));

      // Update cache
      final cached = await getCachedDoctors();
      for (final doc in cached) {
        if (doc['id'] == uid || doc['uid'] == uid) {
          doc['foto'] = photoData;
          await cacheDoctor(doc);
          break;
        }
      }

      return true;
    } catch (e) {
      debugPrint('[DoctorService] Error updateDoctorPhoto: $e');
      return false;
    }
  }

  /// Pastikan akun user saat ini ditandai sebagai role dokter
  Future<bool> ensureUserIsDoctor({
    required String uid,
    required String email,
    String? displayName,
  }) async {
    try {
      DocumentSnapshot<Map<String, dynamic>>? existingDoc;
      try {
        existingDoc = await _firestore.collection('users').doc(uid).get();
      } catch (_) {}

      final Map<String, dynamic> existingData =
          (existingDoc != null && existingDoc.exists && existingDoc.data() != null)
              ? existingDoc.data()!
              : {};

      String doctorName = displayName ?? existingData['nama'] ?? 'dr. Dokter HeartCare';
      if (!doctorName.toLowerCase().startsWith('dr.') &&
          !doctorName.toLowerCase().startsWith('dr ')) {
        doctorName = 'dr. $doctorName';
      }

      final normalized = normalizeDoctorData(
        id: uid,
        data: {
          ...existingData,
          'nama': doctorName,
          'email': email,
          'role': 'doctor',
          'isOnline': true,
        },
      );

      await registerOrUpdateDoctorInFirestore(normalized, uid: uid);
      return true;
    } catch (e) {
      debugPrint('[DoctorService] ensureUserIsDoctor error: $e');
      return false;
    }
  }

  /// Promosikan user yang sedang login saat ini menjadi dokter
  Future<bool> promoteCurrentUserToDoctor() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    return ensureUserIsDoctor(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  /// Helper serbaguna untuk menampilkan foto dokter (Base64, Network, Asset, atau File)
  static Widget buildDoctorImage(
    String? photo, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    bool isDark = false,
  }) {
    if (photo == null || photo.trim().isEmpty) {
      return Icon(
        Icons.person_rounded,
        size: width != null ? width * 0.6 : 36,
        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
      );
    }

    final trimmed = photo.trim();

    // 1. URL Internet (http/https)
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.person_rounded,
          size: width != null ? width * 0.6 : 36,
          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
        ),
      );
    }

    // 2. Base64 Image
    if (trimmed.startsWith('data:image') || trimmed.length > 200) {
      try {
        String cleanBase64 = trimmed;
        if (cleanBase64.contains(',')) {
          cleanBase64 = cleanBase64.split(',').last;
        }
        final bytes = base64Decode(cleanBase64);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.person_rounded,
            size: width != null ? width * 0.6 : 36,
            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
          ),
        );
      } catch (_) {}
    }

    // 3. Asset Image
    if (trimmed.startsWith('assets/')) {
      return Image.asset(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.person_rounded,
          size: width != null ? width * 0.6 : 36,
          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
        ),
      );
    }

    // 4. File lokal di perangkat (jika bukan Web)
    if (!kIsWeb) {
      try {
        final file = File(trimmed);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.person_rounded,
              size: width != null ? width * 0.6 : 36,
              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
            ),
          );
        }
      } catch (_) {}
    }

    // Default icon
    return Icon(
      Icons.person_rounded,
      size: width != null ? width * 0.6 : 36,
      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
    );
  }
}
