// This is a basic Flutter widget test for the Academic Overview dashboard.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:responsive_dashboard/main.dart';

void main() {
  testWidgets('Dashboard renders profile, cards, and toggles theme',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AcademicOverviewApp());

    // Header & title are present.
    expect(find.text('Academic Overview'), findsOneWidget);
    expect(find.text('Robby Catur Wicaksono'), findsOneWidget);

    // Info cards render their semantic labels.
    expect(find.text('Assignments'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Portfolio'), findsOneWidget);
    expect(find.text('Current week'), findsOneWidget);

    // Dark mode toggle starts off, then switches on.
    final switchFinder = find.byType(CupertinoSwitch);
    expect(switchFinder, findsOneWidget);
    expect(tester.widget<CupertinoSwitch>(switchFinder).value, isFalse);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(tester.widget<CupertinoSwitch>(switchFinder).value, isTrue);
  });
}
