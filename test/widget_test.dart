import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentalhealth/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TenangApp());
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(TenangApp), findsOneWidget);
  });

  testWidgets('Profil: buka, validasi kosong, simpan nama', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TenangApp());
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('profileButton')));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    expect(find.text('Simpan'), findsOneWidget);
    expect(find.text('Prompt jurnal'), findsOneWidget);
    await tester.ensureVisible(find.text('Latihan'));
    await tester.pumpAndSettle();
    expect(find.text('Latihan'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Simpan'));
    await tester.pump();
    expect(find.text('Isi nama panggilan dulu.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Raka');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Profil tersimpan. Sapaan sekarang: Raka.'), findsOneWidget);
    expect(find.text('Raka'), findsWidgets);
  });
}
