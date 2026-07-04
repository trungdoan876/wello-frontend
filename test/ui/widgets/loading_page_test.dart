import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wello_frontend/ui/widgets/loading_page.dart';

void main() {
  testWidgets('LoadingPage displays bounce text and navigates after delay', (tester) async {
    const nextPageKey = Key('next_page_key');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoadingPage(
            nextPage: Scaffold(
              key: nextPageKey,
              body: const Text('Hello Destination'),
            ),
            delay: const Duration(milliseconds: 200),
          ),
        ),
      ),
    );

    // Initial state: loading text should be present, destination should not
    expect(find.text('Đang tải...'), findsOneWidget);
    expect(find.byKey(nextPageKey), findsNothing);

    // Pump past the delay
    await tester.pump(const Duration(milliseconds: 200));
    // Pump transition animation frame (600ms transition time)
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Verify it navigated to next page
    expect(find.byKey(nextPageKey), findsOneWidget);
    expect(find.text('Hello Destination'), findsOneWidget);
  });
}
