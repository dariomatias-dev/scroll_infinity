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
            await Future.delayed(const Duration(seconds: 2));

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

---

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
              await Future.delayed(const Duration(seconds: 2));

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

---

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
            await Future.delayed(const Duration(seconds: 2));

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

### Core Data Handling

| Name               | Type                                  | Default | Description                                                                                                              |
| ------------------ | ------------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------ |
| `loadData`         | `Future<List<T>?> Function(int)`      | –       | Callback responsible for fetching data for each page. Required.                                                          |
| `itemBuilder`      | `Widget Function(T value, int index)` | –       | Builder function responsible for rendering each item in the list. If `interval` is used, `T` must be nullable. Required. |
| `maxItems`         | `int`                                 | –       | The maximum number of items to retrieve per request. Required.                                                           |
| `initialItems`     | `List<T>?`                            | `null`  | A list of items displayed before the first data fetch is initiated.                                                      |
| `initialPageIndex` | `int`                                 | `0`     | The starting index from which to begin loading data.                                                                     |

---

### Layout & Appearance

| Name               | Type                                  | Default         | Description                                           |
| ------------------ | ------------------------------------- | --------------- | ----------------------------------------------------- |
| `scrollDirection`  | `Axis`                                | `Axis.vertical` | Defines the scroll direction of the list.             |
| `padding`          | `EdgeInsetsGeometry?`                 | `null`          | Defines the internal padding of the list view.        |
| `header`           | `Widget?`                             | `null`          | A widget displayed at the beginning of the list.      |
| `separatorBuilder` | `Widget Function(BuildContext, int)?` | `null`          | A builder that inserts separators between list items. |
| `scrollbars`       | `bool`                                | `true`          | Determines whether scrollbars should be displayed.    |

---

### Behavioral Features

| Name               | Type   | Default | Description                                                                                                                        |
| ------------------ | ------ | ------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `interval`         | `int?` | `null`  | Specifies an interval at which a `null` value is inserted into the list. `T` must be nullable if set.                              |
| `useRealItemIndex` | `bool` | `true`  | The index ignores range items and reflects only actual data items.                                                                 |
| `automaticLoading` | `bool` | `true`  | Determines if new items are fetched automatically on scroll. If `false`, a 'Load More' button is displayed at the end of the list. |

---

### Error Handling

| Name                 | Type   | Default | Description                                                                                                            |
| -------------------- | ------ | ------- | ---------------------------------------------------------------------------------------------------------------------- |
| `enableRetryOnError` | `bool` | `true`  | Indicates whether retrying is allowed when an error occurs.                                                            |
| `maxRetries`         | `int?` | `null`  | The maximum number of retries to attempt after a failed data fetch. If `null`, retries will be attempted indefinitely. |

---

### State-Specific Widgets

| Name                      | Type                             | Default | Description                                                                                            |
| ------------------------- | -------------------------------- | ------- | ------------------------------------------------------------------------------------------------------ |
| `loading`                 | `Widget?`                        | `null`  | Custom widget shown during the loading of additional data.                                             |
| `empty`                   | `Widget?`                        | `null`  | Widget displayed when the initial data fetch returns an empty result.                                  |
| `tryAgainBuilder`         | `Widget Function(VoidCallback)?` | `null`  | A builder that constructs a custom 'Try Again' widget when an error occurs.                            |
| `loadMoreBuilder`         | `Widget Function(VoidCallback)?` | `null`  | A builder that constructs a custom 'Load More' widget when `automaticLoading` is `false`.              |
| `retryLimitReachedWidget` | `Widget?`                        | `null`  | A widget to display when the `maxRetries` limit has been reached. If not provided, a default is shown. |

## License

Distributed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author

Developed by [Dário Matias](https://github.com/dariomatias-dev)

## Support

If you find this package helpful, consider supporting it:

[![Buy Me a Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/dariomatias)
