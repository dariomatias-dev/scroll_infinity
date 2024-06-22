import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

typedef LoadDatatype = Future<List<Color>> Function(
  int pageKey, {
  Axis scrollDirection,
});

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
  final _controller = ScrollInfinityController();

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

    _controller.isListEnd = random.nextInt(4) == 0;

    final isVertical = scrollDirection == Axis.vertical;

    return List.generate(isVertical ? 10 : 6, (index) {
      return Color.fromARGB(
        255,
        random.nextInt(255),
        random.nextInt(255),
        random.nextInt(255),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                navigateTo(
                  InfiniteListingVerticallyScreen(
                    controller: _controller,
                    loadData: _loadData,
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
                    controller: _controller,
                    loadData: _loadData,
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
    required this.controller,
    required this.loadData,
  });

  final ScrollInfinityController controller;
  final LoadDatatype loadData;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).brightness == Brightness.light
          ? ThemeData.light()
          : ThemeData.dark(),
      child: Scaffold(
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
        body: ScrollInfinity<Color>(
          controller: controller,
          loadData: loadData,
          itemBuilder: (value) {
            return Container(
              height: 100.0,
              color: value,
            );
          },
        ),
      ),
    );
  }
}

class InfiniteListingHorizontallyScreen extends StatelessWidget {
  const InfiniteListingHorizontallyScreen({
    super.key,
    required this.controller,
    required this.loadData,
  });

  final ScrollInfinityController controller;
  final LoadDatatype loadData;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).brightness == Brightness.light
          ? ThemeData.light()
          : ThemeData.dark(),
      child: Scaffold(
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
              controller: controller,
              scrollDirection: Axis.horizontal,
              loadData: (pageKey) {
                return loadData(
                  pageKey,
                  scrollDirection: Axis.horizontal,
                );
              },
              itemBuilder: (value) {
                return Container(
                  height: 100.0,
                  color: value,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
