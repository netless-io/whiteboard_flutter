import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'DsBridge.dart';

class DsBridgeWebView extends StatefulWidget {
  final String url;
  final ValueChanged<DsBridge> onDSBridgeCreated;
  final WebViewCreatedCallback onWebViewCreated;

  DsBridgeWebView({
    Key key,
    this.url,
    this.onDSBridgeCreated,
    this.onWebViewCreated,
  }) : super(key: key);

  @override
  DsBridgeWebViewState createState() => DsBridgeWebViewState();
}

class DsBridgeWebViewState extends State<DsBridgeWebView> {
  DsBridge dsBridge = DsBridge();
  WebViewController _controller;
  InnerJavascriptInterface innerJavascriptInterface;

  @override
  void initState() {
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      return WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        allowsInlineMediaPlayback: true,
        javascriptChannels: [dsBridge.javascriptChannel].toSet(),
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        userAgent:
            "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 DsBridge/1.0.0",
        onWebViewCreated: (WebViewController webViewController) async {
          _controller = webViewController;
          widget.onWebViewCreated(_controller);
        },
        navigationDelegate: (NavigationRequest request) {
          print('allowing navigation to $request');
          return NavigationDecision.navigate;
        },
        onWebResourceError: (WebResourceError error) {
          print(error);
        },
        onPageStarted: (String url) {
          print('Page started loading: $url');
        },
        onPageFinished: (String url) {
          if (url != "" && url != "about:blank") {
            dsBridge.initWithWebViewController(_controller);
            widget.onDSBridgeCreated(dsBridge);
            print('Page finished loading: $url');
          }
        },
        gestureNavigationEnabled: true,
      );
    });
  }
}
