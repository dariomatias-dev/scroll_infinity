part of 'scroll_infinity.dart';

class _MessageFieldWidget extends StatelessWidget {
  const _MessageFieldWidget({
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
