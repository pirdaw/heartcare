import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Layanan terpusat untuk registrasi, sinkronisasi, dan penemuan akun dokter
/// dengan dukungan fail-safe: Firestore (users & doctors) + Cache Lokal (SharedPreferences).
class DoctorService {
  DoctorService._();
  static final DoctorService instance = DoctorService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _prefKeyDoctors = 'heartcare_registered_doctors_v2';

  /// Cek apakah suatu map data dokumen merupakan akun dokter
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
    final String telepon = (data['telepon'] as String? ?? '').trim();

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
      'role': 'doctor',
    };
  }

  /// Simpan dokter ke SharedPreferences agar selalu ada fallback instan offline
  Future<void> cacheDoctor(Map<String, dynamic> doctor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList(_prefKeyDoctors) ?? [];
      final List<Map<String, dynamic>> decoded = [];

      for (final item in list) {
        try {
          decoded.add(jsonDecode(item) as Map<String, dynamic>);
        } catch (_) {}
      }

      final docId = doctor['id'] ?? doctor['uid'];
      final docEmail = doctor['email'];

      decoded.removeWhere((d) {
        if (docId != null && (d['id'] == docId || d['uid'] == docId)) {
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

  /// Ambil daftar dokter dari SharedPreferences
  Future<List<Map<String, dynamic>>> getCachedDoctors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList(_prefKeyDoctors) ?? [];
      final List<Map<String, dynamic>> result = [];
      for (final item in list) {
        try {
          result.add(jsonDecode(item) as Map<String, dynamic>);
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

  /// Buat akun dokter uji coba cepat jika user ingin langsung menguji chat
  Future<Map<String, dynamic>> seedQuickTestDoctor({
    String nama = 'dr. Valent Pratama, Sp.JP',
    String spesialis = 'Spesialis Jantung & Pembuluh Darah',
    String email = 'dr.valent@heartcare.id',
  }) async {
    final doctorId = 'dr_valent_${DateTime.now().millisecondsSinceEpoch % 10000}';
    final normalized = normalizeDoctorData(
      id: doctorId,
      data: {
        'nama': nama,
        'email': email,
        'spesialis': spesialis,
        'telepon': '+62 812-9876-5432',
        'sip': 'SIP-9921/2026',
        'lokasi': 'Klinik Jantung HeartCare',
        'pengalaman': '10 tahun',
        'tentang':
            'Dokter Spesialis Jantung dan Pembuluh Darah berpengalaman. Siap memberikan diagnosis dan konsultasi kesehatan jantung komprehensif.',
        'foto': 'assets/images/dokter_nurlitta.jpg',
        'isOnline': true,
        'role': 'doctor',
      },
    );

    await registerOrUpdateDoctorInFirestore(normalized, uid: doctorId);
    return normalized;
  }
}
