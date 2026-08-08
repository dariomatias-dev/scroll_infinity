import 'dart:async';
import 'dart:developer' as dev;
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

/// Immutable set of options assembled on [ConfigScreen] and applied to the
/// [ScrollInfinity] widget shown on [DisplayScreen].
class ExampleConfig {
  /// Creates an [ExampleConfig].
  const ExampleConfig({
    required this.scrollDirection,
    required this.maxItems,
    required this.initialPageIndex,
    required this.interval,
    required this.maxRetries,
    required this.loadMoreThreshold,
    required this.enableHeader,
    required this.enableSeparators,
    required this.reverse,
    required this.scrollbars,
    required this.enablePullToRefresh,
    required this.enableInterval,
    required this.useRealItemIndex,
    required this.enableInitialItems,
    required this.automaticLoading,
    required this.simulateErrors,
    required this.enableRetry,
    required this.enableRetryLimit,
    required this.enableCustomBuilders,
  });

  /// The scroll direction of the list.
  final Axis scrollDirection;

  /// The maximum number of items fetched per page.
  final int maxItems;

  /// The page index the first fetch starts from.
  final int initialPageIndex;

  /// The number of data items between interval placeholders.
  final int interval;

  /// The maximum number of retry attempts allowed after an error.
  final int maxRetries;

  /// The distance, in pixels, from the end of the list at which the next
  /// page starts loading.
  final double loadMoreThreshold;

  /// Whether a header widget is shown above the list.
  final bool enableHeader;

  /// Whether separators are inserted between the list items.
  final bool enableSeparators;

  /// Whether the list grows in the reverse direction (chat-style).
  final bool reverse;

  /// Whether scrollbars are visible.
  final bool scrollbars;

  /// Whether the list is wrapped in a pull-to-refresh indicator.
  final bool enablePullToRefresh;

  /// Whether interval placeholders are inserted into the list.
  final bool enableInterval;

  /// Whether data items and placeholders keep independent indexes.
  final bool useRealItemIndex;

  /// Whether the list is seeded with items before the first fetch.
  final bool enableInitialItems;

  /// Whether new pages are fetched automatically on scroll.
  final bool automaticLoading;

  /// Whether the mock data source randomly fails.
  final bool simulateErrors;

  /// Whether retrying is allowed after a failed fetch. When `false`, the
  /// list is built with `maxRetries: 0`.
  final bool enableRetry;

  /// Whether [maxRetries] is enforced.
  final bool enableRetryLimit;

  /// Whether custom widgets replace the default state widgets.
  final bool enableCustomBuilders;
}

/// Screen for configuring the [ScrollInfinity] example before viewing it.
class ConfigScreen extends StatefulWidget {
  /// Creates a [ConfigScreen].
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  // Notifiers for numeric values.
  final _maxItemsNotifier = ValueNotifier<int>(10);
  final _initialPageIndexNotifier = ValueNotifier<int>(0);
  final _intervalNotifier = ValueNotifier<int>(2);
  final _maxRetriesNotifier = ValueNotifier<int>(3);
  final _thresholdNotifier = ValueNotifier<double>(200);

  // Selection state.
  Axis _scrollDirection = Axis.vertical;
  bool _enableHeader = false;
  bool _enableSeparators = false;
  bool _reverse = false;
  bool _scrollbars = true;
  bool _enablePullToRefresh = false;
  bool _enableInitialItems = false;
  bool _automaticLoading = true;
  bool _enableInterval = false;
  bool _useRealItemIndex = true;
  bool _simulateErrors = true;
  bool _enableRetry = true;
  bool _enableRetryLimit = false;
  bool _enableCustomBuilders = false;

  bool get _isVertical => _scrollDirection == Axis.vertical;

  @override
  void dispose() {
    _maxItemsNotifier.dispose();
    _initialPageIndexNotifier.dispose();
    _intervalNotifier.dispose();
    _maxRetriesNotifier.dispose();
    _thresholdNotifier.dispose();

    super.dispose();
  }

