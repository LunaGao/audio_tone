import 'package:audio_tone/audio_frequency.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_tone/audio_tone.dart';
import 'package:audio_tone/audio_tone_platform_interface.dart';
import 'package:audio_tone/audio_tone_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAudioTonePlatform
    with MockPlatformInterfaceMixin
    implements AudioTonePlatform {
  @override
  Future<void> init(AudioSampleRate sampleRate) {
    throw UnimplementedError();
  }

  @override
  Future<void> play() {
    throw UnimplementedError();
  }

  @override
  Future<int> playMorseCode(String morseCode) {
    throw UnimplementedError();
  }

  @override
  Future<void> setDashDuration(int dotsTimes) {
    throw UnimplementedError();
  }

  @override
  Future<void> setDotDashIntervalDuration(int dotsTimes) {
    throw UnimplementedError();
  }

  @override
  Future<void> setFrequency(AudioFrequency frequency) {
    throw UnimplementedError();
  }

  @override
  Future<void> setLetterIntervalDuration(int dotsTimes) {
    throw UnimplementedError();
  }

  @override
  Future<void> setSpeed(int wpm) {
    throw UnimplementedError();
  }

  @override
  Future<void> setVolume(double volume) {
    throw UnimplementedError();
  }

  @override
  Future<void> setWordsIntervalDuration(int dotsTimes) {
    throw UnimplementedError();
  }

  @override
  Future<void> stop() {
    throw UnimplementedError();
  }
}

void main() {
  final AudioTonePlatform initialPlatform = AudioTonePlatform.instance;

  test('$MethodChannelAudioTone is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAudioTone>());
  });

  // test('getPlatformVersion', () async {
  //   AudioTone audioTonePlugin = AudioTone();
  //   MockAudioTonePlatform fakePlatform = MockAudioTonePlatform();
  //   AudioTonePlatform.instance = fakePlatform;

  //   expect(await audioTonePlugin.getPlatformVersion(), '42');
  // });

  // test('init', () async {
  //   AudioTone audioTonePlugin = AudioTone(
  //     sampleRate: AudioSampleRate.defaultSampleRate,
  //     wpm: 100,
  //   );
  // });
}
