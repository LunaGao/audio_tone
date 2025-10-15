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
      let arguments = call.arguments as! [String: Any]
      let sampleRate = arguments["sampleRate"] as! Int
      if audioTonePlayer != nil {
        audioTonePlayer = nil
      }
      audioTonePlayer = AudioTonePlayer(sampleRate: Double(sampleRate))
    case "setFrequency":
      let arguments = call.arguments as! [String: Any]
      let frequency = arguments["frequency"] as! Int
      audioTonePlayer?.setFrequency(frequency)
      result(nil)
    case "setSpeed":
      let arguments = call.arguments as! [String: Any]
      let wpm = arguments["wpm"] as! Int
      audioTonePlayer?.setSpeed(wpm)
      result(nil)
    case "setDashDuration":
      let arguments = call.arguments as! [String: Any]
      let ditTimes = arguments["dashDuration"] as! Int
      audioTonePlayer?.setDashDuration(ditTimes)
      result(nil)
    case "setDotDashIntervalDuration":
      let arguments = call.arguments as! [String: Any]
      let ditTimes = arguments["dotDashIntervalDuration"] as! Int
      audioTonePlayer?.setDotDashIntervalDuration(ditTimes)
      result(nil)
    case "setWordsIntervalDuration":
      let arguments = call.arguments as! [String: Any]
      let ditTimes = arguments["wordsIntervalDuration"] as! Int
      audioTonePlayer?.setWordsIntervalDuration(ditTimes)
      result(nil)
    case "setVolume":
      let arguments = call.arguments as! [String: Any]
      let volume = arguments["volume"] as! Double
      audioTonePlayer?.setVolume(Float(volume))
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