  void _navigateToExample() {
    final config = ExampleConfig(
      scrollDirection: _scrollDirection,
      maxItems: _maxItemsNotifier.value,
      initialPageIndex: _initialPageIndexNotifier.value,
      interval: _intervalNotifier.value,
      maxRetries: _maxRetriesNotifier.value,
      loadMoreThreshold: _thresholdNotifier.value,
      enableHeader: _enableHeader,
      enableSeparators: _enableSeparators,
      reverse: _reverse,
      scrollbars: _scrollbars,
      // RefreshIndicator only responds to vertical drags.
      enablePullToRefresh: _isVertical && _enablePullToRefresh,
      enableInterval: _enableInterval,
      useRealItemIndex: _useRealItemIndex,
      enableInitialItems: _enableInitialItems,
      automaticLoading: _automaticLoading,
      simulateErrors: _simulateErrors,
      enableRetry: _enableRetry,
      enableRetryLimit: _enableRetryLimit,
      enableCustomBuilders: _enableCustomBuilders,
    );

    unawaited(
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => DisplayScreen(config: config),
        ),
      ),
    );
  }

  SwitchListTile _buildSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
    bool enabled = true,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: enabled
          ? (newValue) => setState(() => onChanged(newValue))
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScrollInfinity Config'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _FieldTitle(title: 'Scroll Direction'),
              const Divider(),
              RadioGroup<Axis>(
                groupValue: _scrollDirection,
                onChanged: (value) => setState(() => _scrollDirection = value!),
                child: const Column(
                  children: [
                    RadioListTile<Axis>(
                      title: Text('Vertical'),
                      value: Axis.vertical,
                    ),
                    RadioListTile<Axis>(
                      title: Text('Horizontal'),
                      value: Axis.horizontal,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _FieldTitle(title: 'Layout & Appearance'),
              const Divider(),
              _buildSwitch(
                title: 'Header',
                value: _enableHeader,
                onChanged: (value) => _enableHeader = value,
              ),
              _buildSwitch(
                title: 'Separators',
                value: _enableSeparators,
                onChanged: (value) => _enableSeparators = value,
              ),
              _buildSwitch(
                title: 'Reverse (chat-style)',
                value: _reverse,
                onChanged: (value) => _reverse = value,
              ),
              _buildSwitch(
                title: 'Show Scrollbars',
                value: _scrollbars,
                onChanged: (value) => _scrollbars = value,
              ),
              _buildSwitch(
                title: 'Pull-to-Refresh',
                subtitle: _isVertical ? null : 'Vertical lists only',
                value: _isVertical && _enablePullToRefresh,
                enabled: _isVertical,
                onChanged: (value) => _enablePullToRefresh = value,
              ),
              const SizedBox(height: 24),
              const _FieldTitle(title: 'Data & Pagination'),
              const Divider(),
              _ConfigRow(
                label: 'Max Items Per Fetch',
                control: _QuantitySelector(notifier: _maxItemsNotifier),
              ),
              _ConfigRow(
                label: 'Initial Page Index',
                control: _QuantitySelector(
                  notifier: _initialPageIndexNotifier,
                  min: 0,
                  max: 5,
                ),
              ),
              _buildSwitch(
                title: 'Initial Items',
                subtitle: 'Seed the list before the first fetch',
                value: _enableInitialItems,
                onChanged: (value) => _enableInitialItems = value,
              ),
              _buildSwitch(
                title: 'Automatic Loading',
                subtitle: 'Off shows a "Load More" button',
                value: _automaticLoading,
                onChanged: (value) => _automaticLoading = value,
              ),
              if (_automaticLoading)
                _ConfigRow(
                  label: 'Load More Threshold (px)',
                  control: _ThresholdSelector(notifier: _thresholdNotifier),
                ),
              _buildSwitch(
                title: 'Intervals',
                subtitle: 'Insert a placeholder every N items',
                value: _enableInterval,
                onChanged: (value) => _enableInterval = value,
              ),
              if (_enableInterval) ...[
                _ConfigRow(
                  label: 'Item Interval',
                  control: _QuantitySelector(notifier: _intervalNotifier),
                ),
                _buildSwitch(
                  title: 'Use Real Item Index',
                  subtitle: 'Independent indexes for items and placeholders',
                  value: _useRealItemIndex,
                  onChanged: (value) => _useRealItemIndex = value,
                ),
              ],
              const SizedBox(height: 24),
              const _FieldTitle(title: 'Error Handling'),
              const Divider(),
              _buildSwitch(
                title: 'Simulate Errors',
                subtitle: 'Random failures after the first page',
                value: _simulateErrors,
                onChanged: (value) => _simulateErrors = value,
              ),
              if (_simulateErrors) ...[
                _buildSwitch(
                  title: 'Enable Retry',
                  value: _enableRetry,
                  onChanged: (value) => _enableRetry = value,
                ),
                if (_enableRetry) ...[
                  _buildSwitch(
                    title: 'Enable Retries Limit',
                    value: _enableRetryLimit,
                    onChanged: (value) => _enableRetryLimit = value,
                  ),
                  if (_enableRetryLimit)
                    _ConfigRow(
                      label: 'Max Retries Count',
                      control: _QuantitySelector(
                        notifier: _maxRetriesNotifier,
                        min: 1,
                        max: 5,
                      ),
                    ),
                ],
              ],
              const SizedBox(height: 24),
              const _FieldTitle(title: 'Customization'),
              const Divider(),
              _buildSwitch(
                title: 'Custom Builders',
                subtitle: 'Custom loading, empty, retry and load-more widgets',
                value: _enableCustomBuilders,
                onChanged: (value) => _enableCustomBuilders = value,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
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
        top: 8,
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
        horizontal: 16,
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(child: Text(label)),
          control,
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.notifier,
    this.min = 2,
    this.max = 20,
  });

  final ValueNotifier<int> notifier;
  final int min;
  final int max;

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
              onPressed: value > min ? () => notifier.value-- : null,
            ),
            SizedBox(
              width: 24,
              child: Center(
                child: Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: value < max ? () => notifier.value++ : null,
            ),
          ],
        );
      },
    );
  }
}

