# 新功能规划：playTimings —— 传入毫秒数组播放摩斯码

## 需求描述

新增一个方法 `playTimings(List<int> timings)`，接受一个毫秒时长数组：
- 索引 0（偶数）：发音（tone on）
- 索引 1（奇数）：静音（tone off）
- 以此类推交替

这是对现有 `playMorseCode(String)` 的底层替代：调用方自己负责将摩斯码翻译成时序，插件只负责按时序播放/静音。

## 需要修改的层次（由内到外）

### 1. Android — `AudioTonePlayer.kt`

**新增方法：**
```kotlin
fun playTimings(timings: List<Long>): Int
```
- 如果 `isPlaying` 返回 1。
- 如果 `isTapPlaying` 先调 `stopTapPlaying()`。
- 在 `executor` 线程中遍历 timings：
  - 偶数索引：调 `ensureAudioTrack()` + 写入对应毫秒的 tone PCM 数据 → `audioTrack.play()`
  - 奇数索引：不要只靠 `Thread.sleep(ms)` 静音；应像现有 `playMorseCode` 一样写入对应毫秒的静音 PCM 数据，否则 `AudioTrack` 容易发生 underrun，时序和听感都会不稳定
- 播完后结束播放并设 `isPlaying = false`。

**实现修正：**
- 当前代码库里没有现成的 `finishPlayback()`；如果要抽 helper，需要新增一个真正适用于序列播放的收尾逻辑，或者复用现有 `resetTrack(audioTrack)` 路径。
- `playTimings` 入口需要先校验 `timings`：空数组返回错误码；负数时长必须直接拒绝，不能继续换算 frameCount，否则 Android 端可能出现负长度数组异常。
- `0ms` 片段建议明确策略：要么允许并跳过，要么统一返回错误码，避免两端行为不一致。

**可复用的现有工具：**
- `generateToneData(durationSeconds: Double)` — 传入 `ms / 1000.0` 即可生成对应帧数的 PCM。
- `generateSilenceData(durationSeconds: Double)` — Android 端静音段应复用这个思路，而不是 sleep。
- `ensureAudioTrack()` — 可直接复用，但收尾逻辑需要按当前代码结构补齐。

### 2. iOS — `AudioTonePlayer.swift`

**新增方法：**
```swift
func playTimings(_ timings: [Int]) -> Int
```
- guard `!isPlaying`，否则返回 1。
- 如果 `isTapPlaying` 先调 `stopTapPlayback()`。
- 调 `ensureAudioEngineRunning()`。
- 遍历 timings，交替：
  - 偶数索引：用现有 tone buffer 生成逻辑生成对应 frameCount 的 PCMBuffer，`playerNode.scheduleBuffer()`
  - 奇数索引：用现有 silence buffer 生成逻辑生成静音 PCMBuffer，`playerNode.scheduleBuffer()`
- 全部 buffer schedule 完毕后，调 `playerNode.play()`，在最后一个 buffer 的 completionHandler 中设 `isPlaying = false`，调 `deactivateAudioSession()`。

**可复用的现有工具：**
- `toneBufferCache` / `silenceBufferCache` — 已有按 frameCount+frequency 缓存的 buffer，直接复用。
- `playSymbols(_:index:)` 内部的 `scheduleBuffer` 模式 — 新方法照搬这个递归/迭代模式即可。
- `ensureAudioEngineRunning()` / `deactivateAudioSession()`。

**实现修正：**
- 当前代码库里并没有 `makeToneBuffer(frameCount:)` / `makeSilenceBuffer(frameCount:)` 这两个 helper，现有实现实际是按 `duration` 生成 buffer；要么补 frameCount 版 helper，要么文档直接改成基于现有方法实现。
- `timings` 同样需要先校验空数组、负数和 `0ms` 策略，避免生成异常 frameCount 或出现两端行为不一致。

### 3. Android — `AudioTonePlugin.kt`

在 `onMethodCall` 的 `when` 分支新增：
```kotlin
"playTimings" -> {
    val timings = (call.arguments as? List<*>)?.mapNotNull { (it as? Number)?.toLong() } ?: emptyList()
    result.success(audioTonePlayer.playTimings(timings))
}
```

**实现修正：**
- 不建议直接用 `call.arguments<List<Long>>()`。Dart 的 `List<int>` 通过 MethodChannel 传到 Android 后，元素运行时类型通常是 `Int`，不是稳定的 `Long`；直接按 `List<Long>` 取值有概率在运行时报类型错误。
- 更稳妥的做法是先按 `List<*>` / `List<Number>` 接，再显式转成 `Long`。

