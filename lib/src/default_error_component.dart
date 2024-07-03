part of 'scroll_infinity.dart';

class _DefaultErrorComponent extends StatelessWidget {
  const _DefaultErrorComponent();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'Failed to fetch data.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
