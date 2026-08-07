// The `ScrollInfinity`, `ScrollController`, and `TextEditingController`
// references below are documentation-only and would otherwise require
// importing `scroll_infinity.dart` (creating an import cycle) and
// `package:flutter/material.dart` (an unused import) purely for doc links.
// ignore_for_file: comment_references

/// Interface implemented by [ScrollInfinity]'s state so a
/// [ScrollInfinityController] can drive it without depending on the
/// widget's generic type parameter.
abstract class ScrollInfinityControllerState {
  /// Whether a fetch is currently in progress.
  bool get isLoading;

  /// Whether the last fetch attempt resulted in an error.
  bool get hasError;

  /// Clears all items and restarts pagination from the initial page index.
  void refresh();

  /// Retries fetching the current page after an error.
  ///
  /// A no-op when the last fetch did not fail.
  void retry();
}

/// Controls a [ScrollInfinity] widget from outside its build method.
///
/// Pass an instance to [ScrollInfinity.controller] to trigger [refresh] or
/// [retry] programmatically (e.g. from a pull-to-refresh button or an
/// external event) and to read [isLoading]/[hasError].
///
/// Like [ScrollController] or [TextEditingController], a single controller
/// must not be attached to more than one [ScrollInfinity] at a time, and it
/// is the caller's responsibility to [dispose] it when it created the
/// instance itself.
class ScrollInfinityController {
  ScrollInfinityControllerState? _state;

  /// Attaches this controller to a [ScrollInfinity] state.
  ///
  /// Called by [ScrollInfinity] itself; not meant to be called directly.
  void attach(ScrollInfinityControllerState state) {
    assert(
      _state == null,
      'This ScrollInfinityController is already attached to a '
      'ScrollInfinity widget.',
    );
    _state = state;
  }

  /// Detaches this controller from a [ScrollInfinity] state.
  ///
  /// Called by [ScrollInfinity] itself; not meant to be called directly.
  void detach(ScrollInfinityControllerState state) {
    if (identical(_state, state)) {
      _state = null;
    }
  }

  /// Whether a fetch is currently in progress.
  bool get isLoading => _state?.isLoading ?? false;

  /// Whether the last fetch attempt resulted in an error.
  bool get hasError => _state?.hasError ?? false;

  /// Clears all items and restarts pagination from
  /// `ScrollInfinity.initialPageIndex`.
  void refresh() => _state?.refresh();

  /// Retries fetching the current page after an error.
  ///
  /// A no-op when the last fetch did not fail, when retrying is disabled via
  /// `ScrollInfinity.enableRetryOnError`, or once the
  /// `ScrollInfinity.maxRetries` limit has been reached.
  void retry() => _state?.retry();

  /// Releases this controller. Call this only if you created the
  /// controller yourself and it is not managed by an ancestor widget.
  void dispose() {
    _state = null;
  }
}
