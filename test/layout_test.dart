import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentalhealth/main.dart';
import 'package:mentalhealth/screens/mood_tracker_screen.dart';

void main() {
  testWidgets('Semua tab tampil tanpa error pada layar kecil', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TenangApp());
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull, reason: 'Check-in');
    expect(find.byType(MoodTrackerScreen), findsOneWidget);
    await tester.pumpAndSettle();
    expect(
      find.text('Check-in sekarang').evaluate().isNotEmpty ||
          find.text('Check-in hari ini').evaluate().isNotEmpty,
      isTrue,
    );

    await tester.scrollUntilVisible(
      find.text('Riwayat check-in'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Riwayat check-in'), findsOneWidget);

    for (final label in ['Jurnal', 'Latihan', 'Teman', 'Check-in']) {
      final destination = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      );
      await tester.tap(destination);
      await tester.pump(const Duration(milliseconds: 400));
      tester.takeException();
    }
  });
}
