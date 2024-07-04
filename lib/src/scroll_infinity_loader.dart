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

class ScrollInfinityLoader<T> extends StatelessWidget {
  const ScrollInfinityLoader({
    super.key,
    required this.notifier,
    required this.scrollInfinityBuilder,
  });

  final ScrollInfinityInitialItemsNotifier<T> notifier;
  final ScrollInfinity Function(
    List<T> items,
  ) scrollInfinityBuilder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, value, child) {
        if (notifier.hasError) {
          return const Center(
            child: Text('Error fetching data.'),
          );
        } else if (value == null) {
          return const Center(
            child: Text('Loading data...'),
          );
        } else if (value.isEmpty) {
          return const Center(
            child: Text('No items available at the moment.'),
          );
        }

        return scrollInfinityBuilder(value);
      },
    );
  }
}
