import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/pages/profil_page.dart';
import 'package:heartcare/pages/data_pribadi_page.dart';
import 'package:heartcare/pages/data_kesehatan_page.dart';
import 'package:heartcare/pages/pengaturan_page.dart';
import 'package:heartcare/pages/tentang_aplikasi_page.dart';

void main() {
  testWidgets('ProfilPage renders user profile, avatar, menu items, and logout confirmation dialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfilPage(),
      ),
    );

    // Verify Title & Hero Profile
    expect(find.text('Profil'), findsNWidgets(2)); // AppBar + Bottom Nav
    expect(find.text('Nadea Fieldzah Putri'), findsOneWidget);
    expect(find.text('+62 123 456 799'), findsOneWidget);
    expect(find.text('nadea123@gmail.com'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);

    // Verify Menu Section "Informasi"
    expect(find.text('Informasi'), findsOneWidget);
    expect(find.text('Data Pribadi'), findsOneWidget);
    expect(find.text('Data Kesehatan'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
    expect(find.text('Tentang Aplikasi'), findsOneWidget);

    // Verify Keluar action
    expect(find.text('Keluar'), findsOneWidget);

    // Tap Keluar to open Konfirmasi Log Out Dialog
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi Log Out'), findsOneWidget);
    expect(find.textContaining('Apakah Anda yakin ingin keluar'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);

    // Tap Batal
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi Log Out'), findsNothing);
  });

  testWidgets('DataPribadiPage renders all personal data and opens edit sheet', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DataPribadiPage(),
      ),
    );

    expect(find.text('Data Pribadi'), findsOneWidget);
    expect(find.text('Informasi Pribadi'), findsOneWidget);
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Jenis Kelamin'), findsOneWidget);
    expect(find.text('Perempuan'), findsOneWidget);
    expect(find.text('Tempat, Tanggal Lahir'), findsOneWidget);
    expect(find.textContaining('29 Februari 2004'), findsOneWidget);
    expect(find.text('Alamat'), findsOneWidget);
    expect(find.text('Ubah Data'), findsOneWidget);

    // Tap Ubah Data
    await tester.tap(find.text('Ubah Data'));
    await tester.pumpAndSettle();

    expect(find.text('Ubah Data Pribadi'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
  });

  testWidgets('DataKesehatanPage renders all health data and opens edit sheet', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DataKesehatanPage(),
      ),
    );

    expect(find.text('Data Kesehatan'), findsOneWidget);
    expect(find.text('Informasi Kesehatan'), findsOneWidget);
    expect(find.text('Golongan Darah'), findsOneWidget);
    expect(find.text('O'), findsOneWidget);
    expect(find.text('Tinggi Badan'), findsOneWidget);
    expect(find.text('167 cm'), findsOneWidget);
    expect(find.text('Berat Badan'), findsOneWidget);
    expect(find.text('51 kg'), findsOneWidget);
    expect(find.text('Alergi'), findsOneWidget);
    expect(find.text('Ubah Data'), findsOneWidget);

    // Tap Ubah Data
    await tester.tap(find.text('Ubah Data'));
    await tester.pumpAndSettle();

    expect(find.text('Ubah Data Kesehatan'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
  });

  testWidgets('PengaturanPage renders account and other settings', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PengaturanPage(),
      ),
    );

    expect(find.text('Pengaturan'), findsOneWidget);
    expect(find.text('Akun'), findsOneWidget);
    expect(find.text('Ubah kata sandi'), findsOneWidget);
    expect(find.text('Lainnya'), findsOneWidget);
    expect(find.text('Bahasa'), findsOneWidget);
    expect(find.text('Bahasa Indonesia'), findsOneWidget);
    expect(find.text('Mode Gelap'), findsOneWidget);

    // Toggle Mode Gelap
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(find.text('Mode Gelap diaktifkan'), findsOneWidget);

    // Tap Ubah kata sandi
    await tester.tap(find.text('Ubah kata sandi'));
    await tester.pumpAndSettle();

    expect(find.text('Kata Sandi Lama'), findsOneWidget);
    expect(find.text('Simpan Kata Sandi'), findsOneWidget);
  });

  testWidgets('TentangAplikasiPage renders brand overview, Visi and Misi', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TentangAplikasiPage(),
      ),
    );

    expect(find.text('Tentang Aplikasi'), findsOneWidget);
    expect(find.text('MediTriage HeartCare'), findsOneWidget);
    expect(find.textContaining('skrining dini kesehatan jantung'), findsOneWidget);
    expect(find.text('Visi'), findsOneWidget);
    expect(find.textContaining('platform layanan kesehatan jantung yang terpercaya'), findsOneWidget);
    expect(find.text('Misi'), findsOneWidget);
  });
}
