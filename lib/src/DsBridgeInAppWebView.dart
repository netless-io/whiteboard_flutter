import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'DsBridge.dart';
import 'DsBridgeInApp.dart';

class DsBridgeInAppWebView extends StatefulWidget {
  final String url;
  final ValueChanged<DsBridge> onDSBridgeCreated;
  final void Function(InAppWebViewController controller) onWebViewCreated;

  DsBridgeInAppWebView({
    Key key,
    this.url,
    this.onDSBridgeCreated,
    this.onWebViewCreated,
  }) : super(key: key);

  @override
  DsBridgeInAppWebViewState createState() => DsBridgeInAppWebViewState();
}

class DsBridgeInAppWebViewState extends State<DsBridgeInAppWebView> {
  DsBridgeInApp dsBridge = DsBridgeInApp();
  InAppWebViewController _controller;
  InnerJavascriptInterface innerJavascriptInterface;

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

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      return InAppWebView(
        initialFile: widget.url,
        onWebViewCreated: (InAppWebViewController webViewController) async {
          _controller = webViewController;
          _controller.setOptions(options: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
                mediaPlaybackRequiresUserGesture: false,
                javaScriptEnabled: true,
                userAgent:
                    "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 DsBridge/1.0.0"),
            ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
            android: AndroidInAppWebViewOptions(useHybridComposition: true),
          ));
          widget.onWebViewCreated(_controller);
        },
        onLoadError: (InAppWebViewController controller, Uri url, int code, String message) {
          print(message);
        },
        onLoadHttpError:
            (InAppWebViewController controller, Uri url, int statusCode, String description) {},
        onLoadStart: (InAppWebViewController controller, Uri url) {
          print('Page started loading: $url');
        },
        onLoadStop: (InAppWebViewController controller, Uri url) async {
          if (url != "" && url != "about:blank") {
            dsBridge.initWithInAppWebViewController(_controller);
            await _controller.evaluateJavascript(source: _compatDsScript);
            widget.onDSBridgeCreated(dsBridge);
            print('Page finished loading: $url');
          }
        },
        onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
          print(consoleMessage.message);
        },
      );
    });
  }
}
