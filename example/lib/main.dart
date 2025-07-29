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
  Axis _scrollDirection = Axis.vertical;
  final _maxItemsNotifier = ValueNotifier<int>(10);
  final _intervalNotifier = ValueNotifier<int>(2);

  final _features = <String, bool>{
    'Header': false,
    'Intervals': false,
    'Initial Items': false,
    'Custom Loader': false,
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
            enableHeader: _features['Header']!,
            enableInterval: _features['Intervals']!,
            enableInitialItems: _features['Initial Items']!,
            enableCustomLoader: _features['Custom Loader']!,
          );
        },
      ),
    );
  }

  Widget _getScrollDirectionSelector() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
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
      ],
    );
  }

  Widget _getFeatureSwitches() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _features.keys.map((key) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SwitchListTile(
              title: Text(key),
              value: _features[key]!,
              onChanged: (bool value) {
                setState(() {
                  _features[key] = value;
                });
              },
            ),
            if (key == 'Intervals' && _features[key]!)
              _QuantitySelector(notifier: _intervalNotifier),
          ],
        );
      }).toList(),
    );
  }

  Widget _getNavigateButton() {
    return Padding(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _FieldTitle(title: 'Scroll Direction'),
              const Divider(),
              _getScrollDirectionSelector(),
              const SizedBox(height: 28.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const _FieldTitle(
                    title: 'Max Items Per Fetch',
                  ),
                  _QuantitySelector(
                    notifier: _maxItemsNotifier,
                  ),
                ],
              ),
              const SizedBox(height: 40.0),
              const _FieldTitle(title: 'Enable Features'),
              const Divider(),
              _getFeatureSwitches(),
              const Divider(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _getNavigateButton(),
    );
  }
}

class _FieldTitle extends StatelessWidget {
  const _FieldTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
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

/// Displays the configured ScrollInfinity widget.
class DisplayScreen extends StatefulWidget {
  const DisplayScreen({
    super.key,
    required this.scrollDirection,
    required this.maxItems,
    required this.interval,
    required this.enableHeader,
    required this.enableInterval,
    required this.enableInitialItems,
    required this.enableCustomLoader,
  });

  final Axis scrollDirection;
  final int maxItems;
  final int interval;
  final bool enableHeader;
  final bool enableInterval;
  final bool enableInitialItems;
  final bool enableCustomLoader;

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  var _scrollInfinityKey = UniqueKey();
  final _random = Random();
  final _initialItems = <Color>[];

  /// Simulates a network request to fetch paginated data.
  Future<List<Color>?> _loadData(int pageIndex) async {
    await Future.delayed(const Duration(seconds: 2));

    if (pageIndex > 0 && _random.nextInt(4) == 0) {
      return null; // Simulate a request failure
    }

    final isListEnd = _random.nextInt(5) == 0;
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

  void _resetList() {
    setState(() {
      _scrollInfinityKey = UniqueKey();
    });
  }

  List<Color> _generateInitialItems() {
    return List.generate(widget.maxItems, (index) {
      return Color.fromARGB(
        255,
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      );
    });
  }

  @override
  void initState() {
    super.initState();

    _initialItems.addAll(
      _generateInitialItems(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVertical = widget.scrollDirection == Axis.vertical;

    final scrollInfinity = ScrollInfinity<Color?>(
      key: _scrollInfinityKey,
      scrollDirection: widget.scrollDirection,
      maxItems: widget.maxItems,
      initialItems: widget.enableInitialItems ? _initialItems : null,
      loadData: _loadData,
      header: widget.enableHeader
          ? Container(
              height: isVertical ? 60.0 : double.infinity,
              width: isVertical ? double.infinity : 160.0,
              color: Colors.red.withAlpha(204),
              alignment: Alignment.center,
              child: const Text(
                'Header',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          : null,
      loading: widget.enableCustomLoader
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
                ),
              ),
            )
          : null,
      interval: widget.enableInterval ? widget.interval : null,
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
