part of 'scroll_infinity.dart';

/// The kind of footer to render at the end of a paginated list.
enum ScrollInfinityFooterType {
  /// No footer should be rendered.
  none,

  /// The loading indicator, shown while fetching another page.
  loading,

  /// The retry widget, shown after a failed fetch.
  error,

  /// The manual "load more" trigger, shown when automatic loading is off.
  manualLoad,

  /// The empty-state widget, shown when the initial fetch returned no items.
  empty,
}
