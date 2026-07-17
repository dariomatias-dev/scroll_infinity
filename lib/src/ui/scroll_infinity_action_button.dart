import 'package:flutter/material.dart';

/// A centered, padded [ElevatedButton] used as the default "Try Again" and
/// "Load More" footer for a paginated list.
class ScrollInfinityActionButton extends StatelessWidget {
  /// Creates a [ScrollInfinityActionButton].
  const ScrollInfinityActionButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// The button's label text.
  final String label;

  /// Called when the button is pressed.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(label),
        ),
      ),
    );
  }
}
