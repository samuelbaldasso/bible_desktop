import 'package:flutter_test/flutter_test.dart';

import 'package:bible_desktop/main.dart';

void main() {
  testWidgets('App inicia mostrando o título Bíblia ARC', (WidgetTester tester) async {
    await tester.pumpWidget(const BibleDesktopApp());
    await tester.pump();

    expect(find.text('Bíblia'), findsOneWidget);
  });
}
