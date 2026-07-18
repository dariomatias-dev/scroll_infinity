import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('Config screen controls', () {
    testWidgets(
      'Nested options appear only when their parent toggle is on',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ConfigScreen()),
        );

        // Intervals off by default: nested controls hidden.
        expect(find.text('Item Interval'), findsNothing);
        expect(find.text('Use Real Item Index'), findsNothing);

        await toggleOption(tester, 'Intervals');
        expect(find.text('Item Interval'), findsOneWidget);
        expect(find.text('Use Real Item Index'), findsOneWidget);

        // Simulate Errors on by default: retry options visible, but the
        // retries count only appears once the limit is enabled.
        expect(find.text('Enable Retry'), findsOneWidget);
        expect(find.text('Enable Retries Limit'), findsOneWidget);
        expect(find.text('Max Retries Count'), findsNothing);

        await toggleOption(tester, 'Enable Retries Limit');
        expect(find.text('Max Retries Count'), findsOneWidget);

        // Turning Simulate Errors off hides the whole retry section.
        await toggleOption(tester, 'Simulate Errors');
        expect(find.text('Enable Retry'), findsNothing);
        expect(find.text('Enable Retries Limit'), findsNothing);
        expect(find.text('Max Retries Count'), findsNothing);

        // Automatic Loading on by default: threshold visible; off hides it.
        expect(find.text('Load More Threshold (px)'), findsOneWidget);
        await toggleOption(tester, 'Automatic Loading');
        expect(find.text('Load More Threshold (px)'), findsNothing);
      },
    );

    testWidgets(
      'Quantity selector disables its buttons at the bounds',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ConfigScreen()),
        );

        final row = find
            .ancestor(
              of: find.text('Initial Page Index'),
              matching: find.byType(Row),
            )
            .first;

        IconButton buttonWithIcon(IconData icon) {
          return tester.widget<IconButton>(
            find
                .ancestor(
                  of: find.descendant(of: row, matching: find.byIcon(icon)),
                  matching: find.byType(IconButton),
                )
                .first,
          );
        }

        // At the minimum (0), only increment is possible.
        expect(buttonWithIcon(Icons.remove).onPressed, isNull);
        expect(buttonWithIcon(Icons.add).onPressed, isNotNull);

        await tester.ensureVisible(find.text('Initial Page Index'));
        await tester.tap(
          find.descendant(of: row, matching: find.byIcon(Icons.add)),
        );
        await tester.pump();

        expect(buttonWithIcon(Icons.remove).onPressed, isNotNull);
      },
    );

    testWidgets(
      'Pull-to-Refresh is disabled and forced off for horizontal lists',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ConfigScreen()),
        );

        SwitchListTile pullTile() {
          return tester.widget<SwitchListTile>(
            find.ancestor(
              of: find.text('Pull-to-Refresh'),
              matching: find.byType(SwitchListTile),
            ),
          );
        }

        // Enable pull-to-refresh while vertical.
        await toggleOption(tester, 'Pull-to-Refresh');
        expect(pullTile().value, isTrue);

        // Switching to horizontal disables the control and shows it off.
        await toggleOption(tester, 'Horizontal');
        expect(pullTile().value, isFalse);
        expect(pullTile().onChanged, isNull);
        expect(find.text('Vertical lists only'), findsOneWidget);

        // The example screen builds a horizontal, height-constrained list
        // without a RefreshIndicator.
        await openExample(tester);
        expect(find.byType(RefreshIndicator), findsNothing);

        final listView = tester.widget<ListView>(
          inExample(find.byType(ListView)),
        );
        expect(listView.scrollDirection, Axis.horizontal);
        expect(tester.getSize(inExample(find.byType(ListView))).height, 140);

        // Drain the pending mock fetch before the test ends.
        await tester.pump(const Duration(seconds: 2));
      },
    );
  });
}
