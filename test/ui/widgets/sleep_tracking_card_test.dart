import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wello_frontend/ui/widgets/sleep_tracking_card.dart';

void main() {
  testWidgets('SleepTrackingCard renders target hours, bedtime, and waketime correctly', (tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;


    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SleepTrackingCard(
            targetHours: 7.5,
            bedtime: '23:15',
            wakeTime: '06:45',
          ),
        ),
      ),
    );

    // Verify target hours text is rendered
    expect(find.text('7.5 giờ'), findsOneWidget);
    expect(find.text('Mục tiêu giấc ngủ'), findsOneWidget);

    // Verify bedtime and wake time are rendered
    expect(find.text('23:15'), findsOneWidget);
    expect(find.text('06:45'), findsOneWidget);

    // Clean up
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('SleepTrackingCard falls back to default values when arguments are null', (tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;


    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SleepTrackingCard(
            targetHours: null,
            bedtime: null,
            wakeTime: null,
          ),
        ),
      ),
    );

    // Verify default target hours (8.0 giờ) bedtime (22:30) and waketime (06:30)
    expect(find.text('8.0 giờ'), findsOneWidget);
    expect(find.text('22:30'), findsOneWidget);
    expect(find.text('06:30'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
