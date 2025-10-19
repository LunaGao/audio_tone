import 'package:audio_tone/audio_frequency.dart';
import 'package:audio_tone/audio_sample_rate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_tone_platform_interface.dart';

/// An implementation of [AudioTonePlatform] that uses method channels.
class MethodChannelAudioTone extends AudioTonePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('audio_tone');

  @override
  Future<void> init(AudioSampleRate sampleRate) async {
    await methodChannel.invokeMethod<void>('init', sampleRate.value);
  }

  @override
  Future<void> setFrequency(AudioFrequency frequency) async {
    await methodChannel.invokeMethod<void>('setFrequency', frequency.value);
  }

  @override
  Future<void> setSpeed(int wpm) async {
    await methodChannel.invokeMethod<void>('setSpeed', wpm);
  }

  @override
  Future<void> setDashDuration(int dotsTimes) async {
    await methodChannel.invokeMethod<void>('setDashDuration', dotsTimes);
  }

  @override
  Future<void> setDotDashIntervalDuration(int dotsTimes) async {
    await methodChannel.invokeMethod<void>(
      'setDotDashIntervalDuration',
      dotsTimes,
    );
  }

  /// 设置字母之间的间隔时长（点的倍数）
  /// Set Duration of a Letter Interval (Dot counts)
  /// default value 3 dots, range 1-5 dots / 默认3个点，范围1-5个点
  ///
  /// [dotsTimes] Duration of a Letter Interval in dots / 字母之间的间隔时长（点的倍数）
  @override
  Future<void> setLetterIntervalDuration(int dotsTimes) async {
    await methodChannel.invokeMethod<void>(
      'setOneWhiteSpaceDuration',
      dotsTimes,
    );
  }

  /// 设置单词间间隔时长（点的倍数）
  /// Set Duration of a Words Interval (Dot counts)
  /// default value 7 dots, range 3-20 dots / 默认7个点，范围3-20个点
  ///
  /// [dotsTimes] Duration of a Words Interval in dots / 单词间间隔时长（点的倍数）
  @override
  Future<void> setWordsIntervalDuration(int dotsTimes) async {
    await methodChannel.invokeMethod<void>(
      'setTwoWhiteSpacesDuration',
      dotsTimes,
    );
  }

  @override
  Future<void> setVolume(double volume) async {
    await methodChannel.invokeMethod<void>('setVolume', volume);
  }

  @override
  Future<int> playMorseCode(String morseCode) async {
    var result = await methodChannel.invokeMethod<int>(
      'playMorseCode',
      morseCode,
    );
    return result ?? 99;
  }

  @override
  Future<double> getMorseCodePlayDuration(String morseCode) async {
    var result = await methodChannel.invokeMethod<double>(
      'getMorseCodePlayDuration',
      morseCode,
    );
    return result ?? 0.0;
  }

  /// 播放
  /// Play
  @override
  Future<void> play() async {
    await methodChannel.invokeMethod<void>('play');
  }

  /// 停止
  /// Stop
  @override
  Future<void> stop() async {
    await methodChannel.invokeMethod<void>('stop');
  }
}
