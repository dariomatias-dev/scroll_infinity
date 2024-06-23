# Scroll Infinity

## Usage Example
Here is an example of how to use the package to create a list with infinite scrolling:

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
  static const maxItems = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollInfinity(
        maxItems: maxItems,
        loadData: (pageKey) async {
          await Future.delayed(
            const Duration(
              seconds: 2,
            ),
          );

          return List.generate(maxItems, (index) {
            return maxItems * pageKey + index + 1;
          });
        },
        itemBuilder: (value) {
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

## Properties

- **scrollDirection**: Defines the scrolling direction of the list. Can be `Axis.vertical` or `Axis.horizontal`.
```dart
scrollDirection: Axis.vertical,
```

- **padding**: Specifies the internal padding of the list.
```dart
padding: EdgeInsets(8.0),
```

- **loading**: Allows passing a custom loading component.
```dart
loading: CustomLoadingWidget(),
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
loadData: (pageKey) async {
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
itemBuilder: (context, index) {
  final item = items[index];

  return ListTile(
    title: Text(item.title),
    subtitle: Text(item.subtitle),
  );
},
```
