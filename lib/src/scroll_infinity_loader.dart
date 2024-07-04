part of 'scroll_infinity.dart';

class ScrollInfinityLoader<T> extends StatelessWidget {
  const ScrollInfinityLoader({
    super.key,
    this.error,
    this.errorMessage,
    this.errorMessageStyle,
    this.loading,
    this.loadingMessage,
    this.loadingMessageStyle,
    this.empty,
    this.emptyMessage,
    this.emptyMessageStyle,
    required this.notifier,
    required this.scrollInfinityBuilder,
  });

  /// Widget to display in case of error.
  final Widget? error;

  /// Error message to display in case of failure.
  final String? errorMessage;

  /// Style for the error message text.
  final TextStyle? errorMessageStyle;

  /// Widget to display during loading.
  final Widget? loading;

  /// Message to display during loading.
  final String? loadingMessage;

  /// Style for the loading message text.
  final TextStyle? loadingMessageStyle;

  /// Widget to display when there are no items to show.
  final Widget? empty;

  /// Message to display when there are no items to show.
  final String? emptyMessage;

  /// Style for the empty list message text.
  final TextStyle? emptyMessageStyle;

  /// Notifier for initial items of infinite scroll.
  final ScrollInfinityInitialItemsNotifier<T> notifier;

  /// Builder for infinite scroll that takes a list of `items`.
  final ScrollInfinity Function(
    List<T> items,
  ) scrollInfinityBuilder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, value, child) {
        if (notifier.hasError) {
          return Center(
            child: error ??
                Text(
                  errorMessage ?? 'Error fetching data.',
                  style: errorMessageStyle,
                ),
          );
        } else if (value == null) {
          return Center(
            child: loading ??
                Text(
                  loadingMessage ?? 'Loading data...',
                  style: loadingMessageStyle,
                ),
          );
        } else if (value.isEmpty) {
          return Center(
            child: empty ??
                Text(
                  emptyMessage ?? 'No items available at the moment.',
                  style: emptyMessageStyle,
                ),
          );
        }

        return scrollInfinityBuilder(value);
      },
    );
  }
}
