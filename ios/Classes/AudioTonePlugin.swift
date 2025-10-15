import Flutter
import UIKit

public class AudioTonePlugin: NSObject, FlutterPlugin {

  let audioTonePlayer = AudioTonePlayer()

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
//      let arguments = call.arguments as! [String: Any]
//      let sampleRate = arguments["sampleRate"] as! Int
//      let wpm = arguments["wpm"] as! Int
//      let dashDuration = arguments["dashDuration"] as! Int
//      let dotDashIntervalDuration = arguments["dotDashIntervalDuration"] as! Int
//      let wordsIntervalDuration = arguments["wordsIntervalDuration"] as! Int
//      let volume = arguments["volume"] as! Double
//      let waveformType = arguments["waveformType"] as! String
      // let audioTonePlayer = AudioTonePlayer()
      audioTonePlayer.playMorseCode(for: "A")
//      result(audioTonePlayer)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
