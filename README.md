# Scroll Infinity

Scroll Infinity is a Flutter widget that provides an infinite scrolling list with support for paginated data loading, including loading, error, and empty states handling.

## Installation

Add the package to your project:

```bash
flutter pub add scroll_infinity
```

## Features

- Infinite scroll with pagination support
- Handling of loading, error, and empty states
- Insertion of separators between items
- Support for both vertical and horizontal scrolling
- Insertion of `null` values at defined intervals
- Optional header widget support
- Optional scrollbars
- Custom retry button on error
- Support for initial items
- Real item index mapping when using intervals

## Usage Example

### Vertical Scrolling

```dart
import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _maxItems = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ScrollInfinity<int>(
          maxItems: _maxItems,
          loadData: (page) async {
            await Future.delayed(
              const Duration(seconds: 2),
            );

            return List.generate(
              _maxItems,
              (index) => page * _maxItems + index + 1,
            );
          },
          itemBuilder: (value, index) {
            return ListTile(
              title: Text('Item $value'),
              subtitle: Text('Subtitle $value'),
            );
          },
        ),
      ),
    );
  }
}
```

### Horizontal Scrolling

```dart
import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _maxItems = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 100.0,
          child: ScrollInfinity<int>(
            scrollDirection: Axis.horizontal,
            maxItems: _maxItems,
            loadData: (page) async {
              await Future.delayed(
                const Duration(seconds: 2),
              );

              return List.generate(
                _maxItems,
                (index) => page * _maxItems + index + 1,
              );
            },
            itemBuilder: (value, index) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Item $value'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
```

### With Interval

```dart
import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _maxItems = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ScrollInfinity<int?>(
          maxItems: _maxItems,
          interval: 2,
          loadData: (page) async {
            await Future.delayed(
              const Duration(seconds: 2),
            );

            return List.generate(
              _maxItems,
              (index) => page * _maxItems + index + 1,
            );
          },
          itemBuilder: (value, index) {
            if (value == null) return const Divider();

            return ListTile(
              title: Text('Item $value'),
            );
          },
        ),
      ),
    );
  }
}
```

## Properties

| Name                 | Type                                   | Description                                                                                |
| -------------------- | -------------------------------------- | ------------------------------------------------------------------------------------------ |
| `loadData`           | `Future<List<T>?> Function(int)`       | Function responsible for loading data per page.                                            |
| `itemBuilder`        | `Widget Function(T? value, int index)` | Builds each list item. If `interval` is set, `value` can be `null`.                        |
| `maxItems`           | `int`                                  | Maximum number of items per page.                                                          |
| `initialItems`       | `List<T>?`                             | Initial items to display before the first request.                                         |
| `initialPageIndex`   | `int`                                  | Starting page index. Default is `0`.                                                       |
| `scrollDirection`    | `Axis`                                 | Scroll direction: `Axis.vertical` or `Axis.horizontal`. Default is `Axis.vertical`.        |
| `padding`            | `EdgeInsetsGeometry?`                  | Inner padding for the list.                                                                |
| `header`             | `Widget?`                              | Widget displayed at the beginning of the list.                                             |
| `separatorBuilder`   | `Widget Function(BuildContext, int)?`  | Builder for separators between items.                                                      |
| `scrollbars`         | `bool`                                 | Enables scrollbars if `true`. Default is `true`.                                           |
| `interval`           | `int?`                                 | Defines the interval for inserting `null` values.                                          |
| `enableRetryOnError` | `bool`                                 | Enables retry button on error. Default is `true`.                                          |
| `loading`            | `Widget?`                              | Widget displayed during loading.                                                           |
| `empty`              | `Widget?`                              | Widget displayed when no data is available.                                                |
| `tryAgainBuilder`    | `Widget Function(VoidCallback)?`       | Custom builder for the retry button.                                                       |
| `useRealItemIndex`   | `bool`                                 | If true, uses only actual item indices, skipping interval placeholders. Default is `true`. |

## License

Distributed under the MIT License. See the `LICENSE` file for more information.

## Author

Developed by [Dário Matias](https://github.com/dariomatias-dev).

## Donations

Help maintain the project with donations.

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/dariomatias)
