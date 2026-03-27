# audio_tone 当前待办

## Android 性能优化

- [ ] 优化持续音播放的缓冲策略  
  位置：`android/src/main/kotlin/com/maomishen/audio_tone/AudioTonePlayer.kt:146-169`  
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
