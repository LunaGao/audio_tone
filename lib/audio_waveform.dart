/// 音频波形数据类 / Audio Waveform Data Class
/// 用于生成、存储和处理音频波形数据 / Used for generating, storing, and processing audio waveform data
/// 支持正弦波、方波、三角波等多种波形类型 / Supports multiple waveform types including sine, square, triangle waves
/// 提供波形数据的可视化和分析功能 / Provides visualization and analysis capabilities for waveform data
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'audio_sample_rate.dart';

/// 波形类型枚举 / Waveform Type Enumeration
/// 定义支持的各种音频波形类型 / Defines various supported audio waveform types
enum WaveformType {
  /// 正弦波 - 平滑的周期性波形，最基础的音频波形 / Sine wave - smooth periodic waveform, most basic audio waveform
  sine,

  /// 方波 - 在高低电平之间切换的波形，包含丰富谐波 / Square wave - waveform that switches between high and low levels, rich in harmonics
  square,

  /// 三角波 - 线性上升下降的波形，谐波含量适中 / Triangle wave - linearly rising and falling waveform, moderate harmonic content
  triangle,

  /// 锯齿波 - 线性上升后瞬间下降的波形，谐波丰富 / Sawtooth wave - linearly rising then instantly falling waveform, rich in harmonics
  sawtooth,

  /// 噪声 - 随机波形，用于测试和特殊音效 / Noise - random waveform, used for testing and special sound effects
  noise,

  /// 脉冲波 - 短促的脉冲信号，用于摩尔斯电码等 / Pulse wave - brief pulse signal, used for Morse code, etc.
  pulse,
}

/// 音频波形生成器类 / Audio Waveform Generator Class
/// 负责生成各种类型的音频波形数据 / Responsible for generating various types of audio waveform data
/// 支持频率、振幅、相位等参数控制 / Supports parameter control for frequency, amplitude, phase, etc.
class AudioWaveform {
  /// 采样率 / Sample rate
  final AudioSampleRate sampleRate;

  /// 波形类型 / Waveform type
  WaveformType waveformType;

  /// 基础频率（赫兹）/ Base frequency (Hz)
  double frequency;

  /// 振幅（0.0-1.0）/ Amplitude (0.0-1.0)
  double amplitude;

  /// 相位偏移（弧度）/ Phase offset (radians)
  double phase;

  /// 持续时间（秒）/ Duration (seconds)
  double duration;

  /// 随机数生成器，用于噪声生成 / Random number generator for noise generation
  final math.Random _random;

  /// 构造函数 / Constructor
  ///
  /// [sampleRate] 音频采样率 / Audio sample rate
  /// [waveformType] 波形类型 / Waveform type
  /// [frequency] 基础频率（赫兹）/ Base frequency (Hz)
  /// [amplitude] 振幅（0.0-1.0）/ Amplitude (0.0-1.0)
  /// [phase] 相位偏移（弧度）/ Phase offset (radians)
  /// [duration] 持续时间（秒）/ Duration (seconds)
  AudioWaveform({
    this.sampleRate = AudioSampleRate.defaultSampleRate,
    this.waveformType = WaveformType.sine,
    this.frequency = 440.0, // A4音符 / A4 note
    this.amplitude = 1.0,
    this.phase = 0.0,
    this.duration = 1.0,
  }) : _random = math.Random();

  /// 生成波形数据 / Generate waveform data
  /// 返回16位有符号整数数组 / Returns 16-bit signed integer array
  Int16List generateWaveform() {
    final totalSamples = (duration * sampleRate.value).round();
    final waveform = Int16List(totalSamples);

    final angularFrequency = 2 * math.pi * frequency;
    final dt = 1.0 / sampleRate.value;

    for (int i = 0; i < totalSamples; i++) {
      final time = i * dt;
      final sample = _generateSample(time, angularFrequency);
      // 转换为16位有符号整数 / Convert to 16-bit signed integer
      waveform[i] = (sample * amplitude * 32767.0).round().clamp(-32768, 32767);
    }

    return waveform;
  }

