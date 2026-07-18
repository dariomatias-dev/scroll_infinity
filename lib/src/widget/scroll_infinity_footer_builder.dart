part of 'scroll_infinity.dart';

extension _ScrollInfinityFooterBuilder<T> on _ScrollInfinityState<T> {
  Widget _buildLoadingIndicator() {
    return widget.loading ??
        const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
  }

  Widget _buildRetryWidget() {
    if (!widget.enableRetryOnError) return const SizedBox.shrink();

    if (_retryLimitReached) {
      return widget.retryLimitReached ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Retry limit has been reached.'),
            ),
          );
    }

    if (widget.tryAgainBuilder != null) {
      return widget.tryAgainBuilder!(_fetchNextPage);
    }

    return ScrollInfinityActionButton(
      label: 'Try Again',
      onPressed: _fetchNextPage,
    );
  }

  Widget _buildLoadMoreWidget() {
    if (widget.loadMoreBuilder != null) {
      return widget.loadMoreBuilder!(_fetchNextPage);
    }

    return ScrollInfinityActionButton(
      label: 'Load More',
      onPressed: _fetchNextPage,
    );
  }
}
