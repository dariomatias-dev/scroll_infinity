import 'dart:async';

import 'package:flutter/material.dart';

import 'package:scroll_infinity/src/try_again_button.dart';

part 'initial_items_notifier.dart';
part 'scroll_infinity_loader.dart';
part 'loading_style.dart';
part 'message_field_widget.dart';
part 'default_empty_component.dart';
part 'default_reset_component.dart';
part 'default_error_component.dart';

class ScrollInfinity<T> extends StatefulWidget {
  const ScrollInfinity({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.scrollbars = false,
    this.padding,
    this.header,
    this.initialPageIndex = 0,
    this.enableRetryOnError = true,
    this.empty,
    this.reset,
    this.error,
    this.initialItems,
    this.interval,
    this.loading,
    this.loadingStyle,
    this.tryAgainButtonBuilder,
    required this.maxItems,
    required this.loadData,
    this.separatorBuilder,
    required this.itemBuilder,
  })  : assert(
          !(initialPageIndex < 0),
          'The initial index cannot be less than zero.',
        ),
        assert(
          !(interval != null && interval <= 0),
          'The interval should not be equal to or less than zero.',
        ),
        assert(
          interval != null ? null is T : true,
          'The generic type `T` must be nullable when `interval` is not null.',
        );

  /// Defines the scrolling direction of the list. Can be `Axis.vertical` or `Axis.horizontal`.
  final Axis scrollDirection;

  /// Show scrollbar if `true`. Default is `false`.
  final bool scrollbars;

  /// Specifies the internal padding of the list.
  final EdgeInsetsGeometry? padding;

  /// Listing header.
  final Widget? header;

  /// Initial page index. Default is `0`.
  final int initialPageIndex;

  /// Determines if retrying to load data after an error is enabled. Default is `true`.
  final bool enableRetryOnError;

  /// Widget used to display custom content when the first request has no response.
  final Widget? empty;

  /// Widget used to display custom content when an reset occurs.
  final Widget? reset;

  /// Widget used to display custom content when an error occurs.
  final Widget? error;

  /// Specifies the initial items to be displayed in the list.
  final List<T>? initialItems;

  /// Specifies the range in which the `null` value is passed.
  final int? interval;

  /// Allows passing a custom loading component.
  final Widget? loading;

  /// Defines the style of the `CircularProgressIndicator`. Use this property to customize the appearance of the default loading indicator.
  final LoadingStyle? loadingStyle;

  /// Allows passing a custom loading component.
  final Widget Function(
    VoidCallback action,
  )? tryAgainButtonBuilder;

  /// Specifies the maximum number of items per request. This will be used to determine when the list reaches the end.
  final int maxItems;

  /// Function responsible for loading the data. It should return a list of items.
  final Future<List<T>?> Function(
    int pageIndex,
  ) loadData;

  /// Builds the separator component between the items in the list. Use this property to add custom dividers between the items.
  final Widget Function(
    BuildContext context,
    int index,
  )? separatorBuilder;

  /// Builds the items in the list. This function should return the widget that represents each item in the list.
  final Widget Function(
    T value,
    int index,
  ) itemBuilder;

  @override
  State<ScrollInfinity<T>> createState() => _ScrollInfinityState<T>();
}

class _ScrollInfinityState<T> extends State<ScrollInfinity<T>> {
  final _scrollController = ScrollController();
  final _scrollKey = GlobalKey();
  int _pageIndex = 0;
  bool _isLoading = false;
  bool _isListEnd = false;
  int _itemsCount = -1;
  int _intervalsCount = 0;
  bool _enableScroll = false;
  bool _hasError = false;
  bool _isReset = false;
  final _isRequestInProgressNotifier = ValueNotifier(false);
  bool _isDisposed = false;

  final _values = <T>[];
  final _items = <Widget>[];

