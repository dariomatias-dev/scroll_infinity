import 'package:flutter/material.dart';

class MessageFieldWidget extends StatelessWidget {
  const MessageFieldWidget({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class DefaultEmptyComponent extends MessageFieldWidget {
  const DefaultEmptyComponent({super.key})
      : super(
          message: 'No items available at the moment.',
        );
}

class DefaultErrorComponent extends MessageFieldWidget {
  const DefaultErrorComponent({super.key})
      : super(
          message: 'Error fetching data.',
        );
}

class DefaultResetComponent extends MessageFieldWidget {
  const DefaultResetComponent({super.key})
      : super(
          message: 'Resetting...',
        );
}
