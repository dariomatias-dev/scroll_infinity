# ScrollInfinity

[![pub package](https://img.shields.io/pub/v/scroll_infinity.svg)](https://pub.dev/packages/scroll_infinity)
[![likes](https://img.shields.io/pub/likes/scroll_infinity)](https://pub.dev/packages/scroll_infinity/score)
[![points](https://img.shields.io/pub/points/scroll_infinity)](https://pub.dev/packages/scroll_infinity/score)
[![popularity](https://img.shields.io/pub/popularity/scroll_infinity)](https://pub.dev/packages/scroll_infinity/score)

**ScrollInfinity** is a Flutter widget that provides an infinite scrollable list with built-in support for paginated data loading. It handles loading, empty, and error states, and offers flexible customization options.

## Installation

Add the package to your project:

```bash
flutter pub add scroll_infinity
```

## Development Environment

The following versions were used during the development and testing of `ScrollInfinity`. Other versions might work, but they haven't been officially tested:

| Tool        | Version Used |
| ----------- | ------------ |
| Flutter SDK | 3.32.7       |
| Dart SDK    | 3.8.1        |

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
- Inserting ranges with `null` value for identification;
- Limitation of retry repetitions;
- Real item index mapping when using intervals.

## How Pagination Works

The pagination mechanism is based on requesting a new page of items when the user scrolls to the end of the list (or manually triggers loading if `automaticLoading` is disabled). The `loadData` function is called with the current page index, and it should return a list of up to `maxItems`.

If the returned list is empty on the **first request**, the widget assumes there are no items to display and shows an empty state widget or message.

If the request returns `null` at any time, it indicates that an error occurred during data fetching, and the error state will be displayed.

Intervals can be used to insert `null` values periodically in the list, which can serve as placeholders to display ads, dividers, or other special widgets.

## Note on Generic Type `T`

The `ScrollInfinity` widget uses a generic type `T` to support any data model. When using features like `interval`, ensure that `T` is nullable (`T?`), as `null` values will be inserted into the list to represent special items (e.g., ads, dividers or spacers). The `itemBuilder` must handle these cases accordingly.

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

### Vertical Scrolling With Interval

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

### Advanced Usage

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
  static const _maxItemsPerPage = 10;
  static const _maxRetries = 3;

  int _retryCount = 0;

  Future<List<int>?> _fetchData(int page) async {
    await Future.delayed(const Duration(seconds: 2));

    if (page == 3 && _retryCount < _maxRetries) {
      _retryCount++;

      return null;
    }

    return List.generate(
      _maxItemsPerPage,
      (index) => page * _maxItemsPerPage + index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ScrollInfinity<int?>(
          initialItems: const <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
          initialPageIndex: 1,
          maxItems: _maxItemsPerPage,
          loadData: _fetchData,
          interval: 4,
          automaticLoading: false,
          maxRetries: _maxRetries,
          header: Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.blue.shade50,
            child: const Center(
              child: Text(
                'This is a header widget',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
          ),
          separatorBuilder: (context, index) {
            return const Divider(
              height: 1.0,
              color: Colors.grey,
            );
          },
          itemBuilder: (item, index) {
            if (item == null) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16.0,
                ),
                padding: const EdgeInsets.all(16.0),
                color: Colors.yellow.shade200,
                child: Center(
                  child: Text(
                    'Sponsored Ad Banner $index',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }

            return ListTile(
              leading: CircleAvatar(
                child: Text('$item'),
              ),
              title: Text('Item #$item'),
              subtitle: Text(
                'This is the subtitle for item #$item',
              ),
            );
          },
          loading: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          empty: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'No items available to display',
              ),
            ),
          ),
          tryAgainBuilder: (onTryAgain) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton.icon(
                onPressed: onTryAgain,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            );
          },
          loadMoreBuilder: (onLoadMore) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: onLoadMore,
                child: const Text(
                  'Load More Items',
                ),
              ),
            );
          },
          retryLimitReached: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'Maximum retry attempts reached.\nPlease try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### Full Example with Configuration Screen

A more advanced and complete example is available in the `example` directory of the repository.
It includes a configuration screen for adjusting `ScrollInfinity` options, and a separate screen that displays the infinite scroll with the selected settings applied:
[example/lib/main.dart](https://github.com/dariomatias-dev/scroll_infinity/blob/main/example/lib/main.dart)

## Properties

### Core Data Handling

| Name               | Type                                  | Default | Description                                                                                                              |
| ------------------ | ------------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------ |
| `loadData`         | `Future<List<T>?> Function(int)`      | –       | Callback responsible for fetching data for each page. Required.                                                          |
| `itemBuilder`      | `Widget Function(T value, int index)` | –       | Builder function responsible for rendering each item in the list. If `interval` is used, `T` must be nullable. Required. |
| `maxItems`         | `int`                                 | –       | The maximum number of items to retrieve per request. Required.                                                           |
| `initialItems`     | `List<T>?`                            | `null`  | A list of items displayed before the first data fetch is initiated.                                                      |
| `initialPageIndex` | `int`                                 | `0`     | The starting index from which to begin loading data.                                                                     |

### Layout & Appearance

| Name               | Type                                  | Default         | Description                                           |
| ------------------ | ------------------------------------- | --------------- | ----------------------------------------------------- |
| `scrollDirection`  | `Axis`                                | `Axis.vertical` | Defines the scroll direction of the list.             |
| `padding`          | `EdgeInsetsGeometry?`                 | `null`          | Defines the internal padding of the list view.        |
| `header`           | `Widget?`                             | `null`          | A widget displayed at the beginning of the list.      |
| `separatorBuilder` | `Widget Function(BuildContext, int)?` | `null`          | A builder that inserts separators between list items. |
| `scrollbars`       | `bool`                                | `true`          | Determines whether scrollbars should be displayed.    |

### Behavioral Features

| Name               | Type   | Default | Description                                                                                                                                       |
| ------------------ | ------ | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `interval`         | `int?` | `null`  | Specifies an interval at which a `null` value is inserted into the list. `T` must be nullable if set.                                             |
| `useRealItemIndex` | `bool` | `true`  | If `true`, real data items have their own index that ignores interval (`null`) items — meaning data and interval items have independent indexing. |
| `automaticLoading` | `bool` | `true`  | Determines if new items are fetched automatically on scroll. If `false`, a 'Load More' button is displayed at the end of the list.                |

### Error Handling

| Name                 | Type   | Default | Description                                                                                                            |
| -------------------- | ------ | ------- | ---------------------------------------------------------------------------------------------------------------------- |
| `enableRetryOnError` | `bool` | `true`  | Indicates whether retrying is allowed when an error occurs.                                                            |
| `maxRetries`         | `int?` | `null`  | The maximum number of retries to attempt after a failed data fetch. If `null`, retries will be attempted indefinitely. |

### State-Specific Widgets

| Name                | Type                             | Default | Description                                                                                            |
| ------------------- | -------------------------------- | ------- | ------------------------------------------------------------------------------------------------------ |
| `loading`           | `Widget?`                        | `null`  | Custom widget shown during the loading of additional data.                                             |
| `empty`             | `Widget?`                        | `null`  | Widget displayed when the initial data fetch returns an empty result.                                  |
| `tryAgainBuilder`   | `Widget Function(VoidCallback)?` | `null`  | A builder that constructs a custom 'Try Again' widget when an error occurs.                            |
| `loadMoreBuilder`   | `Widget Function(VoidCallback)?` | `null`  | A builder that constructs a custom 'Load More' widget when `automaticLoading` is `false`.              |
| `retryLimitReached` | `Widget?`                        | `null`  | A widget to display when the `maxRetries` limit has been reached. If not provided, a default is shown. |

## License

Distributed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author

Developed by [Dário Matias](https://github.com/dariomatias-dev).

## Support

If you find this package helpful, consider supporting it:

[![Buy Me a Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/dariomatias)
