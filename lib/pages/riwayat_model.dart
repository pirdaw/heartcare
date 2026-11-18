import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartcare/pages/Skrining/screening_model.dart';

enum RiwayatType { skrining, konsultasi }

class RiwayatItem {
  final String id;
  final RiwayatType type;
  final String date;
  final String status;
  final Color statusColor;
  final Color statusBgColor;
  final Color cardBgColor;
  final String title;

  // Khusus Riwayat Konsultasi Dokter
  final String? doctorName;
  final String? doctorImage;
  final String? doctorSpecialty;
  final String? hospital;
  final String? sipNumber;
  final String? consultationType;

  // Khusus Riwayat Skrining
  final ScreeningData? screeningData;
  final HeartRiskResult? riskResult;

  RiwayatItem({
    required this.id,
    required this.type,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusBgColor,
    required this.cardBgColor,
    required this.title,
    this.doctorName,
    this.doctorImage,
    this.doctorSpecialty,
    this.hospital,
    this.sipNumber,
    this.consultationType,
    this.screeningData,
    this.riskResult,
  });
}

class RiwayatService {
  static final RiwayatService _instance = RiwayatService._internal();
  factory RiwayatService() => _instance;
  RiwayatService._internal() {
    _initDefaultItems();
  }

  final List<RiwayatItem> _items = [];

  List<RiwayatItem> get items => List.unmodifiable(_items);

  void _initDefaultItems() {
    _items.clear();

    // 1. Riwayat Skrining 1 (TINGGI) - Berisi Hasil Skrining (bukan keluhan)
    final highScreeningData = ScreeningData(
      age: '52',
      gender: 'Laki-laki',
      chestPainType: 'Typical Angina',
      restingBloodPressure: '160',
      cholesterol: '280',
      fastingBloodSugar: 'Ya',
      restingEcg: 'Hypertrophy',
      maxHeartRate: '180',
      exerciseAngina: 'Ya',
      oldpeak: '2.5',
      stSlope: 'Downsloping (Menurun)',
      majorVessels: 2,
      thal: 'Reversible defect (Kelainan dapat diperbaiki)',
    );

    final highRiskResult = HeartRiskResult(
      level: RiskLevel.high,
      title: 'Tinggi',
      subtitle: 'Terdapat indikator klinis risiko kardiovaskular tinggi',
      description:
          'Berdasarkan evaluasi terhadap 11 parameter kesehatan yang dimasukkan, kondisi jantung Anda tergolong memiliki risiko tinggi. Terdapat tekanan darah tinggi, kolesterol meningkat, dan respon segmen ST yang memerlukan atensi spesialis segera.',
      advice:
          'Segera buat jadwal konsultasi tatap muka dengan Dokter Spesialis Jantung (Sp.JP) atau kunjungi fasilitas kesehatan terdekat untuk pemeriksaan EKG 12-lead dan Echocardiogram mendalam.',
      statusColor: const Color(0xFFEF4444),
      backgroundColor: const Color(0xFFFEE2E2),
    );

    _items.add(
      RiwayatItem(
        id: 'riwayat-1',
        type: RiwayatType.skrining,
        date: '12 November 2025 • 10.59',
        status: 'TINGGI',
        statusColor: const Color(0xFFEF4444),
        statusBgColor: const Color(0xFFFFE4E6),
        cardBgColor: const Color(0xFFFFF1F2),
        title: 'Hasil Skrining: Risiko Tinggi',
        screeningData: highScreeningData,
        riskResult: highRiskResult,
      ),
    );

    // 2. Riwayat Konsultasi 2 (SELESAI)
    _items.add(
      RiwayatItem(
        id: 'riwayat-2',
        type: RiwayatType.konsultasi,
        date: '06 Agustus 2025 • 17.23',
        status: 'SELESAI',
        statusColor: const Color(0xFF0284C7),
        statusBgColor: const Color(0xFFE0F2FE),
        cardBgColor: const Color(0xFFF8FAFC),
        title: 'Konsultasi online',
        doctorName: 'dr. Nurlitta Dwi',
        doctorImage: 'assets/images/dokter_nurlitta.jpg',
        doctorSpecialty: 'Spesialis Jantung dan Pembuluh Darah (Sp.JP)',
        hospital: 'RS Harapan Jantung, Jember',
        sipNumber: '1804/SIP/2021',
        consultationType: 'Konsultasi Online via Chat',
      ),
    );

    // 3. Riwayat Skrining 3 (RENDAH) - Berisi Hasil Skrining (bukan keluhan)
    final lowScreeningData = ScreeningData(
      age: '24',
      gender: 'Perempuan',
      chestPainType: 'Asymptomatic',
      restingBloodPressure: '115',
      cholesterol: '175',
      fastingBloodSugar: 'Tidak',
      restingEcg: 'Normal',
      maxHeartRate: '155',
      exerciseAngina: 'Tidak',
      oldpeak: '0.0',
      stSlope: 'Upsloping (Meningkat)',
      majorVessels: 0,
      thal: 'Normal',
    );

    final lowRiskResult = HeartRiskResult(
      level: RiskLevel.low,
      title: 'Rendah',
      subtitle: 'Kondisi kesehatan kardiovaskular dalam batas aman',
      description:
          'Evaluasi seluruh parameter menunjukkan kondisi jantung dan pembuluh darah Anda sangat baik. Tekanan darah normal, profil kolesterol optimal, dan tidak ada indikator gangguan suplai oksigen ke otot jantung.',
      advice:
          'Pertahankan gaya hidup aktif dengan olahraga aerobik ringan-sedang minimal 150 menit per minggu, perbanyak konsumsi serat sayur-buah, dan hindari paparan asap rokok.',
      statusColor: const Color(0xFF16A34A),
      backgroundColor: const Color(0xFFDCFCE7),
    );

    _items.add(
      RiwayatItem(
        id: 'riwayat-3',
        type: RiwayatType.skrining,
        date: '12 April 2025 • 10.59',
        status: 'RENDAH',
        statusColor: const Color(0xFF16A34A),
        statusBgColor: const Color(0xFFDCFCE7),
        cardBgColor: const Color(0xFFF0FDF4),
        title: 'Hasil Skrining: Risiko Rendah',
        screeningData: lowScreeningData,
        riskResult: lowRiskResult,
      ),
    );
  }

