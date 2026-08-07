import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:scroll_infinity/src/controller/scroll_infinity_controller.dart';
import 'package:scroll_infinity/src/models/interval_item_mapper.dart';
import 'package:scroll_infinity/src/ui/scroll_infinity_action_button.dart';

part 'scroll_infinity_footer_type.dart';
part 'scroll_infinity_state.dart';
part 'scroll_infinity_footer_builder.dart';

/// A widget that displays a scrollable list with support for paginated
/// data loading.
class ScrollInfinity<T> extends StatefulWidget {
  /// Creates a [ScrollInfinity] widget.
  const ScrollInfinity({
    required this.loadData,
    required this.itemBuilder,
    required this.maxItems,
    super.key,

    // Core Data Handling
    this.initialItems,
    this.initialPageIndex = 0,
    this.controller,
    this.onItemsLoaded,

    // Layout & Appearance
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.header,
    this.separatorBuilder,
    this.scrollbars = true,
    this.enablePullToRefresh = false,
    this.physics,
    this.shrinkWrap = false,
    this.cacheExtent,

    // Behavioral Features
    this.interval,
    this.useRealItemIndex = true,
    this.automaticLoading = true,
    this.loadMoreThreshold = 200,

    // Error Handling
    this.enableRetryOnError = true,
    this.maxRetries,
    this.onError,

    // State-Specific Widgets
    this.loading,
    this.empty,
    this.tryAgainBuilder,
    this.loadMoreBuilder,
    this.retryLimitReached,
  }) : assert(
         initialPageIndex >= 0,
         'The initial page index cannot be less than zero.',
       ),
       assert(
         interval == null || interval > 0,
         'The interval must be greater than zero.',
       ),
       assert(
         !(interval != null) || null is T,
         'When `interval` is used, the generic type `T` must be nullable '
         '(e.g., String?).',
       ),
       assert(
         maxRetries == null || maxRetries >= 0,
         'maxRetries cannot be negative.',
       ),
       assert(
         loadMoreThreshold >= 0,
         'loadMoreThreshold cannot be negative.',
       );

  // Core Data Handling

  /// Callback responsible for fetching data for each page.
  final Future<List<T>?> Function(
    int pageIndex,
  )
  loadData;

  /// Builder function responsible for rendering each item in the list.
  ///
  /// When an interval is used, `value` will be `null` for interval items.
  /// A nullable type must be used for `T`
  /// (e.g., `String?`) if `interval` is non-null.
  ///
  /// `index` is mapped according to [useRealItemIndex] and [interval] (see
  /// [useRealItemIndex] for details). This differs from
  /// [separatorBuilder]'s `index`, which is always the raw display
  /// position and ignores both properties.
  final Widget Function(
    T value,
    int index,
  )
  itemBuilder;

  /// The maximum number of items to retrieve per request.
  final int maxItems;

  /// A list of items displayed before the first data fetch is initiated.
  ///
  /// These items do **not** advance pagination: the first fetch still asks
  /// [loadData] for [initialPageIndex]. If [initialItems] already holds the
  /// contents of a page, set [initialPageIndex] to the page after it (e.g.
  /// `initialPageIndex: 1`) so that page is not fetched twice.
  ///
  /// Applied when the widget is first built and on every reset (pull-to-
  /// refresh, [ScrollInfinityController.refresh], or a change to [maxItems],
  /// [interval] or [initialPageIndex]). Passing a different list on a plain
  /// rebuild has no effect.
  final List<T>? initialItems;

  /// The starting index from which to begin loading data.
  ///
  /// Changing it after the first build resets the list and restarts
  /// pagination from the new index.
  final int initialPageIndex;

  /// Optional controller to trigger [ScrollInfinityController.refresh] or
  /// [ScrollInfinityController.retry] externally and read
  /// [ScrollInfinityController.isLoading]/[ScrollInfinityController.hasError].
  final ScrollInfinityController? controller;

