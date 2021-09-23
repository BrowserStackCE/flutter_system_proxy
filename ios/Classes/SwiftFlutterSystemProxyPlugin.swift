import Flutter
import UIKit
import JavaScriptCore
public class SwiftFlutterSystemProxyPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_system_proxy", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterSystemProxyPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getDeviceProxy":
      let systemProxySettings = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() ?? [:] as CFDictionary
      result(systemProxySettings as NSDictionary)
      break
    case "executePAC":
      let systemProxySettings = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() ?? [:] as CFDictionary
      let proxyDict = systemProxySettings as NSDictionary
      if(proxyDict.value(forKey:"ProxyAutoConfigEnable")as! Bool){
        let args = call.arguments as! NSDictionary
        let url = args.value(forKey:"url") as! String
        let host = args.value(forKey:"host") as! String
        let PacUrl = proxyDict.value(forKey:"ProxyAutoConfigURLString") as! String
        if let uri = URL(string: PacUrl) {
        do {
          let contents = try String(contentsOf: uri)
          let jsEngine:JSContext = JSContext()
          jsEngine.evaluateScript(contents)
          let fn = "FindProxyForURL(\"" + url + "\",\""+host+"\")"
          let proxy = jsEngine.evaluateScript(fn)
          result(proxy?.toString())
        } catch {
          result("DIRECT")
        }
        } else {
          result("DIRECT")
        }
      }else{
        result("DIRECT")
      }
      break
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
