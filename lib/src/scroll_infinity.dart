import 'package:flutter/material.dart';

class ScrollInfinityController extends ValueNotifier<bool> {
  ScrollInfinityController() : super(false);

  bool _isListEnd = false;

  bool get isListEnd => _isListEnd;

  set isListEnd(bool value) {
    _isListEnd = value;

    notifyListeners();
  }
}

class ScrollInfinity<T> extends StatefulWidget {
  const ScrollInfinity({
    super.key,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.loadingWidget,
    required this.loadData,
    this.separatorBuilder,
    required this.itemBuilder,
  });

  final ScrollInfinityController? controller;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final Widget? loadingWidget;
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
  State<ScrollInfinity> createState() => _ScrollInfinityState();
}

class _ScrollInfinityState<T> extends State<ScrollInfinity> {
  int _pageKey = 0;
  bool _isLoading = false;
  bool _isListEnd = false;

  final _scrollController = ScrollController();
  final _items = [];

  void _onScroll() {
    if (!_isListEnd && !_isLoading && _scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0) {
        _addItems();
      }
    }
  }

  Future<void> _addItems() async {
    _addLoadingWidget();
    _updateIsLoading();

    final newItems = await widget.loadData(_pageKey);
    _pageKey++;

    _removeLoadingWidget();

    final items = _generateItems(newItems);
    _items.addAll(items);

    _updateIsLoading();
  }

  List<Widget> _generateItems(
    List<dynamic> newItems,
  ) {
    final items = <Widget>[];
    for (dynamic newItem in newItems) {
      items.add(
        widget.itemBuilder(newItem),
      );
    }

    return items;
  }

  void _addLoadingWidget() {
    _items.add(
      widget.loadingWidget ??
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
              ],
            ),
          ),
    );
  }

  void _removeLoadingWidget() {
    _items.removeLast();
  }

  void _updateIsLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  void initState() {
    widget.controller?.addListener(() {
      if (widget.controller?.isListEnd ?? false) {
        _isListEnd = !_isListEnd;
      }
    });

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
