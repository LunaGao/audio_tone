# audio_tone

![Static Badge](https://img.shields.io/badge/bless-Cats-green)
![Static Badge](https://img.shields.io/badge/AI-doubao-pink)
![Static Badge](https://img.shields.io/badge/AI-TRAE-pink)
![Pub Version](https://img.shields.io/pub/v/audio_tone)
![Flutter Platform](https://img.shields.io/badge/platform-Flutter-blue)

A professional Flutter plugin for audio tone generation and Morse code playback. This plugin provides comprehensive audio control features including frequency modulation, speed adjustment, and precise Morse code communication timing control.

## Features ✨

- **Audio Tone Generation**: Generate pure audio tones with customizable frequencies
- **Morse Code Support**: Complete Morse code playback with customizable time intervals
- **Professional Audio Control**: Precise audio parameter control
- **Cross-Platform Support**: Support for Android and iOS platforms
- **Real-time Playback**: Real-time audio generation and playback control
- **Flexible Configuration**: Rich audio parameter customization options

## Installation 📦

Add dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  audio_tone: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage 🚀

### Basic Usage

```dart
import 'package:audio_tone/audio_tone.dart';
import 'package:audio_tone/audio_frequency.dart';

// Create instance with default settings
final audioTone = AudioTone();

// Play simple tone
await audioTone.play();

// Stop tone
await audioTone.stop();
```

### Morse Code Playback

```dart
// Play Morse code
await audioTone.playMorseCode(".-.-  .-.- .");

// Plugin supports:
// "." - Dot (short sound)
// "-" - Dash (long sound)
// " " - Letter spacing (single space)
// "  " - Word spacing (double spaces)
```

### Advanced Configuration

```dart
// Create instance with custom settings
final audioTone = AudioTone(
  sampleRate: AudioSampleRate.cdQuality, // 44100Hz
  frequency: AudioFrequency.defaultFrequency, // 800Hz
  wpm: 10, // Words per minute (5-100)
  dashDuration: 3, // Dash duration (dot multiples) (2-10)
  dotDashIntervalDuration: 1, // Dot-dash interval (dot multiples) (1-5)
  letterIntervalDuration: 3, // Letter interval (dot multiples) (1-5)
  wordsIntervalDuration: 7, // Word interval (dot multiples) (3-20)
  volume: 1.0, // Volume (0.0-1.0)
);

// Adjust settings dynamically
audioTone.setFrequency(AudioFrequency.frequency1000Hz);
audioTone.setSpeed(15); // Set to 15 WPM
audioTone.setVolume(0.5); // Set to 50% volume
```

## API Reference 📚

### AudioTone Class

#### Constructor Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `sampleRate` | AudioSampleRate | `44100Hz` | Audio sample rate |
| `frequency` | AudioFrequency | `800Hz` | Tone frequency |
| `wpm` | int | `10` | Words per minute (5-100) |
| `dashDuration` | int | `3` | Dash duration (dot multiples) (2-10) |
| `dotDashIntervalDuration` | int | `1` | Dot-dash interval (dot multiples) (1-5) |
| `letterIntervalDuration` | int | `3` | Letter interval (dot multiples) (1-5) |
| `wordsIntervalDuration` | int | `7` | Word interval (dot multiples) (3-20) |
| `volume` | double | `1.0` | Volume level (0.0-1.0) |

#### Methods

- `setFrequency(AudioFrequency frequency)` - Set audio frequency
- `setSpeed(int wpm)` - Set Morse code speed (5-100 WPM)
- `setDashDuration(int dotsTimes)` - Set dash duration (2-10 dots)
- `setDotDashIntervalDuration(int dotsTimes)` - Set dot-dash interval (1-5 dots)
- `setLetterIntervalDuration(int dotsTimes)` - Set letter interval (1-5 dots)
- `setWordsIntervalDuration(int dotsTimes)` - Set word interval (3-20 dots)
- `setVolume(double volume)` - Set volume (0.0-1.0)
- `playMorseCode(String morseCode)` - Play Morse code string
- `play()` - Start tone playback
- `stop()` - Stop tone playback

### AudioFrequency Enum

- `defaultFrequency` (800Hz)
- `frequency600Hz`
- `frequency800Hz`
- `frequency1000Hz`
- `frequency1200Hz`

### AudioSampleRate Enum

- `defaultSampleRate` (44100Hz)
- `telephoneQuality` (8000Hz)
- `speechRecording` (16000Hz)
- `cdQuality` (44100Hz)
- `dvdQuality` (48000Hz)
- `studioQuality` (96000Hz)

## Complete Example 🎯

```dart
import 'package:flutter/material.dart';
import 'package:audio_tone/audio_tone.dart';
import 'package:audio_tone/audio_frequency.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final audioTone = AudioTone(wpm: 5);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Audio Tone Plugin Example')),
        body: ListView(
          children: [
            ListTile(
              title: const Text('Play Morse Code'),
              subtitle: const Text('Tap to play ".-.-  .-.- ."'),
              onTap: () async {
                await audioTone.playMorseCode(".-.-  .-.- .");
              },
            ),
            GestureDetector(
              onTapDown: (_) => audioTone.play(),
              onTapUp: (_) => audioTone.stop(),
              child: ListTile(
                title: const Text('Hold to Play Tone'),
                subtitle: const Text('Touch and hold to play, release to stop'),
              ),
            ),
            ListTile(
              title: const Text('Set Parameters'),
              subtitle: const Text('Tap to set frequency to 1000Hz, speed to 15 WPM'),
              onTap: () {
                audioTone.setFrequency(AudioFrequency.frequency1000Hz);
                audioTone.setSpeed(15);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Set: 1000Hz, 15 WPM')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## Platform Support 📱

| Platform | Version |
|----------|---------|
| Android | SDK 21+ |
| iOS | 11.0+ |

## Development Notes 🔧

### Project Structure
```
audio_tone/
├── lib/
│   ├── audio_tone.dart              # Main plugin class
│   ├── audio_tone_platform_interface.dart  # Platform interface
│   ├── audio_tone_method_channel.dart      # Method channel implementation
│   ├── audio_frequency.dart         # Frequency enum
│   └── audio_sample_rate.dart       # Sample rate enum
├── ios/
│   └── Classes/
│       ├── AudioTonePlugin.swift    # iOS plugin implementation
│       └── AudioTonePlayer.swift    # iOS audio player
├── android/
│   └── src/main/kotlin/
│       └── com/maomishen/audio_tone/
│           └── AudioTonePlugin.kt   # Android plugin implementation
└── example/                         # Example app
```

### Contributing Guidelines 🤝

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Environment Requirements
- Flutter >= 3.3.0
- Dart SDK >= 3.9.2
- Xcode (for iOS development)
- Android Studio (for Android development)

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author 👨‍💻

Created with ❤️ by [LunaGao](https://github.com/LunaGao)

## Support 💖

If you find this plugin helpful, please give it a ⭐ on [GitHub](https://github.com/LunaGao/audio_tone)!

## Changelog 📝

### 0.0.1
- Initial version
- Basic audio tone generation support
- Morse code playback support
- Android and iOS platform support
- Complete API interface

---

**Note**: This is a Flutter plugin project containing native implementation code for Android and iOS platforms. For Flutter development help, please check the [online documentation](https://docs.flutter.dev).