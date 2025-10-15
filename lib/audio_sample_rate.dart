/// 音频采样率枚举 / Audio Sample Rate Enumeration (Frequency)
/// 提供常用音频采样率常量、验证功能、转换工具等 / Provides common audio sample rate constants, validation functions, and conversion tools
enum AudioSampleRate {
  /// 44100 Hz - 默认采样率 / Default sample rate
  defaultSampleRate(44100),

  /// 8000 Hz - 电话音质，最低常用采样率 / Telephone quality, lowest common sample rate
  telephone(8000),

  /// 11025 Hz - 低质量音频采样率 / Low quality audio sample rate
  lowQuality(11025),

  /// 16000 Hz - 语音录制常用采样率 / Common sample rate for voice recording
  voice(16000),

  /// 22050 Hz - 低质量CD采样率 / Low quality CD sample rate
  halfCD(22050),

  /// 32000 Hz - 专业音频设备常用采样率 / Common sample rate for professional audio equipment
  professional(32000),

  /// 44100 Hz - CD音质标准采样率（默认推荐）/ CD quality standard sample rate (recommended default)
  cdQuality(44100),

  /// 48000 Hz - 专业音频和视频制作标准采样率 / Standard sample rate for professional audio and video production
  professionalVideo(48000),

  /// 88200 Hz - 高质量音频采样率（CD的两倍）/ High quality audio sample rate (twice CD)
  highQuality(88200),

  /// 96000 Hz - 超高音质采样率 / Ultra high quality sample rate
  ultraHighQuality(96000),

  /// 176400 Hz - 极高质量音频采样率 / Extreme quality audio sample rate
  extremeQuality(176400),

  /// 192000 Hz - 最高常用音频采样率 / Highest common audio sample rate
  maximumQuality(192000);

  const AudioSampleRate(this.value);

  /// 采样率数值 / Sample rate value
  final int value;
}
