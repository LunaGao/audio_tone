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

- [x] 排查 Android 插件独立 Gradle 构建缺少 Flutter classpath 的问题  
  位置：`android/build.gradle`、`android/src/main/kotlin/com/maomishen/audio_tone/*`  
  说明：当前从插件根目录执行 `android/./gradlew test` 时，Kotlin 编译阶段无法解析 `io.flutter.*`。这会阻塞 Android 原生单测的独立验证。

### Android 性能优化待办

- [ ] 优化持续音播放的缓冲策略  
  位置：`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:158-168`  
  说明：当前 `playNow()` 只生成约 10ms 的音频数据并在循环中持续 `WRITE_BLOCKING`，写入频率过高，线程唤醒和 CPU 开销偏大。应改为更大的循环缓冲，或改成更低频率的写入策略。

- [ ] 减少摩斯码播放时的音频数组分配和正弦波重复计算  
  位置：`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:356-387`  
  说明：点、划、静音每次播放都会新建 `FloatArray` 并重新生成波形；长串播放时会产生较多对象分配和 GC 压力。可考虑缓存常用片段，或实现相位连续的音频生成器。

- [ ] 复用 `AudioTrack`，避免频繁创建和释放  
  位置：`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:155-169`、`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:317-346`、`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:188-209`  
  说明：当前点击播放和摩斯码播放都会重复创建/释放 `AudioTrack`。这会增加 native 资源抖动和启动延迟，适合改成按模式复用、仅在 `cleanup()` 或参数不兼容时重建。

- [ ] 精简 `playStream` 热路径中的日志和主线程事件派发  
  位置：`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:238-283`  
  说明：当前每个符号都会打印多条 `Log.i`，并 `handler.post` 一次到主线程派发事件。长串摩斯码时会放大主线程切换成本，建议移除热路径日志，并评估是否可以合并事件派发。

- [ ] 去掉 `stop()` 路径中的阻塞式等待  
  位置：`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:173-183`、`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlugin.kt:109-111`  
  说明：当前为满足最短播放时长，在 `playStop()` 里直接 `Thread.sleep()`。这会阻塞平台调用线程，影响停止响应。应把最小时长控制移到播放器工作线程内处理。

## 建议处理顺序

1. 先修复 `AudioTone.sampleRate` 未初始化问题。
2. 修 example 测试和 Android 原生单测，确保仓库内测试不再带模板残留。
3. 同步 README / README_CN / podspec 的发布信息和 API 名称。
4. 最后补充更有针对性的单测，覆盖构造参数、枚举值和时长计算。
5. 按优先级处理 Android 音频播放和事件流的性能优化项。

## 本次变更记录

- [x] 新增 `todo.md`，记录本次项目检查结果
- [x] 修复 `AudioTone.sampleRate` 未初始化问题
- [x] 修复 example 测试模板残留问题
- [x] 修复 Android 原生单测模板残留问题
- [x] 同步 podspec、README/README_CN、平台版本说明和枚举注释
- [x] 修复根包测试 mock 与平台接口不一致的问题
- [x] 修复 Android 插件独立 Gradle 测试缺少 Flutter classpath 的问题
