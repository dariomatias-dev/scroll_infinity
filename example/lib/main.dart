import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ConfigScreen(),
    ),
  );
}

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  // Notifiers for numeric values
  final _maxItemsNotifier = ValueNotifier<int>(10);
  final _intervalNotifier = ValueNotifier<int>(2);
  final _maxRetriesNotifier = ValueNotifier<int>(3);

  // Configuration state
  Axis _scrollDirection = Axis.vertical;
  final _features = <String, bool>{
    'Header': false,
    'Intervals': false,
    'Initial Items': false,
    'Automatic Loading': true,
    'Enable Retries Limit': false,
    'Custom Builders': false,
  };

  void _navigateToExample() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return DisplayScreen(
            scrollDirection: _scrollDirection,
            maxItems: _maxItemsNotifier.value,
            interval: _intervalNotifier.value,
            maxRetries: _maxRetriesNotifier.value,
            enableHeader: _features['Header']!,
            enableInterval: _features['Intervals']!,
            enableInitialItems: _features['Initial Items']!,
            automaticLoading: _features['Automatic Loading']!,
            enableRetryLimit: _features['Enable Retries Limit']!,
            enableCustomBuilders: _features['Custom Builders']!,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scroll Infinity Config'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _FieldTitle(title: 'Scroll Direction'),
              const Divider(),
              RadioListTile<Axis>(
                title: const Text('Vertical'),
                value: Axis.vertical,
                groupValue: _scrollDirection,
                onChanged: (value) => setState(() => _scrollDirection = value!),
              ),
              RadioListTile<Axis>(
                title: const Text('Horizontal'),
                value: Axis.horizontal,
                groupValue: _scrollDirection,
                onChanged: (value) => setState(() => _scrollDirection = value!),
              ),
              const SizedBox(height: 24.0),
              const _FieldTitle(title: 'Data & Features'),
              const Divider(),
              _ConfigRow(
                label: 'Max Items Per Fetch',
                control: _QuantitySelector(notifier: _maxItemsNotifier),
              ),
              const Divider(),
              // Feature Toggles
              ..._features.keys.map((key) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SwitchListTile(
                      title: Text(key),
                      value: _features[key]!,
                      onChanged: (value) {
                        setState(() => _features[key] = value);
                      },
                    ),
                    if (key == 'Intervals' && _features[key]!)
                      _ConfigRow(
                        label: 'Item Interval',
                        control: _QuantitySelector(
                          notifier: _intervalNotifier,
                        ),
                      ),
                    if (key == 'Enable Retries Limit' && _features[key]!)
                      _ConfigRow(
                        label: 'Max Retries Count',
                        control: _QuantitySelector(
                          notifier: _maxRetriesNotifier,
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
              ),
            ),
            onPressed: _navigateToExample,
            child: const Text('Show Example'),
          ),
        ),
      ),
    );
  }
}

// region Helper Widgets for ConfigScreen
class _FieldTitle extends StatelessWidget {
  const _FieldTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({
    required this.label,
    required this.control,
  });

  final String label;
  final Widget control;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label),
          control,
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.notifier,
  });

  final ValueNotifier<int> notifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (context, value, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: value > 2 ? () => notifier.value-- : null,
            ),
            SizedBox(
              width: 24.0,
              child: Center(
                child: Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: value < 20 ? () => notifier.value++ : null,
            ),
          ],
        );
      },
    );
  }
}
// endregion

/// Displays the configured ScrollInfinity widget.
class DisplayScreen extends StatefulWidget {
  const DisplayScreen({
    super.key,
    required this.scrollDirection,
    required this.maxItems,
    required this.interval,
    required this.maxRetries,
    required this.enableHeader,
    required this.enableInterval,
    required this.enableInitialItems,
    required this.automaticLoading,
    required this.enableRetryLimit,
    required this.enableCustomBuilders,
  });

  final Axis scrollDirection;
  final int maxItems;
  final int interval;
  final int maxRetries;
  final bool enableHeader;
  final bool enableInterval;
  final bool enableInitialItems;
  final bool automaticLoading;
  final bool enableRetryLimit;
  final bool enableCustomBuilders;

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  var _scrollInfinityKey = UniqueKey();
  final _random = Random();

  /// Simulates a network request to fetch paginated data.
  Future<List<Color>?> _loadData(int pageIndex) async {
    await Future.delayed(const Duration(seconds: 2));

    // Simulate a request failure
    if (pageIndex > 0 && _random.nextInt(4) == 0) {
      return null;
    }

    // Simulate the end of the list
    final isListEnd = pageIndex > 3 && _random.nextInt(4) == 0;
    final itemCount =
        isListEnd ? _random.nextInt(widget.maxItems) : widget.maxItems;

    return List.generate(itemCount, (index) {
      return Color.fromARGB(
        255,
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      );
    });
  }

  void _resetList() => setState(() => _scrollInfinityKey = UniqueKey());

  List<Color> _generateInitialItems() {
    return List.generate(
      widget.maxItems,
      (index) => Colors.primaries[index % Colors.primaries.length],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVertical = widget.scrollDirection == Axis.vertical;

    final scrollInfinity = ScrollInfinity<Color?>(
      key: _scrollInfinityKey,
      // Core
      maxItems: widget.maxItems,
      initialItems: widget.enableInitialItems ? _generateInitialItems() : null,
      loadData: _loadData,
      itemBuilder: (value, index) {
        final width = isVertical ? double.infinity : 200.0;
        final height = isVertical ? 100.0 : double.infinity;

        if (value == null) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: Text('Interval Widget $index'),
          );
        }

        return Container(
          width: width,
          height: height,
          color: value,
          alignment: Alignment.center,
          child: Text(
            'Item $index',
            style: TextStyle(
              color:
                  value.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            ),
          ),
        );
      },
      // Layout
      scrollDirection: widget.scrollDirection,
      header: widget.enableHeader
          ? Container(
              color: Colors.red.withAlpha(204),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              height: 52.0,
              child: const Text(
                'Header',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          : null,
      // Behavior
      interval: widget.enableInterval ? widget.interval : null,
      automaticLoading: widget.automaticLoading,
      // Error Handling
      maxRetries: widget.enableRetryLimit ? widget.maxRetries : null,
      // Custom State Widgets
      loading: widget.enableCustomBuilders
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  strokeWidth: 6.0,
                  valueColor: AlwaysStoppedAnimation(
                    Colors.orange,
                  ),
                ),
              ),
            )
          : null,
      loadMoreBuilder: widget.enableCustomBuilders
          ? (action) {
              return TextButton.icon(
                onPressed: action,
                icon: const Icon(Icons.add),
                label: const Text('Load More'),
              );
            }
          : null,
      tryAgainBuilder: widget.enableCustomBuilders
          ? (action) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: OutlinedButton.icon(
                    onPressed: action,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Please Try Again'),
                  ),
                ),
              );
            }
          : null,
      retryLimitReached: widget.enableCustomBuilders
          ? const Card(
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Retry limit reached. Please try again later.',
                ),
              ),
            )
          : null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ScrollInfinity Example'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetList,
            tooltip: 'Reset List',
          ),
        ],
      ),
      body: isVertical
          ? scrollInfinity
          : Center(
              child: SizedBox(
                height: 120.0,
                child: scrollInfinity,
              ),
            ),
    );
  }
}
