import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

final _random = Random();

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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const InfiniteScrollExample();
                        },
                      ),
                    );
                  },
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
  const InfiniteScrollExample({super.key});

  @override
  State<InfiniteScrollExample> createState() => _InfiniteScrollExampleState();
}

class _InfiniteScrollExampleState extends State<InfiniteScrollExample> {
  final _notifier = InitialItemsNotifier<Color>(null);

  static const maxItems = 10;

  Future<void> _initLoader() async {
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

    if (_random.nextInt(3) == 0) {
      return null;
    }

    return List.generate(
      maxItems,
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

  @override
  void initState() {
    _initLoader();

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
          Expanded(
            child: ScrollInfinityLoader(
              notifier: _notifier,
              scrollInfinityBuilder: (items) {
                return ScrollInfinity(
                  maxItems: 10,
                  disableInitialRequest: true,
                  initialPageIndex: 0,
                  initialItems: items,
                  interval: 2,
                  loadData: _loadData,
                  itemBuilder: (value, index) {
                    if (value == null) {
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
