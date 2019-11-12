import UIKit
import Flutter
import Lottie

public class LottieView : NSObject, FlutterPlatformView {
   let frame : CGRect
   let viewId : Int64
   
   var animationView: AnimationView?
   var testStream : TestStreamHandler?
   var delegates : [AnyValueProvider]
   var registrarInstance : FlutterPluginRegistrar
    var loopMode : LottieLoopMode
   
   
   init(_ frame: CGRect, viewId: Int64, args: Any?, registrarInstance : FlutterPluginRegistrar) {
    self.frame = frame
    self.viewId = viewId
    self.registrarInstance = registrarInstance
    self.delegates = []
    self.loopMode = .playOnce
      
    super.init()
      
    self.create(args: args)
   }
   
   func create(args: Any?) {
      
      let channel : FlutterMethodChannel = FlutterMethodChannel.init(name: "convictiontech/flutter_lottie_" + String(viewId), binaryMessenger: self.registrarInstance.messenger())
      let handler : FlutterMethodCallHandler = methodCall;
      channel.setMethodCallHandler(handler)
      
      let testChannel = FlutterEventChannel(name: "convictiontech/flutter_lottie_stream_playfinish_"  + String(viewId), binaryMessenger: self.registrarInstance.messenger())
      self.testStream  = TestStreamHandler()
      testChannel.setStreamHandler(testStream as? FlutterStreamHandler & NSObjectProtocol)
      
      
      if let argsDict = args as? Dictionary<String, Any> {
         let filePath = argsDict["filePath"] as? String ?? nil;
         
         if filePath != nil {
            print("THIS IS THE ID " + String(viewId) + " " + filePath!)
            let key = self.registrarInstance.lookupKey(forAsset: filePath!)
            let path = Bundle.main.path(forResource: key, ofType: nil)
            self.animationView = AnimationView(filePath: path!)
         }
         
         let loop = argsDict["loop"] as? Bool ?? false
         let reverse = argsDict["reverse"] as? Bool ?? false
         let autoPlay = argsDict["autoPlay"] as? Bool ?? false
        
        if (loop) {
            loopMode = reverse ? .autoReverse : .loop;
        } else {
            loopMode = .playOnce
        }
         
         
        self.animationView?.loopMode = loopMode
        if(autoPlay) {
            self.animationView?.play(completion: completionBlock);
         }
         
      }
      
   }
   
   public func view() -> UIView {
      return animationView!
   }
   
   public func completionBlock(animationFinished : Bool) -> Void {
      if let ev : FlutterEventSink = self.testStream!.event {
         ev(animationFinished)
      }
   }
   
   
   func methodCall( call : FlutterMethodCall, result: FlutterResult ) {
      var props : Dictionary<String, Any>  = [String: Any]()
      
      if let args = call.arguments as? Dictionary<String, Any> {
         props = args
      }
      
      if(call.method == "play") {
         self.animationView?.currentProgress = 0
         self.animationView?.play(completion: completionBlock);
      }
      
      if(call.method == "resume") {
         self.animationView?.play(completion: completionBlock);
      }
      
      if(call.method == "playWithProgress") {
         let toProgress = props["toProgress"] as! CGFloat
         if let fromProgress = props["fromProgress"] as? CGFloat {
            self.animationView?.play(fromProgress: fromProgress, toProgress: toProgress, completion: completionBlock)
         } else {
            self.animationView?.play(toProgress: toProgress, completion: completionBlock);
         }
      }
      
      
      if(call.method == "playWithFrames") {
        let toFrame = props["toFrame"] as! CGFloat
        let loopMode = props["loopMode"] as? String
        
        let _loopMode = parseLoopMode(value: loopMode)
        
        if let fromFrame = props["fromFrame"] as? CGFloat {
            self.animationView?.play(fromFrame: fromFrame, toFrame: toFrame, loopMode: _loopMode, completion: completionBlock);
        } else {
            self.animationView?.play(toFrame: toFrame, loopMode: _loopMode, completion: completionBlock);
        }
      }
      
      if(call.method == "stop") {
         self.animationView?.stop();
      }
      
      if(call.method == "pause") {
         self.animationView?.pause();
      }
      
      if(call.method == "setAnimationSpeed") {
         self.animationView?.animationSpeed = props["speed"] as! CGFloat
      }
      
      if(call.method == "setAnimationProgress") {
        let progress = props["progress"] as! CGFloat
        self.animationView?.play(toProgress: progress)
      }
      
      if(call.method == "setProgressWithFrame") {
        let frame = props["frame"] as! CGFloat
        self.animationView?.play(toFrame: frame)
      }
      
      if(call.method == "isAnimationPlaying") {
         let isAnimationPlaying = self.animationView?.isAnimationPlaying
         result(isAnimationPlaying)
      }
      
      if(call.method == "getAnimationDuration") {
        let animationDuration = self.animationView?.currentTime
        result(animationDuration)
      }
      
      if(call.method == "getAnimationProgress") {
        let animationProgress = self.animationView?.currentProgress
        result(animationProgress)
      }
      
      if(call.method == "getAnimationSpeed") {
         let animationSpeed = self.animationView?.animationSpeed
         result(animationSpeed)
      }
      
      
      if(call.method == "setValue") {
         let value = props["value"] as! String;
         let keyPath = props["keyPath"] as! String;
         if let type = props["type"] as? String {
            setValue(type: type, value: value, keyPath: keyPath)
         }
      }
      
   }
   
   func setValue(type: String, value: String, keyPath: String) -> Void {
      switch type {
      case "ColorValue":
         let i = UInt32(value.dropFirst(2), radix: 16)
         let color = hexToColor(hex8: i!);
         self.delegates.append(CGColorValueProvider(color: color))
         self.animationView?.setValueProvider(self.delegates[self.delegates.count - 1], keypath: AnimationKeypath(keypath: keyPath + ".Color"))
         break;
      case "OpacityValue":
         if let n = NumberFormatter().number(from: value) {
            let f = CGFloat(truncating: n)
            self.delegates.append(FloatValueProvider(f))
            self.animationView?.setValueProvider(self.delegates[self.delegates.count - 1], keypath: AnimationKeypath(keypath: keyPath + ".Opacity"))
         }
         break;
      default:
         break;
      }
   }
    
    func parseLoopMode(value: String?) -> LottieLoopMode {
        switch value {
            case "playOnce":
                return LottieLoopMode.playOnce
            case "autoReverse":
                return LottieLoopMode.autoReverse
            case "loop":
                return LottieLoopMode.loop
            case "repeat":
                return LottieLoopMode.repeat(100000)
            case "repeatBackwards":
                return LottieLoopMode.repeatBackwards(100000)
            default:
                return LottieLoopMode.playOnce
        }
    }
   
}
