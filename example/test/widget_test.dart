import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audio_tone_example/src/audio_tone_demo_app.dart';

void main() {
  testWidgets('renders interactive demo sections', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final scrollable = find.byType(Scrollable).first;

    expect(find.text('Audio Tone Demo'), findsWidgets);
    expect(find.text('Interactive Morse + tone playground'), findsOneWidget);
    expect(find.text('Morse Input'), findsOneWidget);
    expect(find.text('Play Morse'), findsOneWidget);
    expect(find.text('Stream Events'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Live Controls'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('Live Controls'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Timing Sequence'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('Timing Sequence'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Press And Hold Tone'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('Press And Hold Tone'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Recent Stream Events'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('Recent Stream Events'), findsOneWidget);
    expect(find.text('Stop Everything'), findsOneWidget);
  });
}
