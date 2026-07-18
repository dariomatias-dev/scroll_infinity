import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
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
  await Future<void>.delayed(
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
/// This is used to ensure that MaterialApp and Scaffold context is
/// available during the test.
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

      testWidgets(
        'Renders initialItems immediately, without waiting for loadData',
        (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 10,
                initialItems: const ['Seed 0', 'Seed 1'],
                loadData: (page) => Completer<List<String>?>().future,
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          // A single pump (no pumpAndSettle): the seed items must already
          // be on screen without waiting on `loadData` to resolve.
          await tester.pump();

          expect(find.text('Seed 0'), findsOneWidget);
          expect(find.text('Seed 1'), findsOneWidget);
        },
      );

      testWidgets(
        'Shows the default empty message when no custom empty widget is '
        'set',
        (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 10,
                loadData: (page) => mockLoadData(page, totalItems: 0),
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('No items found.'), findsOneWidget);
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
        'Displays "Load More" button and fetches on tap when '
        'automaticLoading is false',
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

      testWidgets(
        'Automatically fetches the next page when scrolling within '
        'loadMoreThreshold of the end',
        (tester) async {
          var callCount = 0;

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                loadData: (page) {
                  callCount++;
                  return mockLoadData(
                    page,
                    totalItems: 15,
                    maxItemsPerPage: 5,
                  );
                },
                itemBuilder: (item, index) {
                  return SizedBox(height: 300, child: Text(item));
                },
              ),
            ),
          );

          // First page fills (and overflows) the viewport, so the
          // fill-the-screen loop stops after one fetch.
          await tester.pumpAndSettle();
          expect(callCount, 1);
          expect(find.text('Item 5'), findsNothing);

          // Dragging near the bottom must trigger `_onScroll` and fetch
          // the next page automatically (no manual "Load More" tap).
          await tester.drag(find.byType(ListView), const Offset(0, -1400));
          await tester.pumpAndSettle();

          expect(callCount, 2);
          expect(find.text('Item 5'), findsOneWidget);
        },
      );
    });

    /// Tests related to error states and retry logic.
    group('Error Handling and Retries', () {
      testWidgets(
        'Shows error widget and retries on tap',
        (tester) async {
          var callCount = 0;

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
          var callCount = 0;

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

      testWidgets(
        'Shows the error widget when loadData returns null',
        (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 10,
                loadData: (page) async => null,
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Returning `null` (instead of throwing) must also surface the
          // error state.
          expect(find.text('Try Again'), findsOneWidget);
        },
      );

      testWidgets(
        'Hides the retry widget when enableRetryOnError is false',
        (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 10,
                enableRetryOnError: false,
                loadData: (page) => mockLoadData(page, throwErrorOnPage: true),
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('Try Again'), findsNothing);
        },
      );

      testWidgets(
        'Shows the default retry-limit message when no custom widget is '
        'set',
        (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 10,
                maxRetries: 1,
                loadData: (page) {
                  return mockLoadData(page, throwErrorOnPage: true);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('Retry limit has been reached.'), findsOneWidget);
        },
      );
    });

    /// Tests for optional features and specific property behaviors.
    group('Feature-Specific Properties', () {
      testWidgets(
        'Separators are built between items',
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
                separatorBuilder: (context, index) {
                  return const Divider(key: Key('divider'));
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // With 5 items, there should be 4 separators.
          expect(find.byKey(const Key('divider')), findsNWidgets(4));
        },
      );

      testWidgets(
        'useRealItemIndex=true provides correct indices for items and '
        'intervals',
        (tester) async {
          final receivedItems = <String, int>{};

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String?>(
                maxItems: 3,
                interval: 2,
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
            ),
          );
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

          await tester.pumpWidget(
            buildTestableWidget(
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
            ),
          );

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
                  return mockLoadData(page);
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

      testWidgets(
        'Applies horizontal scrollDirection to the underlying ListView',
        (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                scrollDirection: Axis.horizontal,
                loadData: (page) {
                  return mockLoadData(
                    page,
                    totalItems: 5,
                    maxItemsPerPage: 5,
                  );
                },
                itemBuilder: (item, index) {
                  return SizedBox(width: 50, child: Text(item));
                },
              ),
            ),
          );

          await tester.pumpAndSettle();

          final listView = tester.widget<ListView>(find.byType(ListView));
          expect(listView.scrollDirection, Axis.horizontal);
        },
      );

      testWidgets(
        'Applies the padding property to the underlying ListView',
        (tester) async {
          const padding = EdgeInsets.all(24);

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                padding: padding,
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

          final listView = tester.widget<ListView>(find.byType(ListView));
          expect(listView.padding, padding);
        },
      );

      testWidgets(
        'Applies the reverse property to the underlying ListView',
        (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                reverse: true,
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

          final listView = tester.widget<ListView>(find.byType(ListView));
          expect(listView.reverse, isTrue);
        },
      );
    });

    /// Tests covering how the widget reacts to `didUpdateWidget` when its
    /// configuration changes while mounted.
    group('Widget Updates', () {
      testWidgets(
        'Resets and refetches when maxItems changes',
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
          expect(find.text('Item 4'), findsOneWidget);

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 3,
                loadData: (page) {
                  return mockLoadData(
                    page,
                    totalItems: 3,
                    maxItemsPerPage: 3,
                  );
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // The old page's items are gone; the new loadData/maxItems
          // produced a fresh, independent list starting from page 0.
          expect(find.text('Item 4'), findsNothing);
          expect(find.text('Item 2'), findsOneWidget);
        },
      );

      testWidgets(
        'Resets cleanly when interval changes without loadData or '
        'maxItems changing',
        (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              _IntervalToggleHost(
                loadData: (page) {
                  return mockLoadData(
                    page,
                    totalItems: 5,
                    maxItemsPerPage: 5,
                  );
                },
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(find.text('Item 0'), findsOneWidget);

          // Flips `interval` on the live widget while keeping the same
          // `loadData`/`maxItems` references, which used to leave the
          // internal index mapping inconsistent.
          await tester.tap(find.byKey(const Key('toggle_interval')));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.text('Item 0'), findsOneWidget);
          expect(find.textContaining('interval_'), findsWidgets);
        },
      );

      testWidgets(
        'Does not reset when only the loadData reference changes',
        (tester) async {
          // Simulates a parent widget passing a new closure on every
          // rebuild (e.g. an inline `loadData: (page) => ...`), which
          // used to be compared by identity and wrongly reset the list.
          var callCount = 0;

          Widget build() {
            return buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                loadData: (page) {
                  callCount++;
                  return mockLoadData(page, totalItems: 3, maxItemsPerPage: 5);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            );
          }

          await tester.pumpWidget(build());
          await tester.pumpAndSettle();
          expect(find.text('Item 0'), findsOneWidget);
          expect(callCount, 1);

          // Rebuild with a brand-new closure instance but the same
          // maxItems/interval: no reset, no refetch.
          await tester.pumpWidget(build());
          await tester.pump();

          expect(find.text('Item 0'), findsOneWidget);
          expect(callCount, 1);
        },
      );

      testWidgets(
        'Keeps fetched items when an unrelated property changes',
        (tester) async {
          Future<List<String>?> loadData(int page) {
            return mockLoadData(page, totalItems: 5, maxItemsPerPage: 5);
          }

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                loadData: loadData,
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Item 0'), findsOneWidget);

          // Same `loadData`/`maxItems`/`interval`; only an unrelated
          // property changes, so no reset should occur.
          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                header: const Text('New Header'),
                loadData: loadData,
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );
          await tester.pump();

          expect(find.text('Item 0'), findsOneWidget);
          expect(find.text('New Header'), findsOneWidget);
        },
      );
    });

    /// Tests covering widget teardown while asynchronous work is pending.
    group('Lifecycle', () {
      testWidgets(
        'Disposing while a fetch is in flight does not throw',
        (tester) async {
          final completer = Completer<List<String>?>();

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 10,
                loadData: (page) => completer.future,
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          // Unmount while `loadData` is still pending.
          await tester.pumpWidget(const SizedBox());

          completer.complete(['Item 0']);
          await tester.pump();

          expect(tester.takeException(), isNull);
        },
      );
    });

    /// Tests for the widget-builder overrides of the default state widgets.
    group('Custom State Widgets', () {
      testWidgets(
        'Uses the custom loading widget when provided',
        (tester) async {
          final completer = Completer<List<String>?>();

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 10,
                loading: const Text('Custom Loading'),
                loadData: (page) => completer.future,
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          expect(find.text('Custom Loading'), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsNothing);

          completer.complete([]);
          await tester.pumpAndSettle();
        },
      );

      testWidgets(
        'Uses the custom tryAgainBuilder when provided',
        (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 10,
                tryAgainBuilder: (action) {
                  return ElevatedButton(
                    onPressed: action,
                    child: const Text('Custom Retry'),
                  );
                },
                loadData: (page) {
                  return mockLoadData(page, throwErrorOnPage: true);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('Custom Retry'), findsOneWidget);
          expect(find.text('Try Again'), findsNothing);
        },
      );

      testWidgets(
        'Uses the custom loadMoreBuilder when provided',
        (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                automaticLoading: false,
                loadMoreBuilder: (action) {
                  return ElevatedButton(
                    onPressed: action,
                    child: const Text('Custom Load More'),
                  );
                },
                loadData: (page) {
                  return mockLoadData(
                    page,
                    totalItems: 25,
                    maxItemsPerPage: 5,
                  );
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('Custom Load More'), findsOneWidget);
          expect(find.text('Load More'), findsNothing);
        },
      );
    });

    /// Tests for the `onError` and `onItemsLoaded` analytics hooks.
    group('Analytics Callbacks', () {
      testWidgets(
        'onError receives the exception thrown by loadData',
        (tester) async {
          Object? capturedError;

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 10,
                onError: (error) => capturedError = error,
                loadData: (page) {
                  return mockLoadData(page, throwErrorOnPage: true);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(capturedError, isA<Exception>());
          expect(capturedError.toString(), contains('Failed to load data'));
        },
      );

      testWidgets(
        'onError is not called when loadData succeeds',
        (tester) async {
          var called = false;

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                onError: (_) => called = true,
                loadData: (page) {
                  return mockLoadData(page, totalItems: 5, maxItemsPerPage: 5);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(called, isFalse);
        },
      );

      testWidgets(
        'onItemsLoaded receives the raw items returned by loadData',
        (tester) async {
          final loadedBatches = <List<String>>[];

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                onItemsLoaded: loadedBatches.add,
                loadData: (page) {
                  return mockLoadData(page, totalItems: 5, maxItemsPerPage: 5);
                },
                itemBuilder: (item, index) {
                  return SizedBox(height: 150, child: Text(item));
                },
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(loadedBatches, [
            ['Item 0', 'Item 1', 'Item 2', 'Item 3', 'Item 4'],
          ]);
        },
      );

      testWidgets(
        'onItemsLoaded is not called when loadData fails',
        (tester) async {
          var called = false;

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 10,
                onItemsLoaded: (_) => called = true,
                loadData: (page) {
                  return mockLoadData(page, throwErrorOnPage: true);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(called, isFalse);
        },
      );
    });

    /// Tests for driving a mounted [ScrollInfinity] via
    /// [ScrollInfinityController].
    group('External Controller', () {
      testWidgets(
        'Reflects isLoading/hasError and refresh() resets the list',
        (tester) async {
          final controller = ScrollInfinityController();
          var callCount = 0;

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                controller: controller,
                loadData: (page) {
                  callCount++;
                  return mockLoadData(page, totalItems: 5, maxItemsPerPage: 5);
                },
                itemBuilder: (item, index) {
                  return SizedBox(height: 150, child: Text(item));
                },
              ),
            ),
          );

          expect(controller.isLoading, isTrue);
          await tester.pumpAndSettle();
          expect(controller.isLoading, isFalse);
          expect(controller.hasError, isFalse);
          expect(callCount, 1);

          controller.refresh();
          await tester.pump();
          expect(controller.isLoading, isTrue);

          await tester.pumpAndSettle();
          expect(callCount, 2);
          expect(find.text('Item 0'), findsOneWidget);
        },
      );

      testWidgets(
        'retry() re-fetches after an error',
        (tester) async {
          final controller = ScrollInfinityController();
          var callCount = 0;

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 10,
                controller: controller,
                loadData: (page) {
                  callCount++;
                  return mockLoadData(page, throwErrorOnPage: true);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(controller.hasError, isTrue);
          expect(callCount, 1);

          controller.retry();
          await tester.pumpAndSettle();

          expect(callCount, 2);
        },
      );

      testWidgets(
        'retry() ignores maxRetries once the limit is reached',
        (tester) async {
          final controller = ScrollInfinityController();
          var callCount = 0;

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 10,
                maxRetries: 1,
                controller: controller,
                loadData: (page) {
                  callCount++;
                  return mockLoadData(page, throwErrorOnPage: true);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(callCount, 1);

          // The initial failed attempt already set retryCount to 1, which
          // meets maxRetries (1): the limit is reached, so retry() must be
          // a no-op instead of firing another request.
          controller.retry();
          await tester.pumpAndSettle();

          expect(callCount, 1);
          expect(controller.hasError, isTrue);
        },
      );

      testWidgets(
        'retry() does nothing when enableRetryOnError is false',
        (tester) async {
          final controller = ScrollInfinityController();
          var callCount = 0;

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 10,
                enableRetryOnError: false,
                controller: controller,
                loadData: (page) {
                  callCount++;
                  return mockLoadData(page, throwErrorOnPage: true);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(callCount, 1);

          controller.retry();
          await tester.pumpAndSettle();

          expect(callCount, 1);
        },
      );

      testWidgets(
        'Becomes inert without throwing after ScrollInfinity is disposed',
        (tester) async {
          final controller = ScrollInfinityController();

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                controller: controller,
                loadData: (page) {
                  return mockLoadData(page, totalItems: 5, maxItemsPerPage: 5);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );
          await tester.pumpAndSettle();

          await tester.pumpWidget(const SizedBox());

          expect(controller.refresh, returnsNormally);
          expect(controller.isLoading, isFalse);
          expect(controller.hasError, isFalse);
        },
      );

      testWidgets(
        'Detaches the old controller and attaches the new one when the '
        'controller property changes',
        (tester) async {
          final controllerA = ScrollInfinityController();
          final controllerB = ScrollInfinityController();

          Widget buildWith(ScrollInfinityController controller) {
            return buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                controller: controller,
                loadData: (page) {
                  return mockLoadData(page, totalItems: 5, maxItemsPerPage: 5);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            );
          }

          await tester.pumpWidget(buildWith(controllerA));
          await tester.pumpAndSettle();
          expect(controllerA.isLoading, isFalse);

          await tester.pumpWidget(buildWith(controllerB));
          await tester.pumpAndSettle();

          // The old controller is detached: it must report inert defaults
          // instead of forwarding to the (now different) widget state.
          expect(controllerA.isLoading, isFalse);
          expect(controllerA.hasError, isFalse);

          // The new controller is attached and drives the live state.
          controllerB.refresh();
          await tester.pump();
          expect(controllerB.isLoading, isTrue);
          await tester.pumpAndSettle();
        },
      );
    });

    /// Tests for the `enablePullToRefresh` property.
    group('Pull To Refresh', () {
      testWidgets(
        'Does not wrap the list in a RefreshIndicator by default',
        (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                loadData: (page) {
                  return mockLoadData(page, totalItems: 5, maxItemsPerPage: 5);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(find.byType(RefreshIndicator), findsNothing);
        },
      );

      testWidgets(
        'enablePullToRefresh wraps the list and refetches on pull',
        (tester) async {
          var callCount = 0;

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                enablePullToRefresh: true,
                loadData: (page) {
                  callCount++;
                  return mockLoadData(page, totalItems: 5, maxItemsPerPage: 5);
                },
                itemBuilder: (item, index) {
                  return SizedBox(height: 150, child: Text(item));
                },
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(find.byType(RefreshIndicator), findsOneWidget);
          expect(callCount, 1);

          await tester.fling(
            find.byType(ListView),
            const Offset(0, 300),
            1000,
          );
          await tester.pumpAndSettle();

          expect(callCount, 2);
        },
      );
    });

    /// Tests guarding against stale fetches racing a refresh.
    group('Refresh Race Condition', () {
      testWidgets(
        'Discards an in-flight fetch that resolves after refresh',
        (tester) async {
          final requestedPages = <int>[];
          final completers = <Completer<List<String>?>>[];
          final controller = ScrollInfinityController();

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 2,
                controller: controller,
                loadData: (page) {
                  requestedPages.add(page);
                  final completer = Completer<List<String>?>();
                  completers.add(completer);
                  return completer.future;
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          // The initial fetch for page 0 is in flight.
          expect(requestedPages, [0]);

          // Refreshing while that fetch is pending starts a second fetch
          // for page 0.
          controller.refresh();
          await tester.pump();
          expect(requestedPages, [0, 0]);

          // The stale fetch resolves after the refresh: its batch must be
          // discarded instead of polluting the cleared list.
          completers[0].complete(['Stale A', 'Stale B']);
          await tester.pump();
          expect(find.text('Stale A'), findsNothing);

          // The post-refresh fetch resolves and only its items are shown.
          completers[1].complete(['Fresh A', 'Fresh B']);
          await tester.pump();
          expect(find.text('Fresh A'), findsOneWidget);
          expect(find.text('Fresh B'), findsOneWidget);
          expect(find.text('Stale A'), findsNothing);
          expect(find.text('Stale B'), findsNothing);

          // The list does not fill the screen, so the next page is fetched
          // automatically. It must be page 1: the stale fetch must not have
          // advanced the page index.
          await tester.pump();
          expect(requestedPages, [0, 0, 1]);

          completers[2].complete([]);
          await tester.pump();
        },
      );
    });

    /// Tests for properties passed straight through to the underlying
    /// [ListView].
    group('ListView Passthrough', () {
      testWidgets(
        'Applies physics, shrinkWrap and cacheExtent',
        (tester) async {
          const physics = BouncingScrollPhysics();

          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                physics: physics,
                shrinkWrap: true,
                cacheExtent: 500,
                loadData: (page) {
                  return mockLoadData(page, totalItems: 5, maxItemsPerPage: 5);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();

          final listView = tester.widget<ListView>(find.byType(ListView));
          expect(listView.physics, physics);
          expect(listView.shrinkWrap, isTrue);
          expect(
            listView.scrollCacheExtent,
            const ScrollCacheExtent.pixels(500),
          );
        },
      );

      testWidgets(
        'Leaves scrollCacheExtent null when cacheExtent is not set',
        (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              ScrollInfinity<String>(
                maxItems: 5,
                loadData: (page) {
                  return mockLoadData(page, totalItems: 5, maxItemsPerPage: 5);
                },
                itemBuilder: (item, index) => Text(item),
              ),
            ),
          );

          await tester.pumpAndSettle();

          final listView = tester.widget<ListView>(find.byType(ListView));
          expect(listView.scrollCacheExtent, isNull);
        },
      );
    });

    /// Tests for the `loadMoreThreshold` property.
    group('Configuration Validation', () {
      test('loadMoreThreshold cannot be negative', () {
        expect(
          () => ScrollInfinity<String>(
            maxItems: 5,
            loadMoreThreshold: -1,
            loadData: (page) async => [],
            itemBuilder: (item, index) => Text(item),
          ),
          throwsAssertionError,
        );
      });

      test('initialPageIndex cannot be negative', () {
        expect(
          () => ScrollInfinity<String>(
            maxItems: 5,
            initialPageIndex: -1,
            loadData: (page) async => [],
            itemBuilder: (item, index) => Text(item),
          ),
          throwsAssertionError,
        );
      });

      test('interval must be greater than zero', () {
        expect(
          () => ScrollInfinity<String?>(
            maxItems: 5,
            interval: 0,
            loadData: (page) async => [],
            itemBuilder: (item, index) => Text(item ?? ''),
          ),
          throwsAssertionError,
        );
      });

      test('interval requires a nullable generic type T', () {
        expect(
          () => ScrollInfinity<String>(
            maxItems: 5,
            interval: 2,
            loadData: (page) async => [],
            itemBuilder: (item, index) => Text(item),
          ),
          throwsAssertionError,
        );
      });

      test('maxRetries cannot be negative', () {
        expect(
          () => ScrollInfinity<String>(
            maxItems: 5,
            maxRetries: -1,
            loadData: (page) async => [],
            itemBuilder: (item, index) => Text(item),
          ),
          throwsAssertionError,
        );
      });

    });
  });
}

/// Hosts a [ScrollInfinity] whose `interval` can be toggled at runtime
/// while keeping a stable `loadData` reference, used to reproduce state
/// resets triggered by `interval` changing alone.
class _IntervalToggleHost extends StatefulWidget {
  const _IntervalToggleHost({required this.loadData});

  final Future<List<String>?> Function(int page) loadData;

  @override
  State<_IntervalToggleHost> createState() => _IntervalToggleHostState();
}

class _IntervalToggleHostState extends State<_IntervalToggleHost> {
  int? _interval;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          key: const Key('toggle_interval'),
          onPressed: () => setState(
            () => _interval = _interval == null ? 2 : null,
          ),
          child: const Text('Toggle interval'),
        ),
        Expanded(
          child: ScrollInfinity<String?>(
            maxItems: 5,
            interval: _interval,
            loadData: widget.loadData,
            itemBuilder: (item, index) => Text(item ?? 'interval_$index'),
          ),
        ),
      ],
    );
  }
}
