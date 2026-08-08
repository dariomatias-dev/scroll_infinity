# Changelog

## [Unreleased]

> **Minimum SDK requirement raised.** This release requires **Dart `>=3.12.0 <4.0.0`** and **Flutter `>=3.44.0`**. On older toolchains — such as Flutter 3.35 — `flutter pub get` fails to resolve. Upgrade the SDK before updating, or remain on `scroll_infinity: 0.5.2`.

### Added

- `ScrollInfinityController` for driving the list from outside the widget, exposing `refresh()`, `retry()`, and the `hasReachedEnd` getter.
- `scrollController` property, accepting an external `ScrollController` for scroll-to-top and offset reading.
- `enablePullToRefresh` property, wrapping the list in a `RefreshIndicator`.
- `reverse` property for reversed scroll direction, such as chat-style lists.
- `loadMoreThreshold` property, configuring the distance from the list end that triggers the next page.
- `onError` callback, exposing the failure that caused the error state for logging and reporting.
- `onItemsLoaded` callback, reporting each loaded page for analytics.
- `onEndOfList` callback, fired when pagination reaches the last page.
- Passthrough of `physics`, `shrinkWrap`, `cacheExtent`, `itemExtent`, `prototypeItem`, `addAutomaticKeepAlives`, `keyboardDismissBehavior`, and `restorationId` to the underlying `ListView`.
- Spanish translation (`README.es.md`), alongside the English and Portuguese READMEs, with a unified language switcher.
- Continuous integration workflow pinned to Flutter 3.44.6, running both the package and example test suites.

### Changed

- **BREAKING.** Raised the minimum SDK to Dart 3.12 / Flutter 3.44.
- **BREAKING.** `tryAgainBuilder` now receives the failure as its first argument, changing its signature from `(VoidCallback action)` to `(Object error, VoidCallback action)`.
- **BREAKING.** Changing the `loadData` closure no longer resets the list. `didUpdateWidget` no longer compares the `loadData` reference, so parent rebuilds that recreate the closure no longer discard loaded pages. Only `maxItems` and `interval` — both safe value comparisons — still trigger a reset.
- Reorganized `lib/src` into layered folders and split the core widget into smaller components.
- Moved retry-limit state into the footer enum, leaving the builder extension responsible only for mapping footer states to widgets.
- Adopted the `very_good_analysis` lint set and Dart 3.12 tall-style formatting.
- Expanded the example into a configurable demo covering the full API surface.

### Removed

- **BREAKING.** `enableRetryOnError`, superseded by `maxRetries`.

### Fixed

- Stale results from a superseded fetch no longer overwrite fresh state. A generation counter incremented on reset invalidates in-flight fetches, discarding their results, errors, and loading-state cleanup.
- `maxRetries` is now enforced when retrying through `retry()`, not only through the built-in retry button.
- `onError` is now invoked when `loadData` returns `null`, not only when it throws.
- Reset now awaits the refetch, and the scroll controller is guarded while unattached.
- State is now reset when `interval` changes, even when `loadData` and `maxItems` are unchanged.

### Performance

- `ListView.builder` is used instead of `ListView.separated` when separators are disabled, avoiding the separator layer entirely.

### Migration Guide

#### `tryAgainBuilder` signature

The builder now receives the failure that caused the error state, so the message can be tailored to the kind of failure. When `loadData` returns `null`, a synthetic `Exception` is passed, so `error` is never null.

```dart
// Before
tryAgainBuilder: (action) => ElevatedButton(
  onPressed: action,
  child: const Text('Try again'),
),

// After
tryAgainBuilder: (error, action) => Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text('$error'),
    ElevatedButton(
      onPressed: action,
      child: const Text('Try again'),
    ),
  ],
),
```

#### `loadData` no longer resets the list

If you relied on swapping the `loadData` closure to load a different data source, request the reset explicitly — either with a new `Key`, which remounts the widget from scratch, or with `controller.refresh()`, which keeps the same instance.

```dart
// Before: recreating the closure reset the list implicitly.
ScrollInfinity(
  loadData: (pageIndex) => api.fetch(category, pageIndex),
)

// After: remount on a data source change.
ScrollInfinity(
  key: ValueKey(category),
  loadData: (pageIndex) => api.fetch(category, pageIndex),
)

// Or, keeping the same widget instance:
controller.refresh();
```

#### `enableRetryOnError` removed

Replace the boolean flag with the attempt counter. `maxRetries: 0` disables retrying; pass an empty `retryLimitReached` widget to suppress the limit message.

```dart
// Before
ScrollInfinity(
  enableRetryOnError: false,
)

// After
ScrollInfinity(
  maxRetries: 0,
  retryLimitReached: const SizedBox.shrink(),
)
```

## [0.5.2] - 2025-08-13

- **Documentation Update**: Standardized the README documentation to align with the formatting and style of other projects.

