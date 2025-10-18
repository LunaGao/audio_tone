package com.maomishen.audio_tone

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

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
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "init" -> {
                val sampleRate = call.arguments as Int
                audioPlayer = AudioTonePlayer(sampleRate)
                result.success(0)
            }
            
            "setFrequency" -> {
                val frequency = call.arguments as Int
                audioPlayer?.setFrequency(frequency)
                result.success(0)
            }
            
            "setSpeed" -> {
                val wpm = call.arguments as Int
                audioPlayer?.setSpeed(wpm)
                result.success(0)
            }
            
            "setVolume" -> {
                val volume = call.arguments as Double
                audioPlayer?.setVolume(volume)
                result.success(0)
            }
            
            "setDashDuration" -> {
                val dotTimes = call.arguments as Int
                audioPlayer?.setDashDuration(dotTimes)
                result.success(0)
            }
            
            "setDotDashIntervalDuration" -> {
                val dotTimes = call.arguments as Int
                audioPlayer?.setDotDashIntervalDuration(dotTimes)
                result.success(0)
            }
            
            "setOneWhiteSpaceDuration" -> {
                val dotTimes = call.arguments as Int
                audioPlayer?.setOneWhiteSpaceDuration(dotTimes)
                result.success(0)
            }
            
            "setTwoWhiteSpacesDuration" -> {
                val dotTimes = call.arguments as Int
                audioPlayer?.setTwoWhiteSpacesDuration(dotTimes)
                result.success(0)
            }

            "playMorseCode" -> {
                val morseCode = call.arguments as String
                val resultCode = audioPlayer?.playMorseCode(morseCode) ?: -1
                result.success(resultCode)
            }

            "stopMorseCode" -> {
                audioPlayer?.stopMorseCode()
                result.success(0)
            }

            "play" -> {
                audioPlayer?.playNow()
                result.success(0)
            }
            
            "stop" -> {
                audioPlayer?.playStop()
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