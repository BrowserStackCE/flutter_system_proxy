package com.browserstack.fluttersystemproxy.flutter_system_proxy;

import androidx.annotation.NonNull;
import android.text.TextUtils;

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
      Map map = new HashMap<String, String>();
      map.put("http.proxyHost", System.getProperty("http.proxyHost"));
      map.put("http.proxyPort", System.getProperty("http.proxyPort"));
      map.put("https.proxyHost", System.getProperty("https.proxyHost"));
      map.put("https.proxyPort", System.getProperty("https.proxyPort"));
      result.success(map);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
