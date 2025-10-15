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
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> init(AudioSampleRate sampleRate) async {
    await methodChannel.invokeMethod<void>('init', sampleRate.value);
  }

  @override
  Future<void> setFrequency(AudioFrequency frequency) async {
    await methodChannel.invokeMethod<void>('setFrequency', frequency.value);
  }

  @override
  Future<void> setDashDuration(int dashDuration) async {
    await methodChannel.invokeMethod<void>('setDashDuration', dashDuration);
  }

  @override
  Future<void> setDotDashIntervalDuration(int dotDashIntervalDuration) async {
    await methodChannel.invokeMethod<void>(
      'setDotDashIntervalDuration',
      dotDashIntervalDuration,
    );
  }

  @override
  Future<void> setWordsIntervalDuration(int wordsIntervalDuration) async {
    await methodChannel.invokeMethod<void>(
      'setWordsIntervalDuration',
      wordsIntervalDuration,
    );
  }

  @override
  Future<void> setVolume(double volume) async {
    await methodChannel.invokeMethod<void>('setVolume', volume);
  }
}
