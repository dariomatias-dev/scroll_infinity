import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scroll_infinity/src/message_field_widget.dart';

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
    this.scrollbars = false,
    this.interval,
    this.enableRetryOnError = true,
    this.loading,
    this.empty,
    this.tryAgainBuilder,
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
          'The generic type `T` must be nullable when `interval` is provided.',
        );

  /// Callback responsible for fetching data for each page.
  final Future<List<T>?> Function(
    int pageIndex,
  ) loadData;

  /// Builder function responsible for rendering each item in the list.
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

  /// Determines whether scrollbars should be displayed. Defaults to `false`.
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

  @override
  State<ScrollInfinity<T>> createState() => _ScrollInfinityState<T>();
}

class _ScrollInfinityState<T> extends State<ScrollInfinity<T>> {
  final _scrollController = ScrollController();

  final _displayItems = <T?>[];
  int _realItemsCountSinceInterval = 0;
  int _pageIndex = 0;
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
        _realItemsCountSinceInterval = 0;
        _pageIndex = widget.initialPageIndex;
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
        _displayItems.add(null);
        _realItemsCountSinceInterval = 0;
      }

      _displayItems.add(item);
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
        _processAndAddItems(newItems);
        _pageIndex++;
        _isEndOfList = newItems.length < widget.maxItems;
        _checkIfScreenIsFilledAndFetchMore();
      } else {
        _hasError = true;
      }
    } catch (e) {
      if (_isDisposed) return;
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
    if (_displayItems.isEmpty) {
      if (_isLoading) {
        return _buildLoadingIndicator();
      }
      if (_hasError) {
        return Center(child: _buildRetryWidget());
      }

      return widget.empty ??
          const MessageFieldWidget(
            message: 'No items found.',
          );
    }

    final itemCount = _displayItems.length +
        (widget.header != null ? 1 : 0) +
        (_isEndOfList ? 0 : 1);

    return ListView.separated(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      itemCount: itemCount,
      separatorBuilder: widget.separatorBuilder ??
          (context, index) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        if (widget.header != null) {
          if (index == 0) return widget.header!;
          index--;
        }

        if (index < _displayItems.length) {
          final item = _displayItems[index];

          return widget.itemBuilder(item as T, index);
        }

        if (_hasError) {
          return _buildRetryWidget();
        }
        if (_isLoading) {
          return _buildLoadingIndicator();
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
