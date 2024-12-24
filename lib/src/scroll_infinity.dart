import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scroll_infinity/src/try_again_button.dart';

part 'initial_items_notifier.dart';
part 'scroll_infinity_loader.dart';
part 'loading_style.dart';
part 'default_error_component.dart';

class ScrollInfinity<T> extends StatefulWidget {
  const ScrollInfinity({
    super.key,
    this.listKey,
    this.scrollDirection = Axis.vertical,
    this.scrollbars = false,
    this.padding,
    this.header,
    this.disableInitialRequest = false,
    this.initialPageIndex = 0,
    this.enableRetryOnError = true,
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
          !(initialItems == null && disableInitialRequest),
          '`initialItems` must not be `null` when `disableInitialRequest` is `true`.',
        ),
        assert(
          !(interval != null && interval <= 0),
          'The interval should not be equal to or less than zero.',
        ),
        assert(
          interval != null ? null is T : true,
          'The generic type `T` must be nullable when `interval` is not null.',
        ),
        assert(
          !(loadingStyle != null && loading != null),
          'The properties `loading` and `loadingStyle` cannot be used together. Please define only one of these properties.',
        );

  /// Listing key.
  final GlobalKey? listKey;

  /// Defines the scrolling direction of the list. Can be `Axis.vertical` or `Axis.horizontal`.
  final Axis scrollDirection;

  /// Show scrollbar if `true`. Default is `false`.
  final bool scrollbars;

  /// Specifies the internal padding of the list.
  final EdgeInsetsGeometry? padding;

  /// Listing header.
  final Widget? header;

  /// Disables the initial data request if set to `true`. Default is `false`.
  final bool disableInitialRequest;

  /// Initial page index. Default is `0`.
  final int initialPageIndex;

  /// Determines if retrying to load data after an error is enabled. Default is `true`.
  final bool enableRetryOnError;

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
  late final GlobalKey _listKey;
  final _itemKeys = <GlobalKey>[];
  late int _pageIndex;
  bool _isLoading = false;
  bool _isListEnd = false;
  int _itemsCount = 0;
  bool _hasError = false;

  final _scrollController = ScrollController();
  final _values = <T>[];
  final _items = <Widget>[];

  /// Method called during scrolling.
  void _onScroll() {
    if (!_isListEnd && !_isLoading && _scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0) {
        _addItems();
      }
    }
  }

  /// Handles the process of adding new items.
  Future<void> _addItems() async {
    if (_hasError) {
      _hasError = false;

      _items.removeLast();
      _items.removeLast();

      _addLoading();

      if (mounted) {
        setState(() {});
      }
    }

    if (_pageIndex == 0) {
      _addLoading();
      _updateIsLoading();
    } else {
      _isLoading = !_isLoading;
    }

    if (_values.length != widget.maxItems) {
      final newItems = await widget.loadData(
        _pageIndex,
      );

      if (newItems != null) {
        _values.addAll(newItems);
        _pageIndex++;

        _isListEnd = newItems.length < widget.maxItems;
      } else {
        _hasError = true;
      }
    }

    _removeLoading();

    final enableScroll = _itemKeys.isNotEmpty
        ? _itemKeys.first.currentContext?.size?.height == null
        : false;

    if (_hasError) {
      if (!enableScroll) {
        _items.add(
          widget.tryAgainButtonBuilder != null
              ? widget.tryAgainButtonBuilder!(
                  () {},
                )
              : TryAgainButton(
                  action: () {},
                ),
        );
      } else {
        _items.add(
          widget.error ?? const _DefaultErrorComponent(),
        );
      }

      _isListEnd = !widget.enableRetryOnError;
    } else {
      final items = _generateItems();

      _items.addAll(items);
    }

    if (!_isListEnd && enableScroll) {
      _addLoading();
    }

    _updateIsLoading();
  }

  /// Generates new items by calling `itemBuilder`.
  List<Widget> _generateItems() {
    final items = <Widget>[];

    if (widget.interval != null) {
      int i = 0;

      while (items.length != widget.maxItems && _values.isNotEmpty) {
        if (_itemsCount == widget.interval) {
          _itemsCount = 0;

          items.add(
            _setItemKey(
              widget.itemBuilder(
                null as T,
                i + _items.length,
              ),
            ),
          );

          i--;

          continue;
        }

        _itemsCount++;

        items.add(
          _setItemKey(
            widget.itemBuilder(
              _values[0],
              i + _items.length,
            ),
          ),
        );

        i--;

        _values.removeAt(0);
      }
    } else {
      for (int i = 0; i < _values.length; i++) {
        items.add(
          _setItemKey(
            widget.itemBuilder(
              _values[i],
              i + _items.length,
            ),
          ),
        );
      }

      _values.clear();
    }

    return items;
  }

  /// Define the key of the item in the list.
  Widget _setItemKey(
    Widget child,
  ) {
    final itemKey = GlobalKey();

    _itemKeys.add(itemKey);

    return KeyedSubtree(
      key: itemKey,
      child: child,
    );
  }

  /// Adds the loading indicator component.
  void _addLoading() {
    _items.add(
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

  /// Removes the loading indicator component.
  void _removeLoading() {
    _items.removeLast();
  }

  /// Initializes resources.
  void _start() {
    _listKey = widget.listKey ?? GlobalKey();
    _pageIndex = widget.initialPageIndex;

    if (widget.initialItems != null) {
      _isListEnd = widget.initialItems!.length < widget.maxItems;
    }

    if (widget.header != null) {
      _items.add(
        _setItemKey(
          widget.header!,
        ),
      );
    }

    if (widget.initialItems != null) {
      _values.addAll(
        widget.initialItems!,
      );

      _items.addAll(
        _generateItems(),
      );
    }

    if (!widget.disableInitialRequest) {
      _addItems();
    }

    _scrollController.addListener(
      _onScroll,
    );
  }

  /// Reset the component to its initial settings.
  Future<void> _reset() async {
    if (widget.initialItems != null) {
      await _scrollController.animateTo(
        0.0,
        duration: const Duration(
          milliseconds: 600,
        ),
        curve: Curves.linear,
      );
    }

    _itemKeys.clear();
    _pageIndex = widget.initialPageIndex;

    _isListEnd = false;
    if (widget.initialItems != null) {
      _isListEnd = widget.initialItems!.length < widget.maxItems;
    }

    _itemsCount = 0;
    _hasError = false;

    _values.clear();
    _items.clear();

    if (widget.header != null) {
      _items.add(
        _setItemKey(
          widget.header!,
        ),
      );
    }

    if (widget.initialItems != null && widget.disableInitialRequest) {
      _values.addAll(
        widget.initialItems!,
      );

      _items.addAll(
        _generateItems(),
      );

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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: widget.scrollbars,
      ),
      child: ListView.separated(
        key: _listKey,
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
