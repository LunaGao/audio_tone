import 'package:audio_tone/audio_sample_rate.dart';
import 'package:audio_tone/audio_waveform.dart';

import 'audio_tone_platform_interface.dart';

export 'audio_sample_rate.dart';
export 'audio_waveform.dart';

class AudioTone {
  Future<String?> getPlatformVersion() {
    return AudioTonePlatform.instance.getPlatformVersion();
  }

  // Audio Sample Rate （Frequency）/ 音频采样率
  // default 44100Hz / 默认44100Hz
  late AudioSampleRate _sampleRate;

  /// Words per minute / 每分钟单词数
  /// default value 10 WPM, range 5-100 WPM / 默认10WPM，范围5-100WPM
  late int _wpm;

  /// Duration of a Dash (Dot counts) / 破折号持续时间（点的倍数）
  /// default value 3 dots, range 2-10 dots / 默认3个点，范围2-10个点
  late int _dashDuration;

  /// 点与破折号之间的间隔时长（点的倍数）
  /// default value 3 dots, range 1-5 dots / 默认3个点，范围1-5个点
  late int _dotDashIntervalDuration;

  /// 单词间间隔时长（点的倍数）
  /// default value 7 dots, range 3-20 dots / 默认7个点，范围3-20个点
  late int _wordsIntervalDuration;

  /// 音量 / Volume
  /// default value 1.0, range 0.0-1.0 / 默认1.0，范围0.0-1.0
  late double _volume;

  /// 波形类型 / Waveform Type
  /// default value sine / 默认正弦波
  late WaveformType _waveformType;

  AudioTone({
    AudioSampleRate sampleRate = AudioSampleRate.defaultSampleRate,
    int wpm = 10,
    int dashDuration = 3,
    int dotDashIntervalDuration = 1,
    int wordsIntervalDuration = 7,
    double volume = 1.0,
    WaveformType waveformType = WaveformType.sine,
  }) {
    setSampleRate(sampleRate);
    setSpeed(wpm);
    setDashDuration(dashDuration);
    setDotDashIntervalDuration(dotDashIntervalDuration);
    setWordsIntervalDuration(wordsIntervalDuration);
    setVolume(volume);
    setWaveformType(waveformType);
    AudioTonePlatform.instance.init();
  }

  /// 设置音频采样率
  /// Set Audio Sample Rate
  ///
  /// [sampleRate] Audio Sample Rate / 音频采样率，默认44100Hz
  void setSampleRate(AudioSampleRate sampleRate) {
    _sampleRate = sampleRate;
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
  }

  /// 设置破折号持续时间（点的倍数）
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
  }

  /// 设置波形类型
  /// Set Waveform Type
  /// default value sine / 默认正弦波
  ///
  /// [waveformType] Waveform Type / 波形类型
  void setWaveformType(WaveformType waveformType) {
    _waveformType = waveformType;
  }
}
