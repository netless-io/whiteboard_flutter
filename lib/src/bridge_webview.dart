import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'bridge.dart';

class DsBridgeWebView extends StatefulWidget {
  final BridgeCreatedCallback onDSBridgeCreated;

  DsBridgeWebView({
    Key? key,
    required this.onDSBridgeCreated,
  }) : super(key: key);

  @override
  DsBridgeWebViewState createState() => DsBridgeWebViewState();
}

class DsBridgeWebViewState extends State<DsBridgeWebView> {
  DsBridgeBasic dsBridge = DsBridgeBasic();

  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      return WebView(
        initialUrl: "about:blank",
        javascriptMode: JavascriptMode.unrestricted,
        allowsInlineMediaPlayback: true,
        javascriptChannels: {dsBridge.javascriptChannel},
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        userAgent:
            "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 DsBridge/1.0.0",
        onWebViewCreated: (WebViewController controller) async {
          _controller = controller;
          dsBridge.initController(_controller);
          await _controller.loadFlutterAsset(
              "packages/whiteboard_sdk_flutter/assets/whiteboardBridge/index.html");
        },
        navigationDelegate: (NavigationRequest request) {
          print('allowing navigation to $request');
          return NavigationDecision.navigate;
        },
        onWebResourceError: _onWebResourceError,
        onPageStarted: _onPageStarted,
        onPageFinished: _onPageFinished,
        gestureNavigationEnabled: true,
      );
    });
  }

  Future<void> _onPageStarted(String url) async {
    debugPrint('WebView Page started loading: $url');
    if (url.endsWith("whiteboardBridge/index.html")) {}
  }

  Future<void> _onPageFinished(String url) async {
    debugPrint('WebView Page finished loading: $url');
    if (url.endsWith("whiteboardBridge/index.html")) {
      await dsBridge.runCompatScript();
      widget.onDSBridgeCreated(dsBridge);
    }
  }

  void _onWebResourceError(WebResourceError error) {
    debugPrint('WebView resource error ${error.toString()}');
  }
}

class DsBridgeBasic extends DsBridge {
  static const _compatDsScript = """
      if (window.__dsbridge) {
          window._dsbridge = {}
          window._dsbridge.call = function (method, arg) {
              console.log(`call flutter webview \${method} \${arg}`);
              window.__dsbridge.postMessage(JSON.stringify({ "method": method, "args": arg }))
              return '{}';
          }
          console.log("wrapper flutter webview success");
      } else {
          console.log("window.__dsbridge undefine");
      }
  """;

  late WebViewController _controller;

  JavascriptChannel? _javascriptChannel;

  Future<void> initController(WebViewController controller) async {
    _controller = controller;
  }

  Future<void> runCompatScript() async {
    try {
      await _controller.runJavascript(_compatDsScript);
    } catch (e) {
      print("WebView bridge run compat script error $e");
    }
  }

  JavascriptChannel get javascriptChannel {
    _javascriptChannel ??= JavascriptChannel(
      name: DsBridge.BRIDGE_NAME,
      onMessageReceived: (JavascriptMessage message) {
        var res = jsonDecode(message.message);
        javascriptInterface.call(res["method"], res["args"]);
      },
    );
    return _javascriptChannel!;
  }

  @override
  FutureOr<String?> evaluateJavascript(String javascript) async {
    try {
      return await _controller.runJavascriptReturningResult(javascript);
    } catch (e) {
      print("WebView bridge evaluateJavascript cause $e");
      return null;
    }
  }
}
