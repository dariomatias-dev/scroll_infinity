import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

/// Scrolls to and taps the control labeled [title], then pumps a frame.
Future<void> toggleOption(WidgetTester tester, String title) async {
  await tester.ensureVisible(find.text(title));
  await tester.tap(find.text(title));
  await tester.pump();
}

/// Taps 'Show Example' and pumps past the route transition.
Future<void> openExample(WidgetTester tester) async {
  await tester.tap(find.text('Show Example'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Matches [matching] only inside the pushed [DisplayScreen] route, since
/// the config screen below it stays in the tree.
Finder inExample(Finder matching) {
  return find.descendant(of: find.byType(DisplayScreen), matching: matching);
}
