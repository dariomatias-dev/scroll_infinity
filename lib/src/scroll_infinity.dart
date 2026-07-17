import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:scroll_infinity/src/interval_item_mapper.dart';
import 'package:scroll_infinity/src/scroll_infinity_action_button.dart';
import 'package:scroll_infinity/src/scroll_infinity_controller.dart';
import 'package:scroll_infinity/src/scroll_infinity_footer_type.dart';

/// A widget that displays a scrollable list with support for paginated
/// data loading.
class ScrollInfinity<T> extends StatefulWidget {
  /// Creates a [ScrollInfinity] widget.
  const ScrollInfinity({
    required this.loadData,
    required this.itemBuilder,
    required this.maxItems,
    super.key,

    // Core Data Handling
    this.initialItems,
    this.initialPageIndex = 0,
    this.controller,

    // Layout & Appearance
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.header,
    this.separatorBuilder,
    this.scrollbars = true,
    this.enablePullToRefresh = false,
    this.physics,
    this.shrinkWrap = false,
    this.primary,
    this.cacheExtent,

    // Behavioral Features
    this.interval,
    this.useRealItemIndex = true,
    this.automaticLoading = true,
    this.loadMoreThreshold = 200,

    // Error Handling
    this.enableRetryOnError = true,
    this.maxRetries,
    this.onError,

    // State-Specific Widgets
    this.loading,
    this.empty,
    this.tryAgainBuilder,
    this.loadMoreBuilder,
    this.retryLimitReached,
  })  : assert(
          initialPageIndex >= 0,
          'The initial page index cannot be less than zero.',
        ),
        assert(
          interval == null || interval > 0,
          'The interval must be greater than zero.',
        ),
        assert(
          !(interval != null) || null is T,
          'When `interval` is used, the generic type `T` must be nullable '
          '(e.g., String?).',
        ),
        assert(
          maxRetries == null || maxRetries >= 0,
          'maxRetries cannot be negative.',
        ),
        assert(
          loadMoreThreshold >= 0,
          'loadMoreThreshold cannot be negative.',
        );

  // Core Data Handling

  /// Callback responsible for fetching data for each page.
  final Future<List<T>?> Function(
    int pageIndex,
  ) loadData;

  /// Builder function responsible for rendering each item in the list.
  ///
  /// When an interval is used, `value` will be `null` for interval items.
  /// A nullable type must be used for `T`
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

  /// Optional controller to trigger [ScrollInfinityController.refresh] or
  /// [ScrollInfinityController.retry] externally and read
  /// [ScrollInfinityController.isLoading]/[ScrollInfinityController.hasError].
  final ScrollInfinityController? controller;

  // Layout & Appearance

  /// Defines the scroll direction of the list. Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether the list scrolls in the reading direction (`false`, the
  /// default) or the opposite direction (`true`).
  ///
  /// Useful for chat-style layouts: with `reverse: true`, item `0` (the
  /// newest message) is drawn at the end of the list, and pagination
  /// (triggered by scrolling toward the list's start) loads older items.
  final bool reverse;

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

  /// Wraps the list in a [RefreshIndicator] that resets and refetches from
  /// [initialPageIndex] on pull-to-refresh. Defaults to `false`.
  final bool enablePullToRefresh;

  /// Passed directly to the underlying [ListView.physics].
  final ScrollPhysics? physics;

  /// Passed directly to the underlying [ListView.shrinkWrap].
  /// Defaults to `false`.
  final bool shrinkWrap;

  /// Passed directly to the underlying [ListView.primary].
  final bool? primary;

  /// Cache extent, in logical pixels, passed to the underlying
  /// [ListView] as a [ScrollCacheExtent.pixels] value.
  final double? cacheExtent;

  // Behavioral Features

  /// Specifies an interval at which a `null` value is inserted into the list.
  final int? interval;

  /// If `true`, real data items have their own index that ignores interval
  /// (`null`) items, meaning data items and interval items have independent
  /// indexes.
  ///
  /// The default is `true`.
  final bool useRealItemIndex;

  /// Determines if new items are fetched automatically on scroll.
  ///
  /// If `false`, a 'Load More' button will be displayed at the end of the
  /// list. Defaults to `true`.
  final bool automaticLoading;

  /// Distance in pixels from the end of the list at which the next page
  /// starts loading. Defaults to `200`.
  final double loadMoreThreshold;

  // Error Handling

  /// Indicates whether retrying is allowed when an error occurs.
  final bool enableRetryOnError;

  /// Maximum number of retries after a failed data fetch.
  ///
  /// If `null`, retries will be attempted indefinitely. The default is `null`.
  final int? maxRetries;

  /// Called with the exception thrown by [loadData] whenever a fetch fails.
  ///
  /// Use this to log or report the real error; it does not build UI.
  final void Function(Object error)? onError;

  // State-Specific Widgets

  /// Custom widget shown during the loading of additional data.
  final Widget? loading;

  /// Widget displayed when the initial data fetch returns an empty result.
  final Widget? empty;

  /// A builder that constructs a custom 'Try Again' widget when an error
  /// occurs.
  final Widget Function(
    VoidCallback action,
  )? tryAgainBuilder;

  /// A builder that constructs a custom 'Load More' widget when
  /// [automaticLoading] is `false`.
  final Widget Function(
    VoidCallback action,
  )? loadMoreBuilder;

