part of 'scroll_infinity.dart';

class _ScrollInfinityState<T> extends State<ScrollInfinity<T>>
    implements ScrollInfinityControllerState {
  final _itemMapper = IntervalItemMapper<T>();

  /// Created only when the caller does not supply one, and disposed with
  /// this state. A caller-supplied controller is never disposed here.
  ScrollController? _ownedScrollController;

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
  bool _isDisposed = false;

  /// The failure from the last fetch attempt, or `null` when it succeeded.
  /// Single source for both [hasError] and the error handed to
  /// `tryAgainBuilder`, so the two can never disagree.
  Object? _error;

  /// The controller driving the list: the caller's when supplied, otherwise
  /// one owned by this state.
  ScrollController get _scrollController =>
      widget.scrollController ??
      (_ownedScrollController ??= ScrollController());

  @override
  bool get isLoading => _isLoading;

  @override
  bool get hasError => _error != null;

  @override
  bool get hasReachedEnd => _isEndOfList;

  @override
  void refresh() => unawaited(_reset());

  @override
  void retry() {
    if (!hasError) return;

    unawaited(_fetchNextPage());
  }

  _ScrollInfinityFooterType get _footerType {
    if (hasError) {
      return _retryLimitReached
          ? _ScrollInfinityFooterType.retryLimitReached
          : _ScrollInfinityFooterType.error;
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
        _error = null;
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
        !hasError) {
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

    if (hasError && _retryLimitReached) return;

    final generation = _fetchGeneration;

    setState(() {
      _isLoading = true;
      _error = null;
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

        if (_isEndOfList) widget.onEndOfList?.call();
      } else {
        _retryCount++;
        _error = Exception('loadData returned null for page $_pageIndex.');
        widget.onError?.call(_error!);
      }
    } on Object catch (error) {
      if (_isDisposed || generation != _fetchGeneration) return;
      _retryCount++;
      _error = error;
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
    final separatorBuilder = widget.separatorBuilder;

    final cacheExtent = widget.cacheExtent == null
        ? null
        : ScrollCacheExtent.pixels(widget.cacheExtent!);

    Widget itemBuilder(BuildContext context, int index) {
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
    }

    if (separatorBuilder == null) {
      return ListView.builder(
        controller: _scrollController,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        padding: widget.padding,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        scrollCacheExtent: cacheExtent,
        itemExtent: widget.itemExtent,
        prototypeItem: widget.prototypeItem,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        restorationId: widget.restorationId,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      );
    }

    return ListView.separated(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      scrollCacheExtent: cacheExtent,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      itemCount: itemCount,
      separatorBuilder: (context, index) {
        if (hasHeader && index == 0) {
          return const SizedBox.shrink();
        }

        final itemIndex = index - headerCount;
        if (itemIndex >= 0 && itemIndex < displayItems.length - 1) {
          return separatorBuilder(context, itemIndex);
        }

        return const SizedBox.shrink();
      },
      itemBuilder: itemBuilder,
    );
  }

  Widget _buildFooter(_ScrollInfinityFooterType footerType) {
    switch (footerType) {
      case _ScrollInfinityFooterType.error:
        return _buildRetryWidget(_error!);
      case _ScrollInfinityFooterType.retryLimitReached:
        return widget.retryLimitReached ??
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Retry limit has been reached.'),
              ),
            );
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

    if (widget.scrollController != oldWidget.scrollController) {
      (oldWidget.scrollController ?? _ownedScrollController)?.removeListener(
        _onScroll,
      );

      if (widget.scrollController != null) {
        _ownedScrollController?.dispose();
        _ownedScrollController = null;
      }

      _scrollController.addListener(_onScroll);
    }

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
    (widget.scrollController ?? _ownedScrollController)?.removeListener(
      _onScroll,
    );
    _ownedScrollController?.dispose();

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
