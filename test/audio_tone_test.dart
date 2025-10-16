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
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> init(AudioSampleRate sampleRate) {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Future<void> play() {
    // TODO: implement play
    throw UnimplementedError();
  }

  @override
  Future<int> playMorseCode(String morseCode) {
    // TODO: implement playMorseCode
    throw UnimplementedError();
  }

  @override
  Future<void> setDashDuration(int dotsTimes) {
    // TODO: implement setDashDuration
    throw UnimplementedError();
  }

  @override
  Future<void> setDotDashIntervalDuration(int dotsTimes) {
    // TODO: implement setDotDashIntervalDuration
    throw UnimplementedError();
  }

  @override
  Future<void> setFrequency(AudioFrequency frequency) {
    // TODO: implement setFrequency
    throw UnimplementedError();
  }

  @override
  Future<void> setLetterIntervalDuration(int dotsTimes) {
    // TODO: implement setLetterIntervalDuration
    throw UnimplementedError();
  }

  @override
  Future<void> setSpeed(int wpm) {
    // TODO: implement setSpeed
    throw UnimplementedError();
  }

  @override
  Future<void> setVolume(double volume) {
    // TODO: implement setVolume
    throw UnimplementedError();
  }

  @override
  Future<void> setWordsIntervalDuration(int dotsTimes) {
    // TODO: implement setWordsIntervalDuration
    throw UnimplementedError();
  }

  @override
  Future<void> stop() {
    // TODO: implement stop
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

  test('init', () async {
    AudioTone audioTonePlugin = AudioTone(
      sampleRate: AudioSampleRate.defaultSampleRate,
      wpm: 100,
    );
  });
}
