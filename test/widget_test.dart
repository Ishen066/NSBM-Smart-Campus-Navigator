
import 'package:flutter_test/flutter_test.dart';
import 'package:nsbm_smart_campus/main.dart';

void main() {
  testWidgets('NSBM Smart Campus app loads', (tester) async {
    await tester.pumpWidget(const NSBMSmartCampusApp());

    expect(find.text('NSBM'), findsOneWidget);
    expect(find.text('SMART CAMPUS'), findsOneWidget);
  });
}
