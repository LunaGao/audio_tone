import Flutter
import UIKit

public class AudioTonePlugin: NSObject, FlutterPlugin {

  var audioTonePlayer: AudioTonePlayer?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "audio_tone", binaryMessenger: registrar.messenger())
    let instance = AudioTonePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "init":
      let sampleRate = call.arguments as! Int
      if audioTonePlayer != nil {
        audioTonePlayer = nil
      }
      audioTonePlayer = AudioTonePlayer(sampleRate: Double(sampleRate))
    case "setFrequency":
      let frequency = call.arguments as! Int
      audioTonePlayer?.setFrequency(frequency)
      result(nil)
    case "setSpeed":
      let wpm = call.arguments as! Int
      audioTonePlayer?.setSpeed(wpm)
      result(nil)
    case "setDashDuration":
      let dotTimes = call.arguments as! Int
      audioTonePlayer?.setDashDuration(dotTimes)
      result(nil)
    case "setDotDashIntervalDuration":
      let dotTimes = call.arguments as! Int
      audioTonePlayer?.setDotDashIntervalDuration(dotTimes)
      result(nil)
    case "setOneWhiteSpaceDuration":
      let dotTimes = call.arguments as! Int
      audioTonePlayer?.setOneWhiteSpaceDuration(dotTimes)
      result(nil)
    case "setTwoWhiteSpacesDuration":
      let dotTimes = call.arguments as! Int
      audioTonePlayer?.setTwoWhiteSpacesDuration(dotTimes)
      result(nil)
    case "setVolume":
      let volume = call.arguments as! Double
      audioTonePlayer?.setVolume(Float(volume))
      result(nil)
    case "playMorseCode":
      let morseCode = call.arguments as! String
      result(audioTonePlayer?.playMorseCode(for: morseCode))
    case "play":
      audioTonePlayer?.playNow()
      result(nil)
    case "stop":
      audioTonePlayer?.playStop()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
