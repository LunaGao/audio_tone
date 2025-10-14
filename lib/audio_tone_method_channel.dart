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
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
