import 'dart:collection';

/// Builds a display list from paginated data, optionally interspersing
/// `null` placeholder items every `interval` real items.
///
/// Used internally to support the `interval` feature of `ScrollInfinity`
/// while keeping track of independent indices for data items and
/// placeholder items.
class IntervalItemMapper<T> {
  final List<T> _displayItems = [];
  final List<int> _mappedIndices = [];

  int _realItemsSinceLastPlaceholder = 0;
  int _realItemCounter = 0;
  int _placeholderCounter = 0;

  late final UnmodifiableListView<T> _displayItemsView = UnmodifiableListView(
    _displayItems,
  );

  /// The items to render, in display order (data items interleaved with
  /// `null` placeholders whenever an `interval` is supplied to [addAll]).
  ///
  /// The returned list is an unmodifiable view over the internal list: it
  /// reflects later [addAll]/[clear] calls but cannot be mutated by callers.
  List<T> get displayItems => _displayItemsView;

  /// Appends [newItems], inserting a `null` placeholder every [interval]
  /// real items. When [interval] is `null`, items are appended as-is.
  void addAll(List<T> newItems, {required int? interval}) {
    if (interval == null) {
      _displayItems.addAll(newItems);
      return;
    }

    for (final item in newItems) {
      if (_realItemsSinceLastPlaceholder == interval) {
        _displayItems.add(null as T);
        _mappedIndices.add(_placeholderCounter);
        _placeholderCounter++;
        _realItemsSinceLastPlaceholder = 0;
      }

      _displayItems.add(item);
      _mappedIndices.add(_realItemCounter);
      _realItemCounter++;
      _realItemsSinceLastPlaceholder++;
    }
  }

  /// The index to report for the display item at [displayIndex].
  ///
  /// When [useRealItemIndex] is `true` and [interval] is non-null, returns
  /// the item's independent index within its own kind (data item or
  /// placeholder). Otherwise, returns [displayIndex] unchanged.
  ///
  /// Items appended with a `null` interval carry no independent index, so
  /// [displayIndex] is also returned when the two modes were mixed without
  /// a [clear] in between.
  int indexFor(
    int displayIndex, {
    required bool useRealItemIndex,
    required int? interval,
  }) {
    if (useRealItemIndex &&
        interval != null &&
        _mappedIndices.length == _displayItems.length) {
      return _mappedIndices[displayIndex];
    }
    return displayIndex;
  }

  /// Clears all items and resets internal counters.
  void clear() {
    _displayItems.clear();
    _mappedIndices.clear();
    _realItemsSinceLastPlaceholder = 0;
    _realItemCounter = 0;
    _placeholderCounter = 0;
  }
}
