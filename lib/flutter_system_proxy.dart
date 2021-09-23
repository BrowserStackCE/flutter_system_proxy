import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class FlutterSystemProxy {
  static const MethodChannel _channel =
      const MethodChannel('flutter_system_proxy');

  static Future<Map<String, String>?> _getSystemProxy(String url) async {
    bool isHttps = Uri.parse(url).scheme == 'https';
    dynamic proxySettings = await _channel.invokeMethod("getDeviceProxy");
    if (Platform.isAndroid) {
      if (isHttps) {
        if (!isNullOrEmpty(proxySettings['https.proxyHost']) &&
            isPort(proxySettings['https.proxyPort'])) {
          return {
            "enabled": "true",
            "host": proxySettings['https.proxyHost'],
            "port": proxySettings['https.proxyPort']
          };
        }
      } else {
        if (!isNullOrEmpty(proxySettings['http.proxyHost']) &&
            isPort(proxySettings['http.proxyPort'])) {
          return {
            "enabled": "true",
            "host": proxySettings['http.proxyHost'],
            "port": proxySettings['http.proxyPort']
          };
        }
      }
      return null;
    } else if (Platform.isIOS) {
      if (proxySettings["ProxyAutoConfigEnable"] == 1) {
        return {"pacEnabled": "true"};
      } else {
        if (isHttps) {
          if (proxySettings['HTTPSEnable'] == 1) {
            return {
              "enabled": "true",
              "host": proxySettings['HTTPSProxy'].toString(),
              "port": proxySettings['HTTPSPort'].toString()
            };
          }
        } else {
          if (proxySettings['HTTPEnable'] == 1) {
            return {
              "enabled": "true",
              "host": proxySettings['HTTPProxy'].toString(),
              "port": proxySettings['HTTPPort'].toString()
            };
          }
        }
        return null;
      }
    }
  }

  static Future<String> findProxyFromEnvironment(String url) async {
    var parsedProxy = await _getSystemProxy(url);
    print(parsedProxy);
    var host = Uri.parse(url).host;
    if (parsedProxy != null && parsedProxy["enabled"] == "true") {
      return "PROXY " +
          (parsedProxy["host"] as String) +
          ":" +
          (parsedProxy["port"] as String);
    } else if (parsedProxy != null && parsedProxy["pacEnabled"] == "true") {
      String proxy =
          await _channel.invokeMethod("executePAC", {"url": url, "host": host});
      return proxy;
    } else {
      return HttpClient.findProxyFromEnvironment(Uri.parse(url));
    }
  }
}

bool isNullOrEmpty(String? str) {
  return str == null || str == "";
}

bool isPort(String? port) {
  if (port == null) return false;
  final number = num.tryParse(port);
  if (number != null && number > 0) {
    return true;
  } else {
    return false;
  }
}
