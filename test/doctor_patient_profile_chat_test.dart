import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/services/profile_service.dart';
import 'package:heartcare/services/chat_service.dart';
import 'package:heartcare/pages/konsultasi_dokter_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 1x1 transparent PNG encoded in Base64
  const sampleBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';

  group('ProfileService Patient Image Helpers', () {
    test('getImageProvider resolves base64 and asset correctly', () {
      final base64Provider = ProfileService.getImageProvider(sampleBase64);
      expect(base64Provider, isA<MemoryImage>());

      final assetProvider =
          ProfileService.getImageProvider('assets/images/profile_woman.png');
      expect(assetProvider, isA<AssetImage>());

      final emptyProvider = ProfileService.getImageProvider('');
      expect(emptyProvider, isNull);
    });

    testWidgets('buildPatientImage renders MemoryImage for base64 photo',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileService.buildPatientImage(
              sampleBase64,
              width: 50,
              height: 50,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('buildPatientImage renders fallback when photo is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileService.buildPatientImage(
              null,
              patientId: 'patient_test_123',
              width: 50,
              height: 50,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('KonsultasiDokterPage with Patient Profile in Doctor View', () {
    testWidgets(
        'KonsultasiDokterPage in doctor view displays patient name and patient avatar in header',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: KonsultasiDokterPage(
            isDoctorView: true,
            doctorName: 'dr. Nurlitta Dwi',
            doctorPhoto: 'assets/images/dokter_nurlitta.jpg',
            doctorSpecialty: 'Spesialis Jantung',
            patientName: 'Nadea Fieldzah Putri',
            patientPhoto: sampleBase64,
            patientId: 'patient_nadea_uid',
          ),
        ),
      );
      await tester.pump();

      // Check Header in doctor view
      expect(find.text('Konsultasi Pasien'), findsOneWidget);
      expect(find.text('Nadea Fieldzah Putri'), findsOneWidget);
      expect(find.text('Pasien Aktif'), findsOneWidget);

      // Verify that Image widget is rendered in the header avatar
      expect(find.byType(Image), findsWidgets);
    });

    test('ChatService active role can be switched and session id is present', () {
      ChatService.instance.setActiveRole('doctor');
      expect(ChatService.instance.activeRole, equals('doctor'));

      ChatService.instance.setActiveRole('patient');
      expect(ChatService.instance.activeRole, equals('patient'));

      expect(ChatService.instanceSessionId.isNotEmpty, isTrue);
    });
  });
}

