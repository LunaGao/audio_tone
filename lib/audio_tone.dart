
import 'audio_tone_platform_interface.dart';

class AudioTone {
  Future<String?> getPlatformVersion() {
    return AudioTonePlatform.instance.getPlatformVersion();
  }
}