  /// 生成单个采样点 / Generate single sample point
  ///
  /// [time] 时间（秒）/ Time (seconds)
  /// [angularFrequency] 角频率（弧度/秒）/ Angular frequency (radians/second)
  double _generateSample(double time, double angularFrequency) {
    final value = angularFrequency * time + phase;

    switch (waveformType) {
      case WaveformType.sine:
        return math.sin(value);

      case WaveformType.square:
        return math.sin(value) >= 0 ? 1.0 : -1.0;

      case WaveformType.triangle:
        // 将正弦波转换为三角波 / Convert sine wave to triangle wave
        return (2 / math.pi) * math.asin(math.sin(value));

      case WaveformType.sawtooth:
        // 锯齿波：从-1到1线性变化 / Sawtooth wave: linearly change from -1 to 1
        final period = 2 * math.pi;
        return 2 * (value % period) / period - 1;

      case WaveformType.pulse:
        // 脉冲波：短促的正脉冲 / Pulse wave: brief positive pulse
        final period = 2 * math.pi;
        final dutyCycle = (value % period) / period;
        return dutyCycle < 0.1 ? 1.0 : -1.0;

      case WaveformType.noise:
        // 白噪声：-1到1之间的随机值 / White noise: random value between -1 and 1
        return _random.nextDouble() * 2 - 1;

      default:
        return 0.0;
    }
  }

  /// 生成摩尔斯电码波形 / Generate Morse code waveform
  /// 基于当前波形类型生成点、划和间隔 / Generates dots, dashes, and intervals based on current waveform type
  ///
  /// [morseCode] 摩尔斯电码字符串（如 ".- -..."）/ Morse code string (e.g., ".- -...")
  /// [wpm] 速度（每分钟单词数）/ Speed (words per minute)
  /// [dotDuration] 点的持续时间（秒）/ Dot duration (seconds)
  Int16List generateMorseCode({
    required String morseCode,
    required int wpm,
    double? dotDuration,
  }) {
    // 计算点的持续时间 / Calculate dot duration
    final dotTime =
        dotDuration ?? (1.2 / wpm); // 基于PARIS标准 / Based on PARIS standard
    final dashTime = dotTime * 3; // 划是点的3倍时长 / Dash is 3 times dot duration
    final symbolInterval = dotTime; // 符号间间隔 / Symbol interval
    final letterInterval = dotTime * 3; // 字母间间隔 / Letter interval
    final wordInterval = dotTime * 7; // 单词间间隔 / Word interval

    final List<double> timeSequence = [];

    for (int i = 0; i < morseCode.length; i++) {
      final char = morseCode[i];

      if (char == '.') {
        // 点 / Dot
        timeSequence.addAll([dotTime, 0.0]); // 声音 + 静音 / Sound + Silence
      } else if (char == '-') {
        // 划 / Dash
        timeSequence.addAll([dashTime, 0.0]); // 声音 + 静音 / Sound + Silence
      } else if (char == ' ') {
        // 空格（字母间隔）/ Space (letter interval)
        timeSequence.add(letterInterval); // 额外静音 / Additional silence
      }
    }

    // 计算总时长 / Calculate total duration
    final totalDuration = timeSequence.fold<double>(
      0.0,
      (sum, time) => sum + time,
    );
    final totalSamples = (totalDuration * sampleRate.value).round();
    final waveform = Int16List(totalSamples);

    int currentSample = 0;
    final angularFrequency = 2 * math.pi * frequency;

    for (final time in timeSequence) {
      final samples = (time * sampleRate.value).round();

      if (time > 0) {
        final dt = 1.0 / sampleRate.value;

        for (int i = 0; i < samples; i++) {
          final timePos = i * dt;
          double sample;

          if (waveformType == WaveformType.sine) {
            sample = math.sin(angularFrequency * timePos);
          } else if (waveformType == WaveformType.square) {
            sample = math.sin(angularFrequency * timePos) >= 0 ? 1.0 : -1.0;
          } else {
            // 默认使用正弦波 / Default to sine wave
            sample = math.sin(angularFrequency * timePos);
          }

          waveform[currentSample + i] = (sample * amplitude * 32767.0)
              .round()
              .clamp(-32768, 32767);
        }
      }

      currentSample += samples;
    }

    return waveform;
  }

