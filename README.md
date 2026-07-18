<br>
<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
</div>
<br>

<p align="center">
  <strong>Language:</strong>
  <strong>English</strong> | <a href="README.pt.md">Português</a>
</p>

<h1 align="center">Scroll Infinity</h1>

<p align="center">
  A Flutter widget that provides an infinite scrollable list with built-in support for paginated data loading, state handling, and flexible customization.
  <br>
  <a href="#about-the-project"><strong>Explore the docs »</strong></a>
  <br><br>
  <a href="https://pub.dev/packages/scroll_infinity">View on pub.dev</a>
  ·
  <a href="https://github.com/dariomatias-dev/scroll_infinity/issues">Report Bug</a>
  ·
  <a href="https://github.com/dariomatias-dev/scroll_infinity/issues">Request Feature</a>
</p>

<div align="center">
  <img src="https://img.shields.io/pub/v/scroll_infinity.svg">
  <img src="https://img.shields.io/pub/likes/scroll_infinity">
  <img src="https://img.shields.io/pub/points/scroll_infinity">
</div>

## Table of Contents

- [About The Project](#about-the-project)
- [Features](#features)
- [Built With](#built-with)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Installation](#installation)
- [Usage](#usage)
  - [Basic Vertical Scroll](#basic-vertical-scroll)
  - [Basic Horizontal Scroll](#basic-horizontal-scroll)
  - [Vertical Scroll with Interval](#vertical-scroll-with-interval)
  - [Controller (Refresh & Retry)](#controller-refresh--retry)
  - [Switching Data Sources](#switching-data-sources)
  - [Pull-to-Refresh](#pull-to-refresh)
  - [Manual Loading](#manual-loading)
  - [Error and Analytics Callbacks](#error-and-analytics-callbacks)
- [Properties](#properties)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

## About The Project

ScrollInfinity simplifies implementing infinite scroll lists in Flutter. It handles paginated loading, state management (loading, empty, error), and user interactions, letting developers focus on building item UIs.

It offers customization for manual/automatic loading, custom state widgets, and both vertical and horizontal layouts.

### Development Environment

| Tool        | Version Used |
| ----------- | ------------ |
| Flutter SDK | 3.44.6       |
| Dart SDK    | 3.12.2       |

## Features

- Infinite scroll with pagination
- Manual or automatic data loading
- Custom "Load More" and "Try Again" builders
- Loading, error, and empty states handling
- Optional scrollbars, header widget, and separators
- Vertical and horizontal scrolling support
- Reversed scroll direction (e.g. chat-style lists)
- Initial items support
- Insert null values at intervals (ads/dividers)
- Retry attempts limit on error
- Real item index mapping with intervals
- `ScrollInfinityController` for external refresh/retry
- Pull-to-refresh support
- Configurable load-more trigger threshold
- `onError` and `onItemsLoaded` callbacks for logging/analytics
- Passthrough of `physics`, `shrinkWrap`, and `cacheExtent` to the underlying `ListView`

## Built With

- **[Flutter](https://flutter.dev/)** - A UI toolkit by Google for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.  
- **[Dart](https://dart.dev/)** - The programming language used for Flutter, optimized for building fast apps on any platform.

## Getting Started

### Requirements

| Requirement | Version    |
| ----------- | ---------- |
| Dart SDK    | >=3.3.4    |
| Flutter SDK | >=1.17.0   |

Supports Android, iOS, web, Windows, Linux, and macOS.

### Installation

```bash
flutter pub add scroll_infinity
```

## Usage

Pagination requests a new page when the user reaches the list end.
If `loadData` returns `null`, the error state is shown.

**Note:** Use a nullable type `T?` when using `interval`, as null values are inserted.

A fully configurable demo with every property wired to UI controls is available in the [example](example) directory.

### Basic Vertical Scroll

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

### Basic Horizontal Scroll

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

### Vertical Scroll with Interval

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

### Controller (Refresh & Retry)

Use a `ScrollInfinityController` to trigger `refresh()`/`retry()` from outside the widget (e.g. a button) and to read `isLoading`/`hasError`. Dispose it in `dispose()` since you created it.

```dart
final _controller = ScrollInfinityController();

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return ScrollInfinity<int>(
    controller: _controller,
    maxItems: _maxItems,
    loadData: _loadData,
    itemBuilder: _itemBuilder,
  );
}

// Elsewhere, e.g. a FloatingActionButton:
onPressed: () => _controller.refresh(),
```

### Switching Data Sources

`loadData` is a `Function`, so passing an inline closure (e.g. `loadData: (page) => ...`) creates a new instance on every rebuild — comparing it by identity would reset the list on every parent `setState`, which is rarely what you want. Because of that, changing `loadData` alone does **not** reset the list.

To load a different data set (e.g. switching category or search query), either:

- Call `_controller.refresh()` explicitly when the source changes, or
- Give the `ScrollInfinity` a new `Key` (e.g. `ValueKey(category)`) so Flutter remounts it from scratch.

```dart
ScrollInfinity<int>(
  key: ValueKey(_category),
  maxItems: _maxItems,
  loadData: (page) => _loadData(_category, page),
  itemBuilder: _itemBuilder,
)
```

### Pull-to-Refresh

Set `enablePullToRefresh` to wrap the list in a `RefreshIndicator` that resets pagination back to `initialPageIndex`.

```dart
ScrollInfinity<int>(
  enablePullToRefresh: true,
  maxItems: _maxItems,
  loadData: _loadData,
  itemBuilder: _itemBuilder,
)
```

### Manual Loading

Set `automaticLoading` to `false` to show a "Load More" button instead of fetching automatically on scroll. Customize it with `loadMoreBuilder`.

```dart
ScrollInfinity<int>(
  automaticLoading: false,
  loadMoreBuilder: (action) {
    return TextButton(
      onPressed: action,
      child: const Text('Load more'),
    );
  },
  maxItems: _maxItems,
  loadData: _loadData,
  itemBuilder: _itemBuilder,
)
```

### Error and Analytics Callbacks

Use `onError` to log/report the raw exception thrown by `loadData`, and `onItemsLoaded` to observe successfully fetched items (e.g. analytics). Neither affects the build.

```dart
ScrollInfinity<int>(
  onError: (error) => log('Failed to load items', error: error),
  onItemsLoaded: (items) => analytics.logEvent('items_loaded', {'count': items.length}),
  maxItems: _maxItems,
  loadData: _loadData,
  itemBuilder: _itemBuilder,
)
```

## Properties

**Core Data Handling**

| Name             | Type                                  | Default | Description                                     |
| ---------------- | ------------------------------------- | ------- | ------------------------------------------------ |
| loadData         | `Future<List<T>?> Function(int)`      | -       | Fetch data for each page                         |
| itemBuilder      | `Widget Function(T value, int index)` | -       | Builds each item                                 |
| maxItems         | `int`                                 | -       | Max items per request                            |
| initialItems     | `List<T>?`                            | null    | Items before first fetch                         |
| initialPageIndex | `int`                                 | 0       | Starting page index                              |
| controller       | `ScrollInfinityController?`           | null    | External refresh/retry and loading/error state   |
| onItemsLoaded    | `void Function(List<T> items)?`       | null    | Called with fetched items on each successful load |

**Layout & Appearance**

| Name                | Type                                  | Default  | Description                                        |
| ------------------- | ------------------------------------- | -------- | -------------------------------------------------- |
| scrollDirection     | `Axis`                                | vertical | Scroll direction                                   |
| reverse             | `bool`                                | false    | Reverses scroll/growth direction (e.g. chat lists) |
| padding             | `EdgeInsetsGeometry?`                 | null     | Internal padding                                   |
| header              | `Widget?`                             | null     | Header widget                                      |
| separatorBuilder    | `Widget Function(BuildContext, int)?` | null     | Separators                                         |
| scrollbars          | `bool`                                | true     | Show scrollbars                                    |
| enablePullToRefresh | `bool`                                | false    | Wraps list in a `RefreshIndicator`                 |
| physics             | `ScrollPhysics?`                      | null     | Passed to the underlying `ListView`                |
| shrinkWrap          | `bool`                                | false    | Passed to the underlying `ListView`                |
| cacheExtent         | `double?`                             | null     | Passed to the underlying `ListView`                |

**Behavioral Features**

| Name              | Type     | Default | Description                                     |
| ----------------- | -------- | ------- | ------------------------------------------------ |
| interval          | `int?`   | null    | Null item insertion interval                     |
| useRealItemIndex  | `bool`   | true    | Independent indexing                             |
| automaticLoading  | `bool`   | true    | Auto-fetch on scroll                             |
| loadMoreThreshold | `double` | 200     | Distance from list end that triggers the next page |

**Error Handling**

| Name               | Type                          | Default | Description                        |
| ------------------ | ----------------------------- | ------- | ----------------------------------- |
| enableRetryOnError | `bool`                        | true    | Allow retry                         |
| maxRetries         | `int?`                        | null    | Retry limit                         |
| onError            | `void Function(Object error)?` | null    | Called with the exception on failure |

**State-Specific Widgets**

| Name              | Type                             | Default | Description                |
| ----------------- | -------------------------------- | ------- | -------------------------- |
| loading           | `Widget?`                        | null    | Loading state widget       |
| empty             | `Widget?`                        | null    | Empty state widget         |
| tryAgainBuilder   | `Widget Function(VoidCallback)?` | null    | "Try Again" widget         |
| loadMoreBuilder   | `Widget Function(VoidCallback)?` | null    | "Load More" widget         |
| retryLimitReached | `Widget?`                        | null    | Retry limit reached widget |

## Contributing

1. Fork the project
2. Create a feature branch:

   ```bash
   git checkout -b feature/AmazingFeature
   ```

3. Commit changes:

   ```bash
   git commit -m 'Add some AmazingFeature'
   ```

4. Push to branch:

   ```bash
   git push origin feature/AmazingFeature
   ```

5. Open a Pull Request

## License

Distributed under the MIT License. See the [LICENSE](LICENSE) file for more information.

## Author

Developed by **Dário Matias**:

- Portfolio: [https://dariomatias-dev.com](https://dariomatias-dev.com)
- GitHub: [https://github.com/dariomatias-dev](https://github.com/dariomatias-dev)
- Email: [matiasdario75@gmail.com](mailto:matiasdario75@gmail.com)
- Instagram: [https://instagram.com/dariomatias_dev](https://instagram.com/dariomatias_dev)
- LinkedIn: [https://linkedin.com/in/dariomatias-dev](https://linkedin.com/in/dariomatias-dev)
