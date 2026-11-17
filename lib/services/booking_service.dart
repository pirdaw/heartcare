import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model untuk menyimpan data booking jadwal konsultasi dokter
class DoctorBooking {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorPhoto;
  final String dateKey; // Format: "YYYY-MM-DD" atau string tanggal unik
  final String dateDisplay; // Contoh: "Rabu, 3 September 2026"
  final int startMinutes; // Menit sejak tengah malam (contoh: 08:00 = 480)
  final int endMinutes; // Menit sejak tengah malam (contoh: 08:30 = 510)
  final int durationMinutes; // 15, 30, 45, atau 60
  final String timeSlot; // Contoh: "08.00–08.30"
  final String status; // "booked", "completed", "cancelled"
  final String? patientName;
  final DateTime createdAt;

  DoctorBooking({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorPhoto,
    required this.dateKey,
    required this.dateDisplay,
    required this.startMinutes,
    required this.endMinutes,
    required this.durationMinutes,
    required this.timeSlot,
    this.status = 'booked',
    this.patientName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'doctorPhoto': doctorPhoto,
      'dateKey': dateKey,
      'dateDisplay': dateDisplay,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'durationMinutes': durationMinutes,
      'timeSlot': timeSlot,
      'status': status,
      'patientName': patientName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DoctorBooking.fromMap(Map<String, dynamic> map) {
    return DoctorBooking(
      id: map['id'] as String? ?? '',
      doctorId: map['doctorId'] as String? ?? '',
      doctorName: map['doctorName'] as String? ?? '',
      doctorSpecialty: map['doctorSpecialty'] as String? ?? '',
      doctorPhoto: map['doctorPhoto'] as String? ?? '',
      dateKey: map['dateKey'] as String? ?? '',
      dateDisplay: map['dateDisplay'] as String? ?? '',
      startMinutes: (map['startMinutes'] as num?)?.toInt() ?? 0,
      endMinutes: (map['endMinutes'] as num?)?.toInt() ?? 0,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 30,
      timeSlot: map['timeSlot'] as String? ?? '',
      status: map['status'] as String? ?? 'booked',
      patientName: map['patientName'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Model representasi slot waktu konsultasi pada UI
class TimeSlotItem {
  final int startMinutes;
  final int endMinutes;
  final String label; // "08.00–08.30"
  final String startTime; // "08.00"
  final String endTime; // "08.30"
  final String period; // "Pagi", "Siang", "Sore"
  final bool isBooked;

  const TimeSlotItem({
    required this.startMinutes,
    required this.endMinutes,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.period,
    required this.isBooked,
  });
}

/// Layanan manajemen pemesanan jadwal dokter dan pencegahan tabrakan jadwal
class BookingService extends ChangeNotifier {
  BookingService._();
  static final BookingService instance = BookingService._();

  static const String _prefKey = 'heartcare_doctor_bookings_v2';
  final List<DoctorBooking> _bookings = [];
  bool _initialized = false;

  List<DoctorBooking> get bookings => List.unmodifiable(_bookings);

  /// Helper konversi menit sejak 00:00 ke format string jam (HH.mm)
  static String formatMinutes(int minutes) {
    final int h = minutes ~/ 60;
    final int m = minutes % 60;
    final String hStr = h.toString().padLeft(2, '0');
    final String mStr = m.toString().padLeft(2, '0');
    return '$hStr.$mStr';
  }

  /// Mengecek apakah dua rentang waktu saling bertabrakan (overlap)
  /// Matematika overlap: max(startA, startB) < min(endA, endB)
  static bool checkOverlap(int startA, int endA, int startB, int endB) {
    final int maxStart = startA > startB ? startA : startB;
    final int minEnd = endA < endB ? endA : endB;
    return maxStart < minEnd;
  }

  /// Inisialisasi data dari lokal cache dan sediakan seed demo awal
  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? rawJson = prefs.getString(_prefKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final List decoded = jsonDecode(rawJson) as List;
        _bookings.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _bookings.add(DoctorBooking.fromMap(item));
          } else if (item is Map) {
            _bookings.add(DoctorBooking.fromMap(Map<String, dynamic>.from(item)));
          }
        }
      } else {
        _seedDefaultBookings();
        await _persist();
      }
    } catch (e) {
      debugPrint('[BookingService] Gagal memuat data booking: $e');
      if (_bookings.isEmpty) {
        _seedDefaultBookings();
      }
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  /// Seed contoh slot yang sudah terisi agar pasien langsung melihat status 'Sudah Dibooking'
  void _seedDefaultBookings() {
    _bookings.addAll([
      DoctorBooking(
        id: 'seed_booked_morning',
        doctorId: '', // Berlaku umum untuk demo awal
        doctorName: 'dr. Nurlitta Dwi',
        doctorSpecialty: 'Spesialis Jantung',
        doctorPhoto: 'assets/images/dokter_nurlitta.jpg',
        dateKey: 'default',
        dateDisplay: 'Contoh Booking Terjadwal',
        startMinutes: 540, // 09:00
        endMinutes: 570,   // 09:30 (30 Menit)
        durationMinutes: 30,
        timeSlot: '09.00–09.30',
        status: 'booked',
        patientName: 'Pasien Lain',
      ),
      DoctorBooking(
        id: 'seed_booked_afternoon',
        doctorId: '',
        doctorName: 'dr. Nurlitta Dwi',
        doctorSpecialty: 'Spesialis Jantung',
        doctorPhoto: 'assets/images/dokter_nurlitta.jpg',
        dateKey: 'default',
        dateDisplay: 'Contoh Booking Terjadwal',
        startMinutes: 840, // 14:00
        endMinutes: 900,   // 15:00 (60 Menit)
        durationMinutes: 60,
        timeSlot: '14.00–15.00',
        status: 'booked',
        patientName: 'Pasien Lain',
      ),
    ]);
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _bookings.map((b) => b.toMap()).toList();
      await prefs.setString(_prefKey, jsonEncode(list));
    } catch (e) {
      debugPrint('[BookingService] Gagal menyimpan local booking: $e');
    }
  }

  /// Cek apakah suatu slot bertabrakan dengan booking yang sudah ada
  bool isSlotBooked({
    String? doctorId,
    required String dateKey,
    required int startMinutes,
    required int endMinutes,
  }) {
    for (final booking in _bookings) {
      if (booking.status != 'booked') continue;

      // Jika booking terkait spesifik dokter, cek kesesuaian dokterId
      if (doctorId != null &&
          doctorId.isNotEmpty &&
          booking.doctorId.isNotEmpty &&
          booking.doctorId != doctorId) {
        continue;
      }

      // Cek kesesuaian tanggal
      final bool matchesDate = booking.dateKey == 'default' ||
          booking.dateKey == dateKey ||
          booking.dateKey.contains(dateKey) ||
          dateKey.contains(booking.dateKey);

      if (matchesDate) {
        if (checkOverlap(startMinutes, endMinutes, booking.startMinutes, booking.endMinutes)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Generate daftar slot waktu berdasarkan durasi per sesi yang dipilih pasien
  /// Periode:
  /// - Pagi  : 08.00 s/d 11.30 (480 - 690 menit)
  /// - Siang : 13.00 s/d 15.30 (780 - 930 menit)
  /// - Sore  : 16.00 s/d 18.00 (960 - 1080 menit)
  List<TimeSlotItem> generateSlots({
    required int durationMinutes,
    String? doctorId,
    required String dateKey,
  }) {
    final List<TimeSlotItem> result = [];

    final periods = [
      {'name': 'Pagi', 'start': 480, 'end': 690},
      {'name': 'Siang', 'start': 780, 'end': 930},
      {'name': 'Sore', 'start': 960, 'end': 1080},
    ];

    for (final period in periods) {
      final String periodName = period['name'] as String;
      final int pStart = period['start'] as int;
      final int pEnd = period['end'] as int;

      int current = pStart;
      while (current + durationMinutes <= pEnd) {
        final int sStart = current;
        final int sEnd = current + durationMinutes;

        final String startFormatted = formatMinutes(sStart);
        final String endFormatted = formatMinutes(sEnd);
        final String label = '$startFormatted–$endFormatted';

        final bool booked = isSlotBooked(
          doctorId: doctorId,
          dateKey: dateKey,
          startMinutes: sStart,
          endMinutes: sEnd,
        );

        result.add(
          TimeSlotItem(
            startMinutes: sStart,
            endMinutes: sEnd,
            label: label,
            startTime: startFormatted,
            endTime: endFormatted,
            period: periodName,
            isBooked: booked,
          ),
        );

        current += durationMinutes;
      }
    }

    return result;
  }

  /// Melakukan konfirmasi booking baru dan mencegah tabrakan jadwal
  Future<bool> bookSlot({
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    required String doctorPhoto,
    required String dateKey,
    required String dateDisplay,
    required int startMinutes,
    required int endMinutes,
    required int durationMinutes,
    required String timeSlot,
    String? patientName,
  }) async {
    // Validasi tabrakan jadwal
    if (isSlotBooked(
      doctorId: doctorId,
      dateKey: dateKey,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
    )) {
      return false; // Gagal karena slot sudah terbooking atau bertabrakan
    }

    final booking = DoctorBooking(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      doctorPhoto: doctorPhoto,
      dateKey: dateKey,
      dateDisplay: dateDisplay,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      durationMinutes: durationMinutes,
      timeSlot: timeSlot,
      status: 'booked',
      patientName: patientName,
    );

    _bookings.add(booking);
    await _persist();
    notifyListeners();

    // Simpan ke Firestore jika koneksi tersedia
    try {
      await FirebaseFirestore.instance
          .collection('consultation_bookings')
          .doc(booking.id)
          .set(booking.toMap());
    } catch (_) {}

    return true;
  }
}
