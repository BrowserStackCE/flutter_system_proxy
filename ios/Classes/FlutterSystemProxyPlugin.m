#import "FlutterSystemProxyPlugin.h"
#if __has_include(<flutter_system_proxy/flutter_system_proxy-Swift.h>)
#import <flutter_system_proxy/flutter_system_proxy-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_system_proxy-Swift.h"
#endif

@implementation FlutterSystemProxyPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterSystemProxyPlugin registerWithRegistrar:registrar];
}
@end
