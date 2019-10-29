import UIKit
import Flutter
import Lottie

public class TestStreamHandler : FlutterStreamHandler {
   var event : FlutterEventSink?
   public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
      self.event = events
      return nil;
   }
   
   public func onCancel(withArguments arguments: Any?) -> FlutterError? {
      return nil;
   }
}

class CGColorValueProvider : AnyValueProvider {
    var valueType: Any.Type {
        return CGColor.self
    }
    
    public typealias CGColorValueBlock = (CGFloat) -> Color
    
    public var color: CGColor {
       didSet {
         hasUpdate = true
       }
     }
    
     init(color : CGColor) {
       self.color = color
     }
    
    func hasUpdate(frame: CGFloat) -> Bool {
        return hasUpdate
    }
    
    func value(frame: CGFloat) -> Any {
        hasUpdate = false
        return color
    }
    
    private var hasUpdate: Bool = true
}

func hexToColor(hex8: UInt32) -> CGColor {
   let divisor = CGFloat(255)
   let _     = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
   let red   = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
   let green    = CGFloat((hex8 & 0x0000FF00) >>  8) / divisor
   let blue   = CGFloat( hex8 & 0x000000FF       ) / divisor
   return UIColor.init(red: red, green: green, blue: blue, alpha: 255).cgColor
}

func intFromHexString(hexStr: String) -> UInt32 {
   var hexInt: UInt32 = 0
   // Create scanner
   let scanner: Scanner = Scanner(string: hexStr)
   // Tell scanner to skip the # character
   scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
   // Scan hex value
   scanner.scanHexInt32(&hexInt)
   return hexInt
}
