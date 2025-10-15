/// 音频频率枚举 / Audio Frequency Enumeration (Frequency)
enum AudioFrequency {
  /// 800 Hz - 默认频率 / Default frequency
  defaultFrequency(800),

  /// 600 Hz
  frequency600(600),

  /// 800 Hz
  frequency800(800),

  /// 16000 Hz
  frequency1000(1000),

  /// 22050 Hz
  frequency1200(1200);

  const AudioFrequency(this.value);

  /// 频率数值 / Frequency value
  final int value;
}
