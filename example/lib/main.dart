import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

typedef LoadDatatype = Future<List<Color>?> Function(
  int pageIndex, {
  Axis scrollDirection,
});

class LoadingStyleModel<T> {
  const LoadingStyleModel({
    required this.name,
    this.value,
  });

  final String name;
  final T? value;
}

const loadingColors = <LoadingStyleModel<Color>>[
  LoadingStyleModel(
    name: 'Default',
  ),
  LoadingStyleModel(
    name: 'Red',
    value: Colors.red,
  ),
  LoadingStyleModel(
    name: 'Blue',
    value: Colors.blue,
  ),
  LoadingStyleModel(
    name: 'Yellow',
    value: Colors.yellow,
  ),
  LoadingStyleModel(
    name: 'Green',
    value: Colors.green,
  ),
  LoadingStyleModel(
    name: 'Purple',
    value: Colors.purple,
  ),
];

const loadingStrokeAligns = <LoadingStyleModel<double>>[
  LoadingStyleModel(
    name: 'Center',
    value: BorderSide.strokeAlignCenter,
  ),
  LoadingStyleModel(
    name: 'Inside',
    value: BorderSide.strokeAlignInside,
  ),
  LoadingStyleModel(
    name: 'Outside',
    value: BorderSide.strokeAlignOutside,
  ),
];

const loadingStrokeWidths = <LoadingStyleModel<double>>[
  LoadingStyleModel(
    name: 'Default',
  ),
  LoadingStyleModel(
    name: '2',
    value: 2.0,
  ),
  LoadingStyleModel(
    name: '6',
    value: 6.0,
  ),
  LoadingStyleModel(
    name: '8',
    value: 8.0,
  ),
  LoadingStyleModel(
    name: '10',
    value: 10.0,
  ),
];

class LoadingStyleTypeModel<T> {
  const LoadingStyleTypeModel({
    required this.title,
    required this.value,
  });

  final String title;
  final List<LoadingStyleModel> value;
}

const loadingTypeStyles = <LoadingStyleTypeModel>[
  LoadingStyleTypeModel(
    title: 'Color',
    value: loadingColors,
  ),
  LoadingStyleTypeModel(
    title: 'Align',
    value: loadingStrokeAligns,
  ),
  LoadingStyleTypeModel(
    title: 'Width',
    value: loadingStrokeWidths,
  ),
];

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScrollInfinityExample(),
    ),
  );
}

final random = Random();

class ScrollInfinityExample extends StatefulWidget {
  const ScrollInfinityExample({super.key});

  @override
  State<ScrollInfinityExample> createState() => _ScrollInfinityExampleState();
}

class _ScrollInfinityExampleState extends State<ScrollInfinityExample> {
  final _loadingStyles = <LoadingStyleModel>[
    loadingColors.first,
    loadingStrokeAligns.first,
    loadingStrokeWidths.first,
  ];

  final _random = Random();

  LoadingStyle get loadingStyle => LoadingStyle(
        color: _loadingStyles[0].value,
        strokeAlign: _loadingStyles[1].value,
        strokeWidth: _loadingStyles[2].value,
      );

  void navigateTo(
    Widget screen,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return screen;
        },
      ),
    );
  }

  Future<List<Color>?> _loadData(
    int pageIndex, {
    Axis scrollDirection = Axis.vertical,
  }) async {
    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );

    if (_random.nextInt(3) == 0) {
      return null;
    }

    final isListEnd = random.nextInt(5) == 0;

    final isVertical = scrollDirection == Axis.vertical;

    return _generateColors(
      isListEnd
          ? 3
          : isVertical
              ? 10
              : 8,
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
          random.nextInt(255),
          random.nextInt(255),
          random.nextInt(255),
        );
      },
    );
  }

  void navigateToInfiniteListingVerticallyScreen({
    List<Color>? initialItems,
  }) {
    navigateTo(
      InfiniteListingVerticallyScreen(
        initialItems: initialItems,
        loadData: _loadData,
        loadingStyle: loadingStyle,
      ),
    );
  }

  void navigateToInfiniteListingHorizontallyScreen({
    List<Color>? initialItems,
  }) {
    navigateTo(
      InfiniteListingHorizontallyScreen(
        initialItems: initialItems,
        loadData: _loadData,
        loadingStyle: loadingStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ...List.generate(loadingTypeStyles.length, (index) {
              final loadingTypeStyle = loadingTypeStyles[index];

              return Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        loadingTypeStyle.title,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: _loadingStyles[index],
                          items: List.generate(loadingTypeStyle.value.length,
                              (index) {
                            final style = loadingTypeStyle.value[index];

                            return DropdownMenuItem(
                              value: style,
                              child: Text(
                                style.name,
                              ),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              _loadingStyles[index] = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                ],
              );
            }),
            const Text(
              'With initial items',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: () {
                navigateToInfiniteListingVerticallyScreen();
              },
              child: const Text('Show Infinite Listing Vertically'),
            ),
            const SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: () {
                navigateToInfiniteListingHorizontallyScreen();
              },
              child: const Text('Show Infinite Listing Horizontally'),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 320.0,
              ),
              child: const Divider(
                height: 20.0,
              ),
            ),
            const Text(
              'Without initial items',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: () {
                navigateToInfiniteListingVerticallyScreen(
                  initialItems: _generateColors(10),
                );
              },
              child: const Text('Show Infinite Listing Vertically'),
            ),
            const SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: () {
                navigateToInfiniteListingHorizontallyScreen(
                  initialItems: _generateColors(8),
                );
              },
              child: const Text('Show Infinite Listing Horizontally'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                navigateTo(
                  const InfiniteListingVerticallyWithIntervalScreen(),
                );
              },
              child: const Text(
                'Infinite Listing Vertically With Interval Screen',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                navigateTo(
                  const InfiniteScrollLoaderExample(),
                );
              },
              child: const Text('Infinite Scroll With Loader'),
            ),
          ],
        ),
      ),
    );
  }
}

