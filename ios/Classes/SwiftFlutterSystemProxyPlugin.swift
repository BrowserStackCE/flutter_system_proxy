import Flutter
import UIKit
import JavaScriptCore

public class SwiftFlutterSystemProxyPlugin: NSObject, FlutterPlugin {
  static var proxyCache : [String: [String: Any]] = [:]
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_system_proxy", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterSystemProxyPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getDeviceProxy":
        let args = call.arguments as! NSDictionary
        let url = args.value(forKey:"url") as! String
        var dict:[String:Any]? = [:]
        if(SwiftFlutterSystemProxyPlugin.proxyCache[url] != nil){
            let res = SwiftFlutterSystemProxyPlugin.proxyCache[url]
            if(res != nil){
                dict = res
            }
        } 
        else 
        {
            let res = SwiftFlutterSystemProxyPlugin.resolve(url: url)
            if(res != nil){
                dict = res
            }
        }
        result(dict)
        break
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  static func resolve(url:String)->[String:Any]?{
        if(SwiftFlutterSystemProxyPlugin.proxyCache[url] != nil){
            return SwiftFlutterSystemProxyPlugin.proxyCache[url]
        }
        let proxConfigDict = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() as NSDictionary?
        if(proxConfigDict != nil){
            if(proxConfigDict!["ProxyAutoConfigEnable"] as? Int == 1){
                let pacUrl = proxConfigDict!["ProxyAutoConfigURLString"] as? String
                let pacContent = proxConfigDict!["ProxyAutoConfigJavaScript"] as? String
                if(pacContent != nil){
                    self.handlePacContent(pacContent: pacContent! as String, url: url)
                }else if(pacUrl != nil){
                    self.handlePacUrl(pacUrl: pacUrl!,url: url)
                }
            } else if (proxConfigDict!["HTTPEnable"] as? Int == 1){
                var dict: [String: Any] = [:]
                dict["host"] = proxConfigDict!["HTTPProxy"] as? String
                dict["port"] = proxConfigDict!["HTTPPort"] as? Int
                SwiftFlutterSystemProxyPlugin.proxyCache[url] = dict
                
            } else if ( proxConfigDict!["HTTPSEnable"] as? Int == 1){
                var dict: [String: Any] = [:]
                dict["host"] = proxConfigDict!["HTTPSProxy"] as? String
                dict["port"] = proxConfigDict!["HTTPSPort"] as? Int
                SwiftFlutterSystemProxyPlugin.proxyCache[url] = dict
            }
        }
        return SwiftFlutterSystemProxyPlugin.proxyCache[url]
    }
    
    static func handlePacContent(pacContent: String,url: String){
        let proxies = CFNetworkCopyProxiesForAutoConfigurationScript(pacContent as CFString, CFURLCreateWithString(kCFAllocatorDefault, url as CFString, nil), nil)!.takeUnretainedValue() as? [[CFString: Any]] ?? [];
        if(proxies.count > 0){
            let proxy = proxies.first{$0[kCFProxyTypeKey] as! CFString == kCFProxyTypeHTTP || $0[kCFProxyTypeKey] as! CFString == kCFProxyTypeHTTPS}
            if(proxy != nil){
                let host = proxy?[kCFProxyHostNameKey] ?? nil
                let port = proxy?[kCFProxyPortNumberKey] ?? nil
                var dict:[String: Any] = [:]
                dict["host"] = host
                dict["port"] = port
                SwiftFlutterSystemProxyPlugin.proxyCache[url] = dict
            }
        }
    }

    static func handlePacUrl(pacUrl: String, url: String){
        let _pacUrl = CFURLCreateWithString(kCFAllocatorDefault,  pacUrl as CFString?,nil)
        let targetUrl = CFURLCreateWithString(kCFAllocatorDefault, url as CFString?, nil)
        var info = url;
        withUnsafeMutablePointer(to: &info, { infoPointer in
            var context:CFStreamClientContext = CFStreamClientContext.init(version: 0, info: infoPointer, retain: nil, release: nil, copyDescription: nil)
                let runLoopSource = CFNetworkExecuteProxyAutoConfigurationURL(_pacUrl!,targetUrl!,  { client, proxies, error in
                    let _proxies = proxies as? [[CFString: Any]] ?? [];
                        if(_proxies.count > 0){
                        let proxy = _proxies.first{$0[kCFProxyTypeKey] as! CFString == kCFProxyTypeHTTP || $0[kCFProxyTypeKey] as! CFString == kCFProxyTypeHTTPS}
                        if(proxy != nil){
                            let host = proxy?[kCFProxyHostNameKey] ?? nil
                            let port = proxy?[kCFProxyPortNumberKey] ?? nil
                            var dict:[String: Any] = [:]
                            dict["host"] = host
                            dict["port"] = port
                            let url = client.assumingMemoryBound(to: String.self).pointee
                            SwiftFlutterSystemProxyPlugin.proxyCache[url] = dict
                        }
                    }
                    CFRunLoopStop(CFRunLoopGetCurrent());
                }, &context);
                let runLoop = CFRunLoopGetCurrent();
                CFRunLoopAddSource(runLoop, getRunLoopSource(runLoopSource), CFRunLoopMode.defaultMode);
                CFRunLoopRun();
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.defaultMode);
        })
    }
    
    //For backward compatibility <= XCode 15
    static func getRunLoopSource<T>(_ runLoopSource: T) -> CFRunLoopSource {
        if let unmanagedValue = runLoopSource as? Unmanaged<CFRunLoopSource> {
            return unmanagedValue.takeUnretainedValue()
        } else {
            return runLoopSource as! CFRunLoopSource
        }
    }
    
}

