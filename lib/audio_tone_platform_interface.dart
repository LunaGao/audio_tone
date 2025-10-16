import 'package:audio_tone/audio_frequency.dart';
import 'package:audio_tone/audio_sample_rate.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'audio_tone_method_channel.dart';

abstract class AudioTonePlatform extends PlatformInterface {
  /// Constructs a AudioTonePlatform.
  AudioTonePlatform() : super(token: _token);

  static final Object _token = Object();

  static AudioTonePlatform _instance = MethodChannelAudioTone();

  /// The default instance of [AudioTonePlatform] to use.
  ///
  /// Defaults to [MethodChannelAudioTone].
  static AudioTonePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AudioTonePlatform] when
  /// they register themselves.
  static set instance(AudioTonePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> init(AudioSampleRate sampleRate) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<void> setFrequency(AudioFrequency frequency) {
    throw UnimplementedError('setFrequency() has not been implemented.');
  }

  Future<void> setSpeed(int wpm) {
    throw UnimplementedError('setSpeed() has not been implemented.');
  }

  Future<void> setDashDuration(int dotsTimes) {
    throw UnimplementedError('setDashDuration() has not been implemented.');
  }

  Future<void> setDotDashIntervalDuration(int dotsTimes) {
    throw UnimplementedError(
      'setDotDashIntervalDuration() has not been implemented.',
    );
  }

  /// 设置字母之间的间隔时长（点的倍数）
  /// Set Duration of a Letter Interval (Dot counts)
  /// default value 3 dots, range 1-5 dots / 默认3个点，范围1-5个点
  ///
  /// [dotsTimes] Duration of a Letter Interval in dots / 字母之间的间隔时长（点的倍数）
  Future<void> setLetterIntervalDuration(int dotsTimes) {
    throw UnimplementedError(
      'setLetterIntervalDuration() has not been implemented.',
    );
  }

  /// 设置单词间间隔时长（点的倍数）
  /// Set Duration of a Words Interval (Dot counts)
  /// default value 7 dots, range 3-20 dots / 默认7个点，范围3-20个点
  ///
  /// [dotsTimes] Duration of a Words Interval in dots / 单词间间隔时长（点的倍数）
  Future<void> setWordsIntervalDuration(int dotsTimes) {
    throw UnimplementedError(
      'setWordsIntervalDuration() has not been implemented.',
    );
  }

  Future<void> setVolume(double volume) {
    throw UnimplementedError('setVolume() has not been implemented.');
  }

  Future<int> playMorseCode(String morseCode) {
    throw UnimplementedError('playMorseCode() has not been implemented.');
  }

  /// 播放
  /// Play
  Future<void> play() {
    throw UnimplementedError('play() has not been implemented.');
  }

  /// 停止
  /// Stop
  Future<void> stop() {
    throw UnimplementedError('stop() has not been implemented.');
  }
}
