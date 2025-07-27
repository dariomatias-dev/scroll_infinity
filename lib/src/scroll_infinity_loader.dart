import 'package:flutter/material.dart';

import 'package:scroll_infinity/src/initial_items_notifier.dart';

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

  /// Widget to be displayed in case of an error.
  final Widget? error;

  /// Error message to display when a failure occurs.
  final String? errorMessage;

  /// Style for the error message text.
  final TextStyle? errorMessageStyle;

  /// Widget to be displayed during loading.
  final Widget? loading;

  /// Message to be displayed while loading.
  final String? loadingMessage;

  /// Style for the loading message text.
  final TextStyle? loadingMessageStyle;

  /// Widget to be displayed when there are no items to show.
  final Widget? empty;

  /// Message to display when the list is empty.
  final String? emptyMessage;

  /// Style for the empty list message text.
  final TextStyle? emptyMessageStyle;

  /// Notifier that manages the initial list state.
  final InitialItemsNotifier<T> notifier;

  /// Builds the `ScrollInfinity` widget when data is available.
  final Widget Function(
    List<T> items,
  ) scrollInfinityBuilder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<T>?>(
      valueListenable: notifier,
      builder: (context, items, child) {
        if (notifier.hasError) {
          return Center(
            child: error ??
                Text(
                  errorMessage ?? 'An error occurred while fetching the data.',
                  style: errorMessageStyle,
                ),
          );
        }

        if (items == null) {
          return Center(
            child: loading ??
                Text(
                  loadingMessage ?? 'Loading data...',
                  style: loadingMessageStyle,
                ),
          );
        }

        if (items.isEmpty) {
          return Center(
            child: empty ??
                Text(
                  emptyMessage ?? 'No items available at the moment.',
                  style: emptyMessageStyle,
                ),
          );
        }

        return scrollInfinityBuilder(items);
      },
    );
  }
}
