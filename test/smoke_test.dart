import 'package:flutter_test/flutter_test.dart';
import 'package:ownage/main.dart';

void main() {
  testWidgets('App renders Feed on launch', (tester) async {
    await tester.pumpWidget(const OwnAgeApp());
    await tester.pump();
    expect(find.text('OWNAGE'), findsOneWidget);
    expect(find.text('LIVE'), findsOneWidget);
  });
}
