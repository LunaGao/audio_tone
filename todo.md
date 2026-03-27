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

## 本轮总结

- 已完成 5 项 Android 侧性能优化，覆盖持续音播放、摩斯码音频生成、`AudioTrack` 生命周期、`playStream` 事件热路径，以及 `stop()` 的阻塞调用路径。
- 当前优化方向主要集中在减少高频 `AudioTrack.write()` 调用、降低 `FloatArray` 分配和正弦波重复计算、减少主线程事件切换，以及避免平台调用线程被 `sleep` 阻塞。
- 已完成的验证：
  - `android/./gradlew test`：通过
- 当前代码状态：
  - Android 播放路径已从“频繁创建对象和阻塞停止”调整为“缓存复用、后台收尾、低频写入”。
  - `todo.md` 中原定的 Android 性能优化项已全部完成。

## 后续观察项

- 建议在真机上补做一次长按播放和长串摩斯码播放测试，重点观察：
  - 首次发声延迟是否有变化
  - 快速按下/抬起时是否仍满足预期最短播放时长
  - 长串 `playStream` 是否存在事件节奏漂移
- 如果后续还要继续优化，优先考虑补性能基准或埋点，而不是继续凭直觉改动底层播放逻辑。
