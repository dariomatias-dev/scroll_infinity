part of 'scroll_infinity.dart';

/// Notifier for initial items of infinite scroll.
class InitialItemsNotifier<T> extends ValueNotifier<List<T>?> {
  InitialItemsNotifier(
    super.value,
  );

  /// Indicates if an error has occurred.
  bool _hasError = false;

  /// Indicates if the notifier was disposed.
  bool isDisposed = false;

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

  @override
  void dispose() {
    isDisposed = true;

    super.dispose();
  }
}
