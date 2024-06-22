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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                navigateTo(
                  InfiniteListingVerticallyScreen(
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
    required this.loadData,
  });

  final LoadDatatype loadData;

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
  });

  final LoadDatatype loadData;

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
