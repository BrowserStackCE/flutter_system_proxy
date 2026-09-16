import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_system_proxy/flutter_system_proxy.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_system_proxy');

  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group('getSystemProxy', () {
    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return '42';
      });
    });

    test('getSystemProxy', () async {});
  });

  group('findProxyFromEnvironment', () {
    test('returns PROXY string when host and port are valid', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return <String, dynamic>{'host': '127.0.0.1', 'port': '8080'};
      });

      final result =
          await FlutterSystemProxy.findProxyFromEnvironment('https://example.com/v1:drop');

      expect(result, 'PROXY 127.0.0.1:8080');
    });

    test('falls back to HttpClient.findProxyFromEnvironment when host is empty',
        () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return <String, dynamic>{'host': '', 'port': '8080'};
      });

      final result =
          await FlutterSystemProxy.findProxyFromEnvironment('https://example.com');

      expect(result,
          HttpClient.findProxyFromEnvironment(Uri.parse('https://example.com')));
    });

    test('falls back to HttpClient.findProxyFromEnvironment when host is null',
        () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return <String, dynamic>{'host': null, 'port': '8080'};
      });

      final result =
          await FlutterSystemProxy.findProxyFromEnvironment('https://example.com');

      expect(result,
          HttpClient.findProxyFromEnvironment(Uri.parse('https://example.com')));
    });

    test(
        'falls back to HttpClient.findProxyFromEnvironment when port is invalid',
        () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return <String, dynamic>{'host': '127.0.0.1', 'port': 'not-a-port'};
      });

      final result =
          await FlutterSystemProxy.findProxyFromEnvironment('https://example.com');

      expect(result,
          HttpClient.findProxyFromEnvironment(Uri.parse('https://example.com')));
    });

    test(
        'falls back to HttpClient.findProxyFromEnvironment when port is out of range',
        () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return <String, dynamic>{'host': '127.0.0.1', 'port': '70000'};
      });

      final result =
          await FlutterSystemProxy.findProxyFromEnvironment('https://example.com');

      expect(result,
          HttpClient.findProxyFromEnvironment(Uri.parse('https://example.com')));
    });

    test(
        'falls back to HttpClient.findProxyFromEnvironment when port is out of range',
        () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return <String, dynamic>{'host': '127.0.0.1', 'port': '70000'};
      });

      final result =
          await FlutterSystemProxy.findProxyFromEnvironment('https://example.com/v1:drop');

      expect(result,
          HttpClient.findProxyFromEnvironment(Uri.parse('https://example.com/v1:drop')));
    });
  });
}
