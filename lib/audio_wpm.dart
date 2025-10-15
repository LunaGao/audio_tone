/// 音频播放速度（WPM - Words Per Minute）配置类
/// Audio playback speed (WPM - Words Per Minute) configuration class
///
/// 这个类定义了音频播放速度的最小值和最大值限制
/// This class defines the minimum and maximum limits for audio playback speed
class AudioWPM {
  /// 最小播放速度（每分钟单词数）
  /// Minimum playback speed (words per minute)
  ///
  /// 用于限制音频播放的最慢速度，确保播放不会过于缓慢
  /// Used to limit the slowest playback speed to ensure audio doesn't play too slowly
  static const int minWPM = 5;

  /// 最大播放速度（每分钟单词数）
  /// Maximum playback speed (words per minute)
  ///
  /// 用于限制音频播放的最快速度，确保播放不会过于快速而难以理解
  /// Used to limit the fastest playback speed to ensure audio remains comprehensible
  static const int maxWPM = 100;
}
