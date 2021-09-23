# Flutter System Proxy

A Flutter Plugin to detect System proxy. When using HTTP client that are not proxy aware this plugin can help with finding the proxy from system settings which then can be used with HTTP Client to make a successful request.

## Getting Started

### Installation

```yaml
dependencies:
  ...
  flutter_system_proxy:
    git: 
      url: https://github.com/Rushabhshroff/flutter_system_proxy.git
      ref: main

```

### Usage (Example With Dio)

```dart
import 'package:flutter_system_proxy/flutter_system_proxy.dart';


...


var dio = new Dio();
var url = "http://....";
var proxy = await FlutterSystemProxy.findProxyFromEnvironment(url);
(dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
   (HttpClient client) {
      client.findProxy = (uri) {
        return proxy;
   };
};
var response = await dio.get(url);
```
