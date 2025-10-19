package com.maomishen.audio_tone

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import android.os.Build
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import kotlin.math.sin
import kotlin.math.PI
import kotlin.math.max
import kotlin.math.min

class AudioTonePlayer(private val sampleRate: Int) {
    // 音频配置
    private var frequency: Double = 800.0 // 蜂鸣频率，Hz
    
    // 点、划、点划之间、字母、单词之间的倍数关系
    private var dashDotTimes: Int = 3 // 划的时长，点的倍数
    private var dotDashIntervalDotTimes: Int = 1 // 点划之间的时长，点的倍数
    private var oneWhiteSpaceDotTimes: Int = 3 // 单空格的间隔，点的倍数（用于字母之间）
    private var twoWhiteSpacesDotTimes: Int = 7 // 双空格的间隔，点的倍数（用于单词之间）
    
    // 点、划、点划之间、字母、单词之间的时长
    private var dotDuration: Double = 0.12 // 点的时长，秒（基础时长）
    private var dashDuration: Double = 0.36 // 划的时长，秒
    private var dotDashDuration: Double = 0.12 // 点划之间的时长，秒
    private var oneWhiteSpaceDuration: Double = 0.36 // 单空格的间隔，秒
    private var twoWhiteSpacesDuration: Double = 0.84 // 双空格的间隔，秒
    
    private var volume: Float = 1.0f // 音量，0.0到1.0之间
    
    // 音频组件
    private var audioTrack: AudioTrack? = null
    private var tapAudioTrack: AudioTrack? = null
    private var isPlaying = false
    private var isTapPlaying = false // 专门跟踪 tapPlayerNode 的播放状态
    
    // 线程池
    private val executor: ScheduledExecutorService = Executors.newSingleThreadScheduledExecutor()
    private var playStartTime: Long = 0
    private val minimumPlayTime: Long = 50 // 最小播放时间，毫秒
    
    // 音频配置常量
    private val channelConfig = AudioFormat.CHANNEL_OUT_MONO
    private val audioFormat = AudioFormat.ENCODING_PCM_FLOAT

    // MARK: - 音频基础设置
    
    // 设置频率
    fun setFrequency(frequency: Int) {
        this.frequency = frequency.toDouble()
    }
    
    // 设置速度（每分钟单词数）
    fun setSpeed(wpm: Int) {
        val calculatedWpm = (60.0 / wpm.toDouble()) / 50.0
        this.dotDuration = calculatedWpm
        upgradeDuration()
    }
    
    // 设置音量
    fun setVolume(volume: Double) {
        this.volume = volume.toFloat()
        audioTrack?.setVolume(volume.toFloat())
        tapAudioTrack?.setVolume(volume.toFloat())
    }
    
    // MARK: - 时长设置
    
    // 设置划的时长（点的倍数）
    fun setDashDuration(dotTimes: Int) {
        this.dashDotTimes = dotTimes
        upgradeDuration()
    }
    
    // 设置点与划之间的间隔时长（点的倍数）
    fun setDotDashIntervalDuration(dotTimes: Int) {
        this.dotDashIntervalDotTimes = dotTimes
        upgradeDuration()
    }
    
    // 设置单空格的间隔，点的倍数（用于字母之间）
    fun setOneWhiteSpaceDuration(dotTimes: Int) {
        this.oneWhiteSpaceDotTimes = dotTimes
        upgradeDuration()
    }
    
    // 设置双空格的间隔，点的倍数（用于单词之间）
    fun setTwoWhiteSpacesDuration(dotTimes: Int) {
        this.twoWhiteSpacesDotTimes = dotTimes
        upgradeDuration()
    }
    
    // 更新时间配置
    private fun upgradeDuration() {
        this.dashDuration = this.dashDotTimes * this.dotDuration
        this.dotDashDuration = this.dotDashIntervalDotTimes * this.dotDuration
        this.oneWhiteSpaceDuration = this.oneWhiteSpaceDotTimes * this.dotDuration
        this.twoWhiteSpacesDuration = this.twoWhiteSpacesDotTimes * this.dotDuration
    }
    
    // MARK: - 播放控制
    
