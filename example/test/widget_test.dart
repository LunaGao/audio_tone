// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:audio_tone_example/main.dart';

void main() {
  testWidgets('renders example actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Plugin example app'), findsOneWidget);
    expect(find.text('Init Tone Player'), findsOneWidget);
    expect(find.text('Tap to Play'), findsOneWidget);
    expect(find.text('Test playStream'), findsOneWidget);
    expect(find.text('Test getMorseCodePlayDuration'), findsOneWidget);
  });
}
