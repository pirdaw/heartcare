import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/pages/dokter_page.dart';
import 'package:heartcare/pages/detail_dokter_page.dart';

void main() {
  testWidgets('PilihDokterPage renders doctors without categories and without ratings', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PilihDokterPage(),
      ),
    );

    // Verify Title
    expect(find.text('Pilih Dokter'), findsOneWidget);

    // Verify Categories under search bar ARE REMOVED
    expect(find.text('Semua'), findsNothing);
    expect(find.text('Umum'), findsNothing);

    // Verify No Ratings are shown
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    expect(find.textContaining('⭐'), findsNothing);

    // Verify doctors are rendered in ListView
    expect(find.text('dr. Andi Pratama'), findsOneWidget);
    expect(find.text('dr. Sinta Maharani'), findsOneWidget);
    expect(find.text('dr. Nurlitta Dwi'), findsOneWidget);

    // Scroll to see 4th doctor in ListView
    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(find.text('dr. Rina Amelia'), findsOneWidget);
  });

  testWidgets('Tapping dr. Andi Pratama opens DetailDokterPage with his specific data', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PilihDokterPage(),
      ),
    );

    await tester.tap(find.text('dr. Andi Pratama'));
    await tester.pumpAndSettle();

    // Verify DetailDokterPage shows dr. Andi Pratama and his specific info
    expect(find.byType(DetailDokterPage), findsOneWidget);
    expect(find.text('dr. Andi Pratama'), findsOneWidget);
    expect(find.text('1823/SIP/2021'), findsOneWidget);
    expect(find.text('Klinik Jantung Sejahtera, Jember'), findsOneWidget);
    expect(find.text('10 tahun'), findsOneWidget);
    expect(find.text('Pilih Jadwal Konsultasi'), findsOneWidget);

    // Go back
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(PilihDokterPage), findsOneWidget);
  });

  testWidgets('Tapping dr. Sinta Maharani opens DetailDokterPage with her specific data', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PilihDokterPage(),
      ),
    );

    await tester.tap(find.text('dr. Sinta Maharani'));
    await tester.pumpAndSettle();

    // Verify DetailDokterPage shows dr. Sinta Maharani
    expect(find.byType(DetailDokterPage), findsOneWidget);
    expect(find.text('dr. Sinta Maharani'), findsOneWidget);
    expect(find.text('2105/SIP/2022'), findsOneWidget);
    expect(find.text('RS Graha Medika, Jember'), findsOneWidget);
  });
}
