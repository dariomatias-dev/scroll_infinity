import 'package:scroll_infinity/src/message_field_widget.dart';

class DefaultEmptyComponent extends MessageFieldWidget {
  const DefaultEmptyComponent({super.key})
      : super(
          message: 'No items available at the moment.',
        );
}