  /// A widget to display when the [maxRetries] limit has been reached.
  ///
  /// If not provided, a default message is shown.
  final Widget? retryLimitReached;

  @override
  State<ScrollInfinity<T>> createState() => _ScrollInfinityState<T>();
}

class _ScrollInfinityState<T> extends State<ScrollInfinity<T>>
    implements ScrollInfinityControllerState {
  final _scrollController = ScrollController();
  final _itemMapper = IntervalItemMapper<T>();

  int _pageIndex = 0;
  int _retryCount = 0;
  bool _isLoading = false;
  bool _isEndOfList = false;
  bool _hasError = false;
  bool _isDisposed = false;

  @override
  bool get isLoading => _isLoading;

  @override
  bool get hasError => _hasError;

  @override
  void refresh() => unawaited(_reset());

  @override
  void retry() => unawaited(_fetchNextPage());

  ScrollInfinityFooterType get _footerType {
    if (_hasError) return ScrollInfinityFooterType.error;
    if (_isLoading) return ScrollInfinityFooterType.loading;
    if (!widget.automaticLoading && !_isEndOfList) {
      return ScrollInfinityFooterType.manualLoad;
    }
    if (_isEndOfList && _itemMapper.displayItems.isEmpty) {
      return ScrollInfinityFooterType.empty;
    }
    return ScrollInfinityFooterType.none;
  }

  void _initialize() {
    _pageIndex = widget.initialPageIndex;

    if (widget.initialItems != null) {
      _itemMapper.addAll(widget.initialItems!, interval: widget.interval);
      _checkIfScreenIsFilledAndFetchMore();
    } else {
      unawaited(_fetchNextPage());
    }
  }

  Future<void> _reset() async {
    if (mounted) {
      setState(() {
        _itemMapper.clear();
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
    if (!widget.automaticLoading) return;

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                widget.loadMoreThreshold &&
        !_isLoading &&
        !_isEndOfList &&
        !_hasError) {
      unawaited(_fetchNextPage());
    }
  }

  void _checkIfScreenIsFilledAndFetchMore() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          widget.automaticLoading &&
          !_isEndOfList &&
          !_isLoading &&
          _scrollController.position.maxScrollExtent == 0) {
        unawaited(_fetchNextPage());
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
        _itemMapper.addAll(newItems, interval: widget.interval);
        _pageIndex++;
        _isEndOfList = newItems.length < widget.maxItems;
        _checkIfScreenIsFilledAndFetchMore();
      } else {
        _retryCount++;
        _hasError = true;
      }
    } on Object catch (error) {
      if (_isDisposed) return;
      _retryCount++;
      _hasError = true;
      widget.onError?.call(error);
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
    final footerType = _footerType;
    final hasFooter = footerType != ScrollInfinityFooterType.none;
    final displayItems = _itemMapper.displayItems;
    final itemCount = headerCount + displayItems.length + (hasFooter ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      primary: widget.primary,
      scrollCacheExtent: widget.cacheExtent == null
          ? null
          : ScrollCacheExtent.pixels(widget.cacheExtent!),
      itemCount: itemCount,
      separatorBuilder: (context, index) {
        if (widget.separatorBuilder == null) {
          return const SizedBox.shrink();
        }

        if (hasHeader && index == 0) {
          return const SizedBox.shrink();
        }

        final itemIndex = index - headerCount;
        if (itemIndex >= 0 && itemIndex < displayItems.length - 1) {
          return widget.separatorBuilder!(context, itemIndex);
        }

        return const SizedBox.shrink();
      },
      itemBuilder: (context, index) {
        if (hasHeader && index == 0) {
          return widget.header!;
        }

        final itemIndex = index - headerCount;

        if (itemIndex < displayItems.length) {
          final finalIndex = _itemMapper.indexFor(
            itemIndex,
            useRealItemIndex: widget.useRealItemIndex,
            interval: widget.interval,
          );

          return widget.itemBuilder(displayItems[itemIndex], finalIndex);
        }

        return _buildFooter(footerType);
      },
    );
  }

  Widget _buildFooter(ScrollInfinityFooterType footerType) {
    switch (footerType) {
      case ScrollInfinityFooterType.error:
        return _buildRetryWidget();
      case ScrollInfinityFooterType.loading:
        return _buildLoadingIndicator();
      case ScrollInfinityFooterType.manualLoad:
        return _buildLoadMoreWidget();
      case ScrollInfinityFooterType.empty:
        return widget.empty ?? const Center(child: Text('No items found.'));
      case ScrollInfinityFooterType.none:
        return const SizedBox.shrink();
    }
  }

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

    if (widget.maxRetries != null && _retryCount >= widget.maxRetries!) {
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

  @override
  void initState() {
    super.initState();

    widget.controller?.attach(this);
    _initialize();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ScrollInfinity<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.detach(this);
      widget.controller?.attach(this);
    }

    if (widget.loadData != oldWidget.loadData ||
        widget.maxItems != oldWidget.maxItems ||
        widget.interval != oldWidget.interval) {
      unawaited(_reset());
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    widget.controller?.detach(this);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: widget.scrollbars,
      ),
      child: _buildListView(),
    );

    if (widget.enablePullToRefresh) {
      child = RefreshIndicator(
        onRefresh: _reset,
        child: child,
      );
    }

    return child;
  }
}
