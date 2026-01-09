import Flutter
import UIKit

public class AudioTonePlugin: NSObject, FlutterStreamHandler, FlutterPlugin {

  var audioTonePlayer: AudioTonePlayer?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "audio_tone", binaryMessenger: registrar.messenger())
    let instance: AudioTonePlugin = AudioTonePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let streamChannel = FlutterEventChannel(name: "audio_tone_event", binaryMessenger: registrar.messenger())
    streamChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
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
    case "setLightFlashingMagnificationFactor":
      let factor = call.arguments as! Double
      audioTonePlayer?.setLightFlashingMagnificationFactor(factor)
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
    case "getMorseCodePlayDuration":
      let morseCode = call.arguments as! String
      let duration = audioTonePlayer?.getPlayDuration(morseCode) ?? 0.0
      result(duration)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  var eventSink: FlutterEventSink?
  // Handle events on the main thread.
  var timer = Timer()
  var morseCode: String?

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    // self.eventSink = events
    // return nil
    print("onListen......")
    self.eventSink = events

    let returnValue = audioTonePlayer?.playMorseCodeWithoutAudio(for: arguments! as? String ?? "", eventSink :events)
    if(returnValue == 0) {
      return nil
    } else {
      return FlutterError(code: "\(returnValue, default: "11")", message: nil, details: nil)
    }

//      self.timer.invalidate()
//      self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
//          let dateFormat = DateFormatter()
//          dateFormat.dateFormat = "HH:mm:ss"
//          let time = dateFormat.string(from: Date())
//          print(time)
//          events(time + (arguments! as? String ?? "not-found"))
//      })
//      
//    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    print("onCancel......")
    eventSink = nil
    return nil
  }
}
