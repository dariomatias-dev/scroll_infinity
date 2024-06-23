import 'dart:async';

import 'package:flutter/material.dart';

class LoadingStyle {
  const LoadingStyle({
    this.color,
    this.strokeAlign,
    this.strokeWidth,
  });

  final Color? color;
  final double? strokeAlign;
  final double? strokeWidth;
}

class ScrollInfinity<T> extends StatefulWidget {
  const ScrollInfinity({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.loading,
    this.loadingStyle,
    required this.maxItems,
    required this.loadData,
    this.separatorBuilder,
    required this.itemBuilder,
  }) : assert(
          !(loadingStyle != null && loading != null),
          "The properties 'loading' and 'loadingStyle' cannot be used together. Please define only one of these properties.",
        );

  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final Widget? loading;
  final LoadingStyle? loadingStyle;
  final int maxItems;
  final Future<List<T>> Function(
    int pageKey,
  ) loadData;
  final Widget Function(
    BuildContext context,
    int index,
  )? separatorBuilder;
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

  void _onScroll() {
    if (!_isListEnd && !_isLoading && _scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0) {
        _addItems();
      }
    }
  }

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

  void _removeLoading() {
    _items.removeLast();
  }

  void _updateIsLoading() {
    if (mounted) {
      setState(() {
        _isLoading = !_isLoading;
      });
    }
  }

  @override
  void initState() {
    _addItems();
    _scrollController.addListener(_onScroll);

    super.initState();
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
