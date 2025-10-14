import 'package:flutter_test/flutter_test.dart';
import 'package:audio_tone/audio_tone.dart';
import 'package:audio_tone/audio_tone_platform_interface.dart';
import 'package:audio_tone/audio_tone_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAudioTonePlatform
    with MockPlatformInterfaceMixin
    implements AudioTonePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AudioTonePlatform initialPlatform = AudioTonePlatform.instance;

  test('$MethodChannelAudioTone is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAudioTone>());
  });

  test('getPlatformVersion', () async {
    AudioTone audioTonePlugin = AudioTone();
    MockAudioTonePlatform fakePlatform = MockAudioTonePlatform();
    AudioTonePlatform.instance = fakePlatform;

    expect(await audioTonePlugin.getPlatformVersion(), '42');
  });
}
