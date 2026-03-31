# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`audio_tone` is a Flutter **federated plugin** that generates sine-wave audio tones on Android and iOS. It is published to pub.dev by dmt-labs.

## Commands

```bash
# Analyze Dart code
flutter analyze

# Run unit tests (mocked MethodChannel, no device needed)
flutter test

# Run a single test file
flutter test test/audio_tone_test.dart

# Run the example app (requires connected device/emulator)
cd example && flutter run

# Check formatting
dart format --output=none --set-exit-if-changed lib/ test/
```

## Architecture

The plugin uses a single `MethodChannel('audio_tone')` with two methods: `play` and `stop`.

| Layer | File | Responsibility |
|---|---|---|
| Dart API | `lib/audio_tone.dart` | `AudioTone.play(frequency, duration, {volume})` and `AudioTone.stop()` static methods |
| Android | `android/src/main/kotlin/com/dmt/audio_tone/AudioTonePlugin.kt` | Generates PCM sine-wave samples, writes to `AudioTrack` on a background thread |
| iOS | `ios/Classes/SwiftAudioTonePlugin.swift` | Builds an `AVAudioPCMBuffer` sine wave, plays via `AVAudioEngine` + `AVAudioPlayerNode` |

The example app (`example/`) is a standalone Flutter app that exercises the plugin and serves as a manual integration test.

## Platform notes

- Android uses `AudioTrack` in streaming mode; `stop` releases the track.
- iOS uses `AVAudioEngine`; the engine is started lazily on first `play` call.
- Both platforms run audio generation off the main thread to avoid UI jank.
