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
      let args = call.arguments as! NSDictionary
      let url = args.value(forKey:"url") as! String
      var dict:[String:Any] = [:]
      findProxyFromEnvironment(url: url,callback: { host, port in 
        dict["host"] = host 
        dict["port"] = port
        result(dict)
      })
      break
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func findProxyFromEnvironment(url: String,callback: @escaping (_ host:String?,_ port:Int?)->Void) {
        let proxConfigDict = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() as NSDictionary?
        if(proxConfigDict != nil){
            if(proxConfigDict!["ProxyAutoConfigEnable"] as? Int == 1){
                let pacUrl = proxConfigDict!["ProxyAutoConfigURLString"] as? String
                let pacContent = proxConfigDict!["ProxyAutoConfigJavaScript"] as? String
                if(pacContent != nil){
                    self.handlePacContent(pacContent: pacContent! as String, url: url, callback: callback)
                }
                downloadPac(pacUrl: pacUrl!, callback: { pacContent,error in
                    
                    if(error != nil || pacContent == nil){
                        callback(nil,nil)
                    }else{
                        self.handlePacContent(pacContent: pacContent!, url: url, callback: callback)
                    }
                })
            } else if (proxConfigDict!["HTTPEnable"] as? Int == 1){
                callback((proxConfigDict!["HTTPProxy"] as? String),(proxConfigDict!["HTTPPort"] as? Int))
            } else if ( proxConfigDict!["HTTPSEnable"] as? Int == 1){
                callback((proxConfigDict!["HTTPSProxy"] as? String),(proxConfigDict!["HTTPSPort"] as? Int))
            } else {
                callback(nil,nil)
            }
        }
    }
    
    func handlePacContent(pacContent: String,url: String, callback:(_ host:String?,_ port:Int?)->Void){
        let proxies = CFNetworkCopyProxiesForAutoConfigurationScript(pacContent as CFString, CFURLCreateWithString(kCFAllocatorDefault, url as CFString, nil), nil)?.takeUnretainedValue() as? [[CFString: Any]] ?? [];
        if(proxies.count > 0){
            let proxy = proxies.first{$0[kCFProxyTypeKey] as! CFString == kCFProxyTypeHTTP || $0[kCFProxyTypeKey] as! CFString == kCFProxyTypeHTTPS}
            if(proxy != nil){
                let host = proxy?[kCFProxyHostNameKey] ?? nil
                let port = proxy?[kCFProxyPortNumberKey] ?? nil
                callback(host as? String,port as? Int)
            }else{
               callback(nil,nil)
            }
        }else{
            callback(nil,nil)
        }
    }
    
    
    func downloadPac(pacUrl:String, callback:@escaping (_ pacContent:String?,_ error: Error?)->Void) {
        var pacContent:String = ""
        let config = URLSessionConfiguration.default
        config.connectionProxyDictionary = [AnyHashable: Any]()
        let session = URLSession.init(configuration: config,delegate: nil,delegateQueue: OperationQueue.current)
        session.dataTask(with: URL(string: pacUrl)!, completionHandler: { data, response, error in
            if(error != nil || data == nil){
                callback(nil,error)
                return;
            }
            pacContent = String(bytes: data!,encoding: String.Encoding.utf8)!
            callback(pacContent,nil)
        }).resume()

    }

}
