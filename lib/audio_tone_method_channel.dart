import 'dart:async';
import 'dart:typed_data';

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

  @visibleForTesting
  final eventChannel = const EventChannel('audio_tone_event');

  @visibleForTesting
  final toneDataEventChannel = const EventChannel('audio_tone_tone_data');

  StreamSubscription<dynamic>? _streamSubscription;

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

  @override
  Future<void> setLightFlashingMagnificationFactor(double factor) async {
    await methodChannel.invokeMethod<void>(
      'setLightFlashingMagnificationFactor',
      factor,
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
  Future<int> playTimings(List<int> timings) async {
    var result = await methodChannel.invokeMethod<int>('playTimings', timings);
    return result ?? -1;
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

  /// 播放流
  /// Play Stream
  ///
  /// [morseCode] Morse Code / 摩尔斯电码
  /// [onComplete] 播放完成回调 / Playback complete callback
  @override
  StreamSubscription<dynamic> playStream(String morseCode) {
    _streamSubscription = null;
    _streamSubscription = eventChannel
        .receiveBroadcastStream(morseCode)
        .listen(null, cancelOnError: true);
    return _streamSubscription!;
  }

  /// 根据摩斯码生成完整的正弦波+静音采样数据
  /// Generate complete sine wave + silence sample data based on Morse code
  ///
  /// [morseCode] Morse Code / 摩尔斯电码
  /// 返回 Float64List，包含所有符号对应的采样数据
  @override
  Future<Float64List> generateToneSoundData(String morseCode) async {
    final Completer<Float64List> completer = Completer<Float64List>();
    final List<double> allSamples = [];

    final subscription = toneDataEventChannel
        .receiveBroadcastStream(morseCode)
        .listen(
          (dynamic event) {
            if (event is Map) {
              final data = event['data'];
              if (data is List) {
                allSamples.addAll(data.cast<double>());
              }
            }
          },
          onError: (dynamic error) {
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          },
          onDone: () {
            if (!completer.isCompleted) {
              completer.complete(Float64List.fromList(allSamples));
            }
          },
          cancelOnError: true,
        );

    final result = await completer.future;
    await subscription.cancel();
    return result;
  }
}
