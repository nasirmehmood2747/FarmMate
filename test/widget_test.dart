import 'package:flutter_test/flutter_test.dart';

import 'package:farmmate/main.dart';

void main() {
  testWidgets('shows the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FarmMateApp());

    expect(find.text('FarmMate'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
