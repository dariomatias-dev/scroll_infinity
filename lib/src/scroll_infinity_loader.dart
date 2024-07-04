part of 'scroll_infinity.dart';

class ScrollInfinityLoader<T> extends StatelessWidget {
  const ScrollInfinityLoader({
    super.key,
    required this.notifier,
    required this.scrollInfinityBuilder,
    this.error,
    this.errorMessage,
    this.errorMessageStyle,
    this.loading,
    this.loadingMessage,
    this.loadingMessageStyle,
    this.empty,
    this.emptyMessage,
    this.emptyMessageStyle,
  });

  final ScrollInfinityInitialItemsNotifier<T> notifier;
  final ScrollInfinity Function(
    List<T> items,
  ) scrollInfinityBuilder;

  final Widget? error;
  final String? errorMessage;
  final TextStyle? errorMessageStyle;
  final Widget? loading;
  final String? loadingMessage;
  final TextStyle? loadingMessageStyle;
  final Widget? empty;
  final String? emptyMessage;
  final TextStyle? emptyMessageStyle;

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
