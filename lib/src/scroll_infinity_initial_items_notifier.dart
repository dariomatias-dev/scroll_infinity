part of 'scroll_infinity.dart';

class ScrollInfinityInitialItemsNotifier<T> extends ValueNotifier<List<T>?> {
  ScrollInfinityInitialItemsNotifier(
    super.value,
  );

  bool _hasError = false;

  bool get hasError => _hasError;

  void update({
    required List<T>? items,
    bool hasError = false,
  }) {
    value = items;
    _hasError = hasError;

    notifyListeners();
  }
}