  /// 获取波形统计信息 / Get waveform statistics
  ///
  /// [waveform] 波形数据 / Waveform data
  /// 返回包含振幅、频率、RMS等信息的映射 / Returns map containing amplitude, frequency, RMS, and other information
  Map<String, double> getWaveformStats(Int16List waveform) {
    if (waveform.isEmpty) {
      return {};
    }

    // 计算基本统计信息 / Calculate basic statistics
    double sum = 0.0;
    double sumSquares = 0.0;
    int maxAmplitude = 0;
    int minAmplitude = 0;

    for (final sample in waveform) {
      sum += sample;
      sumSquares += sample * sample;
      maxAmplitude = math.max(maxAmplitude, sample);
      minAmplitude = math.min(minAmplitude, sample);
    }

    final mean = sum / waveform.length;
    final rms = math.sqrt(sumSquares / waveform.length);
    final peakToPeak = maxAmplitude - minAmplitude;

    return {
      'mean': mean,
      'rms': rms,
      'peakToPeak': peakToPeak.toDouble(),
      'maxAmplitude': maxAmplitude.toDouble(),
      'minAmplitude': minAmplitude.toDouble(),
      'length': waveform.length.toDouble(),
      'duration': (waveform.length / sampleRate.value),
    };
  }

  /// 设置波形参数 / Set waveform parameters
  ///
  /// [frequency] 频率（赫兹）/ Frequency (Hz)
  /// [amplitude] 振幅（0.0-1.0）/ Amplitude (0.0-1.0)
  /// [phase] 相位（弧度）/ Phase (radians)
  /// [duration] 持续时间（秒）/ Duration (seconds)
  void setParameters({
    double? frequency,
    double? amplitude,
    double? phase,
    double? duration,
    WaveformType? waveformType,
  }) {
    if (frequency != null) this.frequency = frequency;
    if (amplitude != null) this.amplitude = amplitude.clamp(0.0, 1.0);
    if (phase != null) this.phase = phase;
    if (duration != null) this.duration = duration;
    if (waveformType != null) this.waveformType = waveformType;
  }

  /// 生成测试音调序列 / Generate test tone sequence
  /// 用于音频设备测试和校准 / Used for audio equipment testing and calibration
  ///
  /// [frequencies] 频率列表（赫兹）/ Frequency list (Hz)
  /// [duration] 每个音调持续时间（秒）/ Duration of each tone (seconds)
  /// [interval] 音调间间隔时间（秒）/ Interval between tones (seconds)
  Int16List generateTestSequence({
    required List<double> frequencies,
    double duration = 1.0,
    double interval = 0.5,
  }) {
    final List<double> timeSequence = [];

    for (final freq in frequencies) {
      timeSequence.add(duration); // 音调 / Tone
      timeSequence.add(interval); // 间隔 / Interval
    }

    final totalDuration = timeSequence.fold<double>(
      0.0,
      (sum, time) => sum + time,
    );
    final totalSamples = (totalDuration * sampleRate.value).round();
    final waveform = Int16List(totalSamples);

    int currentSample = 0;

    for (int freqIndex = 0; freqIndex < frequencies.length; freqIndex++) {
      final toneDuration = timeSequence[freqIndex * 2];
      final toneSamples = (toneDuration * sampleRate.value).round();
      final angularFrequency = 2 * math.pi * frequencies[freqIndex];

      // 生成音调 / Generate tone
      for (int i = 0; i < toneSamples; i++) {
        final timePos = i / sampleRate.value;
        double sample;

        switch (waveformType) {
          case WaveformType.sine:
            sample = math.sin(angularFrequency * timePos);
            break;
          case WaveformType.square:
            sample = math.sin(angularFrequency * timePos) >= 0 ? 1.0 : -1.0;
            break;
          case WaveformType.triangle:
            sample =
                (2 / math.pi) * math.asin(math.sin(angularFrequency * timePos));
            break;
          default:
            sample = math.sin(angularFrequency * timePos);
        }

        waveform[currentSample + i] = (sample * amplitude * 32767.0)
            .round()
            .clamp(-32768, 32767);
      }

      currentSample += toneSamples;

      // 添加间隔静音 / Add interval silence
      if (freqIndex < frequencies.length - 1) {
        final intervalDuration = timeSequence[freqIndex * 2 + 1];
        final intervalSamples = (intervalDuration * sampleRate.value).round();
        currentSample += intervalSamples;
      }
    }

    return waveform;
  }
}
