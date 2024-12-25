import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

final _random = Random();

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScrollInfinityExample(),
    ),
  );
}

class ScrollInfinityExample extends StatefulWidget {
  const ScrollInfinityExample({super.key});

  @override
  State<ScrollInfinityExample> createState() => _ScrollInfinityExampleState();
}

class _ScrollInfinityExampleState extends State<ScrollInfinityExample> {
  static final _enableTitles = <String>[
    'Header',
    'Interval',
    'Initial Items',
    'Loader',
  ];
  final _enables = List.filled(_enableTitles.length, false);

  void _navigateToExample() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return InfiniteScrollExample(
            enableHeader: _enables[0],
            enableInterval: _enables[1],
            enableInitialItems: _enables[2],
            enableLoader: _enables[3],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Text(
                  'Enable:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Divider(),
              ...List.generate(
                _enableTitles.length,
                (index) {
                  return SwitchListTile(
                    onChanged: (value) {
                      setState(() {
                        _enables[index] = value;
                      });
                    },
                    value: _enables[index],
                    title: Text(
                      _enableTitles[index],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
              const Divider(),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: _navigateToExample,
                  child: const Text('Access'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfiniteScrollExample extends StatefulWidget {
  const InfiniteScrollExample({
    super.key,
    required this.enableHeader,
    required this.enableInterval,
    required this.enableInitialItems,
    required this.enableLoader,
  });

  final bool enableHeader;
  final bool enableInterval;
  final bool enableInitialItems;
  final bool enableLoader;

  @override
  State<InfiniteScrollExample> createState() => _InfiniteScrollExampleState();
}

class _InfiniteScrollExampleState extends State<InfiniteScrollExample> {
  static const maxItems = 10;
  final _notifier = InitialItemsNotifier<Color>(null);

  Future<void> _initLoader() async {
    _notifier.update(
      items: null,
      hasError: false,
    );

    final items = await _loadData(0);

    _notifier.update(
      items: items,
      hasError: items == null,
    );
  }

  Future<List<Color>?> _loadData(
    int pageIndex,
  ) async {
    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );

    if (_random.nextInt(4) == 0) {
      return null;
    }

    final isListEnd = _random.nextInt(5) == 0;

    return _generateColors(
      isListEnd ? 3 : maxItems,
    );
  }

  List<Color> _generateColors(
    int amount,
  ) {
    return List.generate(
      amount,
      (index) {
        return Color.fromARGB(
          255,
          _random.nextInt(255),
          _random.nextInt(255),
          _random.nextInt(255),
        );
      },
    );
  }

  ScrollInfinity<Color?> _getScrollInfinity(
    List<Color>? initialItems,
  ) {
    return ScrollInfinity<Color?>(
      header: widget.enableHeader
          ? Container(
              height: 40.0,
              color: Colors.red,
            )
          : null,
      maxItems: maxItems,
      interval: widget.enableInterval ? 2 : null,
      loadData: _loadData,
      disableInitialRequest: widget.enableInitialItems,
      initialItems: widget.enableInitialItems ? initialItems : null,
      itemBuilder: (value, index) {
        if (widget.enableInterval ? value == null : false) {
          return const SizedBox(
            height: 100.0,
            child: Placeholder(),
          );
        }

        return Container(
          height: 100.0,
          color: value,
        );
      },
    );
  }

  void _reset() {
    if (widget.enableInitialItems) {
      _initLoader();
    } else {
      setState(() {});
    }
  }

  @override
  void initState() {
    if (widget.enableInitialItems) {
      _initLoader();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: _reset,
            child: const Text('Reset'),
          ),
          const SizedBox(height: 20.0),
          const Divider(
            height: 0.0,
          ),
          Expanded(
            child: widget.enableInitialItems
                ? ScrollInfinityLoader(
                    notifier: _notifier,
                    scrollInfinityBuilder: (items) {
                      return _getScrollInfinity(items);
                    },
                  )
                : _getScrollInfinity(null),
          ),
        ],
      ),
    );
  }
}
