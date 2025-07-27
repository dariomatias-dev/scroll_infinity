import 'package:flutter/material.dart';

/// Style configuration for loading indicator.
class LoadingStyle {
  const LoadingStyle({
    this.color,
    this.strokeAlign,
    this.strokeWidth,
  });

  /// Determines the color of the loading indicator.
  final Color? color;

  /// Specifies how the stroke of the loading indicator is aligned.
  final double? strokeAlign;

  /// Specifies the width of the stroke of the loading indicator.
  final double? strokeWidth;
}
