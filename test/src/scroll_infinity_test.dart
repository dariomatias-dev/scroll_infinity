import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

void main() {
  /// Mocks the `loadData` function for testing purposes.
  ///
  /// Simulates loading a list of items based on the `pageIndex`.
  ///
  /// Parameters:
  /// - [pageIndex]: The index of the page to load.
  /// - [totalItems]: Total number of items available to load.
  /// - [maxItemsPerPage]: Maximum number of items per page.
  /// - [throwErrorOnPage]: If `true`, simulates an error on the page specified by [errorPage].
  /// - [errorPage]: The page where the error will occur.
  Future<List<String>?> mockLoadData(
    int pageIndex, {
    int totalItems = 30,
    int maxItemsPerPage = 10,
    bool throwErrorOnPage = false,
    int errorPage = 0,
  }) async {
    // Simulate network latency
    await Future.delayed(
      const Duration(
        milliseconds: 20,
      ),
    );

    if (throwErrorOnPage && pageIndex == errorPage) {
      throw Exception('Failed to load data');
    }

    final start = pageIndex * maxItemsPerPage;
    if (start >= totalItems) {
      return []; // End of the list
    }

    final end = (start + maxItemsPerPage > totalItems)
        ? totalItems
        : start + maxItemsPerPage;

    return List.generate(end - start, (i) => 'Item ${start + i}');
  }

  /// Wraps a widget in a MaterialApp to make it testable.
  ///
  /// This is used to ensure that MaterialApp and Scaffold context is available during the test.
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Directionality(
          textDirection: TextDirection.ltr,
          child: child,
        ),
      ),
    );
  }

  testWidgets(
    'Renders header and initial loading indicator',
    (tester) async {
      final completer = Completer<List<String>?>();

      await tester.pumpWidget(
        buildTestableWidget(
          ScrollInfinity<String>(
            maxItems: 10,
            header: const Text('My Header'),
            loadData: (page) => completer.future,
            itemBuilder: (item, index) => Text(item),
          ),
        ),
      );

      // Verify header and loading indicator are present
      expect(find.text('My Header'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to avoid widget disposal errors
      completer.complete([]);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'Displays empty widget when initial fetch is empty',
    (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ScrollInfinity<String>(
            maxItems: 10,
            empty: const Text('No Data Found'),
            loadData: (page) {
              return mockLoadData(
                page,
                totalItems: 0,
              );
            },
            itemBuilder: (item, index) => Text(item),
          ),
        ),
      );

      // Wait for the initial load to complete
      await tester.pumpAndSettle();

      // Verify the empty state widget is displayed
      expect(find.text('No Data Found'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'Fetches and displays the first page of items',
    (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ScrollInfinity<String>(
            maxItems: 5,
            loadData: (page) {
              return mockLoadData(
                page,
                totalItems: 5,
                maxItemsPerPage: 5,
              );
            },
            itemBuilder: (item, index) => Text(item),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the first page of items is displayed
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
      expect(find.text('Item 5'), findsNothing);
    },
  );

  testWidgets(
    'Shows error widget and retries on tap',
    (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        buildTestableWidget(
          ScrollInfinity<String>(
            maxItems: 10,
            loadData: (page) {
              callCount++;

              return mockLoadData(
                page,
                throwErrorOnPage: true,
                errorPage: 0,
              );
            },
            itemBuilder: (item, index) => Text(item),
          ),
        ),
      );

      // Wait for the error to occur
      await tester.pumpAndSettle();
      expect(find.text('Try Again'), findsOneWidget);
      expect(callCount, 1);

      // Retry the operation
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      // Verify the retry attempts are counted correctly
      expect(find.text('Try Again'), findsOneWidget);
      expect(callCount, 2);
    },
  );

  testWidgets(
    'Separators are built between items',
    (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ScrollInfinity<String>(
          maxItems: 5,
          loadData: (page) {
            return mockLoadData(
              page,
              totalItems: 5,
              maxItemsPerPage: 5,
            );
          },
          separatorBuilder: (context, index) {
            return const Divider(
              key: Key('divider'),
            );
          },
          itemBuilder: (item, index) => Text(item),
        ),
      ));

      await tester.pumpAndSettle();

      // Verify the number of separators between items
      expect(find.byKey(const Key('divider')), findsNWidgets(4));
    },
  );

  testWidgets(
    'useRealItemIndex=true provides correct indices for items and intervals',
    (tester) async {
      final receivedItems = <String, int>{};

      await tester.pumpWidget(buildTestableWidget(
        ScrollInfinity<String?>(
          maxItems: 3,
          interval: 2,
          useRealItemIndex: true,
          loadData: (page) {
            return mockLoadData(
              page,
              totalItems: 5,
              maxItemsPerPage: 5,
            );
          },
          itemBuilder: (item, index) {
            // If it's an interval item, the value is null
            final key = item ?? 'interval_$index';
            receivedItems[key] = index;

            return Text(key);
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Verify the correct indices for both items and intervals
      expect(receivedItems['Item 0'], 0);
      expect(receivedItems['Item 1'], 1);
      expect(receivedItems['interval_0'], 0); // First interval, index 0
      expect(receivedItems['Item 2'], 2);
      expect(receivedItems['Item 3'], 3);
      expect(receivedItems['interval_1'], 1); // Second interval, index 1
    },
  );

  testWidgets(
    'useRealItemIndex=false provides continuous list indices',
    (tester) async {
      final Map<String, int> receivedItems = {};

      await tester.pumpWidget(buildTestableWidget(
        ScrollInfinity<String?>(
          maxItems: 3,
          interval: 2,
          useRealItemIndex: false,
          loadData: (page) {
            return mockLoadData(
              page,
              totalItems: 4,
              maxItemsPerPage: 4,
            );
          },
          itemBuilder: (item, index) {
            final key = item ?? 'interval_$index';
            receivedItems[key] = index;

            return Text(key);
          },
        ),
      ));

      await tester.pumpAndSettle();

      // Verify continuous indices for items
      expect(receivedItems['Item 0'], 0);
      expect(receivedItems['Item 1'], 1);
      expect(receivedItems['interval_2'], 2); // Null item at index 2
      expect(receivedItems['Item 2'], 3);
      expect(receivedItems['Item 3'], 4);
    },
  );
}
