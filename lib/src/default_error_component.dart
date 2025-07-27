import 'package:scroll_infinity/src/message_field_widget.dart';

class DefaultErrorComponent extends MessageFieldWidget {
  const DefaultErrorComponent({super.key})
      : super(
          message: 'Error fetching data.',
        );
}
