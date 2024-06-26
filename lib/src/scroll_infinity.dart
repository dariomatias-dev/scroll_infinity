import 'dart:async';

import 'package:flutter/material.dart';

part 'loading_style.dart';

class ScrollInfinity<T> extends StatefulWidget {
  const ScrollInfinity({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.initialItems,
    this.loading,
    this.loadingStyle,
    required this.maxItems,
    this.disableInitialRequest = false,
    required this.loadData,
    this.separatorBuilder,
    required this.itemBuilder,
  }) : assert(
          !(loadingStyle != null && loading != null),
          "The properties 'loading' and 'loadingStyle' cannot be used together. Please define only one of these properties.",
        );

  /// Defines the scrolling direction of the list. Can be `Axis.vertical` or `Axis.horizontal`
  final Axis scrollDirection;

  /// Specifies the internal padding of the list.
  final EdgeInsetsGeometry? padding;

  /// Specifies the initial items to be displayed in the list.
  final List<T>? initialItems;

  /// Allows passing a custom loading component.
  final Widget? loading;

  /// Defines the style of the `CircularProgressIndicator`. Use this property to customize the appearance of the default loading indicator.
  final LoadingStyle? loadingStyle;

  /// Specifies the maximum number of items per request. This will be used to determine when the list reaches the end.
  final int maxItems;

  /// Disables the initial data request if set to `true`.
  final bool disableInitialRequest;

  /// Function responsible for loading the data. It should return a list of items.
  final Future<List<T>> Function(
    int pageKey,
  ) loadData;

  /// Builds the separator component between the items in the list. Use this property to add custom dividers between the items.
  final Widget Function(
    BuildContext context,
    int index,
  )? separatorBuilder;

  /// Builds the items in the list. This function should return the widget that represents each item in the list.
  final Widget Function(
    T value,
  ) itemBuilder;

  @override
  State<ScrollInfinity<T>> createState() => _ScrollInfinityState<T>();
}

class _ScrollInfinityState<T> extends State<ScrollInfinity<T>> {
  int _pageKey = 0;
  bool _isLoading = false;
  bool _isListEnd = false;

  final _scrollController = ScrollController();
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
    _addLoading();
    _updateIsLoading();

    final newItems = await widget.loadData(_pageKey);
    _pageKey++;

    _removeLoading();

    _isListEnd = newItems.length < widget.maxItems;

    final items = _generateItems(newItems);
    _items.addAll(items);

    _updateIsLoading();
  }

  /// Generates new items by calling `itemBuilder`.
  List<Widget> _generateItems(
    List<T> newItems,
  ) {
    final items = <Widget>[];
    for (T newItem in newItems) {
      items.add(
        widget.itemBuilder(newItem),
      );
    }

    return items;
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
    _items.clear();
    _isListEnd = false;
    _pageKey = 0;

    if (widget.initialItems != null && widget.disableInitialRequest) {
      _items.addAll(
        _generateItems(
          widget.initialItems!,
        ),
      );

      setState(() {});
    } else {
      _addItems();
    }
  }

  @override
  void initState() {
    if (widget.initialItems != null) {
      _items.addAll(
        _generateItems(
          widget.initialItems!,
        ),
      );
    }

    if (!widget.disableInitialRequest) {
      _addItems();
    }

    _scrollController.addListener(_onScroll);

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
        scrollbars: false,
      ),
      child: ListView.separated(
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
