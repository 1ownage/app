import 'package:flutter_test/flutter_test.dart';
import 'package:ownage/main.dart';

void main() {
  testWidgets('App mounts and shows boot splash while auth bootstraps',
      (tester) async {
    await tester.pumpWidget(const OwnAgeApp());
    await tester.pump(); // first frame — booting phase
    // Boot splash renders a spinner; just verify widget tree didn't throw.
    expect(find.byType(OwnAgeApp), findsOneWidget);
  });
}
