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

### Basic Usage (Example With Dio)

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

### Advanced Usage (Custom Dio Adapter)

```dart

// Create a custom adapter that can help resolve proxy based on urls 
// (This is important as in some senerio there are PAC files which might have different proxy based on different urls)
class MyAdapter extends HttpClientAdapter {
  final DefaultHttpClientAdapter _adapter = DefaultHttpClientAdapter();

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future? cancelFuture) async {
    var uri = options.uri;
    var proxy =
        await FlutterSystemProxy.findProxyFromEnvironment(uri.toString()); // This line does the magic
    _adapter.onHttpClientCreate = (HttpClient clinet) {
      clinet.findProxy = (uri) {
        return proxy;
      };
    };
    return _adapter.fetch(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {
    _adapter.close(force: force);
  }
}

// Use a wrapper around getting dio
void getDio(){
  var dio = Dio();
  dio.httpClientAdapter = MyAdapter();
  return dio;
}

```
