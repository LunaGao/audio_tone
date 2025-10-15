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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
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

  Future<void> setDashDuration(int dashDuration) {
    throw UnimplementedError('setDashDuration() has not been implemented.');
  }

  Future<void> setDotDashIntervalDuration(int dotDashIntervalDuration) {
    throw UnimplementedError(
      'setDotDashIntervalDuration() has not been implemented.',
    );
  }

  Future<void> setWordsIntervalDuration(int wordsIntervalDuration) {
    throw UnimplementedError(
      'setWordsIntervalDuration() has not been implemented.',
    );
  }

  Future<void> setVolume(double volume) {
    throw UnimplementedError('setVolume() has not been implemented.');
  }
}
