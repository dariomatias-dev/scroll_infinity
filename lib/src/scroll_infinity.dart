import 'dart:async';

import 'package:flutter/material.dart';

/// A widget that displays a scrollable list with support for paginated data loading.
///
/// As the user scrolls, additional items are automatically fetched to fill the viewport.
/// This widget also provides built-in support for handling loading, empty, and error states.
class ScrollInfinity<T> extends StatefulWidget {
  const ScrollInfinity({
    super.key,
    required this.loadData,
    required this.itemBuilder,
    required this.maxItems,
    this.initialItems,
    this.initialPageIndex = 0,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.header,
    this.separatorBuilder,
    this.scrollbars = true,
    this.interval,
    this.enableRetryOnError = true,
    this.loading,
    this.empty,
    this.tryAgainBuilder,
    this.useRealItemIndex = true,
    this.maxRetries,
    this.retryLimitReachedWidget,
  })  : assert(
          initialPageIndex >= 0,
          'The initial page index cannot be less than zero.',
        ),
        assert(
          interval == null || interval > 0,
          'The interval must be greater than zero.',
        ),
        assert(
          interval != null ? null is T : true,
          'When `interval` is used, the generic type `T` must be nullable (e.g., String?).',
        ),
        assert(
          maxRetries == null || maxRetries >= 0,
          'maxRetries cannot be negative.',
        );

  /// Callback responsible for fetching data for each page.
  final Future<List<T>?> Function(
    int pageIndex,
  ) loadData;

  /// Builder function responsible for rendering each item in the list.
  ///
  /// When an interval is used, `value` will be `null` for interval items.
  /// It is the developer's responsibility to use a nullable type for `T`
  /// (e.g., `String?`) if `interval` is non-null.
  final Widget Function(
    T value,
    int index,
  ) itemBuilder;

  /// The maximum number of items to retrieve per request.
  final int maxItems;

  /// A list of items displayed before the first data fetch is initiated.
  final List<T>? initialItems;

  /// The starting index from which to begin loading data.
  final int initialPageIndex;

  /// Defines the scroll direction of the list. Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Defines the internal padding of the list view.
  final EdgeInsetsGeometry? padding;

  /// A widget displayed at the beginning of the list.
  final Widget? header;

  /// A builder that inserts separators between list items.
  final Widget Function(
    BuildContext context,
    int index,
  )? separatorBuilder;

  /// Determines whether scrollbars should be displayed. Defaults to `true`.
  final bool scrollbars;

  /// Specifies an interval at which a `null` value is inserted into the list.
  final int? interval;

  /// Indicates whether retrying is allowed when an error occurs.
  final bool enableRetryOnError;

  /// Custom widget shown during the loading of additional data.
  final Widget? loading;

  /// Widget displayed when the initial data fetch returns an empty result.
  final Widget? empty;

  /// A builder that constructs a custom 'Try Again' widget when an error occurs.
  final Widget Function(
    VoidCallback action,
  )? tryAgainBuilder;

  /// The index ignores range items and reflects only actual data items.
  ///
  /// The default is `true`.
  final bool useRealItemIndex;

  /// The maximum number of retries to attempt after a failed data fetch.
  ///
  /// If `null`, retries will be attempted indefinitely. Defaults to `null`.
  final int? maxRetries;

  /// A widget to display when the `maxRetries` limit has been reached.
  ///
  /// If not provided, a default message is shown.
  final Widget? retryLimitReachedWidget;

  @override
  State<ScrollInfinity<T>> createState() => _ScrollInfinityState<T>();
}

class _ScrollInfinityState<T> extends State<ScrollInfinity<T>> {
  final _scrollController = ScrollController();

  final _displayItems = <T>[];
  final _mappedIndices = <int>[];
  int _realItemsCountSinceInterval = 0;
  int _realItemCounter = 0;
  int _intervalCounter = 0;
  int _pageIndex = 0;
  int _retryCount = 0;
  bool _isLoading = false;
  bool _isEndOfList = false;
  bool _hasError = false;
  bool _isDisposed = false;

  void _initialize() {
    _pageIndex = widget.initialPageIndex;

    if (widget.initialItems != null) {
      _processAndAddItems(widget.initialItems!);
      _isEndOfList = widget.initialItems!.length < widget.maxItems;
      _checkIfScreenIsFilledAndFetchMore();
    } else {
      _fetchNextPage();
    }
  }

