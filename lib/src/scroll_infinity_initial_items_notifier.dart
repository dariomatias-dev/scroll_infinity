part of 'scroll_infinity.dart';

/// Notifier for initial items of infinite scroll.
class ScrollInfinityInitialItemsNotifier<T> extends ValueNotifier<List<T>?> {
  ScrollInfinityInitialItemsNotifier(
    super.value,
  );

  /// Indicates if an error has occurred.
  bool _hasError = false;

  bool get hasError => _hasError;

  /// Updates the notifier with new `items` and optionally updates `hasError`.
  void update({
    required List<T>? items,
    bool hasError = false,
  }) {
    value = items;
    _hasError = hasError;

    notifyListeners();
  }
}
