import 'dart:async';
import 'package:flutter/material.dart';

import 'package:scroll_infinity/src/default_empty_component.dart';

/// A list widget that loads paginated data as the user scrolls.
class ScrollInfinity<T> extends StatefulWidget {
  const ScrollInfinity({
    super.key,
    required this.loadData,
    required this.itemBuilder,
    required this.maxItems,
    this.scrollDirection = Axis.vertical,
    this.scrollbars = false,
    this.padding,
    this.header,
    this.initialPageIndex = 0,
    this.enableRetryOnError = true,
    this.empty,
    this.error,
    this.initialItems,
    this.interval,
    this.loading,
    this.tryAgainButtonBuilder,
    this.separatorBuilder,
  })  : assert(
          initialPageIndex >= 0,
          'The initial page index cannot be less than zero.',
        ),
        assert(
          interval == null || interval > 0,
          'The interval must not be zero or negative.',
        ),
        assert(
          interval != null ? null is T : true,
          'Generic type `T` must be nullable when `interval` is not null.',
        );

  /// The function that fetches data for each page.
  final Future<List<T>?> Function(
    int pageIndex,
  ) loadData;

  /// Builds the widget for each item in the data list.
  final Widget Function(
    T value,
    int index,
  ) itemBuilder;

  /// The maximum number of items to fetch per request.
  final int maxItems;

  /// The scroll direction of the list.
  final Axis scrollDirection;

  /// Shows scrollbars if true.
  final bool scrollbars;

  /// The inner padding of the list.
  final EdgeInsetsGeometry? padding;

  /// A widget to be displayed at the top of the list.
  final Widget? header;

  /// The initial page index to load.
  final int initialPageIndex;

  /// Allows retrying data loading after an error.
  final bool enableRetryOnError;

  /// Widget to display when the initial fetch returns no items.
  final Widget? empty;

  /// This parameter is no longer used. Use `tryAgainButtonBuilder` to customize the error action.
  final Widget? error;

  /// An initial list of items to display.
  final List<T>? initialItems;

  /// The interval at which to insert a null value, e.g., for ads.
  final int? interval;

  /// A custom loading widget.
  final Widget? loading;

  /// Builds a custom "Try Again" button.
  final Widget Function(
    VoidCallback action,
  )? tryAgainButtonBuilder;

  /// Builds a separator between list items.
  final Widget Function(
    BuildContext context,
    int index,
  )? separatorBuilder;

  @override
  State<ScrollInfinity<T>> createState() => _ScrollInfinityState<T>();
}

class _ScrollInfinityState<T> extends State<ScrollInfinity<T>> {
  final _scrollController = ScrollController();

  final List<T?> _displayItems = [];
  int _realItemsCountSinceInterval = 0;
  int _pageIndex = 0;
  bool _isLoading = false;
  bool _isEndOfList = false;
  bool _hasError = false;
  bool _isDisposed = false;

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

  void _initialize() {
    _pageIndex = widget.initialPageIndex;
    if (widget.initialItems != null) {
      _processAndAddItems(widget.initialItems!);
      _isEndOfList = widget.initialItems!.length < widget.maxItems;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            _scrollController.position.maxScrollExtent == 0 &&
            !_isEndOfList) {
          _fetchNextPage();
        }
      });
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
      await Future.delayed(const Duration(milliseconds: 100));
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

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: widget.scrollbars,
      ),
      child: _buildListView(),
    );
  }

  Widget _buildListView() {
    // Case 1: The list is empty.
    if (_displayItems.isEmpty) {
      if (_isLoading) {
        return _buildLoadingIndicator();
      }
      if (_hasError) {
        return Center(child: _buildRetryWidget());
      }

      return widget.empty ?? const DefaultEmptyComponent();
    }

    // Case 2: The list has items.
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

        // Build list item.
        if (index < _displayItems.length) {
          final item = _displayItems[index];

          return widget.itemBuilder(item as T, index);
        }

        // Build footer (loading indicator or retry button).
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

    if (widget.tryAgainButtonBuilder != null) {
      return widget.tryAgainButtonBuilder!(_fetchNextPage);
    }

    return ElevatedButton(
      onPressed: _fetchNextPage,
      child: const Text('Try Again'),
    );
  }
}
