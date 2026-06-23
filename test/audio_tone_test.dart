import 'dart:async';
import 'dart:typed_data';

import 'package:audio_tone/audio_frequency.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_tone/audio_tone.dart';
import 'package:audio_tone/audio_tone_platform_interface.dart';
import 'package:audio_tone/audio_tone_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAudioTonePlatform
    with MockPlatformInterfaceMixin
    implements AudioTonePlatform {
  List<int>? lastTimings;

  @override
  Future<void> init(AudioSampleRate sampleRate) {
    return Future<void>.value();
  }

  @override
  Future<void> play() {
    return Future<void>.value();
  }

  @override
  Future<int> playMorseCode(String morseCode) {
    return Future<int>.value(0);
  }

  @override
  Future<int> playTimings(List<int> timings) {
    lastTimings = List<int>.from(timings);
    return Future<int>.value(0);
  }

  @override
  Future<void> setDashDuration(int dotsTimes) {
    return Future<void>.value();
  }

  @override
  Future<void> setDotDashIntervalDuration(int dotsTimes) {
    return Future<void>.value();
  }

  @override
  Future<void> setLightFlashingMagnificationFactor(double factor) {
    return Future<void>.value();
  }

  @override
  Future<void> setFrequency(AudioFrequency frequency) {
    return Future<void>.value();
  }

  @override
  Future<void> setLetterIntervalDuration(int dotsTimes) {
    return Future<void>.value();
  }

  @override
  Future<void> setSpeed(int wpm) {
    return Future<void>.value();
  }

  @override
  Future<void> setVolume(double volume) {
    return Future<void>.value();
  }

  @override
  Future<void> setWordsIntervalDuration(int dotsTimes) {
    return Future<void>.value();
  }

  @override
  Future<void> stop() {
    return Future<void>.value();
  }

  @override
  StreamSubscription<dynamic> playStream(String morseCode) {
    throw UnimplementedError();
  }

  @override
  Future<double> getMorseCodePlayDuration(String morseCode) {
    return Future<double>.value(0.48);
  }

  @override
  Future<Float64List> generateToneSoundData(String morseCode) {
    // 返回一个简单的测试数据
    return Future<Float64List>.value(
      Float64List.fromList([0.0, 0.5, 1.0, 0.5, 0.0]),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final AudioTonePlatform initialPlatform = AudioTonePlatform.instance;

  tearDown(() {
    AudioTonePlatform.instance = initialPlatform;
  });

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

  test('getMorseCodePlayDuration delegates to platform', () async {
    MockAudioTonePlatform fakePlatform = MockAudioTonePlatform();
    AudioTonePlatform.instance = fakePlatform;
    AudioTone audioTonePlugin = AudioTone(wpm: 20);

    expect(await audioTonePlugin.getMorseCodePlayDuration('.-.-'), 0.48);
  });

  test('playTimings delegates to platform', () async {
    MockAudioTonePlatform fakePlatform = MockAudioTonePlatform();
    AudioTonePlatform.instance = fakePlatform;
    AudioTone audioTonePlugin = AudioTone(wpm: 20);

    expect(await audioTonePlugin.playTimings(const [120, 120, 360]), 0);
    expect(fakePlatform.lastTimings, const [120, 120, 360]);
  });

  test('generateToneSoundData delegates to platform', () async {
    MockAudioTonePlatform fakePlatform = MockAudioTonePlatform();
    AudioTonePlatform.instance = fakePlatform;
    AudioTone audioTonePlugin = AudioTone(wpm: 20);

    final result = await audioTonePlugin.generateToneSoundData('.- -');
    expect(result.length, 5);
    expect(result[2], 1.0);
  });
}
