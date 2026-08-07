import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('Example screen', () {
    testWidgets(
      'Config screen navigates to a working example list',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ConfigScreen()),
        );

        // Disable error simulation so the smoke test is deterministic.
        await toggleOption(tester, 'Simulate Errors');
        await openExample(tester);

        expect(find.byType(DisplayScreen), findsOneWidget);

        // First page arrives after the mock network latency (1.5s).
        await tester.pump(const Duration(seconds: 2));

        expect(find.text('Item 0'), findsOneWidget);
      },
    );

    testWidgets(
      'Initial items seed the list before the first fetch',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ConfigScreen()),
        );

        await toggleOption(tester, 'Simulate Errors');
        await toggleOption(tester, 'Initial Items');
        await openExample(tester);

        // No latency pump: the seeded items are already on screen, and the
        // filled viewport means no fetch was started.
        expect(find.text('Item 0'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'Header toggle renders the header on the example screen',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ConfigScreen()),
        );

        await toggleOption(tester, 'Simulate Errors');
        await toggleOption(tester, 'Header');
        await openExample(tester);

        expect(inExample(find.text('Header')), findsOneWidget);

        await tester.pump(const Duration(seconds: 2));
        expect(find.text('Item 0'), findsOneWidget);
      },
    );

    testWidgets(
      'Reverse renders the list from the end',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ConfigScreen()),
        );

        await toggleOption(tester, 'Simulate Errors');
        await toggleOption(tester, 'Reverse (chat-style)');
        await openExample(tester);
        await tester.pump(const Duration(seconds: 2));

        final listView = tester.widget<ListView>(
          inExample(find.byType(ListView)),
        );
        expect(listView.reverse, isTrue);

        // Item 0 sits at the bottom edge of the viewport.
        final center = tester.getCenter(find.text('Item 0'));
        expect(center.dy, greaterThan(400));
      },
    );

    testWidgets(
      'Separators toggle inserts dividers between items',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ConfigScreen()),
        );

        await toggleOption(tester, 'Simulate Errors');
        await toggleOption(tester, 'Separators');
        await openExample(tester);
        await tester.pump(const Duration(seconds: 2));

        expect(inExample(find.byType(Divider)), findsWidgets);
      },
    );

    testWidgets(
      'Interval placeholders render with independent indexes',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ConfigScreen()),
        );

        await toggleOption(tester, 'Simulate Errors');
        await toggleOption(tester, 'Intervals');
        await openExample(tester);
        await tester.pump(const Duration(seconds: 2));

        // Placeholders count on their own (0, 1, ...) while data items keep
        // their real indexes, so 'Item 2' follows 'Interval Widget 0'.
        expect(find.text('Interval Widget 0'), findsOneWidget);
        expect(find.text('Interval Widget 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);
      },
    );

    testWidgets(
      'AppBar refresh reloads the list via the controller',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ConfigScreen()),
        );

        await toggleOption(tester, 'Simulate Errors');
        await openExample(tester);

        await tester.pump(const Duration(seconds: 2));
        expect(find.text('Item 0'), findsOneWidget);

        await tester.tap(find.byTooltip('Reset List'));
        await tester.pump();

        // The list is cleared and the loading indicator returns.
        expect(find.text('Item 0'), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pump(const Duration(seconds: 2));
        expect(find.text('Item 0'), findsOneWidget);
      },
    );

    testWidgets(
      'Manual loading shows Load More and fetches the next page on tap',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ConfigScreen()),
        );

        await toggleOption(tester, 'Simulate Errors');
        await toggleOption(tester, 'Automatic Loading');
        await openExample(tester);
        await tester.pump(const Duration(seconds: 2));

        final scrollable = inExample(find.byType(Scrollable));
        await tester.scrollUntilVisible(
          find.text('Load More'),
          100,
          scrollable: scrollable,
        );
        await tester.tap(find.text('Load More'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));

        await tester.scrollUntilVisible(
          find.text('Item 10'),
          100,
          scrollable: scrollable,
        );
        expect(find.text('Item 10'), findsOneWidget);
      },
    );

    testWidgets(
      'The app bar action scrolls the list back to the start',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ConfigScreen()),
        );

        await toggleOption(tester, 'Simulate Errors');
        await openExample(tester);
        await tester.pump(const Duration(seconds: 2));

        final scrollable = inExample(find.byType(Scrollable));
        await tester.scrollUntilVisible(
          find.text('Item 7'),
          100,
          scrollable: scrollable,
        );
        expect(find.text('Item 0'), findsNothing);

        // Scrolling to the end triggers a fetch; let it land so no mock
        // network timer is left pending.
        await tester.pump(const Duration(seconds: 2));

        // Driven through the external ScrollController the screen owns.
        await tester.tap(find.byTooltip('Scroll To Start'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Item 0'), findsOneWidget);
      },
    );

    testWidgets(
      'Custom builders replace the default Load More button',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ConfigScreen()),
        );

        await toggleOption(tester, 'Simulate Errors');
        await toggleOption(tester, 'Automatic Loading');
        await toggleOption(tester, 'Custom Builders');
        await openExample(tester);
        await tester.pump(const Duration(seconds: 2));

        final scrollable = inExample(find.byType(Scrollable));
        await tester.scrollUntilVisible(
          find.byIcon(Icons.add),
          100,
          scrollable: scrollable,
        );

        // Custom TextButton.icon footer instead of the default
        // ElevatedButton one.
        expect(inExample(find.byType(TextButton)), findsOneWidget);
        expect(inExample(find.byType(ElevatedButton)), findsNothing);
      },
    );
  });
}