  /// Method called during scrolling.
  void _onScroll() {
    if (!_isListEnd && !_isLoading && _scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0) {
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) {
            _addItems();
          },
        );
      }
    }
  }

  /// Handles the process of adding new items.
  Future<void> _addItems() async {
    _isRequestInProgressNotifier.value = true;

    if (_hasError) {
      _hasError = false;

      _items.removeLast();

      if (_getEnableScroll()) {
        _items.removeLast();
      }

      _addLoading();
      _updateIsLoading();
    } else if (_pageIndex == 0) {
      _addLoading();
      _updateIsLoading();
    } else {
      _isLoading = !_isLoading;
    }

    if (_values.length != widget.maxItems) {
      final newItems = await widget.loadData(
        _pageIndex,
      );

      if (_isDisposed) {
        return;
      }

      if (newItems != null) {
        _values.addAll(newItems);

        _isListEnd = newItems.length < widget.maxItems;
      } else {
        _hasError = true;
      }
    }

    if (!_hasError) {
      _pageIndex++;
    }

    _items.removeLast();

    if (_hasError) {
      _setItemKey(
        widget.error ?? const _DefaultErrorComponent(),
      );

      if (!_getEnableScroll()) {
        _items.removeLast();

        _setItemKey(
          widget.tryAgainButtonBuilder != null
              ? widget.tryAgainButtonBuilder!(
                  _addItems,
                )
              : TryAgainButton(
                  action: _addItems,
                ),
        );
      }

      _isListEnd = !widget.enableRetryOnError;
    } else {
      if (_pageIndex == 1 && _values.isEmpty) {
        _items.add(
          widget.empty ?? const _DefaultEmptyComponent(),
        );
      } else {
        _generateItems();
      }
    }

    if (!_isListEnd && !(_hasError && !_getEnableScroll())) {
      _addLoading();
    }

    if (!_isReset) {
      _updateIsLoading();

      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          if (!_isListEnd && !_hasError && !_getEnableScroll()) {
            _addItems();
          }
        },
      );
    } else {
      _isLoading = !_isLoading;
    }

    _isRequestInProgressNotifier.value = false;
  }

  bool _getEnableScroll() {
    if (_enableScroll) {
      return _enableScroll;
    }

    final isVertical = widget.scrollDirection == Axis.vertical;
    final scrollSize = _scrollKey.currentContext?.size;
    final scrollSizeValue =
        (isVertical ? scrollSize?.height : scrollSize?.width) ?? 0.0;
    bool enableScroll = false;

    double size = 0.0;
    int i = 0;
    while (i < _items.length) {
      final itemSize = (_items[i].key as GlobalKey?)?.currentContext?.size;

      size += (isVertical ? itemSize?.height : itemSize?.width) ?? 0.0;

      if (size >= scrollSizeValue) {
        enableScroll = true;
        break;
      }

      i++;
    }

    if (i + 1 < _items.length) {
      _enableScroll = true;
    }

    return enableScroll;
  }

  /// Generates new items by calling `itemBuilder`.
  void _generateItems() {
    int itemsLength = 0;

    if (widget.interval != null) {
      while (itemsLength != widget.maxItems && _values.isNotEmpty) {
        _itemsCount++;
        itemsLength++;

        if (_intervalsCount == widget.interval) {
          _intervalsCount = 0;

          _setItemKey(
            widget.itemBuilder(
              null as T,
              _itemsCount,
            ),
          );

          continue;
        }

        _intervalsCount++;

        _setItemKey(
          widget.itemBuilder(
            _values[0],
            _itemsCount,
          ),
        );

        _values.removeAt(0);
      }
    } else {
      for (int i = 0; i < _values.length; i++) {
        _setItemKey(
          widget.itemBuilder(
            _values[i],
            i + (_pageIndex - 1) * widget.maxItems,
          ),
        );
      }

      _values.clear();
    }
  }

  /// Define the key of the item in the list.
  Widget _setItemKey(
    Widget child,
  ) {
    final widget = KeyedSubtree(
      key: GlobalKey(),
      child: child,
    );

    _items.add(widget);

    return widget;
  }

  /// Adds the loading indicator component.
  void _addLoading() {
    _setItemKey(
      widget.loading ??
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  color: widget.loadingStyle?.color,
                  strokeAlign: widget.loadingStyle?.strokeAlign ??
                      BorderSide.strokeAlignCenter,
                  strokeWidth: widget.loadingStyle?.strokeWidth ?? 4.0,
                ),
              ],
            ),
          ),
    );
  }

  /// Updates the state of the loading indicator component.
  void _updateIsLoading() {
    if (mounted) {
      setState(() {
        _isLoading = !_isLoading;
      });
    }
  }

  /// Initializes some resources.
  void _initialize() {
    _pageIndex = widget.initialPageIndex;
    _isListEnd = widget.initialItems!.length < widget.maxItems;

    _values.addAll(widget.initialItems!);
    _generateItems();

    if (widget.initialItems?.length == widget.maxItems) {
      _addLoading();
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (!_isListEnd && !_getEnableScroll()) {
          _addItems();
        }
      },
    );
  }

  /// Initializes resources.
  void _start() {
    if (widget.header != null) {
      _items.add(
        widget.header!,
      );
    }

    if (widget.initialItems != null) {
      _initialize();
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          _addItems();
        },
      );
    }

    _scrollController.addListener(_onScroll);
  }

  /// Reset the component to its initial settings.
  Future<void> _reset() async {
    _isReset = true;

    if (_isRequestInProgressNotifier.value) {
      _items.clear();

      if (widget.header != null) {
        _items.add(
          widget.header!,
        );
      }

      _items.add(
        widget.reset ?? const _DefaultResetComponent(),
      );

      _isRequestInProgressNotifier.addListener(_initializeItems);
    } else {
      _initializeItems();
    }
  }

  void _initializeItems() {
    _isReset = false;
    _isRequestInProgressNotifier.removeListener(_initializeItems);

    _pageIndex = widget.initialPageIndex;

    _isListEnd = false;

    _itemsCount = -1;
    _intervalsCount = 0;
    _enableScroll = false;
    _hasError = false;

    _values.clear();
    _items.clear();

    if (widget.header != null) {
      _items.add(
        widget.header!,
      );
    }

    if (widget.initialItems != null) {
      _initialize();

      setState(() {});
    } else {
      _addItems();
    }
  }

  @override
  void initState() {
    _start();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ScrollInfinity<T> oldWidget) {
    _reset();

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _isRequestInProgressNotifier.dispose();
    _isDisposed = true;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: widget.scrollbars,
      ),
      child: ListView.separated(
        key: _scrollKey,
        controller: _scrollController,
        scrollDirection: widget.scrollDirection,
        padding: widget.padding,
        itemCount: _items.length,
        separatorBuilder: widget.separatorBuilder ??
            (context, index) {
              return Container();
            },
        itemBuilder: (context, index) {
          return _items[index];
        },
      ),
    );
  }
}
