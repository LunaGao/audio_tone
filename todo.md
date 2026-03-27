# audio_tone 项目检查记录

## 本次检查范围

- 已读取项目核心代码：`lib/`、`android/`、`ios/`、`test/`、`example/`、`README.md`、`README_CN.md`、`pubspec.yaml`
- 已执行验证：
  - `fvm flutter analyze`（根包）: 通过
  - `fvm flutter test`（根包）: 通过
  - `fvm flutter analyze`（example）: 通过
  - `fvm flutter test`（example）: 失败

## 已确认问题

### P0

- [x] 修复 `AudioTone.sampleRate` 未初始化问题  
  位置：`lib/audio_tone.dart:11-12`、`lib/audio_tone.dart:49-67`  
  说明：`_sampleRate` 声明为 `late`，但构造函数里只调用了 `AudioTonePlatform.instance.init(sampleRate)`，没有执行 `this._sampleRate = sampleRate`。外部一旦读取 `sampleRate` getter，会触发 `LateInitializationError`。

### P1

- [x] 修复 example 测试仍然使用脚手架默认断言  
  位置：`example/test/widget_test.dart:14-25`、`example/lib/main.dart:38-68`  
  说明：测试期待页面存在 `Running on:` 文本，但当前示例页根本没有该文案；实测 `fvm flutter test`（example）失败。

- [x] 更新 Android 原生单测，移除无效的 `getPlatformVersion` 断言  
  位置：`android/src/test/kotlin/com/maomishen/audio_tone/AudioTonePluginTest.kt:18-25`  
  说明：插件当前没有 `getPlatformVersion` 方法，这个测试属于模板残留，和现有实现不一致。

- [x] 修正 iOS podspec 元数据与发布信息不一致  
  位置：`ios/audio_tone.podspec:7-15`、`pubspec.yaml:1-4`  
  说明：podspec 仍是脚手架默认信息，版本还是 `0.0.1`，而 `pubspec.yaml` 已是 `0.0.3`；`summary`、`description`、`homepage`、`author` 也都未更新。

- [x] 统一 README 与真实 API 命名  
  位置：`README.md:86`、`README.md:124-137`、`README.md:186`、`README_CN.md:86`、`README_CN.md:124-137`、`README_CN.md:186`、`lib/audio_frequency.dart:2-16`、`lib/audio_sample_rate.dart:3-38`  
  说明：文档中使用了 `frequency1000Hz`、`frequency1200Hz`、`telephoneQuality`、`speechRecording`、`dvdQuality`、`studioQuality` 等名称，但代码里的实际枚举名是 `frequency1000`、`frequency1200`、`telephone`、`voice`、`professionalVideo`、`ultraHighQuality` 等。当前 README 示例代码不能直接编译通过。

### P2

- [x] 修正文档中的平台版本说明  
  位置：`README.md:205-206`、`README_CN.md:205-206`、`android/build.gradle:46-48`、`ios/audio_tone.podspec:18`  
  说明：README 写的是 Android `SDK 21+`、iOS `11.0+`，但实际工程配置是 Android `minSdk 24`、iOS `13.0`。

- [x] 修正 `AudioFrequency` 中错误的注释说明  
  位置：`lib/audio_frequency.dart:12-16`  
  说明：`frequency1000(1000)` 注释写成了 `16000 Hz`，`frequency1200(1200)` 注释写成了 `22050 Hz`，会误导调用方。

### 新发现问题

- [x] 更新 `test/audio_tone_test.dart` 中的 mock 实现  
  位置：`test/audio_tone_test.dart`、`lib/audio_tone_platform_interface.dart`  
  说明：平台接口新增了 `setLightFlashingMagnificationFactor` 和 `playStream`，但测试里的 `MockAudioTonePlatform` 没有补实现；当前 `fvm flutter test`（根包）会失败。

- [ ] 排查 Android 插件独立 Gradle 构建缺少 Flutter classpath 的问题  
  位置：`android/build.gradle`、`android/src/main/kotlin/com/maomishen/audio_tone/*`  
  说明：当前从插件根目录执行 `android/./gradlew test` 时，Kotlin 编译阶段无法解析 `io.flutter.*`。这会阻塞 Android 原生单测的独立验证。

## 建议处理顺序

1. 先修复 `AudioTone.sampleRate` 未初始化问题。
2. 修 example 测试和 Android 原生单测，确保仓库内测试不再带模板残留。
3. 同步 README / README_CN / podspec 的发布信息和 API 名称。
4. 最后补充更有针对性的单测，覆盖构造参数、枚举值和时长计算。

## 本次变更记录

- [x] 新增 `todo.md`，记录本次项目检查结果
- [x] 修复 `AudioTone.sampleRate` 未初始化问题
- [x] 修复 example 测试模板残留问题
- [x] 修复 Android 原生单测模板残留问题
- [x] 同步 podspec、README/README_CN、平台版本说明和枚举注释
- [x] 修复根包测试 mock 与平台接口不一致的问题
