import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

void main() {
  testWidgets('Responsive extension methods return correct scale values', (tester) async {
    // Set physical screen size
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              // 50% width of 400
              expect(context.w(0.5), 200.0);
              // 25% height of 800
              expect(context.h(0.25), 200.0);
              // shortestSide (400) * 10 / 100 = 40.0
              expect(context.sp(10), 40.0);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    // Clean up
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