  Future<void> _reset() async {
    if (mounted) {
      setState(() {
        _displayItems.clear();
        _mappedIndices.clear();
        _realItemsCountSinceInterval = 0;
        _realItemCounter = 0;
        _intervalCounter = 0;
        _pageIndex = widget.initialPageIndex;
        _retryCount = 0;
        _isLoading = false;
        _isEndOfList = false;
        _hasError = false;
      });

      _initialize();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isEndOfList &&
        !_hasError) {
      _fetchNextPage();
    }
  }

  void _processAndAddItems(List<T> newItems) {
    if (widget.interval == null) {
      _displayItems.addAll(newItems);
      return;
    }

    for (final item in newItems) {
      if (_realItemsCountSinceInterval == widget.interval) {
        _displayItems.add(null as T);
        _mappedIndices.add(_intervalCounter);
        _intervalCounter++;
        _realItemsCountSinceInterval = 0;
      }

      _displayItems.add(item);
      _mappedIndices.add(_realItemCounter);
      _realItemCounter++;
      _realItemsCountSinceInterval++;
    }
  }

  void _checkIfScreenIsFilledAndFetchMore() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          !_isEndOfList &&
          !_isLoading &&
          _scrollController.position.maxScrollExtent == 0) {
        _fetchNextPage();
      }
    });
  }

  Future<void> _fetchNextPage() async {
    if (_isLoading || _isEndOfList || _isDisposed) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final newItems = await widget.loadData(_pageIndex);

      if (_isDisposed) return;

      if (newItems != null) {
        _retryCount = 0;
        _processAndAddItems(newItems);
        _pageIndex++;
        _isEndOfList = newItems.length < widget.maxItems;
        _checkIfScreenIsFilledAndFetchMore();
      } else {
        _retryCount++;
        _hasError = true;
      }
    } catch (e) {
      if (_isDisposed) return;
      _retryCount++;
      _hasError = true;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildListView() {
    final hasHeader = widget.header != null;
    final headerCount = hasHeader ? 1 : 0;

    final hasFooter =
        _isLoading || _hasError || (_isEndOfList && _displayItems.isEmpty);

    final itemCount = headerCount + _displayItems.length + (hasFooter ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      itemCount: itemCount,
      separatorBuilder: (context, index) {
        if (widget.separatorBuilder == null) {
          return const SizedBox.shrink();
        }

        if (hasHeader && index == 0) {
          return const SizedBox.shrink();
        }

        final itemIndex = index - headerCount;
        if (itemIndex >= 0 && itemIndex < _displayItems.length - 1) {
          return widget.separatorBuilder!(context, itemIndex);
        }

        return const SizedBox.shrink();
      },
      itemBuilder: (context, index) {
        if (hasHeader && index == 0) {
          return widget.header!;
        }

        final itemIndex = index - headerCount;

        if (itemIndex < _displayItems.length) {
          final item = _displayItems[itemIndex];

          int finalIndex = itemIndex;
          if (widget.useRealItemIndex && widget.interval != null) {
            finalIndex = _mappedIndices[itemIndex];
          }

          return widget.itemBuilder(item, finalIndex);
        }

        if (_hasError) {
          return _buildRetryWidget();
        }
        if (_isLoading) {
          return _buildLoadingIndicator();
        }
        if (_isEndOfList && _displayItems.isEmpty) {
          return widget.empty ?? const Center(child: Text('No items found.'));
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return widget.loading ??
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
  }

  Widget _buildRetryWidget() {
    if (!widget.enableRetryOnError) return const SizedBox.shrink();

    if (widget.maxRetries != null && _retryCount >= widget.maxRetries!) {
      return widget.retryLimitReachedWidget ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Retry limit has been reached.'),
            ),
          );
    }

    if (widget.tryAgainBuilder != null) {
      return widget.tryAgainBuilder!(_fetchNextPage);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: _fetchNextPage,
          child: const Text('Try Again'),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _initialize();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ScrollInfinity<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.loadData != oldWidget.loadData ||
        widget.maxItems != oldWidget.maxItems) {
      _reset();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: widget.scrollbars,
      ),
      child: _buildListView(),
    );
  }
}
