import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'bridge.dart';

class DsBridgeInAppWebView extends StatefulWidget {
  final String url;
  final BridgeCreatedCallback onDSBridgeCreated;
  final void Function(InAppWebViewController controller)? onWebViewCreated;

  DsBridgeInAppWebView({
    Key? key,
    required this.url,
    required this.onDSBridgeCreated,
    this.onWebViewCreated,
  }) : super(key: key);

  @override
  DsBridgeInAppWebViewState createState() => DsBridgeInAppWebViewState();
}

class DsBridgeInAppWebViewState extends State<DsBridgeInAppWebView> {
  late DsBridgeInApp dsBridge;
  late InAppWebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      return InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
        onWebViewCreated: (InAppWebViewController controller) async {
          _controller = controller;
          _controller.setOptions(
            options: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  mediaPlaybackRequiresUserGesture: false,
                  javaScriptEnabled: true,
                  userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 DsBridge/1.0.0",
                ),
                ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true)),
          );
          controller.loadFile(assetFilePath: "packages/whiteboard_sdk_flutter/assets/whiteboardBridge/index.html");
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
    print(consoleMessage.message);
  }

  void _onLoadStart(InAppWebViewController controller, Uri? url) async {
    print('Page started loading: $url');
    if (url?.path.endsWith("whiteboardBridge/index.html") ?? false) {
      dsBridge = new DsBridgeInApp(_controller);
    }
  }

  void _onLoadStop(InAppWebViewController controller, Uri? url) async {
    print('Page finished loading: $url');
    if (url?.path.endsWith("whiteboardBridge/index.html") ?? false) {
      widget.onDSBridgeCreated(dsBridge);
    }
  }

  void _onLoadHttpError(
    InAppWebViewController controller,
    Uri? url,
    int statusCode,
    String description,
  ) {}

  void _onLoadError(
    InAppWebViewController controller,
    Uri? url,
    int code,
    String message,
  ) {
    print(message);
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
      }
  """;

  late InAppWebViewController _controller;

  DsBridgeInApp(this._controller) : super() {
    _controller.addJavaScriptHandler(
      handlerName: DsBridge.BRIDGE_NAME,
      callback: (args) {
        var res = jsonDecode(args[0]);
        javascriptInterface.call(res["method"], res["args"]);
      },
    );
    _controller.evaluateJavascript(source: _compatDsScript);
  }

  @override
  FutureOr<String?> evaluateJavascript(String javascript) {
    try {
      return _controller
          .evaluateJavascript(source: javascript)
          .then<String?>((value) => value);
    } on Error catch (e) {
      print(e);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
