# Scroll Infinity

## Installation
Run this command:
```bash
flutter pub add scroll_infinity
```

## Usage Example
Here are some examples of how to use the package to create a list with infinite scrolling:

Vertical:
```dart
import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  static const _maxItems = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollInfinity(
        maxItems: _maxItems,
        loadData: (pageKey) async {
          await Future.delayed(
            const Duration(
              seconds: 2,
            ),
          );

          return List.generate(_maxItems, (index) {
            return _maxItems * pageKey + index + 1;
          });
        },
        itemBuilder: (value, index) {
          return ListTile(
            title: Text('Item $value'),
            subtitle: const Text('Subtitle'),
            trailing: const Icon(
              Icons.keyboard_arrow_right_rounded,
            ),
          );
        },
      ),
    );
  }
}
```

Horizontal:
```dart
import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  static const _maxItems = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 64.0,
          child: ScrollInfinity(
            scrollDirection: Axis.horizontal,
            maxItems: _maxItems,
            loadData: (pageKey) async {
              await Future.delayed(
                const Duration(
                  seconds: 2,
                ),
              );
        
              return List.generate(_maxItems, (index) {
                return _maxItems * pageKey + index + 1;
              });
            },
            itemBuilder: (value, index) {
              return Center(
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.5,
                  child: ListTile(
                    onTap: () {},
                    title: Text('Item $value'),
                    subtitle: const Text('Subtitle'),
                    trailing: const Icon(
                      Icons.keyboard_arrow_right_rounded,
                    ),
                  ),
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

</br>

### With Interval

Intervals are identified when the `value` of `itemBuilder` is `null`.
To allow the `value` of `itemBuilder` to be nullable, facilitating the verification of the `value`, use `ScrollInfinity` with the expected value type followed by `?`.

```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  static const _maxItems = 20;
  final _random = Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollInfinity<int?>(
        maxItems: _maxItems,
        interval: 2,
        loadData: (pageKey) async {
          await Future.delayed(
            const Duration(
              seconds: 2,
            ),
          );

          if (_random.nextInt(4) == 0) {
            return null;
          }

          return List.generate(_maxItems, (index) {
            return _maxItems * pageKey + index + 1;
          });
        },
        itemBuilder: (value, index) {
          if (value == null) {
            return const SizedBox(
              height: 60.0,
              child: Placeholder(),
            );
          }

          return ListTile(
            title: Text('Item $value'),
            subtitle: const Text('Subtitle'),
            trailing: const Icon(
              Icons.keyboard_arrow_right_rounded,
            ),
          );
        },
      ),
    );
  }
}
```

### With Loader

Add custom loading for initial items.

```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final _notifier = ScrollInfinityInitialItemsNotifier<int?>(null);

  static const _maxItems = 20;
  final _random = Random();

  Future<void> _initLoader() async {
    _notifier.value = await _loadData(0);
  }

  Future<List<int>?> _loadData(int pageIndex) async {
    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );

    if (_random.nextInt(4) == 0) {
      return null;
    }

    return List.generate(_maxItems, (index) {
      return _maxItems * pageIndex + index + 1;
    });
  }

  @override
  void initState() {
    _initLoader();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollInfinityLoader(
        notifier: _notifier,
        scrollInfinityBuilder: (items) {
          return ScrollInfinity<int?>(
            maxItems: _maxItems,
            disableInitialRequest: true,
            initialPageIndex: 1,
            initialItems: items,
            interval: 2,
            loadData: _loadData,
            itemBuilder: (value, index) {
              if (value == null) {
                return const SizedBox(
                  height: 60.0,
                  child: Placeholder(),
                );
              }

              return ListTile(
                title: Text('Item $value'),
                subtitle: const Text('Subtitle'),
                trailing: const Icon(
                  Icons.keyboard_arrow_right_rounded,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

## Properties

- **scrollDirection**: Defines the scrolling direction of the list. Can be `Axis.vertical` or `Axis.horizontal`.
```dart
scrollDirection: Axis.vertical,
```

- **scrollbars**: Shows scrollbars if `true`. Default is `false`.
```dart
scrollbars: true,
```

- **padding**: Specifies the internal padding of the list.
```dart
padding: EdgeInsets(8.0),
```

- **disableInitialRequest**: Disables the initial data request if set to `true`. Default is `false`.
```dart
disableInitialRequest: true,
```

- **initialPageIndex**: Initial page index. Default is `0`.
```dart
initialPageIndex: 1,
```

- **enableRetryOnError**: Determines if retrying to load data after an error is enabled. Default is `true`.
```dart
enableRetryOnError = false,
```

- **error**: Widget used to display custom content when an error occurs.
```dart
error: Text('Error message'),
```

- **header**: Listing header.
```dart
header: HeaderWidget(),
```

- **initialItems**: Specifies the initial items to be displayed in the list.
```dart
initialItems: <Widget>[
  // items
],
```

- **interval**: Specifies the range in which the `null` value is passed.
```dart
interval: 20,
```

- **loading**: Allows passing a custom loading component.
```dart
loading: LoadingWidget(),
```

- **loadingStyle**: Defines the style of the `CircularProgressIndicator`. Use this property to customize the appearance of the default loading indicator.
```dart
loadingStyle: CircularProgressIndicator(
  color: Colors.blue,
  strokeWidth: 8.0,
),
```

- **maxItems**: Specifies the maximum number of items per request. This will be used to determine when the list reaches the end.
```dart
maxItems: 20,
```

- **loadData**: Function responsible for loading the data. It should return a list of items.
```dart
loadData: (pageIndex) async {
  // Logic to load the data
},
```

- **separatorBuilder**: Builds the separator component between the items in the list. Use this property to add custom dividers between the items.
```dart
separatorBuilder: (context, index) {
  return Divider(
    color: Colors.grey,
    height: 1.0,
  );
},
```

- **itemBuilder**: Builds the items in the list. This function should return the widget that represents each item in the list.
```dart
itemBuilder: (value, index) {
  final item = items[index];

  return ListTile(
    title: Text(item.title),
    subtitle: Text(item.subtitle),
  );
},
```

# Author
This Flutter package was developed by [Dário Matias](https://github.com/dariomatias-dev).

# Donations

Help maintain the project with donations.

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/dariomatias)
