# Scroll Infinity

**Scroll Infinity** is a Flutter widget that provides an infinite scrollable list with built-in support for paginated data loading. It handles loading, empty, and error states, and offers flexible customization options.

## Installation

Add the package to your project:

```bash
flutter pub add scroll_infinity
```

## Features

- Infinite scroll with pagination;
- Manual or automatic data loading;
- Custom "Load More" and "Try Again" builders;
- Loading, error, and empty states handling;
- Optional scrollbars;
- Optional header widget;
- Optional separators between items;
- Vertical and horizontal scrolling support;
- Support for initial items;
- Inserting ranges with `null` values for identification;
- Limitation of repetitions;
- Real item index mapping when using intervals.

## Usage

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

| Name                      | Type                                  | Description                                                                                      |
| ------------------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `loadData`                | `Future<List<T>?> Function(int)`      | Fetches paginated data. Required.                                                                |
| `itemBuilder`             | `Widget Function(T value, int index)` | Builds each list item. If `interval` is used, `T` must be nullable.                              |
| `maxItems`                | `int`                                 | Max number of items per request. Required.                                                       |
| `initialItems`            | `List<T>?`                            | Optional initial items shown before the first load.                                              |
| `initialPageIndex`        | `int`                                 | Starting page index. Default is `0`.                                                             |
| `scrollDirection`         | `Axis`                                | Scrolling direction. Default is `Axis.vertical`.                                                 |
| `padding`                 | `EdgeInsetsGeometry?`                 | Inner padding of the list.                                                                       |
| `header`                  | `Widget?`                             | Widget shown at the start of the list.                                                           |
| `separatorBuilder`        | `Widget Function(BuildContext, int)?` | Builder for item separators.                                                                     |
| `scrollbars`              | `bool`                                | Whether scrollbars are visible. Default is `true`.                                               |
| `interval`                | `int?`                                | Inserts `null` every `interval` items. `T` must be nullable if set.                              |
| `enableRetryOnError`      | `bool`                                | Enables retry button on error. Default is `true`.                                                |
| `loading`                 | `Widget?`                             | Custom loading indicator.                                                                        |
| `empty`                   | `Widget?`                             | Widget shown when no items are found.                                                            |
| `tryAgainBuilder`         | `Widget Function(VoidCallback)?`      | Custom retry widget builder.                                                                     |
| `useRealItemIndex`        | `bool`                                | If true, uses real indices, ignoring interval items. Default is `true`.                          |
| `maxRetries`              | `int?`                                | Max number of retries before showing `retryLimitReachedWidget`. If `null`, retries indefinitely. |
| `retryLimitReachedWidget` | `Widget?`                             | Widget shown when retry limit is reached.                                                        |
| `automaticLoading`        | `bool`                                | If `true`, loads more items on scroll. If `false`, shows 'Load More' button. Default is `true`.  |
| `loadMoreBuilder`         | `Widget Function(VoidCallback)?`      | Custom builder for 'Load More' widget.                                                           |

## License

Distributed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author

Developed by [Dário Matias](https://github.com/dariomatias-dev)

## Support

If you find this package helpful, consider supporting it:

[![Buy Me a Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/dariomatias)