class _ThresholdSelector extends StatelessWidget {
  const _ThresholdSelector({
    required this.notifier,
  });

  static const _options = <double>[0, 100, 200, 400];

  final ValueNotifier<double> notifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: notifier,
      builder: (context, value, child) {
        return DropdownButton<double>(
          value: value,
          items: _options.map((option) {
            return DropdownMenuItem<double>(
              value: option,
              child: Text('${option.toInt()}'),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) notifier.value = newValue;
          },
        );
      },
    );
  }
}
// endregion

/// Displays a [ScrollInfinity] widget assembled from an [ExampleConfig].
class DisplayScreen extends StatefulWidget {
  /// Creates a [DisplayScreen].
  const DisplayScreen({
    required this.config,
    super.key,
  });

  /// The options selected on [ConfigScreen].
  final ExampleConfig config;

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  static const _totalPages = 5;

  final _controller = ScrollInfinityController();
  final _scrollController = ScrollController();
  final _random = Random();

  ExampleConfig get _config => widget.config;

  bool get _isVertical => _config.scrollDirection == Axis.vertical;

  @override
  void dispose() {
    _controller.dispose();
    // ScrollInfinity never disposes a caller-supplied controller.
    _scrollController.dispose();

    super.dispose();
  }

  void _scrollToStart() {
    unawaited(
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
    );
  }

  /// Simulates a network request to fetch paginated data.
  ///
  /// Always succeeds on the first page so the list renders, may fail
  /// randomly afterwards (alternating between throwing and returning
  /// `null`), and deterministically ends after [_totalPages] pages by
  /// returning a partial page.
  Future<List<Color>?> _loadData(int pageIndex) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    final page = pageIndex - _config.initialPageIndex;

    if (_config.simulateErrors && page > 0 && _random.nextInt(3) == 0) {
      if (_random.nextBool()) {
        throw Exception('Network failure on page $pageIndex.');
      }

      return null;
    }