## [0.5.1] - 2025-08-03

- **Retry limiter and custom message**: Added support to limit the number of retry attempts, displaying a custom message when the limit is reached.
- **Manual loading mode**: Added `automaticLoading` and `loadMoreBuilder` properties, allowing toggling between automatic and manual loading (with a "load more" button).
- **Property renaming**: Renamed `retryLimitReachedWidget` to `retryLimitReached` for naming consistency.
- **Improved example**:

  - Added new customization options to the example project.
  - Included a configurable screen demonstrating package usage with applied options on a second screen.

- **Enhanced documentation**:

  - Updated the package description.
  - Added a section about the development environment.
  - Added advanced usage examples and more detailed feature descriptions.
  - Reorganized and grouped properties for easier reading.
  - Added a subsection referencing the configurable example in the `example` directory.
  - Fixed minor documentation errors and inconsistencies.

- **Testing improvements**: Tests reorganized and new cases added to ensure feature reliability.
- **Internal refactor**: Removed unnecessary nullability from the generic type.

## [0.5.0] - 2025-07-30

- **Dynamic Index Feature**: Introduced the `useRealItemIndex` property to allow differentiation between real data item indexes and interval indexes.
- **Improved Retry Behavior**: The `error` property was removed and the `tryAgainButtonBuilder` was renamed to `tryAgainBuilder` for clarity. Also fixed the retry button display logic.
- **Continuous Fetching Reimplementation**: The logic to fill the visible area with items was restructured for a smoother loading experience.
- **Component Cleanup and Simplification**:

  - Removed unused components, including `LoadingStyle`, `TryAgainButton`, and `MessageFieldWidget`.
  - Standard message components have been removed.

- **Reset Behavior Fix**: Corrected the list reset mechanism to preserve the original `initialItems` without regenerating them.
- **Internal Refactoring**: Simplified and optimized the internal structure of the package for better maintainability.
- **Improved Examples**:

  - Restructured the usage example to better demonstrate the package.
  - Applied standardizations and simplifications to improve clarity.

- **Testing**: Added test cases to cover core functionalities.
- **Updated Documentation**: Revised and expanded the documentation, including full usage examples and explanations of new features.

## [0.4.0] - 2024-01-02

- **Restructuring of the Listing Algorithm**: The algorithm has been rewritten to provide a more efficient and seamless user experience.
- **Auto-fill Listing Feature**: The listing now automatically fills itself whenever visible space is available on the screen.
- **Empty List Indicator**: A visual element has been added to clearly indicate when the list is empty.
- **Component Reset During Requests**: An automatic reset mechanism has been implemented for the component while a request is in progress, accompanied by an informative progress indicator.
- **Retry Button for Errors**: A retry button has been added for scenarios where the list does not contain enough items to fill the visible space due to an error.
- **Code Improvements and Fixes**: Various improvements and fixes have been made to enhance code quality and system performance.
- **Updated Documentation**: The documentation has been updated to reflect the new features of the package.

## [0.3.3] - 2024-07-06

- Added verification for `initialItems` to determine if the listing has reached the end, avoiding unnecessary loads.

## [0.3.2] - 2024-07-05

- Added `header` reset when not null in the `reset` method.
- Renamed `ScrollInfinityInitialItemsNotifier` class to `InitialItemsNotifier`.

## [0.3.1] - 2024-07-05

- Added explanations on how to use interval and loader to facilitate the implementation of these features.
- Added and organized `assert` statements.
- Fixed typing of the value sent to `itemBuilder`.
- Removed `?` from the definition of the `itemBuilder` property.

## [0.3.0] - 2024-07-04

- Added `header` property to allow the addition of a header to the listing.
- Created `ScrollInfinityInitialItemsNotifier` to notify about the initial items.
- Introduced `ScrollInfinityLoader` for custom loading dynamics of initial items.
- Added `enableRetryOnError` and `error` properties for error handling and retry logic.

## [0.2.1] - 2024-07-03

- Fixed item duplication bug when no interval is used.

## [0.2.0] - 2024-07-02

- Added interval feature to allow adding a specific element within a certain interval.
- Added item index to `itemBuilder` for accessing the item's position in the list.

## [0.1.1] - 2024-06-26

- Added `initialPageIndex` property to define the initial page index.
- Renamed `pageKey` to `pageIndex`.
- Reorganized the order of properties.

## [0.1.0] - 2024-06-26

- Added reset feature.
- Improved documentation.
- Added `scrollbars` property to define the visibility state of the scrollbar.

## [0.0.2] - 2024-06-26

- Componentization and documentation of `LoadingStyle`.
- Added documentation for the package properties and methods.
- Added new properties to define the initial items of the list and to disable the initial request.
- Updated the package documentation.

## [0.0.1] - 2024-06-22

- First version.
