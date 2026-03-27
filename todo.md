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

- [ ] 去掉 `stop()` 路径中的阻塞式等待  
  位置：`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:173-183`、`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlugin.kt:109-111`  
  说明：当前为满足最短播放时长，在 `playStop()` 里直接 `Thread.sleep()`。这会阻塞平台调用线程，影响停止响应。应把最小时长控制移到播放器工作线程内处理。
