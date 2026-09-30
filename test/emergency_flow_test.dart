import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/pages/emergency_page.dart';
import 'package:heartcare/pages/home_page.dart';

void main() {
  testWidgets('EmergencyPage renders all emergency hotlines, symptoms, and first aid guide', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EmergencyPage(),
      ),
    );

    // Verify AppBar and Header
    expect(find.text('Panggilan Darurat Medis'), findsOneWidget);
    expect(find.text('Siaga 24 Jam'), findsOneWidget);

    // Verify Main Hotline 119
    expect(find.text('119'), findsOneWidget);
    expect(find.text('Panggil 119 Sekarang'), findsOneWidget);
    expect(find.text('HOTLINE MEDIS NASIONAL'), findsOneWidget);

    // Verify Quick Contact services
    expect(find.text('Layanan Darurat Cepat'), findsOneWidget);
    expect(find.text('112'), findsOneWidget);
    expect(find.text('Darurat Terpadu'), findsOneWidget);
    expect(find.text('118'), findsOneWidget);
    expect(find.text('Ambulans AGD'), findsOneWidget);

    // Verify Symptoms and First Aid guides
    expect(find.text('Gejala Darurat Serangan Jantung'), findsOneWidget);
    expect(find.text('Langkah Pertolongan Pertama (SOP)'), findsOneWidget);
  });

  testWidgets('HomePage renders emergency phone button and navigates to EmergencyPage', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(),
      ),
    );

    // Verify phone icon and SOS badge in HomePage header
    expect(find.byIcon(Icons.phone_in_talk_rounded), findsOneWidget);
    expect(find.text('SOS'), findsOneWidget);

    // Tap on emergency button
    await tester.tap(find.text('SOS'));
    await tester.pumpAndSettle();

    // Verify it navigated to EmergencyPage
    expect(find.byType(EmergencyPage), findsOneWidget);
    expect(find.text('Panggilan Darurat Medis'), findsOneWidget);

    // Test back button
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // Verify returned to HomePage
    expect(find.byType(EmergencyPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
  });
}