    final isLastPage = page >= _totalPages - 1;
    final itemCount = isLastPage ? _config.maxItems ~/ 2 : _config.maxItems;

    return List.generate(itemCount, (index) {
      return Color.fromARGB(
        255,
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      );
    });
  }

  void _onError(Object error) {
    dev.log('ScrollInfinity fetch failed.', name: 'example', error: error);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$error'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _onItemsLoaded(List<Color?> items) {
    dev.log('ScrollInfinity loaded ${items.length} items.', name: 'example');
  }

  void _onEndOfList() {
    dev.log('ScrollInfinity reached the end of the list.', name: 'example');
  }

  List<Color> _generateInitialItems() {
    return List.generate(
      _config.maxItems,
      (index) => Colors.primaries[index % Colors.primaries.length],
    );
  }

  Widget _buildItem(Color? value, int index) {
    final width = _isVertical ? double.infinity : 200.0;
    final height = _isVertical ? 100.0 : double.infinity;

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
          color: value.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  Widget _buildScrollInfinity() {
    final customBuilders = _config.enableCustomBuilders;

    return ScrollInfinity<Color?>(
      // Core
      maxItems: _config.maxItems,
      initialPageIndex: _config.initialPageIndex,
      initialItems: _config.enableInitialItems ? _generateInitialItems() : null,
      loadData: _loadData,
      itemBuilder: _buildItem,
      controller: _controller,
      scrollController: _scrollController,
      onError: _onError,
      onItemsLoaded: _onItemsLoaded,
      onEndOfList: _onEndOfList,
      // Layout
      scrollDirection: _config.scrollDirection,
      reverse: _config.reverse,
      scrollbars: _config.scrollbars,
      enablePullToRefresh: _config.enablePullToRefresh,
      header: _config.enableHeader
          ? Container(
              color: Colors.red.withAlpha(204),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              height: 52,
              child: const Text(
                'Header',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          : null,
      separatorBuilder: _config.enableSeparators
          ? (context, index) => _isVertical
                ? const Divider(height: 1)
                : const VerticalDivider(width: 1)
          : null,
      // Behavior
      interval: _config.enableInterval ? _config.interval : null,
      useRealItemIndex: _config.useRealItemIndex,
      automaticLoading: _config.automaticLoading,
      loadMoreThreshold: _config.loadMoreThreshold,
      // Error Handling
      // `maxRetries: 0` makes the first failure final, which is how a list
      // opts out of retrying entirely.
      maxRetries: !_config.enableRetry
          ? 0
          : _config.enableRetryLimit
          ? _config.maxRetries
          : null,
      // Custom State Widgets
      loading: customBuilders
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation(
                    Colors.orange,
                  ),
                ),
              ),
            )
          : null,
      empty: customBuilders
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Nothing here yet.'),
              ),
            )
          : null,
      loadMoreBuilder: customBuilders
          ? (action) {
              return TextButton.icon(
                onPressed: action,
                icon: const Icon(Icons.add),
                label: const Text('Load More'),
              );
            }
          : null,
      tryAgainBuilder: customBuilders
          ? (error, action) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // The mock alternates between throwing and returning
                      // `null`, so the message differs per failure.
                      Text(
                        '$error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: action,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Please Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }
          : null,
      // With retrying off there is no limit to announce, so the slot is
      // emptied to fail silently.
      retryLimitReached: !_config.enableRetry
          ? const SizedBox.shrink()
          : customBuilders
          ? const Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Retry limit reached. Please try again later.',
                ),
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scrollInfinity = _buildScrollInfinity();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ScrollInfinity Example'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.vertical_align_top),
            onPressed: _scrollToStart,
            tooltip: 'Scroll To Start',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.refresh,
            tooltip: 'Reset List',
          ),
        ],
      ),
      body: _isVertical
          ? scrollInfinity
          : Center(
              child: SizedBox(
                height: 140,
                child: scrollInfinity,
              ),
            ),
    );
  }
}
