## Unreleased

* Fix `AudioTone.sampleRate` state initialization.
* Update example widget tests to match the current example app UI.
* Align Android plugin unit tests with the current method-channel behavior.
* Sync README, README_CN, and iOS podspec metadata with the current API and package information.
* Fix `AudioFrequency` enum comments for `frequency1000` and `frequency1200`.
* Update Dart platform mocks to match the current platform interface.
* Add Flutter Android classpath wiring so standalone Android Gradle tests can run from `android/`.
* Upgrade the project FVM Flutter version to `3.41.4`.

## 0.0.6

* Add `lightFlashingMagnificationFactor` for light flashing control.
* Add `onDone` callback support for Morse code playback completion.

## 0.0.5

* Fix iOS `playStream` issue.

## 0.0.4

* Add `playStream` for streaming Morse code playback callbacks.

## 0.0.3

* Fix Android audio playback issues in specific scenarios.
* Enhance tap-to-play functionality and user experience.
* Improve audio playback reliability on Android devices.

## 0.0.2

* Add `getMorseCodePlayDuration` for calculating Morse code playback duration.
* Fix iOS platform implementation errors.
* Improve audio playback performance and stability.

## 0.0.1

* Initial release.
* Support audio tone generation and Morse code playback.
* Provide Flutter plugin implementations for both iOS and Android.
* Comment out native debug print statements.
* Improve the `pubspec.yaml` description.
* Add complete English README documentation.
* Rename the original Chinese README to `README_CN.md`.