  /// Called with the raw items returned by [loadData] whenever a fetch
  /// succeeds. Useful for analytics; it does not affect the build.
  final void Function(List<T> items)? onItemsLoaded;

  // Layout & Appearance

  /// Defines the scroll direction of the list. Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether the list scrolls in the reading direction (`false`, the
  /// default) or the opposite direction (`true`).
  ///
  /// Useful for chat-style layouts: with `reverse: true`, item `0` (the
  /// newest message) is drawn at the end of the list, and pagination
  /// (triggered by scrolling toward the list's start) loads older items.
  final bool reverse;

  /// Defines the internal padding of the list view.
  final EdgeInsetsGeometry? padding;

  /// A widget displayed at the beginning of the list.
  final Widget? header;

  /// A builder that inserts separators between list items.
  ///
  /// `index` is always the raw display position (0-based, interval
  /// placeholders included) — unlike [itemBuilder]'s `index`, it is not
  /// affected by [useRealItemIndex].
  final Widget Function(
    BuildContext context,
    int index,
  )?
  separatorBuilder;

  /// Determines whether scrollbars should be displayed. Defaults to `true`.
  final bool scrollbars;

  /// Wraps the list in a [RefreshIndicator] that resets and refetches from
  /// [initialPageIndex] on pull-to-refresh. Defaults to `false`.
  final bool enablePullToRefresh;

  /// Passed directly to the underlying [ListView.physics].
  final ScrollPhysics? physics;

  /// Passed directly to the underlying [ListView.shrinkWrap].
  /// Defaults to `false`.
  final bool shrinkWrap;

  /// Cache extent, in logical pixels, passed to the underlying
  /// [ListView] as a [ScrollCacheExtent.pixels] value.
  final double? cacheExtent;

  // Behavioral Features

  /// Specifies an interval at which a `null` value is inserted into the list.
  final int? interval;

  /// If `true`, real data items have their own index that ignores interval
  /// (`null`) items, meaning data items and interval items have independent
  /// indexes.
  ///
  /// The default is `true`.
  final bool useRealItemIndex;

  /// Determines if new items are fetched automatically on scroll.
  ///
  /// If `false`, a 'Load More' button will be displayed at the end of the
  /// list. Defaults to `true`.
  final bool automaticLoading;

  /// Distance in pixels from the end of the list at which the next page
  /// starts loading. Defaults to `200`.
  final double loadMoreThreshold;

  // Error Handling

  /// Indicates whether retrying is allowed when an error occurs.
  final bool enableRetryOnError;

  /// Maximum number of retries after a failed data fetch.
  ///
  /// The first failure is not a retry, so `maxRetries: 2` allows up to three
  /// requests for the same page (one initial attempt plus two retries) before
  /// [retryLimitReached] is shown. With `0`, the failure is final.
  ///
  /// If `null`, retries will be attempted indefinitely. The default is `null`.
  final int? maxRetries;

  /// Called whenever a fetch fails: with the exception thrown by
  /// [loadData], or with a synthetic [Exception] when [loadData] returns
  /// `null` instead of throwing.
  ///
  /// Use this to log or report the real error; it does not build UI.
  final void Function(Object error)? onError;

  // State-Specific Widgets

  /// Custom widget shown during the loading of additional data.
  final Widget? loading;

  /// Widget displayed when the initial data fetch returns an empty result.
  final Widget? empty;

  /// A builder that constructs a custom 'Try Again' widget when an error
  /// occurs.
  final Widget Function(
    VoidCallback action,
  )?
  tryAgainBuilder;

  /// A builder that constructs a custom 'Load More' widget when
  /// [automaticLoading] is `false`.
  final Widget Function(
    VoidCallback action,
  )?
  loadMoreBuilder;

  /// A widget to display when the [maxRetries] limit has been reached.
  ///
  /// If not provided, a default message is shown.
  final Widget? retryLimitReached;

  @override
  State<ScrollInfinity<T>> createState() => _ScrollInfinityState<T>();
}
