package com.maomishen.audio_tone

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel

/** AudioTonePlugin */
class AudioTonePlugin :
    FlutterPlugin,
    MethodCallHandler,
    EventChannel.StreamHandler {
    
    // 音频播放器实例
    private var audioPlayer: AudioTonePlayer? = null
    
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "audio_tone")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "audio_tone_event")
        eventChannel.setStreamHandler(this)
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

            "setLightFlashingMagnificationFactor" -> {
                val factor = call.arguments as Double
                audioPlayer?.setLightFlashingMagnificationFactor(factor)
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
            "getMorseCodePlayDuration" -> {
                val morseCode = call.arguments as String
                val duration = audioPlayer?.getMorseCodePlayDuration(morseCode) ?: 0.0
                result.success(duration)
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

    // Declare our eventSink later it will be initialized
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        eventSink = sink

        try {
            val morseCode = arguments as? String
            if (morseCode != null) {
                val returnValue = audioPlayer?.playMorseCodeWithoutAudio(morseCode, eventSink)
            } else {
                sink.error("INVALID_ARGUMENTS", "Morse code must be provided", null)
            }
        } catch (e: Exception) {
            sink.error("PLAYBACK_ERROR", "Failed to start morse code playback: ${e.message}", null)
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        // 停止摩斯码播放
        audioPlayer?.stopMorseCode()
    }
}