part of 'scroll_infinity.dart';

/// The kind of footer to render at the end of a paginated list.
enum _ScrollInfinityFooterType {
  /// No footer should be rendered.
  none,

  /// The loading indicator, shown while fetching another page.
  loading,

  /// The retry trigger, shown after a failed fetch that may be retried.
  error,

  /// The retry-limit message, shown after a failed fetch once no retries
  /// are left.
  retryLimitReached,

  /// The manual "load more" trigger, shown when automatic loading is off.
  manualLoad,

  /// The empty-state widget, shown when the initial fetch returned no items.
  empty,
}
