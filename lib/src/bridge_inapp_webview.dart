import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'bridge.dart';

class DsBridgeInAppWebView extends StatefulWidget {
  final BridgeCreatedCallback onDSBridgeCreated;

  DsBridgeInAppWebView({
    Key? key,
    required this.onDSBridgeCreated,
  }) : super(key: key);

  @override
  DsBridgeInAppWebViewState createState() => DsBridgeInAppWebViewState();
}

class DsBridgeInAppWebViewState extends State<DsBridgeInAppWebView> {
  DsBridgeInApp dsBridge = DsBridgeInApp();

  late InAppWebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      AndroidInAppWebViewController.setWebContentsDebuggingEnabled(
        DsBridge.isDebug,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      return InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse("about:blank")),
        onWebViewCreated: (InAppWebViewController controller) async {
          _controller = controller;
          _controller.setOptions(
            options: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  mediaPlaybackRequiresUserGesture: false,
                  javaScriptEnabled: true,
                  userAgent:
                      "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 DsBridge/1.0.0",
                ),
                ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true)),
          );
          controller.loadFile(
              assetFilePath:
                  "packages/whiteboard_sdk_flutter/assets/whiteboardBridge/index.html");
          await dsBridge.initController(controller);
        },
        onLoadError: _onLoadError,
        onLoadHttpError: _onLoadHttpError,
        onLoadStart: _onLoadStart,
        onLoadStop: _onLoadStop,
        onConsoleMessage: _onConsoleMessage,
      );
    });
  }

  void _onConsoleMessage(
    InAppWebViewController controller,
    ConsoleMessage consoleMessage,
  ) {
    debugPrint("[InAppWebView] consoleMessage ${consoleMessage.message}");
  }

  void _onLoadStart(InAppWebViewController controller, Uri? url) async {
    debugPrint('[InAppWebView] page started loading: $url');
    if (url?.path.endsWith("whiteboardBridge/index.html") ?? false) {}
  }

  void _onLoadStop(InAppWebViewController controller, Uri? url) async {
    debugPrint('[InAppWebView] page finished loading: $url');
    if (url?.path.endsWith("whiteboardBridge/index.html") ?? false) {
      await dsBridge.runCompatScript();
      widget.onDSBridgeCreated(dsBridge);
    }
  }

  void _onLoadHttpError(
    InAppWebViewController controller,
    Uri? url,
    int statusCode,
    String description,
  ) {
    debugPrint("[InAppWebView] $url load error "
        "code $statusCode, desc $description");
  }

  void _onLoadError(
    InAppWebViewController controller,
    Uri? url,
    int code,
    String message,
  ) {
    debugPrint("[InAppWebView] load error, message $message");
  }
}

class DsBridgeInApp extends DsBridge {
  static const _compatDsScript = """
      function isPromise(value) {
          return Boolean(value && typeof value.then === 'function');
      }
      if (window.flutter_inappwebview) {
          window._dsbridge = {}
          window._dsbridge.call = function (method, arg) {
              console.log(`call flutter inappwebview \${method} \${arg}`);
              var ret = window.flutter_inappwebview.callHandler("__dsbridge", JSON.stringify({ "method": method, "args": arg }));
              console.log(`native call return \${isPromise(ret)}`);
              return '{}';
          }
          console.log("wrapper flutter_inappwebview success");
      } else {
          console.log("window.flutter_inappwebview undefine");
      }
  """;

  late InAppWebViewController _controller;

  Future<void> initController(InAppWebViewController controller) async {
    _controller = controller;
    _controller.addJavaScriptHandler(
      handlerName: DsBridge.BRIDGE_NAME,
      callback: (args) {
        var res = jsonDecode(args[0]);
        javascriptInterface.call(res["method"], res["args"]);
      },
    );
  }

  Future<void> runCompatScript() async {
    await _controller.evaluateJavascript(source: _compatDsScript);
  }

  @override
  FutureOr<String?> evaluateJavascript(String javascript) {
    try {
      return _controller
          .evaluateJavascript(source: javascript)
          .then<String?>((value) => value);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
