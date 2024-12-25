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

class _DefaultNotifier<T> extends ValueNotifier<List<T>> {
  _DefaultNotifier(super._value);

  void set(
    int index,
    T value,
  ) {
    super.value[index] = value;

    notifyListeners();
  }
}

class _EnablesNotifier<T> extends _DefaultNotifier<T> {
  _EnablesNotifier(super._value);
}

class _LoadingStylesNotifier<T> extends _DefaultNotifier<T> {
  _LoadingStylesNotifier(super._value);
}

class ScrollInfinityExample extends StatefulWidget {
  const ScrollInfinityExample({super.key});

  @override
  State<ScrollInfinityExample> createState() => _ScrollInfinityExampleState();
}

class _ScrollInfinityExampleState extends State<ScrollInfinityExample> {
  final _selectedScrollDirectionNotifier = ValueNotifier(Axis.vertical);
  final _maxItemsNotifier = ValueNotifier(10);
  static final _enableTitles = <String>[
    'Header',
    'Intervals',
    'Initial Items',
    'Custom Loader',
  ];
  final _enablesNotifier = _EnablesNotifier(
    List.filled(_enableTitles.length, false),
  );
  final _loadingStylesNotifier = _LoadingStylesNotifier(
    <LoadingStyleModel>[
      loadingColors.first,
      loadingStrokeAligns.first,
      loadingStrokeWidths.first,
    ],
  );

  LoadingStyle get _loadingStyle {
    final loadingStyles = _loadingStylesNotifier.value;

    return LoadingStyle(
      color: loadingStyles[0].value,
      strokeAlign: loadingStyles[1].value,
      strokeWidth: loadingStyles[2].value,
    );
  }

  void _navigateToExample() {
    final enables = _enablesNotifier.value;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return InfiniteScrollExample(
            selectedScrollDirection: _selectedScrollDirectionNotifier.value,
            maxItems: _maxItemsNotifier.value,
            enableHeader: enables[0],
            enableInterval: enables[1],
            enableInitialItems: enables[2],
            enableCustomLoader: enables[3],
            loadingStyle: _loadingStyle,
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
              ValueListenableBuilder(
                valueListenable: _selectedScrollDirectionNotifier,
                builder: (context, value, child) {
                  return Column(
                    children: <Widget>[
                      RadioListTile(
                        title: const Text('Vertical'),
                        value: Axis.vertical,
                        groupValue: value,
                        onChanged: (Axis? value) {
                          setState(() {
                            _selectedScrollDirectionNotifier.value = value!;
                          });
                        },
                      ),
                      RadioListTile(
                        title: const Text('Horizontal'),
                        value: Axis.horizontal,
                        groupValue: value,
                        onChanged: (Axis? value) {
                          setState(() {
                            _selectedScrollDirectionNotifier.value = value!;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const FieldWidget(
                    title: 'Max Items',
                  ),
                  ValueListenableBuilder(
                    valueListenable: _maxItemsNotifier,
                    builder: (context, value, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: value != 2
                                ? () {
                                    _maxItemsNotifier.value--;
                                  }
                                : null,
                          ),
                          const SizedBox(width: 8.0),
                          SizedBox(
                            width: 24.0,
                            child: Center(
                              child: Text(
                                '$value',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: value != 20
                                ? () {
                                    _maxItemsNotifier.value++;
                                  }
                                : null,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40.0),
              const FieldWidget(
                title: 'Enable',
              ),
              const Divider(),
              ...List.generate(
                _enableTitles.length,
                (index) {
                  return ValueListenableBuilder(
                    valueListenable: _enablesNotifier,
                    builder: (context, value, child) {
                      return SwitchListTile(
                        onChanged: (value) {
                          _enablesNotifier.set(index, value);
                        },
                        value: value[index],
                        title: Text(
                          _enableTitles[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
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

                return Padding(
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
                      ValueListenableBuilder(
                        valueListenable: _loadingStylesNotifier,
                        builder: (context, value, child) {
                          return DropdownButtonHideUnderline(
                            child: DropdownButton(
                              value: value[index],
                              items: List.generate(
                                  loadingTypeStyle.value.length, (index) {
                                final style = loadingTypeStyle.value[index];

                                return DropdownMenuItem(
                                  value: style,
                                  child: Text(
                                    style.name,
                                  ),
                                );
                              }),
                              onChanged: (value) {
                                _loadingStylesNotifier.set(index, value!);
                              },
                            ),
                          );
                        },
                      ),
                    ],
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
    required this.maxItems,
    required this.enableHeader,
    required this.enableInterval,
    required this.enableInitialItems,
    required this.enableCustomLoader,
    required this.loadingStyle,
  });

  final Axis selectedScrollDirection;
  final int maxItems;
  final bool enableHeader;
  final bool enableInterval;
  final bool enableInitialItems;
  final bool enableCustomLoader;
  final LoadingStyle loadingStyle;

  @override
  State<InfiniteScrollExample> createState() => _InfiniteScrollExampleState();
}

class _InfiniteScrollExampleState extends State<InfiniteScrollExample> {
  late final int _maxItems;
  final _initialItemsNotifier = InitialItemsNotifier<Color>(null);

  Future<void> _initLoader() async {
    _initialItemsNotifier.update(
      items: null,
      hasError: false,
    );

    final items = await _loadData(0);

    _initialItemsNotifier.update(
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
      isListEnd ? _random.nextInt(widget.maxItems - 1) : _maxItems,
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
      maxItems: _maxItems,
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
    _maxItems = widget.maxItems;

    if (widget.enableInitialItems) {
      _initLoader();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scrollInfinity = widget.enableInitialItems
        ? ScrollInfinityLoader(
            notifier: _initialItemsNotifier,
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
