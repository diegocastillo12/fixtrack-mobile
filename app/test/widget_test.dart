import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('FixTrack inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const FixTrackApp());

    expect(find.text('FixTrack - Incidencias'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
  });
}