class InfiniteListingVerticallyScreen extends StatefulWidget {
  const InfiniteListingVerticallyScreen({
    super.key,
    this.initialItems,
    required this.loadData,
    required this.loadingStyle,
  });

  final List<Color>? initialItems;
  final LoadDatatype loadData;
  final LoadingStyle loadingStyle;

  @override
  State<InfiniteListingVerticallyScreen> createState() =>
      _InfiniteListingVerticallyScreenState();
}

class _InfiniteListingVerticallyScreenState
    extends State<InfiniteListingVerticallyScreen> {
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
            onPressed: () {
              setState(() {});
            },
            child: const Text('Reset'),
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: ScrollInfinity<Color>(
              loadingStyle: widget.loadingStyle,
              initialPageIndex: widget.initialItems != null ? 1 : 0,
              maxItems: 10,
              enableRetryOnError: false,
              initialItems: widget.initialItems,
              disableInitialRequest: widget.initialItems != null,
              loadData: widget.loadData,
              itemBuilder: (value, index) {
                return Container(
                  height: 100.0,
                  color: value,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class InfiniteListingHorizontallyScreen extends StatefulWidget {
  const InfiniteListingHorizontallyScreen({
    super.key,
    this.initialItems,
    required this.loadData,
    required this.loadingStyle,
  });

  final List<Color>? initialItems;
  final LoadDatatype loadData;
  final LoadingStyle loadingStyle;

  @override
  State<InfiniteListingHorizontallyScreen> createState() =>
      _InfiniteListingHorizontallyScreenState();
}

class _InfiniteListingHorizontallyScreenState
    extends State<InfiniteListingHorizontallyScreen> {
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
            onPressed: () {
              setState(() {});
            },
            child: const Text('Reset'),
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: Center(
              child: SizedBox(
                height: 100.0,
                child: ScrollInfinity<Color>(
                  scrollDirection: Axis.horizontal,
                  loadingStyle: widget.loadingStyle,
                  initialPageIndex: widget.initialItems != null ? 1 : 0,
                  maxItems: 8,
                  initialItems: widget.initialItems,
                  disableInitialRequest: widget.initialItems != null,
                  loadData: (pageIndex) {
                    return widget.loadData(
                      pageIndex,
                      scrollDirection: Axis.horizontal,
                    );
                  },
                  itemBuilder: (value, index) {
                    return Container(
                      width: 200.0,
                      color: value,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfiniteListingVerticallyWithIntervalScreen extends StatelessWidget {
  const InfiniteListingVerticallyWithIntervalScreen({super.key});

  final _maxItems = 8;

  Future<List<Color>> _loadData(
    int pageIndex,
  ) async {
    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );

    return List.generate(
      _maxItems,
      (index) {
        return Color.fromARGB(
          255,
          random.nextInt(255),
          random.nextInt(255),
          random.nextInt(255),
        );
      },
    );
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
      body: ScrollInfinity<Color?>(
        maxItems: _maxItems,
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
      ),
    );
  }
}

class InfiniteScrollLoaderExample extends StatefulWidget {
  const InfiniteScrollLoaderExample({super.key});

  @override
  State<InfiniteScrollLoaderExample> createState() =>
      _InfiniteScrollLoaderExampleState();
}

class _InfiniteScrollLoaderExampleState
    extends State<InfiniteScrollLoaderExample> {
  final _notifier = ScrollInfinityInitialItemsNotifier<Color>(null);

  final _random = Random();

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
          random.nextInt(255),
          random.nextInt(255),
          random.nextInt(255),
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
    return CustomScaffold(
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

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    super.key,
    required this.body,
  });

  final Widget body;

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
      body: body,
    );
  }
}
