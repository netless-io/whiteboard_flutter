import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef void OnReturnValue<T>([T returnValue]);

class JavaScriptNamespaceInterface {
  JavaScriptNamespaceInterface(this.namespace);

  String namespace = "";
  Map<String, Function> methods = Map<String, Function>();

  Function getMethod(String method) {
    return methods[method];
  }

  setMethod(String method, Function func) {
    methods[method] = func;
  }
}

class DsBridge {
  int callID = 0;
  Map<int, OnReturnValue> handlerMap = Map<int, OnReturnValue>();
  List<CallInfo> callInfoList;
  InnerJavascriptInterface javascriptInterface;

  static const String BRIDGE_NAME = "__dsbridge";
  static bool isDebug = false;

  List<String> parseNamespace(String method) {
    int pos = method.lastIndexOf('.');
    String namespace = "";
    if (pos != -1) {
      namespace = method.substring(0, pos);
      method = method.substring(pos + 1);
    }
    return [namespace, method];
  }

  addJavascriptInterface(InnerJavascriptInterface jsInterface) {
    javascriptInterface = jsInterface;
    var dsb = JavaScriptNamespaceInterface("_dsb");
    dsb.setMethod("returnValue", (Map<String, dynamic> jsonObject) {
      int id = jsonObject["id"];
      bool isCompleted = jsonObject["complete"];
      OnReturnValue handler = handlerMap[id];
      var data;
      if (jsonObject.containsKey("data")) {
        data = jsonObject["data"];
      }
      if (handler != null) {
        handler(data);
        if (isCompleted) {
          handlerMap.remove(id);
        }
      }
    });
    addJavascriptObject(dsb);
  }

  WebViewController _controller;
  JavascriptChannel _javascriptChannel;

  JavascriptChannel get javascriptChannel {
    if (_javascriptChannel != null) return _javascriptChannel;
    _javascriptChannel = JavascriptChannel(
        name: BRIDGE_NAME,
        onMessageReceived: (JavascriptMessage message) {
          var res = jsonDecode(message.message);
          if (javascriptInterface != null)
            javascriptInterface.call(res["method"], res["args"]);
        });
    return _javascriptChannel;
  }

  void initWithWebViewController(WebViewController controller) {
    this.addJavascriptInterface(InnerJavascriptInterface());
    _controller = controller;
  }

  DsBridge() {
    InnerJavascriptInterface.evaluateJavascript = evaluateJavascript;
    InnerJavascriptInterface.parseNamespace = parseNamespace;
    InnerJavascriptInterface.isDebug = isDebug;
  }

  FutureOr<String> evaluateJavascript(String javascript) {
    try {
      if (_controller == null) {
        return null;
      }
      return _controller.evaluateJavascript(javascript);
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

  FutureOr<String> dispatchJavascriptCall(CallInfo info) {
    return evaluateJavascript("window._handleMessageFromNative($info)");
  }

  FutureOr<String> callHandler(
      String method, List<dynamic> args, Function handler) {
    CallInfo callInfo = new CallInfo(method, ++callID, args);
    if (handler != null) {
      handlerMap[callInfo.callbackId] = handler;
    }
    if (callInfoList != null) {
      /// TODO: 开启线程处理，预留
      callInfoList.add(callInfo);
      return null;
    } else {
      return dispatchJavascriptCall(callInfo);
    }
  }

  void hasJavascriptMethod(
      String handlerName, OnReturnValue<bool> existCallback) {
    callHandler("_hasJavascriptMethod", [handlerName], existCallback);
  }

  void addJavascriptObject(JavaScriptNamespaceInterface interface) {
    if (interface.namespace == null) {
      interface.namespace = BRIDGE_NAME;
    }
    if (interface != null) {
      javascriptInterface?.javaScriptNamespaceInterfaces[interface.namespace] =
          interface;
    }
  }

  void removeJavascriptObject(String namespace) {
    if (namespace == null) {
      namespace = "";
    }
    javascriptInterface.javaScriptNamespaceInterfaces
        .removeWhere((key, value) => key == namespace);
  }
}

class CallInfo {
  final List<dynamic> data;
  final int callbackId;
  final String method;

  CallInfo(this.method, this.callbackId, this.data);

  @override
  String toString() {
    return jsonEncode({
      "method": method,
      "callbackId": callbackId,
      "data": jsonEncode(data),
    });
  }
}

typedef List<String> ParseNamespace(String method);
typedef void EvaluateJavascript(String javascript);

class InnerJavascriptInterface {
  static bool isDebug = false;
  static EvaluateJavascript evaluateJavascript;
  static ParseNamespace parseNamespace;

  Map<String, JavaScriptNamespaceInterface> javaScriptNamespaceInterfaces =
      <String, JavaScriptNamespaceInterface>{};

  void _printDebugInfo(String error) {
    if (isDebug) {
      var msg = "DEBUG ERR MSG:\\n" + error.replaceAll("\\'", "\\\\'");
      evaluateJavascript("alert('$msg')");
    }
  }

  FutureOr<String> call(String methodName, String argStr) async {
    String error = "Js bridge  called, but can't find a corresponded " +
        "JavascriptInterface object , please check your code!";
    List<String> nameStr = parseNamespace(methodName.trim());
    methodName = nameStr[1];
    var jsb = javaScriptNamespaceInterfaces[nameStr[0]];
    var ret = Map<String, dynamic>();
    ret["code"] = -1;
    if (jsb == null) {
      _printDebugInfo(error);
      return ret.toString();
    }
    var arg;
    var method = jsb.getMethod(methodName);
    String callback;
    try {
      var args = jsonDecode(argStr);
      if (args["_dscbstub"] != null) {
        callback = args["_dscbstub"] as String;
      }
      if (args["data"] != null) {
        arg = args["data"];
      }
    } catch (e) {
      error = "The argument of \"$methodName\" must be a JSON object string!";
      _printDebugInfo(error);
      return ret.toString();
    }

    if (method is! Function) {
      error = "Not find method \"" +
          methodName +
          "\" implementation! please check if the  signature or namespace of the method is right ";
      _printDebugInfo(error);
      return ret.toString();
    }

    try {
      if (method is Function) {
        var retData = method(arg);
        if (retData is Future) {
          try {
            var cb = callback;
            var retValue = await retData;
            Map<String, dynamic> ret = Map<String, dynamic>();
            ret["code"] = 0;
            ret["data"] = retValue;
            if (cb != null) {
              String script = "$cb(${jsonEncode(ret)}.data);";
              script += "delete window." + cb;
              evaluateJavascript(script);
            }
          } catch (e) {
            print(e);
          }
        } else {
          var cb = callback;
          ret["code"] = 0;
          ret["data"] = retData;
          if (cb != null) {
            String script = "$cb(${jsonEncode(ret)}.data);";
            script += "delete window." + cb;
            evaluateJavascript(script);
          }
          return jsonEncode(ret);
        }
      }
    } catch (e) {
      print(e);
    }
    return jsonEncode(ret);
  }
}
