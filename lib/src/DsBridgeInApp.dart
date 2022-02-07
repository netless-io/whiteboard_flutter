import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'DsBridge.dart';

class DsBridgeInApp extends DsBridge {
  static bool isDebug = false;

  late InAppWebViewController _controller;

  static const String BRIDGE_NAME = "__dsbridge";

  void initWithInAppWebViewController(InAppWebViewController controller) {
    this.addJavascriptInterface(InnerJavascriptInterface());
    _controller = controller;
    _controller.addJavaScriptHandler(
      handlerName: BRIDGE_NAME,
      callback: (args) {
        var res = jsonDecode(args[0]);
        javascriptInterface.call(res["method"], res["args"]);
      },
    );
  }

  DsBridgeInApp() {
    InnerJavascriptInterface.evaluateJavascript = evaluateJavascript;
    InnerJavascriptInterface.parseNamespace = parseNamespace;
    InnerJavascriptInterface.isDebug = isDebug;
  }

  @override
  FutureOr<String?> evaluateJavascript(String javascript) {
    try {
      if (_controller == null) {
        return null;
      }
      return _controller
          .evaluateJavascript(source: javascript)
          .then<String>((value) => value);
    } on MissingPluginException catch (e) {
      print(e);
      return null;
    } on Error catch (e) {
      print(e);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
