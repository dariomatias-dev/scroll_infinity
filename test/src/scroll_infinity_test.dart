import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

/// Mocks the `loadData` function for testing purposes.
///
/// Simulates loading a list of items based on the `pageIndex`.
Future<List<String>?> mockLoadData(
  int pageIndex, {
  int totalItems = 30,
  int maxItemsPerPage = 10,
  bool throwErrorOnPage = false,
  int errorPage = 0,
}) async {
  // Simulate network latency.
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
    return []; // End of the list.
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

void main() {
  group('ScrollInfinity', () {
    /// Tests related to the initial rendering and state of the widget.
    group('Initial State and Rendering', () {
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

          // Verify header and loading indicator are present.
          expect(find.text('My Header'), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);

          // Complete the future to avoid widget disposal errors.
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
                loadData: (page) => mockLoadData(page, totalItems: 0),
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          // Wait for the initial load to complete.
          await tester.pumpAndSettle();

          // Verify the empty state widget is displayed.
          expect(find.text('No Data Found'), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsNothing);
        },
      );
    });

    /// Tests related to fetching data and paginating through the list.
    group('Data Loading and Pagination', () {
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

          // Verify the first page of items is displayed.
          expect(find.text('Item 0'), findsOneWidget);
          expect(find.text('Item 4'), findsOneWidget);
          expect(find.text('Item 5'), findsNothing);
        },
      );

      testWidgets(
        'Displays "Load More" button and fetches on tap when automaticLoading is false',
        (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                automaticLoading: false,
                loadData: (page) {
                  return mockLoadData(
                    page,
                    totalItems: 25,
                    maxItemsPerPage: 5,
                  );
                },
                itemBuilder: (item, index) {
                  return SizedBox(
                    height: 100,
                    child: Text(item),
                  );
                },
              ),
            ),
          );

          // Load the first page.
          await tester.pumpAndSettle();
          expect(find.text('Item 0'), findsOneWidget);
          expect(find.text('Item 5'), findsNothing);
          expect(find.text('Load More'), findsOneWidget);

          // Attempt to scroll to load (should not work).
          await tester.drag(find.byType(ListView), const Offset(0, -800));
          await tester.pumpAndSettle();
          expect(find.text('Item 5'), findsNothing);

          // Tap the button to load more.
          await tester.tap(find.text('Load More'));
          await tester.pumpAndSettle();

          // Verify the second page was loaded.
          expect(find.text('Item 5'), findsOneWidget);
          expect(find.text('Load More'), findsNothing);
        },
      );
    });

    /// Tests related to error states and retry logic.
    group('Error Handling and Retries', () {
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
                  return mockLoadData(page, throwErrorOnPage: true);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          // Wait for the error to occur.
          await tester.pumpAndSettle();
          expect(find.text('Try Again'), findsOneWidget);
          expect(callCount, 1);

          // Retry the operation.
          await tester.tap(find.text('Try Again'));
          await tester.pumpAndSettle();

          // Verify the retry attempts are counted correctly.
          expect(find.text('Try Again'), findsOneWidget);
          expect(callCount, 2);
        },
      );

      testWidgets(
        'Stops retrying after maxRetries and shows limit reached widget',
        (tester) async {
          int callCount = 0;

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 10,
                maxRetries: 2, // Limit to 2 total attempts.
                retryLimitReached: const Text('No more retries allowed'),
                loadData: (page) {
                  callCount++;
                  throw Exception('Failed to load data');
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          // Attempt 1 (initial load fails). retryCount becomes 1.
          await tester.pumpAndSettle();
          expect(find.text('Try Again'), findsOneWidget);
          expect(callCount, 1);

          // Attempt 2 (tap fails). retryCount becomes 2.
          await tester.tap(find.text('Try Again'));
          await tester.pumpAndSettle();

          // Now retryCount (2) >= maxRetries (2), so the limit is reached.
          expect(find.text('Try Again'), findsNothing);
          expect(find.text('No more retries allowed'), findsOneWidget);
          // Verify that the load function was not called a third time.
          expect(callCount, 2);
        },
      );
    });

    /// Tests for optional features and specific property behaviors.
    group('Feature-Specific Properties', () {
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
                return const Divider(key: Key('divider'));
              },
              itemBuilder: (item, index) => Text(item),
            ),
          ));

          await tester.pumpAndSettle();

          // With 5 items, there should be 4 separators.
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
                final key = item ?? 'interval_$index';
                receivedItems[key] = index;

                return Text(key);
              },
            ),
          ));
          await tester.pumpAndSettle();

          // Verify correct indices for both data items and interval items.
          expect(receivedItems['Item 0'], 0);
          expect(receivedItems['Item 1'], 1);
          expect(receivedItems['interval_0'], 0); // First interval, index 0.
          expect(receivedItems['Item 2'], 2);
          expect(receivedItems['Item 3'], 3);
          expect(receivedItems['interval_1'], 1); // Second interval, index 1.
        },
      );

      testWidgets(
        'useRealItemIndex=false provides continuous list indices',
        (tester) async {
          final receivedItems = <String, int>{};

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

          // Verify list-based continuous indices.
          expect(receivedItems['Item 0'], 0);
          expect(receivedItems['Item 1'], 1);
          expect(receivedItems['interval_2'], 2); // Null item is at index 2.
          expect(receivedItems['Item 2'], 3);
          expect(receivedItems['Item 3'], 4);
        },
      );

      testWidgets(
        'Fetches data starting from a custom initialPageIndex',
        (tester) async {
          int? firstCalledPage;

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 10,
                initialPageIndex: 2, // Start from page 2.
                loadData: (page) {
                  firstCalledPage ??= page;
                  return mockLoadData(page, maxItemsPerPage: 10);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Verify the first call was for the correct page.
          expect(firstCalledPage, 2);

          // Verify items are from page 2 (items 20-29).
          expect(find.text('Item 20'), findsOneWidget);
          expect(find.text('Item 29'), findsOneWidget);
        },
      );
    });
  });
}
