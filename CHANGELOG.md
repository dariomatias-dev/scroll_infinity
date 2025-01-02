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
### Added
- Added explanations on how to use interval and loader, aiming to facilitate the implementation of these features.
- Added and organized `assert` statements.

### Fixed
- Corrected the typing of the value sent to `itemBuilder`.
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
