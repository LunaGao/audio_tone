import 'package:audio_tone/audio_frequency.dart';
import 'package:audio_tone/audio_sample_rate.dart';

import 'audio_tone_platform_interface.dart';

export 'audio_sample_rate.dart';

class AudioTone {
  Future<String?> getPlatformVersion() {
    return AudioTonePlatform.instance.getPlatformVersion();
  }

  // Audio Sample Rate （Frequency）/ 音频采样率
  // default 44100Hz / 默认44100Hz
  late AudioSampleRate _sampleRate;
  AudioSampleRate get sampleRate => _sampleRate;

  /// 音频频率 / Audio Frequency
  /// default 800Hz / 默认800Hz
  late AudioFrequency _frequency;
  AudioFrequency get frequency => _frequency;

  /// Words per minute / 每分钟单词数
  /// default value 10 WPM, range 5-100 WPM / 默认10WPM，范围5-100WPM
  late int _wpm;
  int get wpm => _wpm;

  /// Duration of a Dash (Dot counts) / 破折号持续时间（点的倍数）
  /// default value 3 dots, range 2-10 dots / 默认3个点，范围2-10个点
  late int _dashDuration;
  int get dashDuration => _dashDuration;

  /// 点与破折号之间的间隔时长（点的倍数）
  /// default value 3 dots, range 1-5 dots / 默认3个点，范围1-5个点
  late int _dotDashIntervalDuration;
  int get dotDashIntervalDuration => _dotDashIntervalDuration;

  /// 字母之间的间隔时长（点的倍数）
  /// default value 3 dots, range 1-5 dots / 默认3个点，范围1-5个点
  late int _letterIntervalDuration;
  int get letterIntervalDuration => _letterIntervalDuration;

  /// 单词间间隔时长（点的倍数）
  /// default value 7 dots, range 3-20 dots / 默认7个点，范围3-20个点
  late int _wordsIntervalDuration;
  int get wordsIntervalDuration => _wordsIntervalDuration;

  /// 音量 / Volume
  /// default value 1.0, range 0.0-1.0 / 默认1.0，范围0.0-1.0
  late double _volume;
  double get volume => _volume;

  AudioTone({
    AudioSampleRate sampleRate = AudioSampleRate.defaultSampleRate,
    AudioFrequency frequency = AudioFrequency.defaultFrequency,
    int wpm = 10,
    int dashDuration = 3,
    int dotDashIntervalDuration = 1,
    int wordsIntervalDuration = 7,
    double volume = 1.0,
  }) {
    AudioTonePlatform.instance.init(sampleRate);
    setFrequency(frequency);
    setSpeed(wpm);
    setDashDuration(dashDuration);
    setDotDashIntervalDuration(dotDashIntervalDuration);
    setWordsIntervalDuration(wordsIntervalDuration);
    setVolume(volume);
  }

  /// 设置音频频率
  /// Set Audio Frequency
  /// default value 800Hz / 默认800Hz
  ///
  /// [frequency] Audio Frequency / 音频频率
  void setFrequency(AudioFrequency frequency) {
    _frequency = frequency;
    AudioTonePlatform.instance.setFrequency(frequency);
  }

  /// 设置基础速度（WPM，每分钟单词数）
  /// 标准摩尔斯电码速度单位，基于PARIS单词长度计算
  /// [wpm] 速度值，接受范围5-100WPM
  void setSpeed(int wpm) {
    if (wpm < 5 || wpm > 100) {
      throw ArgumentError.value(
        wpm,
        'wpm',
        'Speed must be between 5 and 100 WPM',
      );
    }
    _wpm = wpm;
    AudioTonePlatform.instance.setSpeed(wpm);
  }

  /// 设置【划】持续时间（点的倍数）
  /// Set Duration of a Dash (Dot counts)
  /// default value 3 dots, range 2-10 dots / 默认3个点，范围2-10个点
  ///
  /// [dotsTimes] Duration of a Dash in dots / 破折号持续时间（点的倍数）
  void setDashDuration(int dotsTimes) {
    if (dotsTimes < 2 || dotsTimes > 10) {
      throw ArgumentError.value(
        dotsTimes,
        'dotsTimes',
        'Dash duration must be between 2 and 10 dots',
      );
    }
    _dashDuration = dotsTimes;
    AudioTonePlatform.instance.setDashDuration(dotsTimes);
  }

  /// 设置点与破折号之间的间隔时长（点的倍数）
  /// Set Duration of a Dot Dash Interval (Dot counts)
  /// default value 3 dots, range 1-5 dots / 默认3个点，范围1-5个点
  ///
  /// [dotsTimes] Duration of a Dot Dash Interval in dots / 点与破折号之间的间隔时长（点的倍数）
  void setDotDashIntervalDuration(int dotsTimes) {
    if (dotsTimes < 1 || dotsTimes > 5) {
      throw ArgumentError.value(
        dotsTimes,
        'dotsTimes',
        'Dot dash interval duration must be between 1 and 5 dots',
      );
    }
    _dotDashIntervalDuration = dotsTimes;
    AudioTonePlatform.instance.setDotDashIntervalDuration(dotsTimes);
  }

  /// 设置字母之间的间隔时长（点的倍数）
  /// Set Duration of a Letter Interval (Dot counts)
  /// default value 3 dots, range 1-5 dots / 默认3个点，范围1-5个点
  ///
  /// [dotsTimes] Duration of a Letter Interval in dots / 字母之间的间隔时长（点的倍数）
  void setLetterIntervalDuration(int dotsTimes) {
    if (dotsTimes < 1 || dotsTimes > 5) {
      throw ArgumentError.value(
        dotsTimes,
        'dotsTimes',
        'Letter interval duration must be between 1 and 5 dots',
      );
    }
    _letterIntervalDuration = dotsTimes;
    AudioTonePlatform.instance.setLetterIntervalDuration(dotsTimes);
  }

  /// 设置单词间间隔时长（点的倍数）
  /// Set Duration of a Words Interval (Dot counts)
  /// default value 7 dots, range 3-20 dots / 默认7个点，范围3-20个点
  ///
  /// [dotsTimes] Duration of a Words Interval in dots / 单词间间隔时长（点的倍数）
  void setWordsIntervalDuration(int dotsTimes) {
    if (dotsTimes < 3 || dotsTimes > 20) {
      throw ArgumentError.value(
        dotsTimes,
        'dotsTimes',
        'Words interval duration must be between 3 and 20 dots',
      );
    }
    _wordsIntervalDuration = dotsTimes;
    AudioTonePlatform.instance.setWordsIntervalDuration(dotsTimes);
  }

  /// 设置音量
  /// Set Volume
  /// default value 1.0, range 0.0-1.0 / 默认1.0，范围0.0-1.0
  ///
  /// [volume] Volume / 音量
  void setVolume(double volume) {
    if (volume < 0.0 || volume > 1.0) {
      throw ArgumentError.value(
        volume,
        'volume',
        'Volume must be between 0.0 and 1.0',
      );
    }
    _volume = volume;
    AudioTonePlatform.instance.setVolume(volume);
  }

  /// 播放摩尔斯电码
  /// Play Morse Code
  ///
  /// [morseCode] Morse Code / 摩尔斯电码
  Future<void> playMorseCode(String morseCode) async {
    await AudioTonePlatform.instance.playMorseCode(morseCode);
  }

  /// 播放
  /// Play
  Future<void> play() async {
    await AudioTonePlatform.instance.play();
  }

  /// 停止
  /// Stop
  Future<void> stop() async {
    await AudioTonePlatform.instance.stop();
  }
}
