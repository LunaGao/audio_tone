package com.maomishen.audio_tone

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** AudioTonePlugin */
class AudioTonePlugin :
    FlutterPlugin,
    MethodCallHandler {
    
    // 音频播放器实例
    private var audioPlayer: AudioTonePlayer? = null
    
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "audio_tone")
        channel.setMethodCallHandler(this)
        
        // 初始化音频播放器（默认采样率44100Hz）
        audioPlayer = AudioTonePlayer(44100)
    }
    
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "audio_tone")
            val plugin = AudioTonePlugin()
            channel.setMethodCallHandler(plugin)
            
            // 初始化音频播放器
            plugin.audioPlayer = AudioTonePlayer(44100)
        }
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            
            "init" -> {
                // 初始化方法，Android版本不需要特殊处理
                result.success(0)
            }
            
            "setFrequency" -> {
                val frequency = call.argument<Int>("frequency") ?: 800
                audioPlayer?.setFrequency(frequency)
                result.success(0)
            }
            
            "setSpeed" -> {
                val wpm = call.argument<Int>("wpm") ?: 20
                audioPlayer?.setSpeed(wpm)
                result.success(0)
            }
            
            "setVolume" -> {
                val volume = call.argument<Double>("volume") ?: 1.0
                audioPlayer?.setVolume(volume)
                result.success(0)
            }
            
            "setDashDuration" -> {
                val dotTimes = call.argument<Int>("dotTimes") ?: 3
                audioPlayer?.setDashDuration(dotTimes)
                result.success(0)
            }
            
            "setDotDashIntervalDuration" -> {
                val dotTimes = call.argument<Int>("dotTimes") ?: 1
                audioPlayer?.setDotDashIntervalDuration(dotTimes)
                result.success(0)
            }
            
            "setOneWhiteSpaceDuration" -> {
                val dotTimes = call.argument<Int>("dotTimes") ?: 3
                audioPlayer?.setOneWhiteSpaceDuration(dotTimes)
                result.success(0)
            }
            
            "setTwoWhiteSpacesDuration" -> {
                val dotTimes = call.argument<Int>("dotTimes") ?: 7
                audioPlayer?.setTwoWhiteSpacesDuration(dotTimes)
                result.success(0)
            }
            
            "getDotDuration" -> {
                // Android版本返回基础时长
                result.success(0.12)
            }
            
            "getDashDuration" -> {
                // Android版本返回基础时长
                result.success(0.36)
            }
            
            "getDotDashIntervalDuration" -> {
                // Android版本返回基础时长
                result.success(0.12)
            }
            
            "getOneWhiteSpaceDuration" -> {
                // Android版本返回基础时长
                result.success(0.36)
            }
            
            "getTwoWhiteSpacesDuration" -> {
                // Android版本返回基础时长
                result.success(0.84)
            }
            
            "playMorseCode" -> {
                val morseCode = call.argument<String>("morseCode") ?: ""
                val resultCode = audioPlayer?.playMorseCode(morseCode) ?: -1
                result.success(resultCode)
            }
            
            "playNow" -> {
                audioPlayer?.playNow()
                result.success(0)
            }
            
            "playStop" -> {
                audioPlayer?.playStop()
                result.success(0)
            }
            
            "stopMorseCode" -> {
                audioPlayer?.stopMorseCode()
                result.success(0)
            }
            
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        
        // 清理音频播放器资源
        audioPlayer?.cleanup()
        audioPlayer = null
    }
}