    // 播放摩斯码
    fun playMorseCode(morseCode: String): Int {
        if (isPlaying) {
            // println("正在播放中，请等待完成")
            return 1
        }
        
        // 如果 tapAudioTrack 正在播放，先停止它
        if (isTapPlaying) {
            stopTapPlaying()
        }
        
        if (morseCode.isEmpty()) {
            // println("错误: 输入文本为空")
            return 2
        }
        
        // 检查输入是否只包含有效字符
        if (!morseCode.all { it == '.' || it == '-' || it == ' ' }) {
            // println("错误: 输入包含无效字符")
            return 3
        }
        
        val symbols = preprocessMorseCode(morseCode)
        
        isPlaying = true
        playSymbols(symbols)
        return 0
    }
    
    // 播放（持续音调）
    fun playNow() {
        if (isTapPlaying) {
            stopTapPlaying()
        }
        
        playStartTime = System.currentTimeMillis()
        isTapPlaying = true
        
        // 创建音频轨道
        createTapAudioTrack()
        
        // 生成持续音调（生成2秒的音频数据用于循环，减少拼接频率）
        val toneData = generateToneData(0.01) // 2秒循环数据，减少缓冲区压力
        
        // 开始播放
        tapAudioTrack?.play()

        // 循环写入数据以维持持续播放
        executor.execute {
             while (isTapPlaying) {
                 tapAudioTrack?.write(toneData, 0, toneData.size, AudioTrack.WRITE_BLOCKING)
             }
        }
    }
    
    // 停止播放
    fun playStop() {
        // 检查是否满足最少播放时间要求
        val currentTime = System.currentTimeMillis()
        val elapsedTime = currentTime - playStartTime
        
        if (elapsedTime < minimumPlayTime && isTapPlaying) {
            // 如果播放时间不足[minimumPlayTime]ms，等待剩余时间
            val remainingTime = minimumPlayTime - elapsedTime
            // println("播放时间不足${minimumPlayTime}ms，等待 ${remainingTime}ms")
            Thread.sleep(remainingTime)
        }
        
        stopTapPlaying()
    }
    
    // 停止摩斯码播放
    fun stopMorseCode() {
        isPlaying = false
        isTapPlaying = false
        
        audioTrack?.stop()
        audioTrack?.release()
        audioTrack = null
        
        tapAudioTrack?.stop()
        tapAudioTrack?.release()
        tapAudioTrack = null
    }
    
    // 停止tap播放
    private fun stopTapPlaying() {
        isTapPlaying = false
        playStartTime = 0
        
        tapAudioTrack?.stop()
        tapAudioTrack?.release()
        tapAudioTrack = null
    }
    
    // MARK: - 私有方法
    
    // 预处理摩斯码内容
    private fun preprocessMorseCode(morseCode: String): String {
        var processed = morseCode.trim()
        
        // 连续双空格替换为t（two的首字母）
        processed = processed.replace("  ", "t")
        
        // 单空格替换为o（one的首字母）
        processed = processed.replace(" ", "o")
        
        // 点和划之间增加i (interval的首字母)
        val result = StringBuilder()
        for (i in processed.indices) {
            result.append(processed[i])
            if (i < processed.length - 1 && 
                ((processed[i] == '.' || processed[i] == '-') && 
                 (processed[i + 1] == '.' || processed[i + 1] == '-'))) {
                result.append('i')
            }
        }
        
        return result.toString()
    }
    
    // 播放符号序列
    private fun playSymbols(symbols: String) {        
        executor.execute {
            try {
                createAudioTrack()
                // 先启动播放，然后立即预填充
                audioTrack?.play()
                for (char in symbols) {
                    if (!isPlaying) break
                    
                    val duration = when (char) {
                        '.' -> dotDuration
                        '-' -> dashDuration
                        'i' -> dotDashDuration
                        'o' -> oneWhiteSpaceDuration
                        't' -> twoWhiteSpacesDuration
                        else -> continue
                    }

//                    println("$char:$duration")
                    
                    if (char == '.' || char == '-') {
                        // 播放音调
                        playTone(duration)
                    } else {
                        // 播放静音
                        playSilence(duration)
                    }
                }
                playSilence(0.5)
                // println("Stop！")
                audioTrack?.stop()
                audioTrack?.release()
                audioTrack = null
                isPlaying = false
                
            } catch (e: Exception) {
                // println("播放摩斯码错误: ${e.message}")
                isPlaying = false
            }
        }
    }
    
