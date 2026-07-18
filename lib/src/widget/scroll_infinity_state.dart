part of 'scroll_infinity.dart';

class _ScrollInfinityState<T> extends State<ScrollInfinity<T>>
    implements ScrollInfinityControllerState {
  final _scrollController = ScrollController();
  final _itemMapper = IntervalItemMapper<T>();

  int _pageIndex = 0;
  int _retryCount = 0;
  int _fetchGeneration = 0;
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
        _fetchGeneration++;
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
