import 'package:flutter/material.dart';

class TryAgainButton extends StatelessWidget {
  const TryAgainButton({
    super.key,
    required this.action,
  });

  final VoidCallback action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(12.0),
        width: 140.0,
        child: ElevatedButton(
          onPressed: action,
          child: const Text('Try Again'),
        ),
      ),
    );
  }
}
