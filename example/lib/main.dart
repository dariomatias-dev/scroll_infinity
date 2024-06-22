import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

typedef LoadDatatype = Future<List<Color>> Function(
  int pageKey, {
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

  Future<List<Color>> _loadData(
    int pageKey, {
    Axis scrollDirection = Axis.vertical,
  }) async {
    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );

    final isListEnd = random.nextInt(3) == 0;

    final isVertical = scrollDirection == Axis.vertical;

    return List.generate(
      isListEnd
          ? 3
          : isVertical
              ? 10
              : 8,
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
    final loadingStyle = LoadingStyle(
      color: _loadingStyles[0].value,
      strokeAlign: _loadingStyles[1].value,
      strokeWidth: _loadingStyles[2].value,
    );

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
                          items: List.generate(loadingTypeStyle.value.length, (index) {
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
            ElevatedButton(
              onPressed: () {
                navigateTo(
                  InfiniteListingVerticallyScreen(
                    loadData: _loadData,
                    loadingStyle: loadingStyle,
                  ),
                );
              },
              child: const Text('Show Infinite Listing Vertically'),
            ),
            const SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: () {
                navigateTo(
                  InfiniteListingHorizontallyScreen(
                    loadData: _loadData,
                    loadingStyle: loadingStyle,
                  ),
                );
              },
              child: const Text('Show Infinite Listing Horizontally'),
            ),
          ],
        ),
      ),
    );
  }
}

class InfiniteListingVerticallyScreen extends StatelessWidget {
  const InfiniteListingVerticallyScreen({
    super.key,
    required this.loadData,
    required this.loadingStyle,
  });

  final LoadDatatype loadData;
  final LoadingStyle loadingStyle;

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
      body: ScrollInfinity(
        maxItems: 10,
        loadingStyle: loadingStyle,
        loadData: loadData,
        itemBuilder: (value) {
          return Container(
            height: 100.0,
            color: value,
          );
        },
      ),
    );
  }
}

class InfiniteListingHorizontallyScreen extends StatelessWidget {
  const InfiniteListingHorizontallyScreen({
    super.key,
    required this.loadData,
    required this.loadingStyle,
  });

  final LoadDatatype loadData;
  final LoadingStyle loadingStyle;

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
      body: Center(
        child: SizedBox(
          height: 100.0,
          child: ScrollInfinity(
            scrollDirection: Axis.horizontal,
            loadingStyle: loadingStyle,
            maxItems: 8,
            loadData: (pageKey) {
              return loadData(
                pageKey,
                scrollDirection: Axis.horizontal,
              );
            },
            itemBuilder: (value) {
              return Container(
                width: 200.0,
                color: value,
              );
            },
          ),
        ),
      ),
    );
  }
}
