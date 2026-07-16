import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_infinity/src/interval_item_mapper.dart';

void main() {
  group('IntervalItemMapper', () {
    test('addAll appends items as-is when interval is null', () {
      final mapper = IntervalItemMapper<String>()
        ..addAll(['a', 'b'], interval: null)
        ..addAll(['c'], interval: null);

      expect(mapper.displayItems, ['a', 'b', 'c']);
    });

    test('addAll inserts a placeholder every `interval` real items', () {
      final mapper = IntervalItemMapper<String?>()
        ..addAll(['a', 'b', 'c', 'd', 'e'], interval: 2);

      expect(mapper.displayItems, ['a', 'b', null, 'c', 'd', null, 'e']);
    });

    test('placeholder insertion continues correctly across calls', () {
      final mapper = IntervalItemMapper<String?>()
        ..addAll(['a', 'b'], interval: 2)
        ..addAll(['c', 'd'], interval: 2);

      expect(mapper.displayItems, ['a', 'b', null, 'c', 'd']);
    });

    test(
      'indexFor returns independent indices for items and placeholders '
      'when useRealItemIndex is true',
      () {
        final mapper = IntervalItemMapper<String?>()
          ..addAll(['a', 'b', 'c'], interval: 2);

        // Display order: a(0) b(1) null(2) c(3)
        expect(
          mapper.indexFor(0, useRealItemIndex: true, interval: 2),
          0,
        ); // a -> real index 0
        expect(
          mapper.indexFor(1, useRealItemIndex: true, interval: 2),
          1,
        ); // b -> real index 1
        expect(
          mapper.indexFor(2, useRealItemIndex: true, interval: 2),
          0,
        ); // first placeholder -> placeholder index 0
        expect(
          mapper.indexFor(3, useRealItemIndex: true, interval: 2),
          2,
        ); // c -> real index 2
      },
    );

    test(
      'indexFor returns the raw display index when useRealItemIndex is '
      'false',
      () {
        final mapper = IntervalItemMapper<String?>()
          ..addAll(['a', 'b', 'c'], interval: 2);

        for (var i = 0; i < mapper.displayItems.length; i++) {
          expect(
            mapper.indexFor(i, useRealItemIndex: false, interval: 2),
            i,
          );
        }
      },
    );

    test(
      'indexFor returns the raw display index when interval is null',
      () {
        final mapper = IntervalItemMapper<String>()
          ..addAll(['a', 'b'], interval: null);

        expect(mapper.indexFor(1, useRealItemIndex: true, interval: null), 1);
      },
    );

    test('clear resets items and counters', () {
      final mapper = IntervalItemMapper<String?>()
        ..addAll(['a', 'b', 'c'], interval: 2)
        ..clear();

      expect(mapper.displayItems, isEmpty);

      mapper.addAll(['x', 'y', 'z'], interval: 2);

      // Counters restart from zero, matching a fresh mapper's output.
      expect(mapper.displayItems, ['x', 'y', null, 'z']);
    });
  });
}
