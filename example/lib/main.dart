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
  Axis _selectedScrollDirection = Axis.vertical;
  static final _enableTitles = <String>[
    'Header',
    'Intervals',
    'Initial Items',
    'Custom Loader',
  ];
  final _enables = List.filled(_enableTitles.length, false);

  final _loadingStyles = <LoadingStyleModel>[
    loadingColors.first,
    loadingStrokeAligns.first,
    loadingStrokeWidths.first,
  ];

  LoadingStyle get loadingStyle {
    return LoadingStyle(
      color: _loadingStyles[0].value,
      strokeAlign: _loadingStyles[1].value,
      strokeWidth: _loadingStyles[2].value,
    );
  }

  void _navigateToExample() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return InfiniteScrollExample(
            selectedScrollDirection: _selectedScrollDirection,
            enableHeader: _enables[0],
            enableInterval: _enables[1],
            enableInitialItems: _enables[2],
            enableCustomLoader: _enables[3],
            loadingStyle: loadingStyle,
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
              const FieldWidget(
                title: 'Scroll Direction',
              ),
              const Divider(),
              RadioListTile(
                title: const Text('Vertical'),
                value: Axis.vertical,
                groupValue: _selectedScrollDirection,
                onChanged: (Axis? value) {
                  setState(() {
                    _selectedScrollDirection = value!;
                  });
                },
              ),
              RadioListTile(
                title: const Text('Horizontal'),
                value: Axis.horizontal,
                groupValue: _selectedScrollDirection,
                onChanged: (Axis? value) {
                  setState(() {
                    _selectedScrollDirection = value!;
                  });
                },
              ),
              const SizedBox(height: 28.0),
              const FieldWidget(
                title: 'Enable',
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
              const SizedBox(height: 40.0),
              const FieldWidget(
                title: 'Customize default loader',
              ),
              const Divider(),
              ...List.generate(loadingTypeStyles.length, (index) {
                final loadingTypeStyle = loadingTypeStyles[index];

                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '${loadingTypeStyle.title}:',
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
                  ),
                );
              }),
              const Divider(),
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: _navigateToExample,
                  child: const Text('Access Example'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FieldWidget extends StatelessWidget {
  const FieldWidget({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: Text(
        '$title:',
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class InfiniteScrollExample extends StatefulWidget {
  const InfiniteScrollExample({
    super.key,
    required this.selectedScrollDirection,
    required this.enableHeader,
    required this.enableInterval,
    required this.enableInitialItems,
    required this.enableCustomLoader,
    required this.loadingStyle,
  });

  final Axis selectedScrollDirection;
  final bool enableHeader;
  final bool enableInterval;
  final bool enableInitialItems;
  final bool enableCustomLoader;
  final LoadingStyle loadingStyle;

  @override
  State<InfiniteScrollExample> createState() => _InfiniteScrollExampleState();
}

class _InfiniteScrollExampleState extends State<InfiniteScrollExample> {
  late final int maxItems;
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
    final isScrollVertical = widget.selectedScrollDirection == Axis.vertical;

    return ScrollInfinity<Color?>(
      scrollDirection: widget.selectedScrollDirection,
      header: widget.enableHeader
          ? Container(
              height: isScrollVertical ? 40.0 : 0.0,
              width: isScrollVertical ? 0.0 : 160.0,
              color: Colors.red,
            )
          : null,
      maxItems: maxItems,
      interval: widget.enableInterval ? 2 : null,
      loadData: _loadData,
      loadingStyle: widget.loadingStyle,
      disableInitialRequest: widget.enableInitialItems,
      initialPageIndex: widget.enableInitialItems ? 1 : 0,
      initialItems: widget.enableInitialItems ? initialItems : null,
      loading: widget.enableCustomLoader
          ? Container(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: const AlwaysStoppedAnimation(Colors.blue),
                  backgroundColor: Colors.grey.shade800,
                ),
              ),
            )
          : null,
      itemBuilder: (value, index) {
        final width = isScrollVertical ? 0.0 : 200.0;
        final height = isScrollVertical ? 100.0 : 0.0;

        if (widget.enableInterval ? value == null : false) {
          return SizedBox(
            height: height,
            width: width,
            child: const Placeholder(),
          );
        }

        return Container(
          height: height,
          width: width,
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
    maxItems = widget.selectedScrollDirection == Axis.vertical ? 10 : 4;

    if (widget.enableInitialItems) {
      _initLoader();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scrollInfinity = widget.enableInitialItems
        ? ScrollInfinityLoader(
            notifier: _notifier,
            scrollInfinityBuilder: (items) {
              return _getScrollInfinity(items);
            },
          )
        : _getScrollInfinity(null);

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
            child: widget.selectedScrollDirection == Axis.vertical
                ? scrollInfinity
                : Center(
                    child: SizedBox(
                      height: 100.0,
                      child: scrollInfinity,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
