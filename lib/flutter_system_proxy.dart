import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class FlutterSystemProxy {
  static const MethodChannel _channel =
      const MethodChannel('flutter_system_proxy');
  
  /// returns host and port from environment
  static Future<dynamic> getEnvironmentProxy(String url) async {
    return _channel.invokeMethod("getDeviceProxy", <String, dynamic>{'url': url});
  }

  /// returns Proxy String
  static Future<String> findProxyFromEnvironment(String url) async {
    dynamic proxySettings = await getEnvironmentProxy(url);
    if (!isNullOrEmpty(proxySettings['host']) &&
        isPort(proxySettings['port'])) {
      return "PROXY " +
          (proxySettings['host'].toString()) +
          ":" +
          (proxySettings['port'].toString());
    } else {
      return HttpClient.findProxyFromEnvironment(Uri.parse(url));
    }
  }
}

bool isNullOrEmpty(String? str) {
  return str == null || str == "";
}

bool isPort(dynamic port) {
  if (port == null) return false;
  final number = num.tryParse(port.toString());
  if (number != null && number > 0 && number <= 65536) {
    return true;
  } else {
    return false;
  }
}