    // 播放音调
    private fun playTone(duration: Double) {
        val toneData = generateToneData(duration)
        // println("toneData:" + toneData.size)
        audioTrack?.write(toneData, 0, toneData.size, AudioTrack.WRITE_BLOCKING)
    }
    
    // 播放静音
    private fun playSilence(duration: Double) {
        val silenceData = generateSilenceData(duration)
        // println("silenceData:" + silenceData.size)
        audioTrack?.write(silenceData, 0, silenceData.size, AudioTrack.WRITE_BLOCKING)
    }
    
    // 生成音调数据
    private fun generateToneData(duration: Double): FloatArray {
        val frameCount = (duration * sampleRate).toInt()
        val data = FloatArray(frameCount)
        
        for (i in 0 until frameCount) {
            val time = i.toDouble() / sampleRate.toDouble()
            data[i] = sin(2 * PI * frequency * time).toFloat()
        }
        
        // println("生成音调: ${duration}秒, 频率: ${frequency}Hz, 采样数: ${frameCount}")
        return data
    }
    
    // 生成静音数据
    private fun generateSilenceData(duration: Double): FloatArray {
        val frameCount = (duration * sampleRate).toInt()
        return FloatArray(frameCount) // 默认值为0.0
    }
    
    // 创建音频轨道
    private fun createAudioTrack() {
        val bufferSize = AudioTrack.getMinBufferSize(sampleRate, channelConfig, audioFormat)
        // 16048
        audioTrack = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            AudioTrack.Builder()
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                .setAudioFormat(
                    AudioFormat.Builder()
                        .setEncoding(audioFormat)
                        .setSampleRate(sampleRate)
                        .setChannelMask(channelConfig)
                        .build()
                )
                .setBufferSizeInBytes(bufferSize)
                .setTransferMode(AudioTrack.MODE_STREAM)
                .build()
        } else {
            @Suppress("DEPRECATION")
            AudioTrack(
                AudioManager.STREAM_MUSIC,
                sampleRate,
                channelConfig,
                audioFormat,
                bufferSize,
                AudioTrack.MODE_STREAM
            )
        }
        
        audioTrack?.setVolume(volume)
    }
    
    // 创建持续音调音频轨道
    private fun createTapAudioTrack() {
        val bufferSize = AudioTrack.getMinBufferSize(sampleRate, channelConfig, audioFormat)

        tapAudioTrack = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            AudioTrack.Builder()
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                .setAudioFormat(
                    AudioFormat.Builder()
                        .setEncoding(audioFormat)
                        .setSampleRate(sampleRate)
                        .setChannelMask(channelConfig)
                        .build()
                )
                .setBufferSizeInBytes(bufferSize)
                .setTransferMode(AudioTrack.MODE_STREAM)
                .build()
        } else {
            @Suppress("DEPRECATION")
            AudioTrack(
                AudioManager.STREAM_MUSIC,
                sampleRate,
                channelConfig,
                audioFormat,
                bufferSize,
                AudioTrack.MODE_STREAM
            )
        }
        
        tapAudioTrack?.setVolume(volume)
    }
    
    // 清理资源
    fun cleanup() {
        stopMorseCode()
        executor.shutdown()
    }
    
    // 获取摩斯码播放时长
    fun getMorseCodePlayDuration(morseCode: String): Double {
        val symbols = preprocessMorseCode(morseCode)
        var duration = 0.0
        
        // 遍历处理后的符号，计算总时长
        for (char in symbols) {
            duration += when (char) {
                '.' -> dotDuration
                '-' -> dashDuration
                'i' -> dotDashDuration
                'o' -> oneWhiteSpaceDuration
                't' -> twoWhiteSpacesDuration
                else -> 0.0
            }
        }
        
        return duration
    }
}