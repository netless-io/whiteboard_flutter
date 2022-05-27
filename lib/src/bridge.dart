// ignore_for_file: prefer_typing_uninitialized_variables, strict_raw_type, inference_failure_on_uninitialized_variable, inference_failure_on_untyped_parameter

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

typedef BridgeCreatedCallback = void Function(DsBridge value);
typedef OnReturnValue<T> = void Function([T returnValue]);

class JavaScriptNamespaceInterface {
  String namespace;
  Map<String, Function> methods = {};

  JavaScriptNamespaceInterface([this.namespace = ""]);

  Function? getMethod(String method) {
    return methods[method];
  }

  void setMethod(String method, Function func) {
    methods[method] = func;
  }
}

abstract class DsBridge {
  // ignore: constant_identifier_names
  static const String BRIDGE_NAME = "__dsbridge";
  static bool isDebug = true;

  int callID = 0;
  Map<int, OnReturnValue<dynamic>> handlerMap = <int, OnReturnValue<dynamic>>{};

  // TODO: 迁移遗留，暂保留未使用
  List<CallInfo>? callInfoList;
  late InnerJavascriptInterface javascriptInterface;

  DsBridge() {
    javascriptInterface = InnerJavascriptInterface(this);
    var dsb = JavaScriptNamespaceInterface("_dsb")
      ..setMethod("returnValue", (Map<String, dynamic> jsonObject) {
        debugPrint("_dsb.returnValue called ${jsonEncode(jsonObject)}");

        int id = jsonObject["id"];
        bool isCompleted = jsonObject["complete"];
        OnReturnValue<dynamic>? handler = handlerMap[id];
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
      })
      ..setMethod("dsinit", (args) {
        // TODO 无法保证不修改WhiteboardBridge的情况下完全兼容 DsBridge，兼容 的Js 无法在合适的位置注入
        debugPrint("_dsb.dsinit called ${jsonEncode(args)}");
      });
    addJavascriptObject(dsb);
  }

  FutureOr<String?> evaluateJavascript(String javascript);

  FutureOr<String?> dispatchJavascriptCall(CallInfo info) {
    return evaluateJavascript("window._handleMessageFromNative($info)");
  }

  FutureOr<String?> callHandler(String method,
      [List<dynamic> args = const [], OnReturnValue? handler]) {
    CallInfo callInfo = CallInfo(++callID, method, args);
    if (handler != null) {
      handlerMap[callInfo.callbackId] = handler;
    }
    if (callInfoList != null) {
      callInfoList!.add(callInfo);
      return null;
    } else {
      return dispatchJavascriptCall(callInfo);
    }
  }

  void hasJavascriptMethod(String handlerName, OnReturnValue existCallback) {
    callHandler("_hasJavascriptMethod", [handlerName], existCallback);
  }

  void addJavascriptObject(JavaScriptNamespaceInterface interface) {
    javascriptInterface.addNamespaceInterface(interface);
  }

  void removeJavascriptObject(String namespace) {
    javascriptInterface.removeNamespaceInterface(namespace);
  }
}

class CallInfo {
  final List<dynamic> data;
  final int callbackId;
  final String method;

  CallInfo(this.callbackId, this.method, this.data);

  @override
  String toString() {
    return jsonEncode({
      "method": method,
      "callbackId": callbackId,
      "data": jsonEncode(data),
    });
  }
}

class InnerJavascriptInterface {
  InnerJavascriptInterface(this.dsBridge);

  DsBridge dsBridge;

  @visibleForTesting
  var javaScriptNamespaceInterfaces = <String, JavaScriptNamespaceInterface>{};

  void addNamespaceInterface(JavaScriptNamespaceInterface interface) {
    if (interface.namespace == "") {
      interface.namespace = DsBridge.BRIDGE_NAME;
    }
    javaScriptNamespaceInterfaces[interface.namespace] = interface;
  }

  void removeNamespaceInterface(String namespace) {
    assert(javaScriptNamespaceInterfaces.containsKey(namespace));
    javaScriptNamespaceInterfaces.remove(namespace);
  }

  FutureOr<String> call(String methodName, String argStr) async {
    void _printDebugInfo(String error) {
      if (DsBridge.isDebug) {
        var msg = 'DEBUG ERR MSG:\\n ${error.replaceAll("\\'", "\\\\'")}';
        dsBridge.evaluateJavascript("alert('$msg')");
      }
    }

    debugPrint("[InnerJavascriptInterface] call: method $methodName, "
        "args $argStr");
    String error = "Js bridge  called, but can't find a corresponded "
        "JavascriptInterface object , please check your code!";
    List<String> nameStr = parseNamespace(methodName.trim());
    methodName = nameStr[1];
    var jsb = javaScriptNamespaceInterfaces[nameStr[0]];
    var ret = <String, dynamic>{};
    ret["code"] = -1;
    if (jsb == null) {
      _printDebugInfo(error);
      return ret.toString();
    }
    dynamic arg;
    var method = jsb.getMethod(methodName);
    late String callback;
    try {
      var args = jsonDecode(argStr);
      if (args["_dscbstub"] != null) {
        callback = args["_dscbstub"] as String;
      }
      if (args["data"] != null) {
        arg = args["data"];
      }
    } catch (e) {
      error = 'The argument of "$methodName" must be a JSON object string!';
      _printDebugInfo(error);
      return ret.toString();
    }

    if (method is! Function) {
      error = "Not find method $methodName implementation! "
          "please check if the signature or namespace of the method is right ";
      _printDebugInfo(error);
      return ret.toString();
    }

    try {
      var retData = method(arg);
      if (retData is Future) {
        try {
          var cb = callback;
          var retValue = await retData;
          Map<String, dynamic> ret = <String, dynamic>{};
          ret["code"] = 0;
          ret["data"] = retValue;
          String script = "$cb(${jsonEncode(ret)}.data);";
          script += "delete window." + cb;
          dsBridge.evaluateJavascript(script);
        } catch (e) {
          print(e);
        }
      } else {
        ret["code"] = 0;
        ret["data"] = retData;
        return jsonEncode(ret);
      }
    } catch (e) {
      print(e);
    }
    return jsonEncode(ret);
  }

  List<String> parseNamespace(String method) {
    int pos = method.lastIndexOf('.');
    String namespace = "";
    if (pos != -1) {
      namespace = method.substring(0, pos);
      method = method.substring(pos + 1);
    }
    return [namespace, method];
  }
}
