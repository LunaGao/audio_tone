import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audio_tone_example/main.dart';

void main() {
  testWidgets('renders interactive demo sections', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Audio Tone Demo'), findsWidgets);
    expect(find.text('Interactive Morse + tone playground'), findsOneWidget);
    expect(find.text('Morse Input'), findsOneWidget);
    expect(find.text('Play Morse'), findsOneWidget);
    expect(find.text('Stream Events'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Live Controls'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Press And Hold Tone'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Recent Stream Events'), findsOneWidget);
    expect(find.text('Stop Everything'), findsOneWidget);
  });
}
