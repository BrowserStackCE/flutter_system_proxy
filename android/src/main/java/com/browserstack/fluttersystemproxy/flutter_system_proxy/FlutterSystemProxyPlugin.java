package com.browserstack.fluttersystemproxy.flutter_system_proxy;

import androidx.annotation.NonNull;
import android.text.TextUtils;

import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.ProxySelector;
import java.net.URI;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterSystemProxyPlugin */
public class FlutterSystemProxyPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native
  /// Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine
  /// and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_system_proxy");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getDeviceProxy")) {
      HashMap<String, String> _map = new HashMap<String, String>() {
        {
          put("host", null);
          put("port", null);
        }
      };
      String url = call.argument("url");
      ProxySelector selector = ProxySelector.getDefault();
      try {
        for (Proxy proxy : selector.select(new URI(url))) {
          if (proxy.type() == Proxy.Type.HTTP) {
            InetSocketAddress addr = (InetSocketAddress) proxy.address();
            _map.put("host", addr.getHostName());
            _map.put("port", Integer.toString(addr.getPort()));
          }
        }
        result.success(_map);
      } catch (Exception ex) {
        result.error("URL Error",ex.getMessage(),null);
      }
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
