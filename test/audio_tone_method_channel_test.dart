import 'package:audio_tone/audio_tone_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('audio_tone');
  final methodCalls = <MethodCall>[];

  setUp(() {
    methodCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          if (methodCall.method == 'playTimings') {
            return 7;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('playTimings forwards timings over the method channel', () async {
    final platform = MethodChannelAudioTone();

    final result = await platform.playTimings(const [120, 120, 360]);

    expect(result, 7);
    expect(methodCalls, hasLength(1));
    expect(methodCalls.single.method, 'playTimings');
    expect(methodCalls.single.arguments, const [120, 120, 360]);
  });
}
