# audio_tone 当前待办

## Android 性能优化

- [x] 优化持续音播放的缓冲策略  
  位置：`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:146-169`  
  说明：已将持续音循环缓冲从约 10ms 提升到 200ms，并在写入循环里增加失败退出保护，降低 `WRITE_BLOCKING` 调用频率和线程唤醒成本。

- [x] 减少摩斯码播放时的音频数组分配和正弦波重复计算  
  位置：`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:356-387`  
  说明：已为 tone/silence 数据增加缓存，按 `frameCount` 和 `frequency` 复用已生成的 `FloatArray`，减少摩斯码播放和持续音播放中的对象分配与波形重复计算。

- [x] 复用 `AudioTrack`，避免频繁创建和释放  
  位置：`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:155-169`、`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:317-346`、`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:188-209`  
  说明：已改为按需创建并复用 `audioTrack` / `tapAudioTrack`，日常停止只做重置，`cleanup()` 才真正释放，减少了频繁创建/释放带来的 native 资源抖动。

- [x] 精简 `playStream` 热路径中的日志和主线程事件派发  
  位置：`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:238-283`  
  说明：已移除 `playStream` 热路径中的高频日志，只在存在实际事件时才切主线程派发，并跳过结束符的无意义事件，减少主线程切换和日志 I/O。

- [x] 去掉 `stop()` 路径中的阻塞式等待  
  位置：`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:173-183`、`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlugin.kt:109-111`  
  说明：`playStop()` 已改为发送停止请求，由音频写入线程在满足最小时长后自行收尾，不再阻塞平台调用线程。

## iOS 性能优化

- [x] 复用 `AVAudioPCMBuffer`，避免在摩斯码播放热路径里重复生成 tone/silence 数据  
  位置：`ios/Classes/AudioTonePlayer.swift:4-42`、`ios/Classes/AudioTonePlayer.swift:140-147`、`ios/Classes/AudioTonePlayer.swift:574-623`  
  说明：已引入 `ToneBufferKey`、共享 `audioFormat`、tone/silence buffer 缓存；摩斯码和持续音路径现在会优先复用已生成的 `AVAudioPCMBuffer`，不再在每个符号播放时重复创建格式对象和逐采样计算波形。

- [x] 去掉 iOS `play()` / `stop()` 路径中的阻塞式 `Thread.sleep`  
  位置：`ios/Classes/AudioTonePlayer.swift:422-496`  
  说明：已移除 `playNow()` / `playStop()` 中的阻塞式等待，改为通过 `pendingTapStopWorkItem` 和 `tapPlaybackSessionId` 实现可取消的异步停止；新的播放会话会主动取消旧的延迟 stop，避免平台调用线程被 `sleep` 阻塞。

- [x] 复用 `AVAudioEngine` / `AVAudioSession` 生命周期，避免 stop 或重新 init 时频繁停启  
  位置：`ios/Classes/AudioTonePlugin.swift:18-27`、`ios/Classes/AudioTonePlayer.swift:45-47`、`ios/Classes/AudioTonePlayer.swift:112-182`、`ios/Classes/AudioTonePlayer.swift:320-329`、`ios/Classes/AudioTonePlayer.swift:583-603`  
  说明：已为 iOS 侧增加 session 配置/激活状态管理，并将资源释放收敛到 `cleanup()`；同采样率重复 `init` 会直接复用现有 player，普通 `stopMorseCode()` 不再停止 `AVAudioEngine` 或取消激活 `AVAudioSession`，只在真正销毁时释放。

- [x] 精简 `playStream` 热路径中的主线程调度和日志输出  
  位置：`ios/Classes/AudioTonePlayer.swift:339-463`、`ios/Classes/AudioTonePlugin.swift:75-91`  
  说明：已移除 `playStream` 热路径和 `onListen` / `onCancel` 的无条件日志，引入串行 `streamEventQueue` 与 `streamPlaybackSessionId` 管理事件推进和取消；事件节奏调度不再依赖主线程，只在最终派发 `eventSink` 时回到主线程。

- [x] 避免参数更新时重复向 `tapPlayerNode` 安排循环缓冲  
  位置：`ios/Classes/AudioTonePlayer.swift:102-108`、`ios/Classes/AudioTonePlayer.swift:491-505`、`ios/Classes/AudioTonePlayer.swift:544-551`  
  说明：`upgradeDuration()` 现在只标记 `tapToneNeedsScheduling`，不再立刻重复 `scheduleBuffer(..., .loops)`；持续音缓冲改为在 `playNow()` 之前按需重建并重新排程，避免节点上累积循环 buffer。

## 本轮总结

- 已完成 5 项 Android 侧性能优化，覆盖持续音播放、摩斯码音频生成、`AudioTrack` 生命周期、`playStream` 事件热路径，以及 `stop()` 的阻塞调用路径。
- 当前优化方向主要集中在减少高频 `AudioTrack.write()` 调用、降低 `FloatArray` 分配和正弦波重复计算、减少主线程事件切换，以及避免平台调用线程被 `sleep` 阻塞。
- 已完成的验证：
  - `android/./gradlew test`：通过
  - iOS 原生逻辑已完成本地静态检查与代码路径复核，但当前环境下 `xcodebuild` 无法连接 `CoreSimulatorService`，未能完成自动化编译验证
- 当前代码状态：
  - Android 播放路径已从“频繁创建对象和阻塞停止”调整为“缓存复用、后台收尾、低频写入”。
  - `todo.md` 中原定的 Android 性能优化项已全部完成。
  - iOS 侧列出的 5 项性能优化已全部完成，覆盖停止路径去阻塞、buffer 缓存复用、`playStream` 热路径瘦身、`AVAudioEngine`/`AVAudioSession` 生命周期复用，以及 tap 循环缓冲按需排程。

## 后续观察项

- 建议在真机上补做一次长按播放和长串摩斯码播放测试，重点观察：
  - 首次发声延迟是否有变化
  - 快速按下/抬起时是否仍满足预期最短播放时长
  - 长串 `playStream` 是否存在事件节奏漂移
- 如果后续还要继续优化，优先考虑补性能基准或埋点，而不是继续凭直觉改动底层播放逻辑。
