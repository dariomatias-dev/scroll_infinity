part of 'scroll_infinity.dart';

class _ScrollInfinityState<T> extends State<ScrollInfinity<T>>
    implements ScrollInfinityControllerState {
  final _scrollController = ScrollController();
  final _itemMapper = IntervalItemMapper<T>();

  /// Maximum number of consecutive fetches triggered solely to fill the
  /// viewport. Guards against an unbounded fetch loop when the list never
  /// becomes scrollable (e.g. items with zero extent), in which case
  /// `maxScrollExtent` stays at `0` no matter how many pages are loaded.
  static const _maxViewportFillFetches = 10;

  int _pageIndex = 0;
  int _retryCount = 0;
  int _fetchGeneration = 0;
  int _viewportFillFetches = 0;
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
  void retry() {
    if (!_hasError) return;

    unawaited(_fetchNextPage());
  }

  _ScrollInfinityFooterType get _footerType {
    if (_hasError) {
      return widget.enableRetryOnError
          ? _ScrollInfinityFooterType.error
          : _ScrollInfinityFooterType.none;
    }
    if (_isLoading) return _ScrollInfinityFooterType.loading;
    if (!widget.automaticLoading && !_isEndOfList) {
      return _ScrollInfinityFooterType.manualLoad;
    }
    if (_isEndOfList && _itemMapper.displayItems.isEmpty) {
      return _ScrollInfinityFooterType.empty;
    }
    return _ScrollInfinityFooterType.none;
  }

  Future<void> _initialize() async {
    _pageIndex = widget.initialPageIndex;

    if (widget.initialItems != null) {
      _itemMapper.addAll(widget.initialItems!, interval: widget.interval);
      _checkIfScreenIsFilledAndFetchMore();
    } else {
      await _fetchNextPage();
    }
  }

  Future<void> _reset() async {
    if (mounted) {
      setState(() {
        _fetchGeneration++;
        _itemMapper.clear();
        _pageIndex = widget.initialPageIndex;
        _retryCount = 0;
        _viewportFillFetches = 0;
        _isLoading = false;
        _isEndOfList = false;
        _hasError = false;
      });

      await _initialize();
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
      if (!mounted ||
          !widget.automaticLoading ||
          _isEndOfList ||
          _isLoading ||
          !_scrollController.hasClients) {
        return;
      }

      if (_scrollController.position.maxScrollExtent > 0) {
        _viewportFillFetches = 0;
        return;
      }

      if (_viewportFillFetches >= _maxViewportFillFetches) return;

      _viewportFillFetches++;
      unawaited(_fetchNextPage());
    });
  }

  bool get _retryLimitReached =>
      widget.maxRetries != null && _retryCount > widget.maxRetries!;

  Future<void> _fetchNextPage() async {
    if (_isLoading || _isEndOfList || _isDisposed) return;

    if (_hasError && (!widget.enableRetryOnError || _retryLimitReached)) {
      return;
    }

    final generation = _fetchGeneration;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final newItems = await widget.loadData(_pageIndex);

      if (_isDisposed || generation != _fetchGeneration) return;

      if (newItems != null) {
        _retryCount = 0;
        _itemMapper.addAll(newItems, interval: widget.interval);
        _pageIndex++;
        _isEndOfList = newItems.length < widget.maxItems;
        _checkIfScreenIsFilledAndFetchMore();
        widget.onItemsLoaded?.call(newItems);
      } else {
        _retryCount++;
        _hasError = true;
        widget.onError?.call(
          Exception('loadData returned null for page $_pageIndex.'),
        );
      }
    } on Object catch (error) {
      if (_isDisposed || generation != _fetchGeneration) return;
      _retryCount++;
      _hasError = true;
      widget.onError?.call(error);
    } finally {
      if (!_isDisposed && generation == _fetchGeneration) {
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
    final hasFooter = footerType != _ScrollInfinityFooterType.none;
    final displayItems = _itemMapper.displayItems;
    final itemCount = headerCount + displayItems.length + (hasFooter ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
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

  Widget _buildFooter(_ScrollInfinityFooterType footerType) {
    switch (footerType) {
      case _ScrollInfinityFooterType.error:
        return _buildRetryWidget();
      case _ScrollInfinityFooterType.loading:
        return _buildLoadingIndicator();
      case _ScrollInfinityFooterType.manualLoad:
        return _buildLoadMoreWidget();
      case _ScrollInfinityFooterType.empty:
        return widget.empty ?? const Center(child: Text('No items found.'));
      case _ScrollInfinityFooterType.none:
        return const SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();

    widget.controller?.attach(this);
    unawaited(_initialize());
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ScrollInfinity<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.detach(this);
      widget.controller?.attach(this);
    }

    // `initialItems` is deliberately absent: it is a list instance that many
    // callers rebuild inline, so comparing it here would reset the list on
    // every rebuild. It is applied on init and on reset only.
    if (widget.maxItems != oldWidget.maxItems ||
        widget.interval != oldWidget.interval ||
        widget.initialPageIndex != oldWidget.initialPageIndex) {
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