### 4. iOS — `AudioTonePlugin.swift`

在 `handle(_ call:)` 的 `switch` 新增：
```swift
case "playTimings":
    let timings = call.arguments as? [Int] ?? []
    result(audioTonePlayer?.playTimings(timings) ?? -1)
```

### 5. Dart — `AudioTonePlatform`（`lib/audio_tone_platform_interface.dart`）

新增抽象方法：
```dart
Future<int> playTimings(List<int> timings);
```

### 6. Dart — `MethodChannelAudioTone`（`lib/audio_tone_method_channel.dart`）

实现该方法，通过 MethodChannel 传递：
```dart
@override
Future<int> playTimings(List<int> timings) async {
  return await methodChannel.invokeMethod<int>('playTimings', timings) ?? -1;
}
```

### 7. Dart — `AudioTone`（`lib/audio_tone.dart`）

新增公共方法：
```dart
/// 按毫秒时序播放音调序列
/// [timings] 毫秒数组，偶数索引发音，奇数索引静音
Future<int> playTimings(List<int> timings) async {
  return await AudioTonePlatform.instance.playTimings(timings);
}
```

## 不需要修改的部分

- `playMorseCode` / `playStream` / `play` / `stop` —— 保持原样，新方法是独立添加。
- 所有 WPM / dash / dot 参数配置方法。
- `preprocessMorseCode` 逻辑。
- `EventChannel` / stream 相关逻辑。

## 当前方案需要补充的约束

- `timings` 的合法输入范围要写清楚：是否允许 `0`，是否允许超大值，是否必须从发音段开始。
- 负数时长必须视为非法输入；这不是“边界情况”，而是会导致原生层异常的输入。
- 如果 `playTimings` 是新的序列播放能力，需要明确它是否应该被现有 `stop()` 中断。当前项目中的 `stop()` 主要用于持续按压音播放，不等价于停止序列播放。

## 可能的影响与注意事项

| 问题 | 说明 |
|---|---|
| 并发冲突 | `playTimings` 与现有 `playMorseCode` 共用 `isPlaying` flag，需确保互斥 |
| Android 静音实现 | 不能只靠 `Thread.sleep(ms)` 表示静音；当前项目的 AudioTrack 模型应持续写入 tone/silence PCM，否则会有 underrun 风险 |
| iOS buffer 调度精度 | AVAudioEngine scheduleBuffer 连续调度精度很高，buffer 之间无间隙，优于 Android |
| 空数组 | 应返回错误码（如 2），不崩溃 |
| 负数时长 | 必须提前拦截；否则 frameCount 计算可能导致 Android/iOS 原生层异常 |
| `0ms` 策略 | 需要定义为“允许并跳过”还是“非法输入”，否则两端实现容易分叉 |
| 单元素数组 | 只播一段音，正常处理 |
| Android 参数桥接 | MethodChannel 传过来的 `List<int>` 不应直接按 `List<Long>` 强取，需显式按 `Number` 转换 |
| helper 不匹配 | 文档引用的 `finishPlayback()`、`makeToneBuffer(frameCount:)`、`makeSilenceBuffer(frameCount:)` 当前代码库并不存在，需要改文档或先补 helper |
| `stop()` 语义 | 需要确认 `playTimings` 播放中调用现有 `stop()` 是否应该生效；当前 `stop()` 更偏向停止持续音 |
| 版本号 | 新增公共 API，需 bump minor version（0.0.8 → 0.1.0 或 0.0.9，视团队规范） |
| CHANGELOG / README | 需补充新方法的说明 |

## 验证方式

1. 在 example app 中调用：
   ```dart
   await audioTone.playTimings([200, 100, 600, 100, 200]); // 短-长间隔-短
   ```
2. 用标准摩斯码 `·-` (A) 对比：
   - 现有：`audioTone.playMorseCode('.-')`
   - 新方式：`audioTone.playTimings([120, 120, 360])`（以10WPM点=120ms为例）
3. 运行 `flutter analyze` 无新错误。
4. 运行 `flutter test` 通过，并至少补一条 MethodChannel 测试，验证 `playTimings` 的参数和方法名是否正确传递。
5. 增加边界验证：
   - `[]` 返回预期错误码
   - `[200]` 可以正常播放单段发音
   - `[200, 0, 200]` 按约定行为处理
   - `[200, -1, 200]` 被拒绝，不进入原生播放流程
