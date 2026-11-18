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
  final String dateKey; // Format: "YYYY-MM-DD" e.g. "2026-09-02"
  final String dateDisplay; // Contoh: "Sel, 2 September 2026"
  final int startMinutes; // Menit sejak tengah malam (contoh: 08:00 = 480)
  final int endMinutes; // Menit sejak tengah malam (contoh: 08:30 = 510)
  final int durationMinutes; // 15, 30, 45, atau 60
  final String timeSlot; // Contoh: "08.00–08.30"
  final String status; // "Menunggu Konfirmasi", "Diterima", "Ditolak", "Selesai", "Dibatalkan"
  final String? patientId;
  final String? patientName;
  final String? patientPhoto;
  final String? patientPhone;
  final String? rejectionReason;
  final String? notes;
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
    this.status = 'Menunggu Konfirmasi',
    this.patientId,
    this.patientName,
    this.patientPhoto,
    this.patientPhone,
    this.rejectionReason,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  DoctorBooking copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialty,
    String? doctorPhoto,
    String? dateKey,
    String? dateDisplay,
    int? startMinutes,
    int? endMinutes,
    int? durationMinutes,
    String? timeSlot,
    String? status,
    String? patientId,
    String? patientName,
    String? patientPhoto,
    String? patientPhone,
    String? rejectionReason,
    String? notes,
    DateTime? createdAt,
  }) {
    return DoctorBooking(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorPhoto: doctorPhoto ?? this.doctorPhoto,
      dateKey: dateKey ?? this.dateKey,
      dateDisplay: dateDisplay ?? this.dateDisplay,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhoto: patientPhoto ?? this.patientPhoto,
      patientPhone: patientPhone ?? this.patientPhone,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory DoctorBooking.fromJson(Map<String, dynamic> json) =>
      DoctorBooking.fromMap(json);

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
      'patientId': patientId,
      'patientName': patientName,
      'patientPhoto': patientPhoto,
      'patientPhone': patientPhone,
      'rejectionReason': rejectionReason,
      'notes': notes,
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
      status: map['status'] as String? ?? 'Menunggu Konfirmasi',
      patientId: map['patientId'] as String?,
      patientName: map['patientName'] as String?,
      patientPhoto: map['patientPhoto'] as String?,
      patientPhone: map['patientPhone'] as String?,
      rejectionReason: map['rejectionReason'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Model jadwal praktik yang ditentukan oleh dokter sendiri
class DoctorPracticeSchedule {
  final String id;
  final String doctorId;
  final String doctorName;
  final String dateKey; // Format: "YYYY-MM-DD" e.g. "2026-09-02"
  final String dateDisplay; // "Sel, 2 September 2026"
  final String dayName; // "Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"
  final String dayNumber; // "1", "2", "3", dst.
  final int startMinutes; // default 480 (08.00)
  final int endMinutes; // default 720 (12.00)
  final int durationMinutes; // 15, 30, 45, atau 60
  final bool hasBreak;
  final int? breakStartMinutes; // e.g. 720 (12.00)
  final int? breakEndMinutes; // e.g. 780 (13.00)
  final bool isActive; // true = Praktik dibuka, false = Libur / Ditutup
  final DateTime createdAt;
  final DateTime? updatedAt;

  DoctorPracticeSchedule({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.dateKey,
    required this.dateDisplay,
    this.dayName = '',
    this.dayNumber = '',
    this.startMinutes = 480,
    this.endMinutes = 720,
    this.durationMinutes = 30,
    this.hasBreak = false,
    this.breakStartMinutes,
    this.breakEndMinutes,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  DoctorPracticeSchedule copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? dateKey,
    String? dateDisplay,
    String? dayName,
    String? dayNumber,
    int? startMinutes,
    int? endMinutes,
    int? durationMinutes,
    bool? hasBreak,
    int? breakStartMinutes,
    int? breakEndMinutes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorPracticeSchedule(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      dateKey: dateKey ?? this.dateKey,
      dateDisplay: dateDisplay ?? this.dateDisplay,
      dayName: dayName ?? this.dayName,
      dayNumber: dayNumber ?? this.dayNumber,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      hasBreak: hasBreak ?? this.hasBreak,
      breakStartMinutes: breakStartMinutes ?? this.breakStartMinutes,
      breakEndMinutes: breakEndMinutes ?? this.breakEndMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory DoctorPracticeSchedule.fromJson(Map<String, dynamic> json) =>
      DoctorPracticeSchedule.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'dateKey': dateKey,
      'dateDisplay': dateDisplay,
      'dayName': dayName,
      'dayNumber': dayNumber,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'durationMinutes': durationMinutes,
      'hasBreak': hasBreak,
      'breakStartMinutes': breakStartMinutes,
      'breakEndMinutes': breakEndMinutes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory DoctorPracticeSchedule.fromMap(Map<String, dynamic> map) {
    return DoctorPracticeSchedule(
      id: map['id'] as String? ?? '',
      doctorId: map['doctorId'] as String? ?? '',
      doctorName: map['doctorName'] as String? ?? '',
      dateKey: map['dateKey'] as String? ?? '',
      dateDisplay: map['dateDisplay'] as String? ?? '',
      dayName: map['dayName'] as String? ?? '',
      dayNumber: map['dayNumber'] as String? ?? '',
      startMinutes: (map['startMinutes'] as num?)?.toInt() ?? 480,
      endMinutes: (map['endMinutes'] as num?)?.toInt() ?? 720,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 30,
      hasBreak: map['hasBreak'] as bool? ?? false,
      breakStartMinutes: (map['breakStartMinutes'] as num?)?.toInt(),
      breakEndMinutes: (map['breakEndMinutes'] as num?)?.toInt(),
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
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
  final bool isBreak;
  final DoctorBooking? booking;

  const TimeSlotItem({
    required this.startMinutes,
    required this.endMinutes,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.period,
    required this.isBooked,
    this.isBreak = false,
    this.booking,
  });
}

/// Layanan terpusat manajemen jadwal praktik dokter dan booking pasien
class BookingService extends ChangeNotifier {
  BookingService._();
  static final BookingService instance = BookingService._();

  static const String _prefKeyBookings = 'heartcare_doctor_bookings_v2';
  static const String _prefKeySchedules = 'heartcare_doctor_schedules_v2';

  final List<DoctorBooking> _bookings = [];
  final List<DoctorPracticeSchedule> _schedules = [];
  bool _initialized = false;

  List<DoctorBooking> get bookings => List.unmodifiable(_bookings);
  List<DoctorPracticeSchedule> get schedules => List.unmodifiable(_schedules);

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

      // 1. Muat data booking
      final String? rawBookings = prefs.getString(_prefKeyBookings);
      if (rawBookings != null && rawBookings.isNotEmpty) {
        final List decoded = jsonDecode(rawBookings) as List;
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
        await _persistBookings();
      }

      // 2. Muat data jadwal praktik dokter
      final String? rawSchedules = prefs.getString(_prefKeySchedules);
      if (rawSchedules != null && rawSchedules.isNotEmpty) {
        final List decoded = jsonDecode(rawSchedules) as List;
        _schedules.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _schedules.add(DoctorPracticeSchedule.fromMap(item));
          } else if (item is Map) {
            _schedules.add(DoctorPracticeSchedule.fromMap(Map<String, dynamic>.from(item)));
          }
        }
      } else {
        _seedDefaultSchedules();
        await _persistSchedules();
      }

      // 3. Sinkronkan ke/dari Firestore di background jika online
      _listenToFirestoreBookings();
      _listenToFirestoreSchedules();
    } catch (e) {
      debugPrint('[BookingService] Inisialisasi: $e');
      if (_bookings.isEmpty) _seedDefaultBookings();
      if (_schedules.isEmpty) _seedDefaultSchedules();
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  /// Seed data jadwal praktik dokter default (September 2026: Sen 1 s/d Min 7)
  void _seedDefaultSchedules() {
    _schedules.clear();
    final defaultDays = [
      {'dateKey': '2026-09-01', 'full': 'Sen, 1 September 2026', 'day': 'Sen', 'num': '1', 'start': 480, 'end': 720, 'dur': 30, 'active': true},
      {'dateKey': '2026-09-02', 'full': 'Sel, 2 September 2026', 'day': 'Sel', 'num': '2', 'start': 480, 'end': 720, 'dur': 30, 'active': true},
      {'dateKey': '2026-09-03', 'full': 'Rab, 3 September 2026', 'day': 'Rab', 'num': '3', 'start': 480, 'end': 720, 'dur': 30, 'active': true},
      {'dateKey': '2026-09-04', 'full': 'Kam, 4 September 2026', 'day': 'Kam', 'num': '4', 'start': 480, 'end': 720, 'dur': 30, 'active': true},
      {'dateKey': '2026-09-05', 'full': 'Jum, 5 September 2026', 'day': 'Jum', 'num': '5', 'start': 480, 'end': 690, 'dur': 30, 'active': true},
      {'dateKey': '2026-09-06', 'full': 'Sab, 6 September 2026', 'day': 'Sab', 'num': '6', 'start': 540, 'end': 720, 'dur': 30, 'active': true},
      {'dateKey': '2026-09-07', 'full': 'Min, 7 September 2026', 'day': 'Min', 'num': '7', 'start': 480, 'end': 720, 'dur': 30, 'active': false},
    ];

    for (final d in defaultDays) {
      _schedules.add(
        DoctorPracticeSchedule(
          id: 'sched_default_${d['dateKey']}',
          doctorId: '', // Berlaku umum sebagai template awal
          doctorName: 'dr. Asya Catherine',
          dateKey: d['dateKey'] as String,
          dateDisplay: d['full'] as String,
          dayName: d['day'] as String,
          dayNumber: d['num'] as String,
          startMinutes: d['start'] as int,
          endMinutes: d['end'] as int,
          durationMinutes: d['dur'] as int,
          hasBreak: false,
          isActive: d['active'] as bool,
        ),
      );
    }
  }

  /// Seed data booking default untuk demo interaktif
  void _seedDefaultBookings() {
    _bookings.clear();
    _bookings.addAll([
      // 1. Permintaan booking yang MENUNGGU KONFIRMASI DOKTER
      DoctorBooking(
        id: 'booking_pending_1',
        doctorId: '',
        doctorName: 'dr. Asya Catherine',
        doctorSpecialty: 'Spesialis Jantung & Kardiovaskular',
        doctorPhoto: 'assets/images/dokter_asya.jpg',
        dateKey: '2026-09-02',
        dateDisplay: 'Sel, 2 September 2026',
        startMinutes: 480, // 08:00
        endMinutes: 510,   // 08:30
        durationMinutes: 30,
        timeSlot: '08.00–08.30',
        status: 'Menunggu Konfirmasi',
        patientId: 'patient_budi_01',
        patientName: 'Budi Santoso',
        patientPhoto: '',
        patientPhone: '081234567890',
        notes: 'Keluhan dada kiri sering berdebar saat olahraga pagi.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      // 2. Slot yang SUDAH DITERIMA (Booking Aktif)
      DoctorBooking(
        id: 'seed_booked_morning',
        doctorId: '',
        doctorName: 'dr. Asya Catherine',
        doctorSpecialty: 'Spesialis Jantung',
        doctorPhoto: 'assets/images/dokter_asya.jpg',
        dateKey: '2026-09-02',
        dateDisplay: 'Sel, 2 September 2026',
        startMinutes: 540, // 09:00
        endMinutes: 570,   // 09:30
        durationMinutes: 30,
        timeSlot: '09.00–09.30',
        status: 'Diterima',
        patientId: 'patient_siti_02',
        patientName: 'Siti Rahmawati',
        patientPhoto: '',
        patientPhone: '082198765432',
        notes: 'Konsultasi lanjutan hasil tensi darah tinggi.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      // 3. Konsultasi yang SUDAH SELESAI
      DoctorBooking(
        id: 'booking_completed_1',
        doctorId: '',
        doctorName: 'dr. Asya Catherine',
        doctorSpecialty: 'Spesialis Jantung',
        doctorPhoto: 'assets/images/dokter_asya.jpg',
        dateKey: '2026-09-01',
        dateDisplay: 'Sen, 1 September 2026',
        startMinutes: 600, // 10:00
        endMinutes: 630,   // 10:30
        durationMinutes: 30,
        timeSlot: '10.00–10.30',
        status: 'Selesai',
        patientId: 'patient_ahmad_03',
        patientName: 'Ahmad Fauzi',
        patientPhoto: '',
        patientPhone: '085678901234',
        notes: 'Konsultasi pencegahan aritmia pasca skrining.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
  }

  Future<void> _persistBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _bookings.map((b) => b.toMap()).toList();
      await prefs.setString(_prefKeyBookings, jsonEncode(list));
    } catch (e) {
      debugPrint('[BookingService] Gagal simpan booking lokal: $e');
    }
  }

  Future<void> _persistSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _schedules.map((s) => s.toMap()).toList();
      await prefs.setString(_prefKeySchedules, jsonEncode(list));
    } catch (e) {
      debugPrint('[BookingService] Gagal simpan jadwal lokal: $e');
    }
  }

  void _listenToFirestoreBookings() {
    try {
      FirebaseFirestore.instance
          .collection('consultation_bookings')
          .snapshots()
          .listen((snapshot) {
        bool changed = false;
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final booking = DoctorBooking.fromMap(data);
          final idx = _bookings.indexWhere((b) => b.id == booking.id);
          if (idx >= 0) {
            _bookings[idx] = booking;
            changed = true;
          } else {
            _bookings.insert(0, booking);
            changed = true;
          }
        }
        if (changed) {
          _persistBookings();
          notifyListeners();
        }
      }, onError: (_) {});
    } catch (_) {}
  }

  void _listenToFirestoreSchedules() {
    try {
      FirebaseFirestore.instance
          .collection('doctor_schedules')
          .snapshots()
          .listen((snapshot) {
        bool changed = false;
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final schedule = DoctorPracticeSchedule.fromMap(data);
          final idx = _schedules.indexWhere((s) => s.id == schedule.id);
          if (idx >= 0) {
            _schedules[idx] = schedule;
            changed = true;
          } else {
            _schedules.add(schedule);
            changed = true;
          }
        }
        if (changed) {
          _persistSchedules();
          notifyListeners();
        }
      }, onError: (_) {});
    } catch (_) {}
  }

  // ==========================================================================
  // MANAJEMEN BOOKING PASIEN
  // ==========================================================================

  /// Cek apakah suatu slot bertabrakan dengan booking aktif yang belum dibatalkan/ditolak
  bool isSlotBooked({
    String? doctorId,
    required String dateKey,
    required int startMinutes,
    required int endMinutes,
  }) {
    for (final booking in _bookings) {
      final status = booking.status.trim().toLowerCase();

      // Hanya status 'Menunggu Konfirmasi', 'Diterima', atau legacy 'booked' yang mengunci slot
      final bool isBlocking = status == 'menunggu konfirmasi' ||
          status == 'diterima' ||
          status == 'booked' ||
          status == 'pending' ||
          status == 'accepted';

      if (!isBlocking) continue;

      // Filter kesesuaian dokter
      if (doctorId != null &&
          doctorId.isNotEmpty &&
          booking.doctorId.isNotEmpty &&
          booking.doctorId != doctorId) {
        continue;
      }

      // Filter kesesuaian tanggal
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

  /// Ambil objek booking yang menduduki slot tertentu (jika ada)
  DoctorBooking? getBookingForSlot({
    String? doctorId,
    required String dateKey,
    required int startMinutes,
    required int endMinutes,
  }) {
    for (final booking in _bookings) {
      final status = booking.status.trim().toLowerCase();
      final bool isBlocking = status == 'menunggu konfirmasi' ||
          status == 'diterima' ||
          status == 'booked' ||
          status == 'pending' ||
          status == 'accepted';

      if (!isBlocking) continue;

      if (doctorId != null &&
          doctorId.isNotEmpty &&
          booking.doctorId.isNotEmpty &&
          booking.doctorId != doctorId) {
        continue;
      }

      final bool matchesDate = booking.dateKey == 'default' ||
          booking.dateKey == dateKey ||
          booking.dateKey.contains(dateKey) ||
          dateKey.contains(booking.dateKey);

      if (matchesDate) {
        if (checkOverlap(startMinutes, endMinutes, booking.startMinutes, booking.endMinutes)) {
          return booking;
        }
      }
    }
    return null;
  }

  /// Ambil daftar booking khusus dokter tertentu (diurutkan dari yang terbaru)
  List<DoctorBooking> getDoctorBookings(String doctorId, {String? doctorName}) {
    final cleanDocId = doctorId.trim().toLowerCase();
    final cleanDocName = (doctorName ?? '').trim().toLowerCase();

    final result = _bookings.where((b) {
      // Cocokkan UID
      if (cleanDocId.isNotEmpty && b.doctorId.isNotEmpty) {
        if (b.doctorId.toLowerCase() == cleanDocId) return true;
      }
      // Cocokkan Nama Dokter
      if (cleanDocName.isNotEmpty && b.doctorName.isNotEmpty) {
        final bName = b.doctorName.toLowerCase();
        if (bName.contains(cleanDocName) || cleanDocName.contains(bName)) {
          return true;
        }
      }
      // Booking umum template / demo jika doctorId kosong
      if (b.doctorId.isEmpty) return true;

      return false;
    }).toList();

    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  /// Hitung jumlah permintaan booking yang berstatus 'Menunggu Konfirmasi'
  int getPendingBookingsCount(String doctorId, {String? doctorName}) {
    final list = getDoctorBookings(doctorId, doctorName: doctorName);
    return list.where((b) {
      final s = b.status.trim().toLowerCase();
      return s == 'menunggu konfirmasi' || s == 'pending';
    }).length;
  }

  /// Update status booking (Terima, Tolak, Selesai, Dibatalkan)
  Future<void> updateBookingStatus(
    String bookingId,
    String newStatus, {
    String? rejectionReason,
  }) async {
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx < 0) return;

    final current = _bookings[idx];
    final updated = current.copyWith(
      status: newStatus,
      rejectionReason: rejectionReason,
    );

    _bookings[idx] = updated;
    await _persistBookings();
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('consultation_bookings')
          .doc(bookingId)
          .set(updated.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  /// Membuat pesanan slot baru dari pasien
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
    String? patientId,
    String? patientName,
    String? patientPhoto,
    String? patientPhone,
    String? notes,
    String status = 'Menunggu Konfirmasi',
  }) async {
    // Validasi tabrakan jadwal
    if (isSlotBooked(
      doctorId: doctorId,
      dateKey: dateKey,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
    )) {
      return false;
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
      status: status,
      patientId: patientId,
      patientName: patientName,
      patientPhoto: patientPhoto,
      patientPhone: patientPhone,
      notes: notes,
    );

    _bookings.insert(0, booking);
    await _persistBookings();
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('consultation_bookings')
          .doc(booking.id)
          .set(booking.toMap());
    } catch (_) {}

    return true;
  }

  // ==========================================================================
  // MANAJEMEN ATUR JADWAL PRAKTIK DOKTER
  // ==========================================================================

  /// Ambil seluruh jadwal yang telah diatur oleh dokter
  List<DoctorPracticeSchedule> getDoctorSchedules(String doctorId, {String? doctorName}) {
    final cleanDocId = doctorId.trim().toLowerCase();
    final cleanDocName = (doctorName ?? '').trim().toLowerCase();

    final result = _schedules.where((s) {
      if (cleanDocId.isNotEmpty && s.doctorId.isNotEmpty) {
        if (s.doctorId.toLowerCase() == cleanDocId) return true;
      }
      if (cleanDocName.isNotEmpty && s.doctorName.isNotEmpty) {
        final sName = s.doctorName.toLowerCase();
        if (sName.contains(cleanDocName) || cleanDocName.contains(sName)) {
          return true;
        }
      }
      // Template default jika belum dispesifikasikan
      if (s.doctorId.isEmpty) return true;

      return false;
    }).toList();

    result.sort((a, b) => a.dateKey.compareTo(b.dateKey));
    return result;
  }

  /// Ambil jadwal praktik dokter untuk tanggal tertentu
  DoctorPracticeSchedule? getDoctorScheduleForDate(
    String doctorId,
    String dateKey, {
    String? doctorName,
  }) {
    final list = getDoctorSchedules(doctorId, doctorName: doctorName);
    // 1. Cari yang cocok persis dengan dateKey
    for (final s in list) {
      if (s.dateKey == dateKey) return s;
    }
    // 2. Cari berdasarkan kecocokan substring tanggal
    for (final s in list) {
      if (dateKey.contains(s.dateKey) || s.dateKey.contains(dateKey)) {
        return s;
      }
    }
    return null;
  }

  /// Tambah atau perbarui jadwal praktik dokter
  Future<void> savePracticeSchedule(DoctorPracticeSchedule schedule) async {
    final idx = _schedules.indexWhere((s) {
      if (s.id == schedule.id) return true;
      if (s.doctorId == schedule.doctorId && s.dateKey == schedule.dateKey) {
        return true;
      }
      return false;
    });

    if (idx >= 0) {
      _schedules[idx] = schedule;
    } else {
      _schedules.add(schedule);
    }

    await _persistSchedules();
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('doctor_schedules')
          .doc(schedule.id)
          .set(schedule.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  /// Hapus jadwal praktik dokter
  Future<void> deletePracticeSchedule(String scheduleId) async {
    _schedules.removeWhere((s) => s.id == scheduleId);
    await _persistSchedules();
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('doctor_schedules')
          .doc(scheduleId)
          .delete();
    } catch (_) {}
  }

  /// Aktifkan / Liburkan jadwal praktik pada tanggal tertentu
  Future<void> toggleScheduleActive(String scheduleId, bool isActive) async {
    final idx = _schedules.indexWhere((s) => s.id == scheduleId);
    if (idx < 0) return;

    final updated = _schedules[idx].copyWith(
      isActive: isActive,
      updatedAt: DateTime.now(),
    );
    _schedules[idx] = updated;

    await _persistSchedules();
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('doctor_schedules')
          .doc(scheduleId)
          .set(updated.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  // ==========================================================================
  // PEMBAGIAN SLOT KONSULTASI DINAMIS (INTEGRASI PASIEN & DOKTER)
  // ==========================================================================

  /// Generate daftar slot waktu konsultasi:
  /// - Jika dokter telah mengatur jadwal khusus pada tanggal tersebut:
  ///   * Membagi rentang jam praktik (startMinutes s/d endMinutes) berdasarkan durasi
  ///   * Melewati/mengecualikan jam jeda istirahat jika ada
  ///   * Mengecek status ketersediaan (Tersedia vs Sudah Dibooking)
  /// - Jika dokter menonaktifkan jadwal pada tanggal tersebut: mengembalikan list kosong
  /// - Jika dokter belum memiliki jadwal khusus: menggunakan template default jam operasional
  List<TimeSlotItem> generateSlots({
    required int durationMinutes,
    String? doctorId,
    required String dateKey,
  }) {
    final List<TimeSlotItem> result = [];

    // Cek apakah dokter memiliki jadwal custom untuk tanggal ini
    final customSchedule = getDoctorScheduleForDate(
      doctorId ?? '',
      dateKey,
    );

    if (customSchedule != null) {
      // Jika dokter menonaktifkan jadwal pada tanggal ini, slot tidak tersedia
      if (!customSchedule.isActive) {
        return [];
      }

      final int start = customSchedule.startMinutes;
      final int end = customSchedule.endMinutes;
      final int dur = durationMinutes > 0 ? durationMinutes : customSchedule.durationMinutes;

      int current = start;
      while (current + dur <= end) {
        final int sStart = current;
        final int sEnd = current + dur;

        // Cek apakah slot berada di dalam jam jeda istirahat
        bool isBreak = false;
        if (customSchedule.hasBreak &&
            customSchedule.breakStartMinutes != null &&
            customSchedule.breakEndMinutes != null) {
          if (checkOverlap(
            sStart,
            sEnd,
            customSchedule.breakStartMinutes!,
            customSchedule.breakEndMinutes!,
          )) {
            isBreak = true;
          }
        }

        if (!isBreak) {
          final String startFormatted = formatMinutes(sStart);
          final String endFormatted = formatMinutes(sEnd);
          final String label = '$startFormatted–$endFormatted';

          final bool booked = isSlotBooked(
            doctorId: doctorId,
            dateKey: dateKey,
            startMinutes: sStart,
            endMinutes: sEnd,
          );

          final matchedBooking = booked
              ? getBookingForSlot(
                  doctorId: doctorId,
                  dateKey: dateKey,
                  startMinutes: sStart,
                  endMinutes: sEnd,
                )
              : null;

          // Kelompokkan periode (Pagi, Siang, Sore)
          String period = 'Pagi';
          if (sStart >= 720 && sStart < 900) {
            period = 'Siang';
          } else if (sStart >= 900) {
            period = 'Sore';
          }

          result.add(
            TimeSlotItem(
              startMinutes: sStart,
              endMinutes: sEnd,
              label: label,
              startTime: startFormatted,
              endTime: endFormatted,
              period: period,
              isBooked: booked,
              isBreak: false,
              booking: matchedBooking,
            ),
          );
        }

        current += dur;
      }

      return result;
    }

    // Default Fallback: template 3 periode standar
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

        final matchedBooking = booked
            ? getBookingForSlot(
                doctorId: doctorId,
                dateKey: dateKey,
                startMinutes: sStart,
                endMinutes: sEnd,
              )
            : null;

        result.add(
          TimeSlotItem(
            startMinutes: sStart,
            endMinutes: sEnd,
            label: label,
            startTime: startFormatted,
            endTime: endFormatted,
            period: periodName,
            isBooked: booked,
            isBreak: false,
            booking: matchedBooking,
          ),
        );

        current += durationMinutes;
      }
    }

    return result;
  }

  /// Helper untuk pengujian unit testing
  @visibleForTesting
  void simulateScheduleForTesting(DoctorPracticeSchedule schedule) {
    _schedules.removeWhere((s) =>
        s.id == schedule.id ||
        (s.doctorId == schedule.doctorId && s.dateKey == schedule.dateKey));
    _schedules.add(schedule);
    notifyListeners();
  }

  /// Helper untuk pengujian unit testing
  @visibleForTesting
  void simulateBookingForTesting(DoctorBooking booking) {
    _bookings.removeWhere((b) =>
        b.id == booking.id ||
        (b.doctorId == booking.doctorId &&
            b.dateKey == booking.dateKey &&
            b.timeSlot == booking.timeSlot));
    _bookings.add(booking);
    notifyListeners();
  }
}
