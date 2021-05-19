import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'DsBridge.dart';
import 'DsBridgeInApp.dart';

class DsBridgeInAppWebView extends StatefulWidget {
  final String url;
  final ValueChanged<DsBridge> onDSBridgeCreated;
  final void Function(InAppWebViewController controller) onWebViewCreated;

  DsBridgeInAppWebView(
      {Key key, this.url, this.onDSBridgeCreated, this.onWebViewCreated})
      : super(key: key);

  @override
  DsBridgeInAppWebViewState createState() => DsBridgeInAppWebViewState();
}

class DsBridgeInAppWebViewState extends State<DsBridgeInAppWebView> {
  DsBridgeInApp dsBridge = DsBridgeInApp();
  InAppWebViewController _controller;
  InnerJavascriptInterface innerJavascriptInterface;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      return InAppWebView(
        initialUrl: widget.url,
        onWebViewCreated: (InAppWebViewController webViewController) async {
          _controller = webViewController;
          _controller.setOptions(
              options: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                      mediaPlaybackRequiresUserGesture: false,
                      javaScriptEnabled: true,
                      userAgent:
                          "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 DsBridge/1.0.0"),
                  ios:
                      IOSInAppWebViewOptions(allowsInlineMediaPlayback: true)));
          widget.onWebViewCreated(_controller);
        },
        onLoadError: (InAppWebViewController controller, String url, int code,
            String message) {
          print(message);
        },
        onLoadHttpError: (InAppWebViewController controller, String url,
            int statusCode, String description) {},
        onLoadStart: (InAppWebViewController controller, String url) {
          print('Page started loading: $url');
        },
        onLoadStop: (InAppWebViewController controller, String url) {
          if (url != "" && url != "about:blank") {
            dsBridge.initWithInAppWebViewController(_controller);
            widget.onDSBridgeCreated(dsBridge);
            print('Page finished loading: $url');
          }
        },
        onConsoleMessage:
            (InAppWebViewController controller, ConsoleMessage consoleMessage) {
          print(consoleMessage.message);
        },
      );
    });
  }
}