  void addScreeningRecord({
    required ScreeningData data,
    required HeartRiskResult result,
  }) {
    final now = DateTime.now();
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dateStr =
        '${now.day} ${months[now.month - 1]} ${now.year} • ${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';

    final isHigh = result.level == RiskLevel.high;
    final isModerate = result.level == RiskLevel.moderate;

    final statusText = isHigh
        ? 'TINGGI'
        : (isModerate ? 'SEDANG' : 'RENDAH');

    final statusColor = isHigh
        ? const Color(0xFFEF4444)
        : (isModerate ? const Color(0xFFD97706) : const Color(0xFF16A34A));

    final statusBg = isHigh
        ? const Color(0xFFFFE4E6)
        : (isModerate ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7));

    final cardBg = isHigh
        ? const Color(0xFFFFF1F2)
        : (isModerate ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4));

    final resultTitle = isHigh
        ? 'Hasil Skrining: Risiko Tinggi'
        : (isModerate
            ? 'Hasil Skrining: Risiko Sedang'
            : 'Hasil Skrining: Risiko Rendah');

    final newItem = RiwayatItem(
      id: 'riwayat-${DateTime.now().millisecondsSinceEpoch}',
      type: RiwayatType.skrining,
      date: dateStr,
      status: statusText,
      statusColor: statusColor,
      statusBgColor: statusBg,
      cardBgColor: cardBg,
      title: resultTitle,
      screeningData: data,
      riskResult: result,
    );

    // Sisipkan di posisi teratas riwayat
    _items.insert(0, newItem);
    _latestScreeningData = data;
    _latestRiskResult = result;
    _saveLatestToLocal(data, result, newItem);
    _saveToFirestore(data, result, newItem);
  }

  ScreeningData? _latestScreeningData;
  HeartRiskResult? _latestRiskResult;

  ScreeningData? get latestScreeningData {
    if (_latestScreeningData != null) return _latestScreeningData;
    for (final it in _items) {
      if (it.type == RiwayatType.skrining && it.screeningData != null) {
        return it.screeningData;
      }
    }
    return null;
  }

  HeartRiskResult? get latestRiskResult {
    if (_latestRiskResult != null) return _latestRiskResult;
    for (final it in _items) {
      if (it.type == RiwayatType.skrining && it.riskResult != null) {
        return it.riskResult;
      }
    }
    return null;
  }

  RiwayatItem? getLatestScreeningItem() {
    for (final it in _items) {
      if (it.type == RiwayatType.skrining && it.screeningData != null) {
        return it;
      }
    }
    return null;
  }

  Future<void> _saveLatestToLocal(
    ScreeningData data,
    HeartRiskResult result,
    RiwayatItem item,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('heartcare_latest_screening_data', data.toJson());
      await prefs.setString('heartcare_latest_screening_result', result.toJson());
      await prefs.setString('heartcare_latest_screening_date', item.date);
    } catch (e) {
      debugPrint('[RiwayatService] Error saving to local: $e');
    }
  }

  Future<void> _saveToFirestore(
    ScreeningData data,
    HeartRiskResult result,
    RiwayatItem item,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('screenings')
          .doc(item.id)
          .set({
        'id': item.id,
        'userId': user.uid,
        'date': item.date,
        'timestamp': FieldValue.serverTimestamp(),
        'status': item.status,
        'title': item.title,
        'riskLevel': result.level.name,
        'riskProbability': result.probability,
        'screeningData': data.toMap(),
        'riskResult': result.toMap(),
      });
    } catch (e) {
      debugPrint('[RiwayatService] Error saving to Firestore: $e');
    }
  }
}
